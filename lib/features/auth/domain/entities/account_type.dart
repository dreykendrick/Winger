/// Represents distinct account capability types in Winger.
enum AccountType {
  customer('CUSTOMER'),
  vendor('VENDOR'),
  affiliate('AFFILIATE'),
  admin('ADMIN');

  final String key;
  const AccountType(this.key);

  static AccountType fromKey(String key) {
    return AccountType.values.firstWhere(
      (e) => e.key.toUpperCase() == key.toUpperCase(),
      orElse: () => AccountType.customer,
    );
  }
}
