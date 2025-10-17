import 'package:flutter/material.dart';

class AddItemDialog extends StatefulWidget {
  final Function(String, String, int) onAdd;
  final List<String> availableCategories;
  final Function(String) onDetectCategory;

  const AddItemDialog({
    Key? key,
    required this.onAdd,
    required this.availableCategories,
    required this.onDetectCategory,
  }) : super(key: key);

  @override
  _AddItemDialogState createState() => _AddItemDialogState();
}

class _AddItemDialogState extends State<AddItemDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  String _selectedCategory = 'Другое';
  int _quantity = 1;

  @override
  void initState() {
    super.initState();
    _nameController.addListener(_autoDetectCategory);
  }

  void _autoDetectCategory() {
    if (_nameController.text.isNotEmpty) {
      final detectedCategory = widget.onDetectCategory(_nameController.text);
      setState(() {
        _selectedCategory = detectedCategory;
      });
    }
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      widget.onAdd(
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
      title: Text('Добавить товар'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _nameController,
              autofocus: true,
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
                Container(
                  width: 40,
                  alignment: Alignment.center,
                  child: Text(
                    '$_quantity',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.add),
                  onPressed: () {
                    setState(() {
                      _quantity++;
                    });
                  },
                ),
                Spacer(),
                TextButton(
                  onPressed: () {
                    setState(() {
                      _quantity = 1;
                    });
                  },
                  child: Text('Сбросить'),
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
          child: Text('Добавить'),
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