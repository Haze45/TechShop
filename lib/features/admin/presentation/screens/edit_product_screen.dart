import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../../products/domain/entities/product_entity.dart';
import '../../../products/domain/entities/product_image_entity.dart';
import '../providers/admin_product_creation_providers.dart';
import '../providers/admin_product_providers.dart';

class EditProductScreen extends ConsumerStatefulWidget {
  final ProductEntity product;

  const EditProductScreen({super.key, required this.product});

  @override
  ConsumerState<EditProductScreen> createState() => _EditProductScreenState();
}

class _EditProductScreenState extends ConsumerState<EditProductScreen> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _nameController;
  late final TextEditingController _skuController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _priceController;
  late final TextEditingController _comparePriceController;
  late final TextEditingController _stockController;
  late final TextEditingController _specificationsController;

  int? _categoryId;
  int? _brandId;

  late bool _isActive;
  late bool _isFeatured;

  bool _isSaving = false;

  final ImagePicker _imagePicker = ImagePicker();

  late List<ProductImageEntity> _existingImages;

  final List<XFile> _newImages = [];
  final List<Uint8List> _newImageBytes = [];

  @override
  void initState() {
    super.initState();

    final product = widget.product;

    _existingImages = List<ProductImageEntity>.from(widget.product.images);

    _nameController = TextEditingController(text: product.name);
    _skuController = TextEditingController(text: product.sku);
    _descriptionController = TextEditingController(
      text: product.description ?? '',
    );

    _priceController = TextEditingController(text: product.price.toString());

    _comparePriceController = TextEditingController(
      text: product.compareAtPrice?.toString() ?? '',
    );

    _stockController = TextEditingController(
      text: product.stockQuantity.toString(),
    );

    _specificationsController = TextEditingController(
      text: const JsonEncoder.withIndent('  ').convert(product.specifications),
    );

    _categoryId = product.categoryId;
    _brandId = product.brandId;

    _isActive = product.isActive;
    _isFeatured = product.isFeatured;
  }

  bool _isUploadingImages = false;
  final Set<String> _deletingImageIds = {};

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

  Future<void> _updateProduct() async {
    if (!_formKey.currentState!.validate()) return;

    if (_categoryId == null || _brandId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a category and brand.')),
      );
      return;
    }

    Map<String, dynamic> specifications;

    try {
      final decoded = jsonDecode(_specificationsController.text);

      if (decoded is! Map) {
        throw const FormatException('Specifications must be a JSON object.');
      }

      specifications = Map<String, dynamic>.from(decoded);
    } catch (error) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Invalid specifications: $error')));
      return;
    }

    final price = double.tryParse(_priceController.text.trim());

    final comparePriceText = _comparePriceController.text.trim();

    final comparePrice = comparePriceText.isEmpty
        ? null
        : double.tryParse(comparePriceText);

    final stockQuantity = int.tryParse(_stockController.text.trim());

    if (price == null || price <= 0) return;

    if (comparePriceText.isNotEmpty &&
        (comparePrice == null || comparePrice <= price)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Compare-at price must be greater than selling price.'),
        ),
      );
      return;
    }

    if (stockQuantity == null || stockQuantity < 0) return;

    setState(() => _isSaving = true);

    try {
      final oldProduct = widget.product;

      final updatedProduct = ProductEntity(
        id: oldProduct.id,
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
        stockQuantity: stockQuantity,
        specifications: specifications,
        isActive: _isActive,
        isFeatured: _isFeatured,
        createdAt: oldProduct.createdAt,
        updatedAt: DateTime.now().toUtc(),
        images: oldProduct.images,
      );

      await ref
          .read(adminProductRepositoryProvider)
          .updateProduct(updatedProduct);

      ref.invalidate(adminProductsProvider);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Product updated successfully.')),
      );

      Navigator.pop(context);
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update product: $error')),
      );
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final categoriesAsync = ref.watch(adminCategoriesProvider);
    final brandsAsync = ref.watch(adminBrandsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Edit Product')),
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
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Product name is required';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            TextFormField(
              controller: _skuController,
              decoration: const InputDecoration(
                labelText: 'SKU',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'SKU is required';
                }
                return null;
              },
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
              'Existing Product Images',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 12),

            if (_existingImages.isEmpty)
              const Text('No existing images')
            else
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: _existingImages.map((image) {
                  return Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          image.imageUrl,
                          width: 110,
                          height: 110,
                          fit: BoxFit.cover,
                          errorBuilder: (_, _, _) {
                            return Container(
                              width: 110,
                              height: 110,
                              color: Colors.grey.shade300,
                              child: const Icon(Icons.broken_image),
                            );
                          },
                        ),
                      ),
                      Positioned(
                        right: 0,
                        top: 0,
                        child: IconButton(
                          onPressed: _deletingImageIds.contains(image.id)
                              ? null
                              : () => _deleteExistingImage(image),

                          icon: _deletingImageIds.contains(image.id)
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Icon(Icons.delete, color: Colors.white),

                          style: IconButton.styleFrom(
                            backgroundColor: Colors.red,
                          ),
                        ),
                      ),
                    ],
                  );
                }).toList(),
              ),

            const SizedBox(height: 24),

            // Add new images
            const Text(
              'Add New Images',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 12),

            OutlinedButton.icon(
              onPressed: _pickImages,
              icon: const Icon(Icons.add_photo_alternate),
              label: const Text('Select Images'),
            ),

            const SizedBox(height: 12),

            if (_newImageBytes.isNotEmpty)
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: List.generate(_newImageBytes.length, (index) {
                  return Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.memory(
                          _newImageBytes[index],
                          width: 110,
                          height: 110,
                          fit: BoxFit.cover,
                        ),
                      ),
                      Positioned(
                        right: 0,
                        top: 0,
                        child: IconButton(
                          onPressed: () {
                            setState(() {
                              _newImages.removeAt(index);
                              _newImageBytes.removeAt(index);
                            });
                          },
                          icon: const Icon(Icons.close, color: Colors.white),
                          style: IconButton.styleFrom(
                            backgroundColor: Colors.red,
                          ),
                        ),
                      ),
                    ],
                  );
                }),
              ),

            if (_newImages.isNotEmpty) ...[
              const SizedBox(height: 12),
              ElevatedButton.icon(
                onPressed: _isUploadingImages ? null : _uploadNewImages,
                icon: const Icon(Icons.cloud_upload),
                label: Text(
                  _isUploadingImages
                      ? 'Uploading...'
                      : 'Upload ${_newImages.length} Images',
                ),
              ),
            ],

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
                  initialValue:
                      categories.any(
                        (category) =>
                            (category['id'] as num).toInt() == _categoryId,
                      )
                      ? _categoryId
                      : null,
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
                  initialValue:
                      brands.any(
                        (brand) => (brand['id'] as num).toInt() == _brandId,
                      )
                      ? _brandId
                      : null,
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
                final number = double.tryParse(value?.trim() ?? '');

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
                if (value == null || value.trim().isEmpty) {
                  return null;
                }

                final number = double.tryParse(value.trim());

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
                final number = int.tryParse(value?.trim() ?? '');

                if (number == null || number < 0) {
                  return 'Enter a valid non-negative quantity';
                }

                return null;
              },
            ),
            const SizedBox(height: 24),

            const Text(
              'Specifications (JSON)',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),

            TextFormField(
              controller: _specificationsController,
              maxLines: 8,
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
                onPressed: _isSaving ? null : _updateProduct,
                child: _isSaving
                    ? const CircularProgressIndicator()
                    : const Text('Update Product'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickImages() async {
    try {
      final images = await _imagePicker.pickMultiImage();

      if (images.isEmpty) return;

      final bytes = <Uint8List>[];

      for (final image in images) {
        bytes.add(await image.readAsBytes());
      }

      if (!mounted) return;

      setState(() {
        _newImages.addAll(images);
        _newImageBytes.addAll(bytes);
      });
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Failed to select images: $e')));
    }
  }

  Future<void> _uploadNewImages() async {
    if (_newImages.isEmpty || _isUploadingImages) return;

    setState(() => _isUploadingImages = true);

    try {
      await ref
          .read(adminProductRepositoryProvider)
          .uploadProductImages(
            productId: widget.product.id,
            imageBytes: _newImageBytes,
            fileNames: _newImages.map((image) => image.name).toList(),
          );

      if (!mounted) return;

      setState(() {
        _newImages.clear();
        _newImageBytes.clear();
      });

      ref.invalidate(adminProductsProvider);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Images uploaded successfully')),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Image upload failed: $e')));
    } finally {
      if (mounted) {
        setState(() => _isUploadingImages = false);
      }
    }
  }

  Future<void> _deleteExistingImage(ProductImageEntity image) async {
    if (_deletingImageIds.contains(image.id)) return;

    setState(() {
      _deletingImageIds.add(image.id);
    });

    try {
      await ref.read(adminProductRepositoryProvider).deleteProductImage(image);

      if (!mounted) return;

      setState(() {
        _existingImages.removeWhere((item) => item.id == image.id);
      });

      ref.invalidate(adminProductsProvider);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Image deleted successfully')),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Failed to delete image: $e')));
    } finally {
      if (mounted) {
        setState(() {
          _deletingImageIds.remove(image.id);
        });
      }
    }
  }
}
