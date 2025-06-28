import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/pendapatan_model.dart';

class TransaksiList extends StatelessWidget {
  final List<PendapatanModel> transaksi;

  const TransaksiList({Key? key, required this.transaksi}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final format = NumberFormat.currency(locale: 'id', symbol: 'Rp ', decimalDigits: 0); // Removed decimal digits for a cleaner look

    if (transaksi.isEmpty) {
      return Center( // Center the message
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Text(
            "Belum ada transaksi tercatat.", // More elegant phrasing
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
              fontStyle: FontStyle.italic,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(), // Consider if you truly need NeverScrollableScrollPhysics. If this list is inside another scrollable widget, it's fine.
      itemCount: transaksi.length,
      itemBuilder: (context, index) {
        final item = transaksi[index];
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          elevation: 4, // Add a subtle shadow
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12), // Rounded corners for a softer look
          ),
          color: Colors.white, // Keep card background white for contrast
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 15.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${DateFormat('dd MMMM yyyy').format(item.label)}', // Format date for better readability
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600, // Slightly bolder for date
                          color: Colors.green[800], // Darker green for date
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Keterangan: ${item.jumlah ?? "Tidak ada keterangan"}', // Assuming you might add a description
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[700],
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  format.format(item.jumlah),
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: Colors.green[700], // Prominent green for the amount
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}