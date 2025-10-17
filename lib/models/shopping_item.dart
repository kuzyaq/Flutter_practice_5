class ShoppingItem {
  final String id;
  String name;
  String category;
  bool isCompleted;
  int quantity;
  DateTime createdAt;
  DateTime? completedAt;

  ShoppingItem({
    required this.id,
    required this.name,
    required this.category,
    this.isCompleted = false,
    this.quantity = 1,
    required this.createdAt,
    this.completedAt,
  });

  ShoppingItem copyWith({
    String? id,
    String? name,
    String? category,
    bool? isCompleted,
    int? quantity,
    DateTime? createdAt,
    DateTime? completedAt,
  }) {
    return ShoppingItem(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      isCompleted: isCompleted ?? this.isCompleted,
      quantity: quantity ?? this.quantity,
      createdAt: createdAt ?? this.createdAt,
      completedAt: completedAt ?? this.completedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'category': category,
      'isCompleted': isCompleted,
      'quantity': quantity,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'completedAt': completedAt?.millisecondsSinceEpoch,
    };
  }

  factory ShoppingItem.fromJson(Map<String, dynamic> json) {
    return ShoppingItem(
      id: json['id'],
      name: json['name'],
      category: json['category'],
      isCompleted: json['isCompleted'],
      quantity: json['quantity'],
      createdAt: DateTime.fromMillisecondsSinceEpoch(json['createdAt']),
      completedAt: json['completedAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(json['completedAt'])
          : null,
    );
  }
}