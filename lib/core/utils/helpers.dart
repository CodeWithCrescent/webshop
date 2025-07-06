
  /// Safely returns String if [value] is String, otherwise ''
  String parseString(Object? value) {
    return value is String ? value : '';
  }