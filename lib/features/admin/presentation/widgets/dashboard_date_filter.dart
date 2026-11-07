import 'package:flutter/material.dart';

import '../../domain/entities/dashboard_date_filter.dart';

class DashboardDateFilterWidget extends StatelessWidget {
  final DashboardDateFilter selectedFilter;
  final ValueChanged<DashboardDateFilter> onChanged;

  const DashboardDateFilterWidget({
    super.key,
    required this.selectedFilter,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: DropdownButtonFormField<DashboardDateFilter>(
          initialValue: selectedFilter,
          isExpanded: true,
          decoration: const InputDecoration(
            labelText: 'Analytics Period',
            prefixIcon: Icon(Icons.calendar_month),
            border: OutlineInputBorder(),
          ),
          items: DashboardDateFilter.values.map((filter) {
            return DropdownMenuItem(value: filter, child: Text(filter.label));
          }).toList(),
          onChanged: (value) {
            if (value != null) {
              onChanged(value);
            }
          },
        ),
      ),
    );
  }
}
