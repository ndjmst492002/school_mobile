class ProfileNotFoundException implements Exception {
  final String message;
  ProfileNotFoundException(this.message);

  @override
  String toString() => message;
}
