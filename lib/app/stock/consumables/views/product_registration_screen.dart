import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/models/models.dart';
import '../../../../core/providers/providers.dart';

class ProductRegistrationScreen extends ConsumerStatefulWidget {
  final Product? product; // Para edição

  const ProductRegistrationScreen({super.key, this.product});

  @override
  ConsumerState<ProductRegistrationScreen> createState() => _ProductRegistrationScreenState();
}

class _ProductRegistrationScreenState extends ConsumerState<ProductRegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _minStockController = TextEditingController();
  final _maxStockController = TextEditingController();
  final _currentStockController = TextEditingController();
  final _locationController = TextEditingController();

  String? _selectedCategory;
  String? _selectedUnit;

  

  final List<String> _units = [
    'Unidade',
    'Kg',
    'L',
    'Pacote',
    'Caixa',
    'Metro',
    'Litro',
  ];

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.product != null) {
      _populateFields();
    }
  }

  void _populateFields() {
    final product = widget.product!;
    final categories = ref.read(categoriesProvider);
    _nameController.text = product.name;
    _descriptionController.text = product.description;
    _minStockController.text = product.minStock.toString();
    _maxStockController.text = product.maxStock.toString();
    _currentStockController.text = product.currentStock.toString();
    _locationController.text = product.location;
    _selectedCategory = categories.firstWhere(
      (cat) => cat.toLowerCase() == product.category.toLowerCase(),
      orElse: () => product.category, // Fallback if not found
    );
    _selectedUnit = product.unit;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _minStockController.dispose();
    _maxStockController.dispose();
    _currentStockController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  Future<void> _submitProduct() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final productService = ref.read(productServiceProvider);
      final now = DateTime.now();

      final product = Product(
        id: widget.product?.id,
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim(),
        category: _selectedCategory!,
        unit: _selectedUnit!,
        currentStock: int.parse(_currentStockController.text),
        minStock: int.parse(_minStockController.text),
        maxStock: int.parse(_maxStockController.text),
        location: _locationController.text.trim(),
        createdAt: widget.product?.createdAt ?? now,
        updatedAt: now,
      );

      if (widget.product == null) {
        // Criar novo produto
        await productService.createProduct(product);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Produto cadastrado com sucesso!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        // Atualizar produto existente
        final updatedProduct = product.copyWith(id: widget.product!.id);
        await productService.updateProduct(updatedProduct);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Produto atualizado com sucesso!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      }

      if (mounted) {
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao salvar produto: $e'),
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

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.product != null;
    final categories = ref.watch(categoriesProvider);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => context.pop(),
        ),
        title: Text(isEditing ? 'Editar Produto' : 'Cadastrar Produto'),
        backgroundColor: Colors.blue.shade700,
        foregroundColor: Colors.white,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Informações básicas
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Informações Básicas',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _nameController,
                        decoration: const InputDecoration(
                          labelText: 'Nome do Produto *',
                          hintText: 'Ex: Papel A4',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Nome é obrigatório';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _descriptionController,
                        decoration: const InputDecoration(
                          labelText: 'Descrição',
                          hintText: 'Descrição detalhada do produto',
                          border: OutlineInputBorder(),
                        ),
                        maxLines: 3,
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              value: _selectedCategory,
                              decoration: const InputDecoration(
                                labelText: 'Categoria *',
                                border: OutlineInputBorder(),
                              ),
                              items: categories.map((category) {
                                return DropdownMenuItem(
                                  value: category,
                                  child: Text(category),
                                );
                              }).toList(),
                              onChanged: (value) {
                                setState(() {
                                  _selectedCategory = value;
                                });
                              },
                              validator: (value) {
                                if (value == null) {
                                  return 'Categoria é obrigatória';
                                }
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              value: _selectedUnit,
                              decoration: const InputDecoration(
                                labelText: 'Unidade *',
                                border: OutlineInputBorder(),
                              ),
                              items: _units.map((unit) {
                                return DropdownMenuItem(
                                  value: unit,
                                  child: Text(unit),
                                );
                              }).toList(),
                              onChanged: (value) {
                                setState(() {
                                  _selectedUnit = value;
                                });
                              },
                              validator: (value) {
                                if (value == null) {
                                  return 'Unidade é obrigatória';
                                }
                                return null;
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
              // Controle de estoque
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Controle de Estoque',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _currentStockController,
                        decoration: const InputDecoration(
                          labelText: 'Estoque Atual *',
                          hintText: '0',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Estoque atual é obrigatório';
                          }
                          if (int.tryParse(value) == null) {
                            return 'Digite um número válido';
                          }
                          if (int.parse(value) < 0) {
                            return 'Estoque não pode ser negativo';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _minStockController,
                              decoration: const InputDecoration(
                                labelText: 'Estoque Mínimo *',
                                hintText: '0',
                                border: OutlineInputBorder(),
                              ),
                              keyboardType: TextInputType.number,
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Estoque mínimo é obrigatório';
                                }
                                if (int.tryParse(value) == null) {
                                  return 'Digite um número válido';
                                }
                                if (int.parse(value) < 0) {
                                  return 'Estoque não pode ser negativo';
                                }
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: TextFormField(
                              controller: _maxStockController,
                              decoration: const InputDecoration(
                                labelText: 'Estoque Máximo *',
                                hintText: '0',
                                border: OutlineInputBorder(),
                              ),
                              keyboardType: TextInputType.number,
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Estoque máximo é obrigatório';
                                }
                                if (int.tryParse(value) == null) {
                                  return 'Digite um número válido';
                                }
                                final maxStock = int.parse(value);
                                final minStock = int.tryParse(_minStockController.text) ?? 0;
                                if (maxStock <= minStock) {
                                  return 'Deve ser maior que o mínimo';
                                }
                                return null;
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
              // Localização
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Localização',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _locationController,
                        decoration: const InputDecoration(
                          labelText: 'Localização *',
                          hintText: 'Ex: Almoxarifado A - Prateleira 1',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Localização é obrigatória';
                          }
                          return null;
                        },
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
                  Visibility(
                    visible: ref.watch(isAdminProvider),
                    maintainSize: false,
                    maintainAnimation: false,
                    maintainState: false,
                    child: Expanded(
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _submitProduct,
                        child: _isLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : Text(isEditing ? 'Atualizar' : 'Cadastrar'),
                      ),
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
}