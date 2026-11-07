import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/address_entity.dart';
import '../viewmodels/address_viewmodel.dart';

class AddressForm extends ConsumerStatefulWidget {
  final AddressEntity? address;

  const AddressForm({super.key, this.address});

  bool get isEditing => address != null;

  @override
  ConsumerState<AddressForm> createState() => _AddressFormState();
}

class _AddressFormState extends ConsumerState<AddressForm> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _nameController;
  late final TextEditingController _phoneController;
  late final TextEditingController _address1Controller;
  late final TextEditingController _address2Controller;
  late final TextEditingController _cityController;
  late final TextEditingController _stateController;
  late final TextEditingController _postalCodeController;
  late final TextEditingController _countryController;

  @override
  void initState() {
    super.initState();

    final address = widget.address;

    _nameController = TextEditingController(text: address?.fullName ?? '');
    _phoneController = TextEditingController(text: address?.phone ?? '');
    _address1Controller = TextEditingController(
      text: address?.addressLine1 ?? '',
    );
    _address2Controller = TextEditingController(
      text: address?.addressLine2 ?? '',
    );
    _cityController = TextEditingController(text: address?.city ?? '');
    _stateController = TextEditingController(text: address?.state ?? '');
    _postalCodeController = TextEditingController(
      text: address?.postalCode ?? '',
    );
    _countryController = TextEditingController(
      text: address?.country ?? 'India',
    );

    _addressType = address?.addressType ?? 'home';
  }

  String _addressType = 'home';
  bool _isSaving = false;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _address1Controller.dispose();
    _address2Controller.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _postalCodeController.dispose();
    _countryController.dispose();
    super.dispose();
  }

  String? _requiredValidator(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'This field is required';
    }
    return null;
  }

  Future<void> _saveAddress() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      final viewModel = ref.read(addressViewModelProvider.notifier);

      if (widget.isEditing) {
        await viewModel.updateAddress(
          addressId: widget.address!.id,
          fullName: _nameController.text.trim(),
          phone: _phoneController.text.trim(),
          addressLine1: _address1Controller.text.trim(),
          addressLine2: _address2Controller.text.trim().isEmpty
              ? null
              : _address2Controller.text.trim(),
          city: _cityController.text.trim(),
          stateName: _stateController.text.trim(),
          postalCode: _postalCodeController.text.trim(),
          country: _countryController.text.trim(),
          addressType: _addressType,
        );
      } else {
        await viewModel.addAddress(
          fullName: _nameController.text.trim(),
          phone: _phoneController.text.trim(),
          addressLine1: _address1Controller.text.trim(),
          addressLine2: _address2Controller.text.trim().isEmpty
              ? null
              : _address2Controller.text.trim(),
          city: _cityController.text.trim(),
          stateName: _stateController.text.trim(),
          postalCode: _postalCodeController.text.trim(),
          country: _countryController.text.trim(),
          addressType: _addressType,
        );
      }

      if (!mounted) return;

      Navigator.of(context).pop();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            widget.isEditing
                ? 'Address updated successfully.'
                : 'Address added successfully.',
          ),
        ),
      );
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Unable to save address: $error')));
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  Widget _buildField({
    required TextEditingController controller,
    required String label,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        validator: validator ?? _requiredValidator,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildField(controller: _nameController, label: 'Full Name'),
            _buildField(
              controller: _phoneController,
              label: 'Phone Number',
              keyboardType: TextInputType.phone,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Phone number is required';
                }
                if (!RegExp(r'^\+?[0-9]{10,15}$').hasMatch(value.trim())) {
                  return 'Enter a valid phone number';
                }
                return null;
              },
            ),
            _buildField(
              controller: _address1Controller,
              label: 'Address Line 1',
            ),
            _buildField(
              controller: _address2Controller,
              label: 'Address Line 2 (Optional)',
              validator: (_) => null,
            ),
            _buildField(controller: _cityController, label: 'City'),
            _buildField(controller: _stateController, label: 'State'),
            _buildField(
              controller: _postalCodeController,
              label: 'Postal Code',
              keyboardType: TextInputType.number,
            ),
            _buildField(controller: _countryController, label: 'Country'),
            DropdownButtonFormField<String>(
              initialValue: _addressType,
              decoration: const InputDecoration(
                labelText: 'Address Type',
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(value: 'home', child: Text('Home')),
                DropdownMenuItem(value: 'work', child: Text('Work')),
                DropdownMenuItem(value: 'other', child: Text('Other')),
              ],
              onChanged: (value) {
                if (value != null) {
                  setState(() => _addressType = value);
                }
              },
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _isSaving ? null : _saveAddress,
                child: _isSaving
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(widget.isEditing ? 'Update Address' : 'Save Address'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
