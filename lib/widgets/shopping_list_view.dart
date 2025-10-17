import 'package:flutter/material.dart';
import '../models/shopping_item.dart';
import 'add_item_dialog.dart';

class ShoppingListView extends StatefulWidget {
  final List<ShoppingItem> items;
  final Function(String) onToggle;
  final Function(ShoppingItem, String, String, int) onEdit;
  final Function(String, int) onUpdateQuantity;
  final Function(String) onDelete;
  final List<String> availableCategories;

  const ShoppingListView({
    Key? key,
    required this.items,
    required this.onToggle,
    required this.onEdit,
    required this.onUpdateQuantity,
    required this.onDelete,
    required this.availableCategories,
  }) : super(key: key);

  @override
  _ShoppingListViewState createState() => _ShoppingListViewState();
}

class _ShoppingListViewState extends State<ShoppingListView> {
  String? _expandedItemId;

  void _toggleExpand(String itemId) {
    setState(() {
      _expandedItemId = _expandedItemId == itemId ? null : itemId;
    });
  }

  void _showEditDialog(ShoppingItem item) {
    showDialog(
      context: context,
      builder: (context) => _EditItemDialog(
        item: item,
        onEdit: widget.onEdit,
        availableCategories: widget.availableCategories,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.items.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.shopping_cart_outlined, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'Список покупок пуст',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
            Text(
              'Добавьте первый товар',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      );
    }

    String? currentCategory;

    return ListView.builder(
      itemCount: widget.items.length,
      itemBuilder: (context, index) {
        final item = widget.items[index];
        final showCategoryHeader = currentCategory != item.category;
        currentCategory = item.category;

        return Column(
          children: [
            if (showCategoryHeader && !item.isCompleted)
              _CategoryHeader(category: item.category),
            _ShoppingListItem(
              item: item,
              isExpanded: _expandedItemId == item.id,
              onToggle: () => widget.onToggle(item.id),
              onExpand: () => _toggleExpand(item.id),
              onEdit: () => _showEditDialog(item),
              onUpdateQuantity: (newQuantity) =>
                  widget.onUpdateQuantity(item.id, newQuantity),
              onDelete: () => widget.onDelete(item.id),
            ),
          ],
        );
      },
    );
  }
}

class _CategoryHeader extends StatelessWidget {
  final String category;

  const _CategoryHeader({Key? key, required this.category}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      width: double.infinity,
      color: Colors.grey[100],
      child: Text(
        category,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: Colors.grey[700],
        ),
      ),
    );
  }
}

class _ShoppingListItem extends StatelessWidget {
  final ShoppingItem item;
  final bool isExpanded;
  final VoidCallback onToggle;
  final VoidCallback onExpand;
  final VoidCallback onEdit;
  final Function(int) onUpdateQuantity;
  final VoidCallback onDelete;

  const _ShoppingListItem({
    Key? key,
    required this.item,
    required this.isExpanded,
    required this.onToggle,
    required this.onExpand,
    required this.onEdit,
    required this.onUpdateQuantity,
    required this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      color: item.isCompleted ? Colors.green[50] : null,
      child: Column(
        children: [
          ListTile(
            leading: Checkbox(
              value: item.isCompleted,
              onChanged: (value) => onToggle(),
            ),
            title: Text(
              item.name,
              style: TextStyle(
                decoration: item.isCompleted ?
                TextDecoration.lineThrough : TextDecoration.none,
                color: item.isCompleted ? Colors.grey : null,
              ),
            ),
            subtitle: Text('Количество: ${item.quantity}'),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: Icon(isExpanded ? Icons.expand_less : Icons.expand_more),
                  onPressed: onExpand,
                ),
              ],
            ),
            onTap: onExpand,
          ),
          if (isExpanded) ..._buildExpandedContent(),
        ],
      ),
    );
  }

  List<Widget> _buildExpandedContent() {
    return [
      Divider(height: 1),
      Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Text('Категория: ${item.category}'),
                Spacer(),
                Chip(
                  label: Text(item.isCompleted ? 'Куплено' : 'Не куплено'),
                  backgroundColor: item.isCompleted ? Colors.green : Colors.orange,
                  labelStyle: TextStyle(color: Colors.white),
                ),
              ],
            ),
            SizedBox(height: 16),
            Row(
              children: [
                Text('Количество:'),
                SizedBox(width: 16),
                IconButton(
                  icon: Icon(Icons.remove),
                  onPressed: () => onUpdateQuantity(item.quantity - 1),
                ),
                Text(
                  '${item.quantity}',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: Icon(Icons.add),
                  onPressed: () => onUpdateQuantity(item.quantity + 1),
                ),
                Spacer(),
                IconButton(
                  icon: Icon(Icons.edit, color: Colors.blue),
                  onPressed: onEdit,
                ),
                IconButton(
                  icon: Icon(Icons.delete, color: Colors.red),
                  onPressed: onDelete,
                ),
              ],
            ),
            if (item.completedAt != null) ...[
              SizedBox(height: 8),
              Text(
                'Куплено: ${_formatDate(item.completedAt!)}',
                style: TextStyle(color: Colors.grey, fontSize: 12),
              ),
            ],
          ],
        ),
      ),
    ];
  }

  String _formatDate(DateTime date) {
    return '${date.day}.${date.month}.${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
}

class _EditItemDialog extends StatefulWidget {
  final ShoppingItem item;
  final Function(ShoppingItem, String, String, int) onEdit;
  final List<String> availableCategories;

  const _EditItemDialog({
    Key? key,
    required this.item,
    required this.onEdit,
    required this.availableCategories,
  }) : super(key: key);

  @override
  __EditItemDialogState createState() => __EditItemDialogState();
}

class __EditItemDialogState extends State<_EditItemDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  late String _selectedCategory;
  late int _quantity;

  @override
  void initState() {
    super.initState();
    _nameController.text = widget.item.name;
    _selectedCategory = widget.item.category;
    _quantity = widget.item.quantity;
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      widget.onEdit(
        widget.item,
        _nameController.text.trim(),
        _selectedCategory,
        _quantity,
      );
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Редактировать товар'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'Название товара',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Введите название товара';
                }
                return null;
              },
            ),
            SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _selectedCategory,
              decoration: InputDecoration(
                labelText: 'Категория',
                border: OutlineInputBorder(),
              ),
              items: widget.availableCategories.map((category) {
                return DropdownMenuItem(
                  value: category,
                  child: Text(category),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedCategory = value!;
                });
              },
            ),
            SizedBox(height: 16),
            Row(
              children: [
                Text('Количество:'),
                SizedBox(width: 16),
                IconButton(
                  icon: Icon(Icons.remove),
                  onPressed: _quantity > 1 ? () {
                    setState(() {
                      _quantity--;
                    });
                  } : null,
                ),
                Text(
                  '$_quantity',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: Icon(Icons.add),
                  onPressed: () {
                    setState(() {
                      _quantity++;
                    });
                  },
                ),
              ],
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text('Отмена'),
        ),
        ElevatedButton(
          onPressed: _submit,
          child: Text('Сохранить'),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }
}