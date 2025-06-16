part of 'sejour_info_bloc.dart';

sealed class SejourInfoState {
  const SejourInfoState();
}

class SejourInfoInitial extends SejourInfoState {
  final Sejour? sejour;

  const SejourInfoInitial({this.sejour});
}

class SejourInfoLoading extends SejourInfoState {
  const SejourInfoLoading();
}

class SejourInfoLoaded extends SejourInfoState {
  final Sejour sejour;

  const SejourInfoLoaded({required this.sejour});
}

class SejourInfoError extends SejourInfoState {
  final String message;
  final Sejour? cachedSejour;

  const SejourInfoError({
    required this.message,
    this.cachedSejour,
  });
}