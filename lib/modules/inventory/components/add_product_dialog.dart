class AddProductDialog extends StatefulWidget {
  @override
  State<AddProductDialog> createState() => _AddProductDialogState();
}

class _AddProductDialogState extends State<AddProductDialog> {
  final _formKey = GlobalKey<FormState>();
  final _codeController = TextEditingController();
  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  final _stockController = TextEditingController();
  String? _selectedCategory;
  int _selectedTaxCategory = 1; // Default to Standard (18%)

  final List<Map<String, dynamic>> taxCategories = [
    {'value': 1, 'label': 'Standard (18%)'},
    {'value': 2, 'label': 'Special rate'},
    {'value': 3, 'label': 'Zero Rated'},
    {'value': 4, 'label': 'Special Relief'},
    {'value': 5, 'label': 'Exempted'},
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppBar(
              title: Text('Add Product'),
              actions: [
                TextButton(
                  child: Text('Save'),
                  onPressed: _saveProduct,
                ),
              ],
            ),
            Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                children: [
                  TextFormField(
                    controller: _codeController,
                    decoration: InputDecoration(labelText: 'Item Code'),
                    validator: (value) => value?.isEmpty ?? true ? 'Required' : null,
                  ),
                  TextFormField(
                    controller: _nameController,
                    decoration: InputDecoration(labelText: 'Item Name'),
                    validator: (value) => value?.isEmpty ?? true ? 'Required' : null,
                  ),
                  DropdownButtonFormField<String>(
                    value: _selectedCategory,
                    decoration: InputDecoration(labelText: 'Category'),
                    items: [
                      DropdownMenuItem(child: Text('Select category'), value: null),
                      ...context.read<InventoryProvider>().categories.map((category) {
                        return DropdownMenuItem(
                          child: Text(category.name),
                          value: category.name,
                        );
                      }).toList(),
                      DropdownMenuItem(
                        child: Text('+ Add new category'),
                        value: '__add_new__',
                      ),
                    ],
                    onChanged: (value) {
                      if (value == '__add_new__') {
                        _showAddCategoryDialog();
                      } else {
                        setState(() => _selectedCategory = value);
                      }
                    },
                  ),
                  TextFormField(
                    controller: _priceController,
                    decoration: InputDecoration(labelText: 'Price'),
                    keyboardType: TextInputType.number,
                    validator: (value) => value?.isEmpty ?? true ? 'Required' : null,
                  ),
                  DropdownButtonFormField<int>(
                    value: _selectedTaxCategory,
                    decoration: InputDecoration(labelText: 'Tax Category'),
                    items: taxCategories.map((tax) {
                      return DropdownMenuItem(
                        value: tax['value'],
                        child: Text(tax['label']),
                      );
                    }).toList(),
                    onChanged: (value) => setState(() => _selectedTaxCategory = value!),
                  ),
                  TextFormField(
                    controller: _stockController,
                    decoration: InputDecoration(labelText: 'Initial Stock'),
                    keyboardType: TextInputType.number,
                    validator: (value) => value?.isEmpty ?? true ? 'Required' : null,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _saveProduct() async {
    if (_formKey.currentState!.validate()) {
      final product = Product(
        id: Uuid().v4(),
        code: _codeController.text,
        name: _nameController.text,
        category: _selectedCategory ?? 'Uncategorized',
        price: double.parse(_priceController.text),
        taxCategory: _selectedTaxCategory,
        stock: int.parse(_stockController.text),
        createdAt: DateTime.now(),
      );

      await context.read<InventoryProvider>().addProduct(product);
      Navigator.pop(context);
    }
  }

  void _showAddCategoryDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Add New Category'),
        content: TextField(
          autofocus: true,
          decoration: InputDecoration(labelText: 'Category Name'),
        ),
        actions: [
          TextButton(
            child: Text('Cancel'),
            onPressed: () => Navigator.pop(context),
          ),
          TextButton(
            child: Text('Add'),
            onPressed: () {
              // Add category logic
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }
}