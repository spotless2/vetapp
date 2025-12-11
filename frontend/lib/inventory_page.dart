import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';
import 'config/api_config.dart';

class InventoryPage extends StatefulWidget {
  final Map<String, dynamic> user;

  InventoryPage({required this.user});

  @override
  _InventoryPageState createState() => _InventoryPageState();
}

class _InventoryPageState extends State<InventoryPage> {
  List<dynamic> _products = [];
  List<dynamic> _filteredProducts = [];
  bool _isLoading = false;
  String _selectedCategory = 'Toate';
  String _searchQuery = '';
  bool _showLowStock = false;
  bool _showExpired = false;
  Set<int> _selectedProductIds = {};
  bool _isMultiSelectMode = false;

  final List<String> _categories = [
    'Toate',
    'Medicamente',
    'Materiale Chirurgicale',
    'Consumabile',
    'Echipamente',
    'Alimente',
    'Suplimente',
    'Igienă',
    'Altele'
  ];

  final List<String> _units = ['buc', 'cutie', 'flacon', 'kg', 'g', 'l', 'ml', 'pachet', 'set'];

  Map<String, dynamic> _stats = {
    'totalProducts': 0,
    'activeProducts': 0,
    'totalValue': '0.00',
    'lowStockCount': 0,
    'expiredCount': 0
  };

  @override
  void initState() {
    super.initState();
    _loadProducts();
    _loadStats();
  }

  Future<void> _loadProducts() async {
    setState(() => _isLoading = true);

    try {
      print('📦 Loading products for cabinet: ${widget.user['cabinetId']}');
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/products/cabinet/${widget.user['cabinetId']}'),
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final products = json.decode(response.body);
        setState(() {
          _products = products;
          _applyFilters();
        });
        print('✅ Loaded ${products.length} products');
      } else {
        throw Exception('Failed to load products');
      }
    } catch (e) {
      print('❌ Error loading products: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Eroare la încărcarea produselor: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loadStats() async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/products/cabinet/${widget.user['cabinetId']}/stats'),
      );

      if (response.statusCode == 200) {
        setState(() {
          _stats = json.decode(response.body);
        });
      }
    } catch (e) {
      print('❌ Error loading stats: $e');
    }
  }

  void _applyFilters() {
    setState(() {
      _filteredProducts = _products.where((product) {
        // Category filter
        if (_selectedCategory != 'Toate' && product['category'] != _selectedCategory) {
          return false;
        }

        // Search filter
        if (_searchQuery.isNotEmpty) {
          final query = _searchQuery.toLowerCase();
          final name = (product['name'] ?? '').toString().toLowerCase();
          final manufacturer = (product['manufacturer'] ?? '').toString().toLowerCase();
          final sku = (product['sku'] ?? '').toString().toLowerCase();
          
          if (!name.contains(query) && !manufacturer.contains(query) && !sku.contains(query)) {
            return false;
          }
        }

        // Low stock filter
        if (_showLowStock) {
          if (product['quantity'] > product['minQuantity']) {
            return false;
          }
        }

        // Expired filter
        if (_showExpired) {
          if (product['expiryDate'] == null) return false;
          final expiryDate = DateTime.parse(product['expiryDate']);
          if (expiryDate.isAfter(DateTime.now())) {
            return false;
          }
        }

        return true;
      }).toList();
    });
  }

  void _toggleMultiSelect() {
    setState(() {
      _isMultiSelectMode = !_isMultiSelectMode;
      if (!_isMultiSelectMode) {
        _selectedProductIds.clear();
      }
    });
  }

  void _toggleProductSelection(int productId) {
    setState(() {
      if (_selectedProductIds.contains(productId)) {
        _selectedProductIds.remove(productId);
      } else {
        _selectedProductIds.add(productId);
      }
    });
  }

  void _selectAll() {
    setState(() {
      if (_selectedProductIds.length == _filteredProducts.length) {
        _selectedProductIds.clear();
      } else {
        _selectedProductIds = _filteredProducts.map((p) => p['id'] as int).toSet();
      }
    });
  }

  Future<void> _bulkDelete() async {
    if (_selectedProductIds.isEmpty) return;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmare Ștergere'),
        content: Text('Sigur doriți să ștergeți ${_selectedProductIds.length} produse?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Anulează'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Șterge'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      print('🗑️ Bulk deleting products: $_selectedProductIds');
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/products/bulk-delete'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'ids': _selectedProductIds.toList()}),
      );

      print('Response: ${response.statusCode} - ${response.body}');

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${_selectedProductIds.length} produse șterse cu succes')),
        );
        _selectedProductIds.clear();
        _isMultiSelectMode = false;
        await _loadProducts();
        await _loadStats();
      } else {
        throw Exception('Failed to delete products');
      }
    } catch (e) {
      print('❌ Error deleting products: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Eroare la ștergerea produselor: $e')),
      );
    }
  }

  Future<void> _deleteProduct(int productId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmare Ștergere'),
        content: const Text('Sigur doriți să ștergeți acest produs?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Anulează'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Șterge'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      print('🗑️ Deleting product: $productId');
      final response = await http.delete(
        Uri.parse('${ApiConfig.baseUrl}/products/$productId'),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Produs șters cu succes')),
        );
        await _loadProducts();
        await _loadStats();
      } else {
        throw Exception('Failed to delete product');
      }
    } catch (e) {
      print('❌ Error deleting product: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Eroare la ștergerea produsului: $e')),
      );
    }
  }

  void _showProductDialog({Map<String, dynamic>? product}) {
    final isEdit = product != null;
    final nameController = TextEditingController(text: product?['name'] ?? '');
    final descriptionController = TextEditingController(text: product?['description'] ?? '');
    final skuController = TextEditingController(text: product?['sku'] ?? '');
    final barcodeController = TextEditingController(text: product?['barcode'] ?? '');
    final manufacturerController = TextEditingController(text: product?['manufacturer'] ?? '');
    final supplierController = TextEditingController(text: product?['supplier'] ?? '');
    final unitPriceController = TextEditingController(
      text: product?['unitPrice']?.toString() ?? '0',
    );
    final vatRateController = TextEditingController(
      text: product?['vatRate']?.toString() ?? '19',
    );
    final quantityController = TextEditingController(
      text: product?['quantity']?.toString() ?? '0',
    );
    final minQuantityController = TextEditingController(
      text: product?['minQuantity']?.toString() ?? '0',
    );
    final maxQuantityController = TextEditingController(
      text: product?['maxQuantity']?.toString() ?? '',
    );
    final batchNumberController = TextEditingController(text: product?['batchNumber'] ?? '');
    final locationController = TextEditingController(text: product?['location'] ?? '');
    final notesController = TextEditingController(text: product?['notes'] ?? '');

    String selectedCategory = product?['category'] ?? 'Consumabile';
    String selectedUnit = product?['unit'] ?? 'buc';
    DateTime? expiryDate = product?['expiryDate'] != null
        ? DateTime.parse(product!['expiryDate'])
        : null;
    bool isActive = product?['isActive'] ?? true;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(isEdit ? 'Editare Produs' : 'Adaugă Produs Nou'),
          content: SingleChildScrollView(
            child: SizedBox(
              width: 600,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Basic Info
                  const Text(
                    'Informații de Bază',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      labelText: 'Nume Produs *',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: selectedCategory,
                          decoration: const InputDecoration(
                            labelText: 'Categorie *',
                            border: OutlineInputBorder(),
                          ),
                          items: _categories.where((c) => c != 'Toate').map((category) {
                            return DropdownMenuItem(value: category, child: Text(category));
                          }).toList(),
                          onChanged: (value) {
                            setDialogState(() => selectedCategory = value!);
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: selectedUnit,
                          decoration: const InputDecoration(
                            labelText: 'Unitate Măsură *',
                            border: OutlineInputBorder(),
                          ),
                          items: _units.map((unit) {
                            return DropdownMenuItem(value: unit, child: Text(unit));
                          }).toList(),
                          onChanged: (value) {
                            setDialogState(() => selectedUnit = value!);
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: descriptionController,
                    decoration: const InputDecoration(
                      labelText: 'Descriere',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 2,
                  ),

                  const SizedBox(height: 24),
                  const Text(
                    'Identificare',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: skuController,
                          decoration: const InputDecoration(
                            labelText: 'SKU',
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          controller: barcodeController,
                          decoration: const InputDecoration(
                            labelText: 'Cod de Bare',
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: manufacturerController,
                          decoration: const InputDecoration(
                            labelText: 'Producător',
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          controller: supplierController,
                          decoration: const InputDecoration(
                            labelText: 'Furnizor',
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),
                  const Text(
                    'Prețuri',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: unitPriceController,
                          decoration: const InputDecoration(
                            labelText: 'Preț Unitar (fără TVA) *',
                            border: OutlineInputBorder(),
                            suffixText: 'RON',
                          ),
                          keyboardType: TextInputType.number,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          controller: vatRateController,
                          decoration: const InputDecoration(
                            labelText: 'Cotă TVA *',
                            border: OutlineInputBorder(),
                            suffixText: '%',
                          ),
                          keyboardType: TextInputType.number,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),
                  const Text(
                    'Stoc',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: quantityController,
                          decoration: const InputDecoration(
                            labelText: 'Cantitate Curentă *',
                            border: OutlineInputBorder(),
                          ),
                          keyboardType: TextInputType.number,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          controller: minQuantityController,
                          decoration: const InputDecoration(
                            labelText: 'Stoc Minim *',
                            border: OutlineInputBorder(),
                          ),
                          keyboardType: TextInputType.number,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          controller: maxQuantityController,
                          decoration: const InputDecoration(
                            labelText: 'Stoc Maxim',
                            border: OutlineInputBorder(),
                          ),
                          keyboardType: TextInputType.number,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),
                  const Text(
                    'Detalii Suplimentare',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: batchNumberController,
                          decoration: const InputDecoration(
                            labelText: 'Număr Lot',
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          controller: locationController,
                          decoration: const InputDecoration(
                            labelText: 'Locație',
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Data Expirării'),
                    subtitle: Text(
                      expiryDate != null
                          ? DateFormat('dd MMM yyyy').format(expiryDate!)
                          : 'Nu este setată',
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (expiryDate != null)
                          IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              setDialogState(() => expiryDate = null);
                            },
                          ),
                        IconButton(
                          icon: const Icon(Icons.calendar_today),
                          onPressed: () async {
                            final date = await showDatePicker(
                              context: context,
                              initialDate: expiryDate ?? DateTime.now(),
                              firstDate: DateTime.now(),
                              lastDate: DateTime.now().add(const Duration(days: 3650)),
                            );
                            if (date != null) {
                              setDialogState(() => expiryDate = date);
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: notesController,
                    decoration: const InputDecoration(
                      labelText: 'Notițe',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 2,
                  ),
                  const SizedBox(height: 12),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Activ'),
                    value: isActive,
                    onChanged: (value) {
                      setDialogState(() => isActive = value);
                    },
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Anulează'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (nameController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Numele produsului este obligatoriu')),
                  );
                  return;
                }

                final productData = {
                  'name': nameController.text,
                  'category': selectedCategory,
                  'description': descriptionController.text,
                  'sku': skuController.text.isEmpty ? null : skuController.text,
                  'barcode': barcodeController.text.isEmpty ? null : barcodeController.text,
                  'manufacturer': manufacturerController.text.isEmpty ? null : manufacturerController.text,
                  'supplier': supplierController.text.isEmpty ? null : supplierController.text,
                  'unitPrice': double.tryParse(unitPriceController.text) ?? 0.0,
                  'vatRate': double.tryParse(vatRateController.text) ?? 19.0,
                  'quantity': int.tryParse(quantityController.text) ?? 0,
                  'minQuantity': int.tryParse(minQuantityController.text) ?? 0,
                  'maxQuantity': maxQuantityController.text.isEmpty ? null : int.tryParse(maxQuantityController.text),
                  'unit': selectedUnit,
                  'expiryDate': expiryDate?.toIso8601String(),
                  'batchNumber': batchNumberController.text.isEmpty ? null : batchNumberController.text,
                  'location': locationController.text.isEmpty ? null : locationController.text,
                  'notes': notesController.text.isEmpty ? null : notesController.text,
                  'isActive': isActive,
                  'cabinetId': widget.user['cabinetId'],
                  'createdBy': widget.user['id'],
                  'updatedBy': widget.user['id'],
                };

                try {
                  print('${isEdit ? '🔄 Updating' : '📝 Creating'} product: $productData');
                  final response = isEdit
                      ? await http.put(
                          Uri.parse('${ApiConfig.baseUrl}/products/${product['id']}'),
                          headers: {'Content-Type': 'application/json'},
                          body: json.encode(productData),
                        )
                      : await http.post(
                          Uri.parse('${ApiConfig.baseUrl}/products'),
                          headers: {'Content-Type': 'application/json'},
                          body: json.encode(productData),
                        );

                  print('Response: ${response.statusCode} - ${response.body}');

                  if (response.statusCode == 200 || response.statusCode == 201) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(isEdit ? 'Produs actualizat cu succes' : 'Produs adăugat cu succes')),
                    );
                    await _loadProducts();
                    await _loadStats();
                  } else {
                    throw Exception('Failed to save product');
                  }
                } catch (e) {
                  print('❌ Error saving product: $e');
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Eroare la salvarea produsului: $e')),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00796B),
              ),
              child: Text(isEdit ? 'Actualizează' : 'Adaugă'),
            ),
          ],
        ),
      ),
    );
  }

  void _showQuickQuantityDialog(Map<String, dynamic> product) {
    final quantityController = TextEditingController();
    String operation = 'add';

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text('Modifică Stoc - ${product['name']}'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Stoc curent: ${product['quantity']} ${product['unit']}',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              SegmentedButton<String>(
                segments: const [
                  ButtonSegment(value: 'add', label: Text('Adaugă'), icon: Icon(Icons.add)),
                  ButtonSegment(value: 'subtract', label: Text('Scade'), icon: Icon(Icons.remove)),
                  ButtonSegment(value: 'set', label: Text('Setează'), icon: Icon(Icons.edit)),
                ],
                selected: {operation},
                onSelectionChanged: (Set<String> newSelection) {
                  setDialogState(() => operation = newSelection.first);
                },
              ),
              const SizedBox(height: 20),
              TextField(
                controller: quantityController,
                decoration: InputDecoration(
                  labelText: operation == 'set' ? 'Cantitate nouă' : 'Cantitate',
                  border: const OutlineInputBorder(),
                  suffixText: product['unit'],
                ),
                keyboardType: TextInputType.number,
                autofocus: true,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Anulează'),
            ),
            ElevatedButton(
              onPressed: () async {
                final quantity = int.tryParse(quantityController.text);
                if (quantity == null || quantity < 0) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Introduceți o cantitate validă')),
                  );
                  return;
                }

                try {
                  print('➕ Updating quantity for product ${product['id']}: $operation $quantity');
                  final response = await http.put(
                    Uri.parse('${ApiConfig.baseUrl}/products/${product['id']}/quantity'),
                    headers: {'Content-Type': 'application/json'},
                    body: json.encode({
                      'quantity': quantity,
                      'operation': operation,
                    }),
                  );

                  print('Response: ${response.statusCode} - ${response.body}');

                  if (response.statusCode == 200) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Stoc actualizat cu succes')),
                    );
                    await _loadProducts();
                    await _loadStats();
                  } else {
                    throw Exception('Failed to update quantity');
                  }
                } catch (e) {
                  print('❌ Error updating quantity: $e');
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Eroare la actualizarea stocului: $e')),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00796B),
              ),
              child: const Text('Salvează'),
            ),
          ],
        ),
      ),
    );
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'Medicamente':
        return Colors.red.shade400;
      case 'Materiale Chirurgicale':
        return Colors.blue.shade400;
      case 'Consumabile':
        return Colors.green.shade400;
      case 'Echipamente':
        return Colors.orange.shade400;
      case 'Alimente':
        return Colors.brown.shade400;
      case 'Suplimente':
        return Colors.purple.shade400;
      case 'Igienă':
        return Colors.cyan.shade400;
      default:
        return Colors.grey.shade400;
    }
  }

  Widget _buildStatsCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildStatItem(
              icon: Icons.inventory_2,
              label: 'Total Produse',
              value: _stats['totalProducts'].toString(),
              color: const Color(0xFF00796B),
            ),
            _buildStatItem(
              icon: Icons.check_circle,
              label: 'Active',
              value: _stats['activeProducts'].toString(),
              color: Colors.green,
            ),
            _buildStatItem(
              icon: Icons.attach_money,
              label: 'Valoare Totală',
              value: '${_stats['totalValue']} RON',
              color: Colors.blue,
            ),
            _buildStatItem(
              icon: Icons.warning,
              label: 'Stoc Mic',
              value: _stats['lowStockCount'].toString(),
              color: Colors.orange,
            ),
            _buildStatItem(
              icon: Icons.error,
              label: 'Expirate',
              value: _stats['expiredCount'].toString(),
              color: Colors.red,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Column(
      children: [
        Icon(icon, size: 32, color: color),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }

  Widget _buildFilterBar() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: TextField(
                    decoration: InputDecoration(
                      labelText: 'Căutare',
                      hintText: 'Nume, producător, SKU...',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                    onChanged: (value) {
                      setState(() {
                        _searchQuery = value;
                        _applyFilters();
                      });
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _selectedCategory,
                    decoration: InputDecoration(
                      labelText: 'Categorie',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                    items: _categories.map((category) {
                      return DropdownMenuItem(value: category, child: Text(category));
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedCategory = value!;
                        _applyFilters();
                      });
                    },
                  ),
                ),
                const SizedBox(width: 16),
                FilterChip(
                  label: const Text('Stoc Mic'),
                  selected: _showLowStock,
                  avatar: Icon(
                    Icons.warning,
                    size: 18,
                    color: _showLowStock ? Colors.white : Colors.orange,
                  ),
                  onSelected: (value) {
                    setState(() {
                      _showLowStock = value;
                      _applyFilters();
                    });
                  },
                ),
                const SizedBox(width: 8),
                FilterChip(
                  label: const Text('Expirate'),
                  selected: _showExpired,
                  avatar: Icon(
                    Icons.error,
                    size: 18,
                    color: _showExpired ? Colors.white : Colors.red,
                  ),
                  onSelected: (value) {
                    setState(() {
                      _showExpired = value;
                      _applyFilters();
                    });
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductCard(Map<String, dynamic> product) {
    final isLowStock = product['quantity'] <= product['minQuantity'];
    final isExpired = product['expiryDate'] != null &&
        DateTime.parse(product['expiryDate']).isBefore(DateTime.now());
    final isSelected = _selectedProductIds.contains(product['id']);

    return Card(
      elevation: isSelected ? 4 : 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: isSelected
            ? const BorderSide(color: Color(0xFF00796B), width: 2)
            : BorderSide.none,
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: _isMultiSelectMode
            ? () => _toggleProductSelection(product['id'])
            : () => _showProductDialog(product: product),
        onLongPress: () {
          if (!_isMultiSelectMode) {
            setState(() {
              _isMultiSelectMode = true;
              _selectedProductIds.add(product['id']);
            });
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (_isMultiSelectMode)
                Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: Checkbox(
                    value: isSelected,
                    onChanged: (_) => _toggleProductSelection(product['id']),
                  ),
                ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: _getCategoryColor(product['category']),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            product['category'],
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        if (isLowStock)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.orange,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.warning, color: Colors.white, size: 12),
                                SizedBox(width: 4),
                                Text(
                                  'Stoc Mic',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        if (isExpired)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.red,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.error, color: Colors.white, size: 12),
                                SizedBox(width: 4),
                                Text(
                                  'Expirat',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        const Spacer(),
                        if (!product['isActive'])
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.grey,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Text(
                              'Inactiv',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      product['name'],
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (product['manufacturer'] != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        'Producător: ${product['manufacturer']}',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                    if (product['sku'] != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        'SKU: ${product['sku']}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade500,
                        ),
                      ),
                    ],
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        _buildInfoChip(
                          icon: Icons.inventory,
                          label: 'Stoc: ${product['quantity']} ${product['unit']}',
                          color: isLowStock ? Colors.orange : Colors.green,
                        ),
                        const SizedBox(width: 8),
                        _buildInfoChip(
                          icon: Icons.attach_money,
                          label: '${product['unitPrice']} RON',
                          color: Colors.blue,
                        ),
                        const SizedBox(width: 8),
                        _buildInfoChip(
                          icon: Icons.receipt,
                          label: '${product['priceWithVAT']} RON (cu TVA)',
                          color: Colors.purple,
                        ),
                      ],
                    ),
                    if (product['expiryDate'] != null) ...[
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(
                            Icons.calendar_today,
                            size: 14,
                            color: isExpired ? Colors.red : Colors.grey.shade600,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Expiră: ${DateFormat('dd MMM yyyy').format(DateTime.parse(product['expiryDate']))}',
                            style: TextStyle(
                              fontSize: 12,
                              color: isExpired ? Colors.red : Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              if (!_isMultiSelectMode)
                Column(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.add_circle_outline),
                      color: const Color(0xFF00796B),
                      onPressed: () => _showQuickQuantityDialog(product),
                      tooltip: 'Modifică stoc rapid',
                    ),
                    IconButton(
                      icon: const Icon(Icons.edit),
                      color: Colors.blue,
                      onPressed: () => _showProductDialog(product: product),
                      tooltip: 'Editează',
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete),
                      color: Colors.red,
                      onPressed: () => _deleteProduct(product['id']),
                      tooltip: 'Șterge',
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoChip({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.inventory_2_rounded, size: 26),
            const SizedBox(width: 10),
            const Text(
              'Inventar',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFFE64A19),
        elevation: 2,
        shadowColor: Colors.black.withOpacity(0.3),
        actions: [
          if (_isMultiSelectMode) ...[
            IconButton(
              icon: Icon(
                _selectedProductIds.length == _filteredProducts.length
                    ? Icons.deselect
                    : Icons.select_all,
              ),
              onPressed: _selectAll,
              tooltip: _selectedProductIds.length == _filteredProducts.length
                  ? 'Deselectează tot'
                  : 'Selectează tot',
            ),
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: _selectedProductIds.isEmpty ? null : _bulkDelete,
              tooltip: 'Șterge selecționate',
            ),
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: _toggleMultiSelect,
              tooltip: 'Anulează selecția',
            ),
          ] else ...[
            IconButton(
              icon: const Icon(Icons.checklist),
              onPressed: _toggleMultiSelect,
              tooltip: 'Mod selecție multiplă',
            ),
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () {
                _loadProducts();
                _loadStats();
              },
              tooltip: 'Reîmprospătează',
            ),
          ],
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildStatsCard(),
                  const SizedBox(height: 24),
                  _buildFilterBar(),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${_filteredProducts.length} produse',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey.shade700,
                        ),
                      ),
                      if (_isMultiSelectMode && _selectedProductIds.isNotEmpty)
                        Text(
                          '${_selectedProductIds.length} selectate',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF00796B),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  if (_filteredProducts.isEmpty)
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.all(48),
                        child: Column(
                          children: [
                            Icon(
                              Icons.inventory_2_outlined,
                              size: 80,
                              color: Colors.grey.shade400,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Nu există produse',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  else
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _filteredProducts.length,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: _buildProductCard(_filteredProducts[index]),
                        );
                      },
                    ),
                ],
              ),
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showProductDialog(),
        backgroundColor: const Color(0xFF00796B),
        icon: const Icon(Icons.add),
        label: const Text('Adaugă Produs'),
      ),
    );
  }
}
