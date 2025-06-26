import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/models/models.dart';
import '../../../../core/providers/providers.dart';

class StockMovementScreen extends ConsumerStatefulWidget {
  const StockMovementScreen({super.key});

  @override
  ConsumerState<StockMovementScreen> createState() => _StockMovementScreenState();
}

class _StockMovementScreenState extends ConsumerState<StockMovementScreen> {
  final _formKey = GlobalKey<FormState>();
  final _quantityController = TextEditingController();
  final _observationController = TextEditingController();

  String? _selectedProductId;
  MovementType _movementType = MovementType.entry;
  String? _selectedReason;

  final List<String> _entryReasons = [
    'Compra',
    'Doação',
    'Transferência de entrada',
    'Devolução',
    'Ajuste de inventário',
    'Outros',
  ];

  final List<String> _exitReasons = [
    'Consumo',
    'Transferência de saída',
    'Perda',
    'Vencimento',
    'Ajuste de inventário',
    'Outros',
  ];

  bool _isLoading = false;

  @override
  void dispose() {
    _quantityController.dispose();
    _observationController.dispose();
    super.dispose();
  }

  List<String> get _currentReasons {
    return _movementType == MovementType.entry ? _entryReasons : _exitReasons;
  }

  Product? _getSelectedProduct(List<Product> products) {
    if (_selectedProductId == null) return null;
    try {
      return products.firstWhere((p) => p.id == _selectedProductId);
    } catch (e) {
      return null;
    }
  }

  Future<void> _submitMovement() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final productsAsync = ref.read(productsStreamProvider);
    final products = productsAsync.value;
    if (products == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Erro: Lista de produtos não carregada'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final selectedProduct = _getSelectedProduct(products);
    if (selectedProduct == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Erro: Produto não encontrado'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final movementService = ref.read(stockMovementServiceProvider);
      final quantity = int.parse(_quantityController.text);

      // Verificar se há estoque suficiente para saída
      if (_movementType == MovementType.exit && quantity > selectedProduct.currentStock) {
        throw Exception('Estoque insuficiente. Disponível: ${selectedProduct.currentStock}');
      }

      final movement = StockMovement(
        productId: selectedProduct.id!,
        productName: selectedProduct.name,
        type: _movementType,
        quantity: quantity,
        reason: _selectedReason!,
        observation: _observationController.text.trim().isEmpty
            ? null
            : _observationController.text.trim(),
        createdAt: DateTime.now(),
        userId: 'user_default', // TODO: Implementar autenticação
      );

      await movementService.createMovement(movement);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Movimentação registrada com sucesso!'),
            backgroundColor: Colors.green,
          ),
        );

        // Limpar formulário
        _resetForm();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao registrar movimentação: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _resetForm() {
    _quantityController.clear();
    _observationController.clear();
    setState(() {
      _selectedProductId = null;
      _movementType = MovementType.entry;
      _selectedReason = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final productsAsync = ref.watch(productsStreamProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Movimentação de Estoque'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Tipo de movimentação
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Tipo de Movimentação',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: RadioListTile<MovementType>(
                              title: const Text('Entrada'),
                              value: MovementType.entry,
                              groupValue: _movementType,
                              onChanged: (value) {
                                setState(() {
                                  _movementType = value!;
                                  _selectedReason = null; // Reset reason
                                });
                              },
                            ),
                          ),
                          Expanded(
                            child: RadioListTile<MovementType>(
                              title: const Text('Saída'),
                              value: MovementType.exit,
                              groupValue: _movementType,
                              onChanged: (value) {
                                setState(() {
                                  _movementType = value!;
                                  _selectedReason = null; // Reset reason
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // Seleção do produto
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Produto',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 16),
                      productsAsync.when(
                        data: (products) {
                          if (products.isEmpty) {
                            return const Text('Nenhum produto cadastrado');
                          }
                          
                          return DropdownButtonFormField<String>(
                            value: _selectedProductId,
                            decoration: const InputDecoration(
                              labelText: 'Selecione o produto *',
                              border: OutlineInputBorder(),
                            ),
                            items: products.map((product) {
                              return DropdownMenuItem(
                                value: product.id,
                                child: Text('${product.name} (${product.currentStock} ${product.unit})'),
                              );
                            }).toList(),
                            onChanged: (value) {
                              setState(() {
                                _selectedProductId = value;
                              });
                            },
                            validator: (value) {
                              if (value == null) {
                                return 'Produto é obrigatório';
                              }
                              return null;
                            },
                          );
                        },
                        loading: () => const CircularProgressIndicator(),
                        error: (error, stack) => Text('Erro ao carregar produtos: $error'),
                      ),
                      const SizedBox(height: 16),
                      // Informações do produto selecionado
                      productsAsync.when(
                        data: (products) {
                          final selectedProduct = _getSelectedProduct(products);
                          if (selectedProduct == null) {
                            return const SizedBox.shrink();
                          }
                          
                          return Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.grey[100],
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Informações do Produto',
                                  style: Theme.of(context).textTheme.titleMedium,
                                ),
                                const SizedBox(height: 8),
                                Text('Categoria: ${selectedProduct.category}'),
                                Text('Estoque Atual: ${selectedProduct.currentStock} ${selectedProduct.unit}'),
                                Text('Localização: ${selectedProduct.location}'),
                                Container(
                                  margin: const EdgeInsets.only(top: 4),
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: _getStockStatusColor(selectedProduct),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    selectedProduct.stockStatus,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                        loading: () => const SizedBox.shrink(),
                        error: (error, stack) => const SizedBox.shrink(),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // Detalhes da movimentação
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Detalhes da Movimentação',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _quantityController,
                              decoration: const InputDecoration(
                                labelText: 'Quantidade *',
                                hintText: '0',
                                border: OutlineInputBorder(),
                              ),
                              keyboardType: TextInputType.number,
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Quantidade é obrigatória';
                                }
                                if (int.tryParse(value) == null) {
                                  return 'Digite um número válido';
                                }
                                if (int.parse(value) <= 0) {
                                  return 'Quantidade deve ser maior que zero';
                                }
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              value: _selectedReason,
                              decoration: const InputDecoration(
                                labelText: 'Motivo *',
                                border: OutlineInputBorder(),
                              ),
                              items: _currentReasons.map((reason) {
                                return DropdownMenuItem(
                                  value: reason,
                                  child: Text(reason),
                                );
                              }).toList(),
                              onChanged: (value) {
                                setState(() {
                                  _selectedReason = value;
                                });
                              },
                              validator: (value) {
                                if (value == null) {
                                  return 'Motivo é obrigatório';
                                }
                                return null;
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _observationController,
                        decoration: const InputDecoration(
                          labelText: 'Observações',
                          hintText: 'Informações adicionais (opcional)',
                          border: OutlineInputBorder(),
                        ),
                        maxLines: 3,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              // Botões
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _isLoading ? null : () => context.pop(),
                      child: const Text('Cancelar'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _submitMovement,
                      child: _isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('Registrar Movimentação'),
                    ),
                  ),
                ],
              ),
            ],
          ),
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
}