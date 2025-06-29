class ProductCard extends StatelessWidget {
  final Product product;

  const ProductCard({required this.product});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: CircleAvatar(
          child: Text(product.code.substring(0, 2)),
        ),
        title: Text(product.name),
        subtitle: Text('\$${product.price.toStringAsFixed(2)} • ${product.stock} in stock'),
        trailing: IconButton(
          icon: Icon(Icons.edit),
          onPressed: () => _showEditDialog(context),
        ),
        onTap: () => _showProductDetails(context),
      ),
    );
  }

  void _showEditDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (_) => AddProductDialog(product: product),
    );
  }
}