import 'package:flutter/material.dart';

class AdminLoadingCard extends StatelessWidget {
  final double height;

  const AdminLoadingCard({super.key, this.height = 200});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: SizedBox(
        height: height,
        child: const Center(child: CircularProgressIndicator()),
      ),
    );
  }
}
