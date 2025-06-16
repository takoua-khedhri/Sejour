class SejourInfoException implements Exception {
  final String message;
  SejourInfoException(this.message);
}

class SejourNotFoundException extends SejourInfoException {
  SejourNotFoundException(super.message);
}

class SejourNetworkException extends SejourInfoException {
  SejourNetworkException(super.message);
}