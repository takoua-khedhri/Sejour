import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:parent_5sur5/features/home/domain/entities/publication.dart';
import 'package:flutter/foundation.dart';
import 'package:parent_5sur5/features/home/domain/entities/sejour.dart';
import 'package:parent_5sur5/features/home/domain/usecases/get_day_description_usecase.dart';
import 'package:parent_5sur5/features/home/domain/usecases/get_publications_usecase.dart';
import 'package:parent_5sur5/features/home/domain/usecases/get_sejour_usecase.dart';
import 'package:parent_5sur5/features/home/presentation/blocs/home_event.dart';
import 'package:parent_5sur5/features/home/presentation/blocs/home_state.dart';
import 'package:parent_5sur5/features/favorites/domain/repositories/favorites_repository.dart';
import 'dart:async';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final GetSejourUseCase getSejour;
  final GetDayDescriptionUseCase getDayDescription;
  final GetPublicationsUseCase getPublications;
  final FavoritesRepository favoritesRepository;
  final String token;

  HomeBloc({
    required this.getSejour,
    required this.getDayDescription,
    required this.getPublications,
    required this.favoritesRepository,
    required this.token,
  }) : super(HomeInitial()) {
    on<LoadHomeEvent>(_onLoadHome);
    on<TogglePublicationLikeEvent>(_onTogglePublicationLike);
  }

  Future<void> _onLoadHome(LoadHomeEvent event, Emitter<HomeState> emit) async {
    if (event.codeSejour.isEmpty) {
      emit(HomeError(message: "Code séjour manquant"));
      return;
    }

    emit(HomeLoading());

    try {
      // 1. Chargement des données de base
      final sejour = await getSejour(event.codeSejour, token);
      final dateToUse = _determineDateToUse(event.date, sejour);

      final (description, publications) = await (
        getDayDescription(event.codeSejour, dateToUse, token),
        getPublications(event.codeSejour, event.type, dateToUse, token),
      ).wait;

      emit(HomeLoaded(
        sejour: sejour,
        description: description,
        publications: publications,
        matchingActive: false, // Désactivé car on a supprimé la partie IA
      ));

    } catch (e) {
      emit(HomeError(message: _getErrorMessage(e)));
    }
  }

  String _determineDateToUse(String? requestedDate, Sejour sejour) {
    if (requestedDate != null && requestedDate.isNotEmpty) {
      final date = DateTime.parse(requestedDate);
      final startDate = DateTime.parse(sejour.dateDebut!.split('T')[0]);
      final endDate = DateTime.parse(sejour.dateFin!.split('T')[0]);
      
      if (date.isBefore(startDate) || date.isAfter(endDate)) {
        return sejour.dateDebut!.split('T')[0];
      }
      return requestedDate;
    }
    return sejour.dateDebut!.split('T')[0];
  }

  String _getErrorMessage(dynamic e) {
    return e is TimeoutException
        ? "Traitement trop long - Réessayez"
        : "Erreur de chargement";
  }

  Future<void> _onTogglePublicationLike(
    TogglePublicationLikeEvent event,
    Emitter<HomeState> emit,
  ) async {
    if (state is! HomeLoaded) return;

    final currentState = state as HomeLoaded;
    try {
      // Mise à jour optimiste de l'UI
      final updatedPublications = currentState.publications.map((pub) {
        return pub.id == event.publicationId 
            ? pub.copyWith(isLiked: event.isLiked)
            : pub;
      }).toList();

      emit(currentState.copyWith(publications: updatedPublications));
      
      await favoritesRepository.toggleLike(
        event.publicationId,
        event.isLiked,
        event.token,
      );
    } catch (e, stackTrace) {
      debugPrint('Erreur like: $e\n$stackTrace');
      emit(currentState);
      emit(HomeError(message: "Échec de la mise à jour"));
      await Future.delayed(const Duration(seconds: 2));
      emit(currentState);
    }
  }
}