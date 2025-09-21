// lib/filter_modal_content.dart

import 'package:flutter/material.dart';

class FilterModalContent extends StatelessWidget {
  final Function(String) onSelectFilter;
  final String selectedFilter;

  const FilterModalContent({
    Key? key,
    required this.onSelectFilter,
    required this.selectedFilter,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // List opsi filter
    final List<String> filters = [
      'Tahunan',
      'Bulanan',
      'Mingguan',
      'Periode',
    ];

    return Column(
      mainAxisSize: MainAxisSize.min, // Agar modal tidak melebar
      children: filters.map((filter) {
        return InkWell(
          onTap: () {
            onSelectFilter(filter); // Panggil callback saat opsi dipilih
            Navigator.pop(context); // Tutup modal
          },
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 16),
            width: double.infinity,
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: Colors.grey.shade300,
                ),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  filter,
                  style: TextStyle(
                    fontSize: 16,
                    color:
                        selectedFilter == filter ? Colors.blue : Colors.black,
                    fontWeight: selectedFilter == filter
                        ? FontWeight.bold
                        : FontWeight.normal,
                  ),
                ),
                if (selectedFilter == filter)
                  const Icon(
                    Icons.check,
                    color: Colors.blue,
                  ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}
