// File: pendapatan_page.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/pendapatan_model.dart';
import '../services/order_service.dart';
import '../widgets/bar_chart_widget.dart';
import '../widgets/produk_terlaris_chart.dart';
import '../widgets/transaksi_list.dart';
import '../utils/date_helper.dart';

enum FilterMode { perhari, perbulan, semua }

class PendapatanPage extends StatefulWidget {
  @override
  State<PendapatanPage> createState() => _PendapatanPageState();
}

class _PendapatanPageState extends State<PendapatanPage> {
  FilterMode _filter = FilterMode.perhari;
  DateTime _selectedDate = DateTime.now();
  bool _isLoading = true;

  List<PendapatanModel> _dataPendapatan = [];
  List<Map<String, dynamic>> _produkTerlaris = [];

  @override
  void initState() {
    super.initState();
    _loadData();
    print('DATA PENDAPATAN: $_dataPendapatan');
print('FILTERED DATA: $_filteredData');
print('PRODUK TERLARIS: $_produkTerlaris');

  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    await fetchPendapatan();
    await fetchProdukTerlaris();
    setState(() => _isLoading = false);
  }

  Future<void> fetchPendapatan() async {
    try {
      final type = _filter == FilterMode.perhari
          ? 'day'
          : _filter == FilterMode.perbulan
              ? 'day'
              : 'month';

      final data = await OrderService.fetchPendapatan(
        type: type,
        year: _selectedDate.year,
        month: _filter != FilterMode.semua ? _selectedDate.month : null,
        day: _filter == FilterMode.perhari ? _selectedDate.day : null,
      );
      _dataPendapatan = PendapatanModel.fromJsonList(data);
    } catch (e) {
      print("Error fetching pendapatan: $e");
    }
  }

  Future<void> fetchProdukTerlaris() async {
    try {
      final data = await OrderService.fetchProdukTerlaris(
        year: _selectedDate.year,
        month: _filter == FilterMode.perbulan ? _selectedDate.month : null,
      );
      _produkTerlaris = List<Map<String, dynamic>>.from(data);
    } catch (e) {
      print("Error fetching produk terlaris: $e");
    }
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
      await _loadData();
    }
  }

  List<PendapatanModel> get _filteredData {
    return _dataPendapatan.where((e) {
      if (_filter == FilterMode.perhari) {
        return DateHelper.isSameDay(e.label, _selectedDate);
      } else if (_filter == FilterMode.perbulan) {
        return e.label.month == _selectedDate.month &&
            e.label.year == _selectedDate.year;
      }
      return true;
    }).toList();
  }

  double get totalPendapatan =>
      _filteredData.fold(0.0, (sum, item) => sum + item.jumlah);

  Map<String, double> get _pendapatanPerTanggal {
    final Map<String, double> map = {};
    for (var item in _filteredData) {
      final key = DateFormat('yyyy-MM-dd').format(item.label);
      map[key] = (map[key] ?? 0) + item.jumlah;
    }
    return map;
  }

  @override
  Widget build(BuildContext context) {
    final currency = NumberFormat.currency(locale: 'id', symbol: 'Rp ');

    return Scaffold(
      appBar: AppBar(title: Text('Laporan Pendapatan')),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildFilterControls(),
                    SizedBox(height: 12),
                    Text('Total Pendapatan: ${currency.format(totalPendapatan)}',
                        style:
                            TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    SizedBox(height: 16),
                    BarChartWidget(data: _filteredData),
                    SizedBox(height: 20),
                    Divider(),
                    Text('Detail Transaksi:',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    SizedBox(height: 8),
                    TransaksiList(transaksi: _filteredData),
                    SizedBox(height: 20),
                    Divider(),
                    Text('Produk Terlaris:',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    SizedBox(height: 8),
                    ProdukTerlarisChart(data: ProdukTerlarisModel.fromJsonList(_produkTerlaris)),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildFilterControls() {
    return Row(
      children: [
        Expanded(
          child: DropdownButton<FilterMode>(
            value: _filter,
            items: [
              DropdownMenuItem(
                  value: FilterMode.perhari, child: Text('Per Hari')),
              DropdownMenuItem(
                  value: FilterMode.perbulan, child: Text('Per Bulan')),
              DropdownMenuItem(value: FilterMode.semua, child: Text('Semua')),
            ],
            onChanged: (val) async {
              if (val != null) {
                setState(() => _filter = val);
                await _loadData();
              }
            },
          ),
        ),
        SizedBox(width: 10),
        ElevatedButton(
          onPressed: _pickDate,
          child: Text(DateFormat('yyyy-MM-dd').format(_selectedDate)),
        ),
      ],
    );
  }
}
