class InventoryPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Inventory'),
        actions: [
          IconButton(
            icon: Icon(Icons.filter_alt),
            onPressed: _showFilterDialog,
          ),
        ],
      ),
      body: Column(
        children: [
          _buildSearchBar(),
          _buildCategoryChips(),
          _buildProductList(),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: _showAddProductDialog,
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: EdgeInsets.all(16),
      child: SearchBar(
        hintText: 'Search products...',
        onChanged: (query) => context.read<InventoryProvider>().setSearchQuery(query),
      ),
    );
  }

  Widget _buildCategoryChips() {
    return Consumer<InventoryProvider>(
      builder: (context, provider, _) {
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              SizedBox(width: 16),
              FilterChip(
                label: Text('All'),
                selected: provider.selectedCategory == null,
                onSelected: (_) => provider.setCategoryFilter(null),
              ),
              ...provider.categories.map((category) {
                return Padding(
                  padding: EdgeInsets.symmetric(horizontal: 4),
                  child: FilterChip(
                    label: Text(category.name),
                    selected: provider.selectedCategory == category.name,
                    onSelected: (_) => provider.setCategoryFilter(category.name),
                  ),
                );
              }).toList(),
              SizedBox(width: 16),
            ],
          ),
        );
      },
    );
  }

  Widget _buildProductList() {
    return Expanded(
      child: Consumer<InventoryProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) return Center(child: CircularProgressIndicator());
          
          return ListView.builder(
            itemCount: provider.filteredProducts.length,
            itemBuilder: (context, index) {
              final product = provider.filteredProducts[index];
              return ProductCard(product: product);
            },
          );
        },
      ),
    );
  }

  void _showAddProductDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => AddProductDialog(),
    );
  }
}