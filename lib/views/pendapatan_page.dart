import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import '../services/order_service.dart'; // Pastikan path ini sesuai struktur foldermu

class PendapatanPage extends StatefulWidget {
  @override
  _PendapatanPageState createState() => _PendapatanPageState();
}

class _PendapatanPageState extends State<PendapatanPage> {
  String _filter = 'perhari';
  DateTime _selectedDate = DateTime.now();
  List<Map<String, dynamic>> _dataPendapatan = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchPendapatan();
  }

  Future<void> fetchPendapatan() async {
    try {
      final data = await OrderService.fetchPendapatan();
      if (mounted) {
        setState(() {
          _dataPendapatan = data;
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  List<Map<String, dynamic>> get _filteredData {
    final formatter = DateFormat('yyyy-MM-dd');
    final selectedStr = formatter.format(_selectedDate);

    if (_filter == 'perhari') {
      return _dataPendapatan
          .where((item) => item['tanggal'] == selectedStr)
          .toList();
    } else if (_filter == 'perbulan') {
      return _dataPendapatan.where((item) {
        final date = DateTime.parse(item['tanggal']);
        return date.month == _selectedDate.month &&
            date.year == _selectedDate.year;
      }).toList();
    } else {
      return _dataPendapatan;
    }
  }

  Map<String, double> get _pendapatanPerTanggal {
    Map<String, double> result = {};
    for (var item in _filteredData) {
      result[item['tanggal']] = (result[item['tanggal']] ?? 0) +
          (item['jumlah'] as num).toDouble();
    }
    return result;
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2024),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    final formatCurrency = NumberFormat.currency(locale: 'id', symbol: 'Rp ');
    final pendapatanTotal = _filteredData.fold<int>(
      0,
      (sum, item) => sum + (item['jumlah'] as int),
    );

    return Scaffold(
      appBar: AppBar(
        title: Text('Laporan Pendapatan'),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                children: [
                  // Filter dan tanggal
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButton<String>(
                          value: _filter,
                          items: [
                            DropdownMenuItem(
                                value: 'perhari', child: Text('Per Hari')),
                            DropdownMenuItem(
                                value: 'perbulan', child: Text('Per Bulan')),
                            DropdownMenuItem(
                                value: 'semua', child: Text('Semua')),
                          ],
                          onChanged: (val) {
                            if (val != null) {
                              setState(() => _filter = val);
                            }
                          },
                        ),
                      ),
                      SizedBox(width: 10),
                      ElevatedButton(
                        onPressed: _pickDate,
                        child:
                            Text(DateFormat('yyyy-MM-dd').format(_selectedDate)),
                      ),
                    ],
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Total Pendapatan: ${formatCurrency.format(pendapatanTotal)}',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 20),

                  // Grafik pendapatan
                  _pendapatanPerTanggal.isEmpty
                      ? Expanded(child: Center(child: Text("Tidak ada data")))
                      : Expanded(
                          child: BarChart(
                            BarChartData(
                              alignment: BarChartAlignment.spaceAround,
                              barGroups: _pendapatanPerTanggal.entries
                                  .toList()
                                  .asMap()
                                  .entries
                                  .map(
                                    (entry) => BarChartGroupData(
                                      x: entry.key,
                                      barRods: [
                                        BarChartRodData(
                                          toY: entry.value.value / 1000,
                                          color: Colors.green,
                                          width: 16,
                                        ),
                                      ],
                                    ),
                                  )
                                  .toList(),
                              titlesData: FlTitlesData(
                                bottomTitles: AxisTitles(
                                  sideTitles: SideTitles(
                                    showTitles: true,
                                    getTitlesWidget: (value, meta) {
                                      final index = value.toInt();
                                      final dateKeys = _pendapatanPerTanggal.keys.toList();
                                      if (index >= 0 &&
                                          index < dateKeys.length) {
                                        return Text(DateFormat('MM-dd').format(
                                            DateTime.parse(dateKeys[index])));
                                      }
                                      return Text('');
                                    },
                                  ),
                                ),
                                leftTitles: AxisTitles(
                                  sideTitles: SideTitles(
                                    showTitles: true,
                                    reservedSize: 40,
                                    getTitlesWidget: (value, _) =>
                                        Text('${(value * 1000).toInt()}'),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),

                  SizedBox(height: 10),
                  Divider(),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text('Detail Transaksi:',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                  SizedBox(height: 8),

                  // List detail transaksi
                  Expanded(
                    child: ListView.builder(
                      itemCount: _filteredData.length,
                      itemBuilder: (context, index) {
                        final item = _filteredData[index];
                        return ListTile(
                          title: Text('Tanggal: ${item['tanggal']}'),
                          trailing: Text(formatCurrency.format(item['jumlah'])),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
