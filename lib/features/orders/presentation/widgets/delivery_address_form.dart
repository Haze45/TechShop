import 'package:flutter/material.dart';

class DeliveryAddressForm extends StatelessWidget {
  final TextEditingController nameController;
  final TextEditingController phoneController;
  final TextEditingController addressController;
  final TextEditingController landmarkController;
  final TextEditingController cityController;
  final TextEditingController stateController;
  final TextEditingController postalCodeController;

  const DeliveryAddressForm({
    super.key,
    required this.nameController,
    required this.phoneController,
    required this.addressController,
    required this.landmarkController,
    required this.cityController,
    required this.stateController,
    required this.postalCodeController,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Delivery Address', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 16),

        _buildField(
          controller: nameController,
          label: 'Full Name',
          icon: Icons.person_outline,
        ),

        _buildField(
          controller: phoneController,
          label: 'Phone Number',
          icon: Icons.phone_outlined,
          keyboardType: TextInputType.phone,
        ),

        _buildField(
          controller: addressController,
          label: 'House No. / Street Address',
          icon: Icons.home_outlined,
        ),

        _buildField(
          controller: landmarkController,
          label: 'Landmark (Optional)',
          icon: Icons.location_on_outlined,
          required: false,
        ),

        Row(
          children: [
            Expanded(
              child: _buildField(
                controller: cityController,
                label: 'City',
                icon: Icons.location_city,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildField(
                controller: stateController,
                label: 'State',
                icon: Icons.map_outlined,
              ),
            ),
          ],
        ),

        _buildField(
          controller: postalCodeController,
          label: 'PIN Code',
          icon: Icons.markunread_mailbox_outlined,
          keyboardType: TextInputType.number,
        ),
      ],
    );
  }

  Widget _buildField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    bool required = true,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        textCapitalization: TextCapitalization.words,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon),
          border: const OutlineInputBorder(),
        ),
        validator: (value) {
          if (!required) return null;

          if (value == null || value.trim().isEmpty) {
            return 'Please enter $label';
          }

          return null;
        },
      ),
    );
  }
}
