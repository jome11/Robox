class InventoryItem {
  final String name;
  final int quantity;
  final double price;

  InventoryItem({
    required this.name,
    required this.quantity,
    required this.price,
  });

  double get totalValue => quantity * price;
}
