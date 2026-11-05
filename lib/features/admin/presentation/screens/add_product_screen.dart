import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../providers/admin_product_creation_providers.dart';
import '../providers/admin_product_providers.dart';

class AddProductScreen extends ConsumerStatefulWidget {
  const AddProductScreen({super.key});

  @override
  ConsumerState<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends ConsumerState<AddProductScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _skuController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _comparePriceController = TextEditingController();
  final _stockController = TextEditingController();
  final _specificationsController = TextEditingController(
    text: '{\n  "RAM": "8GB",\n  "Storage": "128GB"\n}',
  );

  int? _categoryId;
  int? _brandId;

  bool _isActive = true;
  bool _isFeatured = false;
  bool _isSaving = false;
  final ImagePicker _imagePicker = ImagePicker();

  final List<XFile> _selectedImages = [];
  final List<Uint8List> _imageBytes = [];

  @override
  void dispose() {
    _nameController.dispose();
    _skuController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _comparePriceController.dispose();
    _stockController.dispose();
    _specificationsController.dispose();
    super.dispose();
  }

  String _generateSlug(String value) {
    return value
        .toLowerCase()
        .trim()
        .replaceAll(RegExp(r'[^a-z0-9]+'), '-')
        .replaceAll(RegExp(r'^-+|-+$'), '');
  }

  String? _validateRequired(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'This field is required';
    }
    return null;
  }

  Future<void> _saveProduct() async {
    if (!_formKey.currentState!.validate()) return;

    if (_categoryId == null || _brandId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a category and brand.')),
      );
      return;
    }

    Map<String, dynamic> specifications;

    try {
      specifications = Map<String, dynamic>.from(
        jsonDecode(_specificationsController.text),
      );
    } catch (_) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Specifications must be valid JSON.')),
      );
      return;
    }

    final price = double.parse(_priceController.text.trim());
    final comparePriceText = _comparePriceController.text.trim();
    final comparePrice = comparePriceText.isEmpty
        ? null
        : double.parse(comparePriceText);

    if (comparePrice != null && comparePrice <= price) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Compare price must be greater than selling price.'),
        ),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      final repository = ref.read(adminProductCreationRepositoryProvider);

      final productId = await repository.createProduct(
        categoryId: _categoryId!,
        brandId: _brandId!,
        name: _nameController.text.trim(),
        slug: _generateSlug(_nameController.text),
        sku: _skuController.text.trim(),
        description: _descriptionController.text.trim().isEmpty
            ? null
            : _descriptionController.text.trim(),
        price: price,
        compareAtPrice: comparePrice,
        stockQuantity: int.parse(_stockController.text.trim()),
        specifications: specifications,
        isActive: _isActive,
        isFeatured: _isFeatured,
      );

      if (_imageBytes.isNotEmpty) {
        await repository.uploadProductImages(
          productId: productId,
          imageBytes: _imageBytes,
          fileNames: _selectedImages.map((image) => image.name).toList(),
        );
      }

      ref.invalidate(adminProductsProvider);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Product created successfully.')),
      );

      Navigator.pop(context);
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to create product: $error')),
      );
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  Future<void> _pickImages() async {
    try {
      final images = await _imagePicker.pickMultiImage(imageQuality: 85);

      if (images.isEmpty || !mounted) return;

      final bytes = await Future.wait(
        images.map((image) => image.readAsBytes()),
      );

      if (!mounted) return;

      setState(() {
        _selectedImages.addAll(images);
        _imageBytes.addAll(bytes);
      });
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Unable to select images: $error')),
      );
    }
  }

  void _removeImage(int index) {
    setState(() {
      _selectedImages.removeAt(index);
      _imageBytes.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    final categoriesAsync = ref.watch(adminCategoriesProvider);
    final brandsAsync = ref.watch(adminBrandsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Add Product')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const Text(
              'Basic Information',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Product Name',
                border: OutlineInputBorder(),
              ),
              validator: _validateRequired,
            ),
            const SizedBox(height: 16),

            TextFormField(
              controller: _skuController,
              decoration: const InputDecoration(
                labelText: 'SKU',
                border: OutlineInputBorder(),
              ),
              validator: _validateRequired,
            ),
            const SizedBox(height: 16),

            TextFormField(
              controller: _descriptionController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Description',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),

            const Text(
              'Category and Brand',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            categoriesAsync.when(
              loading: () => const LinearProgressIndicator(),
              error: (error, _) => Text('Categories error: $error'),
              data: (categories) {
                return DropdownButtonFormField<int>(
                  initialValue: _categoryId,
                  decoration: const InputDecoration(
                    labelText: 'Category',
                    border: OutlineInputBorder(),
                  ),
                  items: categories.map((category) {
                    return DropdownMenuItem<int>(
                      value: (category['id'] as num).toInt(),
                      child: Text(category['name'].toString()),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() => _categoryId = value);
                  },
                  validator: (value) =>
                      value == null ? 'Select a category' : null,
                );
              },
            ),
            const SizedBox(height: 16),

            brandsAsync.when(
              loading: () => const LinearProgressIndicator(),
              error: (error, _) => Text('Brands error: $error'),
              data: (brands) {
                return DropdownButtonFormField<int>(
                  initialValue: _brandId,
                  decoration: const InputDecoration(
                    labelText: 'Brand',
                    border: OutlineInputBorder(),
                  ),
                  items: brands.map((brand) {
                    return DropdownMenuItem<int>(
                      value: (brand['id'] as num).toInt(),
                      child: Text(brand['name'].toString()),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() => _brandId = value);
                  },
                  validator: (value) => value == null ? 'Select a brand' : null,
                );
              },
            ),
            const SizedBox(height: 24),

            const Text(
              'Pricing and Inventory',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            TextFormField(
              controller: _priceController,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: const InputDecoration(
                labelText: 'Selling Price (₹)',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Enter selling price';
                }
                final number = double.tryParse(value);
                if (number == null || number <= 0) {
                  return 'Enter a valid positive price';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            TextFormField(
              controller: _comparePriceController,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: const InputDecoration(
                labelText: 'Compare-at Price (Optional)',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) return null;
                final number = double.tryParse(value);
                if (number == null || number <= 0) {
                  return 'Enter a valid positive price';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            TextFormField(
              controller: _stockController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Stock Quantity',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Enter stock quantity';
                }
                final number = int.tryParse(value);
                if (number == null || number < 0) {
                  return 'Enter a valid non-negative quantity';
                }
                return null;
              },
            ),
            const SizedBox(height: 24),

            const Text(
              'Product Images',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 12),

            OutlinedButton.icon(
              onPressed: _pickImages,
              icon: const Icon(Icons.add_photo_alternate),
              label: const Text('Select Product Images'),
            ),

            const SizedBox(height: 12),

            if (_selectedImages.isNotEmpty)
              SizedBox(
                height: 115,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _selectedImages.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 12),
                      child: Stack(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.memory(
                              // Display the selected image bytes.
                              // See the note below about loading bytes.
                              _imageBytes[index],
                              width: 100,
                              height: 100,
                              fit: BoxFit.cover,
                            ),
                          ),
                          Positioned(
                            right: 0,
                            top: 0,
                            child: IconButton(
                              onPressed: () => _removeImage(index),
                              icon: const Icon(Icons.cancel, color: Colors.red),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),

            const Text(
              'Specifications (JSON)',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),

            TextFormField(
              controller: _specificationsController,
              maxLines: 7,
              decoration: const InputDecoration(
                hintText: '{"RAM": "8GB", "Storage": "128GB"}',
                border: OutlineInputBorder(),
                alignLabelWithHint: true,
              ),
            ),
            const SizedBox(height: 24),

            SwitchListTile(
              title: const Text('Active Product'),
              subtitle: const Text('Make this product visible to customers'),
              value: _isActive,
              onChanged: (value) {
                setState(() => _isActive = value);
              },
            ),

            SwitchListTile(
              title: const Text('Featured Product'),
              subtitle: const Text('Display in featured products'),
              value: _isFeatured,
              onChanged: (value) {
                setState(() => _isFeatured = value);
              },
            ),

            const SizedBox(height: 24),

            SizedBox(
              height: 50,
              child: ElevatedButton(
                onPressed: _isSaving ? null : _saveProduct,
                child: _isSaving
                    ? const CircularProgressIndicator()
                    : const Text('Create Product'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
