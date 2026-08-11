/// Enum representing backend-authoritative Order Guardian Escrow Protection Status.
enum GuardianStatus {
  protected('PROTECTED', 'Escrow Protected'),
  deliveryConfirmed('DELIVERY_CONFIRMED', 'Delivery Verified'),
  protectionWindowActive('WINDOW_ACTIVE', 'Protection Window Active'),
  releaseRequested('RELEASE_REQUESTED', 'Release Requested'),
  released('RELEASED', 'Funds Released'),
  disputed('DISPUTED', 'Under Dispute'),
  onHold('ON_HOLD', 'Escrow On Hold'),
  completed('COMPLETED', 'Protection Completed');

  final String code;
  final String label;

  const GuardianStatus(this.code, this.label);

  factory GuardianStatus.fromCode(String? code) {
    return GuardianStatus.values.firstWhere(
      (e) => e.code == code?.toUpperCase(),
      orElse: () => GuardianStatus.protected,
    );
  }
}
