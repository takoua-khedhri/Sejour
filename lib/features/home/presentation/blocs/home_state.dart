import 'package:flutter/foundation.dart'; // Import nécessaire pour listEquals
import '../../domain/entities/sejour.dart';
import '../../domain/entities/day_description.dart';
import '../../domain/entities/publication.dart';

abstract class HomeState {}

class HomeInitial extends HomeState {}

class HomeLoading extends HomeState {}

class HomeLoaded extends HomeState {
  final Sejour sejour;
  final DayDescription description;
  final List<Publication> publications;
  final bool matchingActive;

  HomeLoaded({
    required this.sejour,
    required this.description,
    required this.publications,
    this.matchingActive = false,
  });

  HomeLoaded copyWith({
    Sejour? sejour,
    DayDescription? description,
    List<Publication>? publications,
    bool? matchingActive,
  }) {
    return HomeLoaded(
      sejour: sejour ?? this.sejour,
      description: description ?? this.description,
      publications: publications ?? this.publications,
      matchingActive: matchingActive ?? this.matchingActive,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    
    return other is HomeLoaded &&
        other.sejour == sejour &&
        other.description == description &&
        listEquals(other.publications, publications) && // Correction ici
        other.matchingActive == matchingActive;
  }

  @override
  int get hashCode {
    return sejour.hashCode ^
        description.hashCode ^
        Object.hashAll(publications) ^ // Meilleure pratique pour les listes
        matchingActive.hashCode;
  }
}

class HomeError extends HomeState {
  final String message;

  HomeError({required this.message});
}

class PublicationLikeUpdated extends HomeState {
  final String publicationId;
  final bool isLiked;

  PublicationLikeUpdated({
    required this.publicationId,
    required this.isLiked,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
  
    return other is PublicationLikeUpdated &&
        other.publicationId == publicationId &&
        other.isLiked == isLiked;
  }

  @override
  int get hashCode => publicationId.hashCode ^ isLiked.hashCode;
}