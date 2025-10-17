import 'package:flutter/material.dart';
import '../models/shopping_item.dart';
import '../services/shopping_service.dart';
import '../widgets/add_item_dialog.dart';
import '../widgets/category_filter.dart';
import '../widgets/shopping_stats.dart';
import '../widgets/shopping_list_view.dart';

class ShoppingListScreen extends StatefulWidget {
  @override
  _ShoppingListScreenState createState() => _ShoppingListScreenState();
}

class _ShoppingListScreenState extends State<ShoppingListScreen> {
  final ShoppingService _shoppingService = ShoppingService();
  final List<ShoppingItem> _items = [];
  final TextEditingController _searchController = TextEditingController();

  String _selectedCategory = 'Все';
  String _searchQuery = '';
  bool _showCompleted = true;

  ShoppingItem? _recentlyDeletedItem;
  int? _recentlyDeletedIndex;
  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text;
      });
    });

    _addExampleItems();
  }

  void _addExampleItems() {
    final exampleItems = [
      ShoppingItem(
        id: '1',
        name: 'Яблоки',
        category: 'Овощи и фрукты',
        quantity: 5,
        createdAt: DateTime.now().subtract(Duration(hours: 2)),
      ),
      ShoppingItem(
        id: '2',
        name: 'Молоко',
        category: 'Молочные продукты',
        quantity: 1,
        createdAt: DateTime.now().subtract(Duration(hours: 1)),
      ),
      ShoppingItem(
        id: '3',
        name: 'Хлеб',
        category: 'Хлеб и выпечка',
        quantity: 1,
        createdAt: DateTime.now(),
        isCompleted: true,
        completedAt: DateTime.now().subtract(Duration(minutes: 30)),
      ),
    ];

    setState(() {
      _items.addAll(exampleItems);
    });
  }

  void _addItem(String name, String category, int quantity) {
    final newItem = ShoppingItem(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      category: category,
      quantity: quantity,
      createdAt: DateTime.now(),
    );

    setState(() {
      _items.add(newItem);
    });
  }

  void _editItem(ShoppingItem oldItem, String newName, String newCategory, int newQuantity) {
    final index = _items.indexWhere((item) => item.id == oldItem.id);
    if (index != -1) {
      setState(() {
        _items[index] = oldItem.copyWith(
          name: newName,
          category: newCategory,
          quantity: newQuantity,
        );
      });
    }
  }

  void _toggleItem(String id) {
    final index = _items.indexWhere((item) => item.id == id);
    if (index != -1) {
      setState(() {
        _items[index] = _items[index].copyWith(
          isCompleted: !_items[index].isCompleted,
          completedAt: _items[index].isCompleted ? null : DateTime.now(),
        );
      });
    }
  }

  void _updateQuantity(String id, int newQuantity) {
    if (newQuantity <= 0) {
      _deleteItem(id);
      return;
    }

    final index = _items.indexWhere((item) => item.id == id);
    if (index != -1) {
      setState(() {
        _items[index] = _items[index].copyWith(quantity: newQuantity);
      });
    }
  }

  void _deleteItem(String id) {
    final index = _items.indexWhere((item) => item.id == id);
    if (index != -1) {
      setState(() {
        _recentlyDeletedItem = _items[index];
        _recentlyDeletedIndex = index;
        _items.removeAt(index);
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Товар "${_recentlyDeletedItem!.name}" удален'),
          action: SnackBarAction(
            label: 'Отменить',
            onPressed: () {
              _undoDelete();
            },
          ),
          duration: Duration(seconds: 5),
        ),
      );
    }
  }

  void _undoDelete() {
    if (_recentlyDeletedItem != null && _recentlyDeletedIndex != null) {
      setState(() {
        _items.insert(_recentlyDeletedIndex!, _recentlyDeletedItem!);
        _recentlyDeletedItem = null;
        _recentlyDeletedIndex = null;
      });
    }
  }

  void _clearCompleted() {
    _recentlyDeletedItem = null;
    _recentlyDeletedIndex = null;

    setState(() {
      _items.removeWhere((item) => item.isCompleted);
    });
  }

  void _clearAll() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Очистить список'),
        content: Text('Вы уверены, что хотите удалить все товары?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Отмена'),
          ),
          TextButton(
            onPressed: () {
              _recentlyDeletedItem = null;
              _recentlyDeletedIndex = null;

              setState(() {
                _items.clear();
              });
              Navigator.pop(context);
            },
            child: Text('Очистить', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  List<ShoppingItem> get _filteredItems {
    var filtered = _items.where((item) {
      final matchesSearch = _searchQuery.isEmpty ||
          item.name.toLowerCase().contains(_searchQuery.toLowerCase());
      final matchesCategory = _selectedCategory == 'Все' ||
          item.category == _selectedCategory;
      final matchesCompletion = _showCompleted || !item.isCompleted;

      return matchesSearch && matchesCategory && matchesCompletion;
    }).toList();

    filtered.sort((a, b) {
      if (a.isCompleted != b.isCompleted) {
        return a.isCompleted ? 1 : -1;
      }
      if (a.category != b.category) {
        return a.category.compareTo(b.category);
      }
      return a.name.compareTo(b.name);
    });

    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    final filteredItems = _filteredItems;
    final categories = ['Все', ..._shoppingService.availableCategories];

    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text('Список покупок'),
        actions: [
          if (_items.isNotEmpty) ...[
            if (_items.any((item) => item.isCompleted))
              IconButton(
                icon: Icon(Icons.cleaning_services),
                onPressed: _clearCompleted,
                tooltip: 'Удалить выполненные',
              ),
            PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'clear_all') _clearAll();
                if (value == 'toggle_completed') {
                  setState(() {
                    _showCompleted = !_showCompleted;
                  });
                }
              },
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: 'toggle_completed',
                  child: Row(
                    children: [
                      Icon(_showCompleted ? Icons.visibility : Icons.visibility_off),
                      SizedBox(width: 8),
                      Text(_showCompleted ? 'Скрыть выполненные' : 'Показать выполненные'),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 'clear_all',
                  child: Row(
                    children: [
                      Icon(Icons.delete_forever, color: Colors.red),
                      SizedBox(width: 8),
                      Text('Очистить весь список', style: TextStyle(color: Colors.red)),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Поиск товаров...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
                suffixIcon: _searchQuery.isNotEmpty ? IconButton(
                  icon: Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                  },
                ) : null,
              ),
            ),
          ),

          CategoryFilter(
            categories: categories,
            selectedCategory: _selectedCategory,
            onCategorySelected: (category) {
              setState(() {
                _selectedCategory = category;
              });
            },
          ),

          ShoppingStats(items: _items),

          Expanded(
            child: ShoppingListView(
              items: filteredItems,
              onToggle: _toggleItem,
              onEdit: _editItem,
              onUpdateQuantity: _updateQuantity,
              onDelete: _deleteItem,
              availableCategories: _shoppingService.availableCategories,
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddDialog(context),
        child: Icon(Icons.add),
        tooltip: 'Добавить товар',
      ),
    );
  }

  void _showAddDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AddItemDialog(
        onAdd: _addItem,
        availableCategories: _shoppingService.availableCategories,
        onDetectCategory: _shoppingService.detectCategory,
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}