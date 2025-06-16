part of 'sejour_info_bloc.dart';

abstract class SejourInfoEvent {}

class LoadSejourInfo extends SejourInfoEvent {
  final String codeSejour;
  final String token;
  final Sejour? initialSejour;

  LoadSejourInfo({
    required this.codeSejour, 
    required this.token,
    this.initialSejour,
  });
}