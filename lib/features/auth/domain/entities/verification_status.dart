/// Represents backend identity verification status.
enum VerificationStatus {
  unverified('UNVERIFIED'),
  pending('PENDING'),
  verified('VERIFIED'),
  rejected('REJECTED'),
  suspended('SUSPENDED');

  final String key;
  const VerificationStatus(this.key);

  static VerificationStatus fromKey(String key) {
    return VerificationStatus.values.firstWhere(
      (e) => e.key.toUpperCase() == key.toUpperCase(),
      orElse: () => VerificationStatus.unverified,
    );
  }
}
