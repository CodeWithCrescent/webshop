import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:webshop/core/localization/inventory_localizations.dart';
import 'package:webshop/modules/inventory/models/category.dart';
import 'package:webshop/modules/inventory/models/product.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/modal_header.dart';
import '../../../shared/widgets/gradient_button.dart';
import '../providers/inventory_provider.dart';

class ProductModal extends StatefulWidget {
  final Product? product;
  final Function()? onSuccess;
  final VoidCallback? onDelete;

  const ProductModal({
    super.key,
    this.product,
    this.onSuccess,
    this.onDelete,
  });

  @override
  State<ProductModal> createState() => _ProductModalState();
}

class _ProductModalState extends State<ProductModal> {
  late final TextEditingController _codeController;
  late final TextEditingController _nameController;
  late final TextEditingController _priceController;
  late final TextEditingController _stockController;
  late String? _selectedCategory;
  late int _selectedTaxCategory;
  final _formKey = GlobalKey<FormState>();
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _codeController = TextEditingController(text: widget.product?.code ?? '');
    _nameController = TextEditingController(text: widget.product?.name ?? '');
    _priceController = TextEditingController(
      text: widget.product?.price.toString() ?? '',
    );
    _stockController = TextEditingController(
      text: widget.product?.stock.toString() ?? '',
    );
    _selectedCategory = widget.product?.category;
    _selectedTaxCategory = widget.product?.taxCategory ?? 1;
  }

  @override
  void dispose() {
    _codeController.dispose();
    _nameController.dispose();
    _priceController.dispose();
    _stockController.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      final provider = context.read<InventoryProvider>();
      final product = Product(
        id: widget.product?.id,
        code: _codeController.text,
        name: _nameController.text,
        category: _selectedCategory ?? 'Uncategorized',
        price: double.parse(_priceController.text),
        taxCategory: _selectedTaxCategory,
        stock: int.parse(_stockController.text),
      );

      if (widget.product == null) {
        await provider.addProduct(product);
      } else {
        await provider.updateProduct(product);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.product == null
                ? InventoryLocalizations(context).addSuccess
                : InventoryLocalizations(context).updateSuccess),
            backgroundColor: Colors.green,
          ),
        );

        Navigator.pop(context);
        widget.onSuccess?.call();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            backgroundColor: Colors.red,
          ),
        );
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.lightTheme;
    final loc = InventoryLocalizations(context);
    final provider = context.watch<InventoryProvider>();

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ModalHeader(
                title:
                    widget.product == null ? loc.addProduct : loc.editProduct,
                onClose: () => Navigator.pop(context),
                actions: widget.product != null
                    ? [
                        IconButton(
                          icon: const Icon(Icons.delete),
                          color: theme.colorScheme.error,
                          onPressed: widget.onDelete,
                        ),
                      ]
                    : null,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    TextFormField(
                      controller: _codeController,
                      decoration: InputDecoration(
                        labelText: loc.productCode,
                        prefixIcon: const Icon(Icons.code),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return loc.validationRequired;
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        labelText: loc.productName,
                        prefixIcon: const Icon(Icons.shopping_bag),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return loc.validationRequired;
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: _selectedCategory,
                      decoration: InputDecoration(
                        labelText: loc.category,
                        prefixIcon: const Icon(Icons.category),
                      ),
                      items: [
                        DropdownMenuItem(
                          value: null,
                          child: Text(loc.selectCategory),
                        ),
                        ...provider.categories.map((category) {
                          return DropdownMenuItem(
                            value: category.name,
                            child: Text(category.name),
                          );
                        }).toList(),
                        DropdownMenuItem(
                          value: '__add_new__',
                          child: Text(loc.addNewCategory),
                        ),
                      ],
                      onChanged: (value) {
                        if (value == '__add_new__') {
                          _showAddCategoryDialog(provider);
                        } else {
                          setState(() => _selectedCategory = value);
                        }
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _priceController,
                      decoration: InputDecoration(
                        labelText: loc.price,
                        prefixIcon: const Icon(Icons.attach_money),
                      ),
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(
                            RegExp(r'^\d+\.?\d{0,2}')),
                      ],
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return loc.validationRequired;
                        }
                        if (double.tryParse(value) == null) {
                          return loc.validationInvalidPrice;
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<int>(
                      value: _selectedTaxCategory,
                      decoration: InputDecoration(
                        labelText: loc.taxCategory,
                        prefixIcon: const Icon(Icons.receipt),
                      ),
                      items: [
                        DropdownMenuItem(
                          value: 1,
                          child: Text(loc.taxStandard),
                        ),
                        DropdownMenuItem(
                          value: 2,
                          child: Text(loc.taxSpecialRate),
                        ),
                        DropdownMenuItem(
                          value: 3,
                          child: Text(loc.taxZeroRated),
                        ),
                        DropdownMenuItem(
                          value: 4,
                          child: Text(loc.taxSpecialRelief),
                        ),
                        DropdownMenuItem(
                          value: 5,
                          child: Text(loc.taxExempted),
                        ),
                      ],
                      onChanged: (value) =>
                          setState(() => _selectedTaxCategory = value!),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _stockController,
                      decoration: InputDecoration(
                        labelText: loc.stock,
                        prefixIcon: const Icon(Icons.inventory),
                      ),
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                      ],
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return loc.validationRequired;
                        }
                        if (int.tryParse(value) == null) {
                          return loc.validationInvalidStock;
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 32),
                    GradientButton(
                      onPressed: _isSaving ? null : _handleSave,
                      child: _isSaving
                          ? const CircularProgressIndicator(color: Colors.white)
                          : Text(
                              widget.product == null ? loc.save : loc.update),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showAddCategoryDialog(InventoryProvider provider) {
    final theme = AppTheme.lightTheme;
    final loc = InventoryLocalizations(context);
    final controller = TextEditingController();
    bool isAdding = false;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text(loc.addNewCategory),
              content: TextFormField(
                controller: controller,
                decoration: InputDecoration(
                  labelText: loc.categoryName,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return loc.validationRequired;
                  }
                  return null;
                },
              ),
              actions: [
                TextButton(
                  onPressed: isAdding ? null : () => Navigator.pop(context),
                  child: Text(loc.cancel),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.primaryColor,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: isAdding
                      ? null
                      : () async {
                          if (controller.text.isNotEmpty) {
                            setState(() => isAdding = true);
                            final messenger = ScaffoldMessenger.of(context);
                            try {
                              await provider
                                  .addCategory(Category(name: controller.text));
                              if (mounted) {
                                setState(
                                    () => _selectedCategory = controller.text);
                                Navigator.pop(context);
                              }
                            } catch (e) {
                              messenger.showSnackBar(
                                SnackBar(
                                  content: Text(e.toString()),
                                  backgroundColor: theme.colorScheme.error,
                                ),
                              );
                            } finally {
                              if (mounted) {
                                setState(() => isAdding = false);
                              }
                            }
                          }
                        },
                  child: isAdding
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Text(loc.add),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
