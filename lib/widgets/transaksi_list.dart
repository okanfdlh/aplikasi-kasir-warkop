import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/pendapatan_model.dart';

class TransaksiList extends StatelessWidget {
  final List<PendapatanModel> transaksi;

  const TransaksiList({required this.transaksi});

  @override
  Widget build(BuildContext context) {
    final format = NumberFormat.currency(locale: 'id', symbol: 'Rp ');
    if (transaksi.isEmpty) return Text("Tidak ada transaksi.");

    return ListView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemCount: transaksi.length,
      itemBuilder: (context, index) {
        final item = transaksi[index];
        return ListTile(
          title: Text('Tanggal: ${item.label}'),
          trailing: Text(format.format(item.jumlah)),
        );
      },
    );
  }
}