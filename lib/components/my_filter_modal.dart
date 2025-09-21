import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class MyFilterModal extends StatefulWidget {
  final void Function({
    DateTime? startDate,
    DateTime? endDate,
    String? keyword,
  }) onApply;

  const MyFilterModal({super.key, required this.onApply});

  @override
  State<MyFilterModal> createState() => _MyFilterModalState();
}

class _MyFilterModalState extends State<MyFilterModal> {
  DateTime? _startDate;
  DateTime? _endDate;
  final TextEditingController _keywordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Filter Pencarian',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Color(0xFF2D3748),
            ),
          ),
          const SizedBox(height: 16),

          // 🔎 Keyword
          TextField(
            controller: _keywordController,
            decoration: InputDecoration(
              hintText: "Cari produk / nama customer",
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              contentPadding: const EdgeInsets.symmetric(vertical: 10),
            ),
          ),
          const SizedBox(height: 16),

          // 📅 Tanggal
          Row(
            children: [
              Expanded(
                child: _buildDateButton(
                  label: "Dari",
                  date: _startDate,
                  onTap: () => _pickDate(isStart: true),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildDateButton(
                  label: "Sampai",
                  date: _endDate,
                  onTap: () => _pickDate(isStart: false),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Tombol aksi
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: _resetFilter,
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size.fromHeight(45),
                  ),
                  child: const Text("Reset"),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    widget.onApply(
                      startDate: _startDate,
                      endDate: _endDate,
                      keyword: _keywordController.text.isNotEmpty
                          ? _keywordController.text
                          : null,
                    );
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green.shade700,
                    minimumSize: const Size.fromHeight(45),
                  ),
                  child: const Text("Pakai Filter"),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildDateButton({
    required String label,
    required DateTime? date,
    required VoidCallback onTap,
  }) {
    return ElevatedButton.icon(
      onPressed: onTap,
      icon: const Icon(Icons.calendar_today, size: 18),
      label: Text(
        date != null ? DateFormat('dd MMM yyyy').format(date) : label,
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xff024924),
        foregroundColor: Colors.white,
        elevation: 0,
        padding: const EdgeInsets.symmetric(vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  Future<void> _pickDate({required bool isStart}) async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (date != null) {
      setState(() {
        if (isStart) {
          _startDate = date;
        } else {
          _endDate = date;
        }
      });
    }
  }

  void _resetFilter() {
    setState(() {
      _startDate = null;
      _endDate = null;
      _keywordController.clear();
    });
  }
}
