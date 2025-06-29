import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/models/models.dart';
import '../../../../core/providers/providers.dart';

class ProductListScreen extends ConsumerStatefulWidget {
  const ProductListScreen({super.key});

  @override
  ConsumerState<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends ConsumerState<ProductListScreen> {
  @override
  Widget build(BuildContext context) {
    final filteredProductsAsync = ref.watch(filteredProductsProvider);
    final categoryFilter = ref.watch(categoryFilterProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Lista de Produtos'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Column(
        children: [
          // Seção de busca e filtros
          Container(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                // Campo de busca
                TextField(
                  decoration: const InputDecoration(
                    labelText: 'Buscar produtos',
                    hintText: 'Digite o nome do produto...',
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (value) {
                    ref.read(searchQueryProvider.notifier).state = value;
                  },
                ),
                const SizedBox(height: 16),
                // Filtro por categoria
                Consumer(
                  builder: (context, ref, child) {
                    final categories = ref.watch(categoriesProvider);
                    return DropdownButtonFormField<String>(
                      value: categoryFilter,
                      decoration: const InputDecoration(
                        labelText: 'Filtrar por categoria',
                        border: OutlineInputBorder(),
                      ),
                      items: categories.map((category) {
                        return DropdownMenuItem<String>(
                          value: category,
                          child: Text(category),
                        );
                      }).toList(),
                      onChanged: (value) {
                        if (value != null) {
                          ref.read(categoryFilterProvider.notifier).state = value;
                        }
                      },
                    );
                  },
                ),
              ],
            ),
          ),
          // Lista de produtos
          Expanded(
            child: filteredProductsAsync.when(
              data: (products) {
                if (products.isEmpty) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.inventory_2, size: 64, color: Colors.grey),
                        SizedBox(height: 16),
                        Text(
                          'Nenhum produto encontrado',
                          style: TextStyle(fontSize: 18, color: Colors.grey),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  itemCount: products.length,
                  itemBuilder: (context, index) {
                    final product = products[index];
                    return _ProductCard(product: product);
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error, size: 64, color: Colors.red),
                    const SizedBox(height: 16),
                    Text('Erro ao carregar produtos: $error'),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        ref.invalidate(productsStreamProvider);
                      },
                      child: const Text('Tentar novamente'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: Consumer(
        builder: (context, ref, child) {
          final isAdmin = ref.watch(isAdminProvider);
          return isAdmin
              ? FloatingActionButton(
                  onPressed: () {
                    context.push('/stock/product-registration');
                  },
                  child: const Icon(Icons.add),
                )
              : const SizedBox.shrink();
        },
      ),
    );
  }
}

class _ProductCard extends ConsumerWidget {
  final Product product;

  const _ProductCard({required this.product});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: _getStockStatusColor(product),
          child: Text(
            product.currentStock.toString(),
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Text(
          product.name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Categoria: ${product.category}'),
            Text('Unidade: ${product.unit}'),
            Text('Localização: ${product.location}'),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: _getStockStatusColor(product),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                product.stockStatus,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        trailing: Consumer(
          builder: (context, ref, child) {
            final isAdmin = ref.watch(isAdminProvider);
            return PopupMenuButton<String>(
              onSelected: (value) async {
                switch (value) {
                  case 'details':
                    _showProductDetails(context, product);
                    break;
                  case 'edit':
                    context.push('/stock/product-registration', extra: product);
                    break;
                  case 'delete':
                    _deleteProduct(context, ref, product);
                    break;
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'details',
                  child: ListTile(
                    leading: Icon(Icons.info),
                    title: Text('Detalhes'),
                  ),
                ),
                if (isAdmin)
                  const PopupMenuItem(
                    value: 'edit',
                    child: ListTile(
                      leading: Icon(Icons.edit),
                      title: Text('Editar'),
                    ),
                  ),
                if (isAdmin)
                  const PopupMenuItem(
                    value: 'delete',
                    child: ListTile(
                      leading: Icon(Icons.delete, color: Colors.red),
                      title: Text('Excluir', style: TextStyle(color: Colors.red)),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }

  Color _getStockStatusColor(Product product) {
    switch (product.stockStatus) {
      case 'Crítico':
        return Colors.red;
      case 'Baixo':
        return Colors.orange;
      default:
        return Colors.green;
    }
  }

  void _showProductDetails(BuildContext context, Product product) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(product.name),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _DetailRow('Descrição', product.description),
            _DetailRow('Categoria', product.category),
            _DetailRow('Unidade', product.unit),
            _DetailRow('Estoque Atual', '${product.currentStock}'),
            _DetailRow('Estoque Mínimo', '${product.minStock}'),
            _DetailRow('Estoque Máximo', '${product.maxStock}'),
            _DetailRow('Localização', product.location),
            _DetailRow('Status', product.stockStatus),
            _DetailRow('Criado em', _formatDate(product.createdAt)),
            _DetailRow('Atualizado em', _formatDate(product.updatedAt)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Fechar'),
          ),
        ],
      ),
    );
  }

  void _deleteProduct(BuildContext context, WidgetRef ref, Product product) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar Exclusão'),
        content: Text('Tem certeza que deseja excluir o produto "${product.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();
              try {
                final productService = ref.read(productServiceProvider);
                await productService.deleteProduct(product.id!);
                
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Produto excluído com sucesso!'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Erro ao excluir produto: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            child: const Text('Excluir', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;

  const _DetailRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}