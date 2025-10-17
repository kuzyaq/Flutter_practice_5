import 'package:flutter/material.dart';
import '../models/shopping_item.dart';

class ShoppingStats extends StatelessWidget {
  final List<ShoppingItem> items;

  const ShoppingStats({Key? key, required this.items}) : super(key: key);

  Map<String, int> _getCategoryCounts() {
    final counts = <String, int>{};
    for (final item in items.where((item) => !item.isCompleted)) {
      counts[item.category] = (counts[item.category] ?? 0) + item.quantity;
    }
    return counts;
  }

  @override
  Widget build(BuildContext context) {
    final totalItems = items.length;
    final completedItems = items.where((item) => item.isCompleted).length;
    final categoryCounts = _getCategoryCounts();
    final totalQuantity = items.fold(0, (sum, item) => sum + item.quantity);

    return Card(
      margin: EdgeInsets.all(16),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _StatItem(
                  value: totalItems.toString(),
                  label: 'Всего товаров',
                  color: Colors.blue,
                ),
                _StatItem(
                  value: completedItems.toString(),
                  label: 'Куплено',
                  color: Colors.green,
                ),
                _StatItem(
                  value: totalQuantity.toString(),
                  label: 'Общее кол-во',
                  color: Colors.orange,
                ),
              ],
            ),
            if (categoryCounts.isNotEmpty) ...[
              Divider(),
              Text('По категориям:', style: TextStyle(fontWeight: FontWeight.bold)),
              SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 4,
                children: categoryCounts.entries.map((entry) => Chip(
                  label: Text('${entry.key}: ${entry.value}'),
                  backgroundColor: Colors.grey[200],
                )).toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String value;
  final String label;
  final Color color;

  const _StatItem({
    Key? key,
    required this.value,
    required this.label,
    required this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: TextStyle(fontSize: 12, color: Colors.grey),
        ),
      ],
    );
  }
}