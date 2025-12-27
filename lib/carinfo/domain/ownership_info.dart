class OwnershipInfo {
  final DateTime purchaseDate;
  final int purchasePrice;
  final String ownershipType;
  final bool isFinanced;

  const OwnershipInfo({
    required this.purchaseDate,
    required this.purchasePrice,
    required this.ownershipType,
    required this.isFinanced,
  });
}
