import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/pendapatan_model.dart';
import '../services/order_service.dart';
import '../widgets/bar_chart_widget.dart';
import '../widgets/produk_terlaris_chart.dart';
import '../widgets/transaksi_list.dart';
import '../utils/date_helper.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'dart:typed_data';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io';
import 'package:excel/excel.dart' as ex;


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
      _dataPendapatan = data;
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
      _produkTerlaris = data
          .map((item) => {
                'product_name': item.productName,
                'total_terjual': item.totalTerjual,
              })
          .toList();
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
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Color(0xFF6C63FF),
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
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
  Future<void> _exportToExcel() async {
    final excel = ex.Excel.createExcel();
    final sheet = excel['Laporan Pendapatan'];
    final currency = NumberFormat.currency(locale: 'id', symbol: 'Rp ');

    sheet.appendRow(['Tanggal', 'Jumlah']);

    for (var item in _filteredData) {
      sheet.appendRow([
        DateFormat('dd/MM/yyyy').format(item.label),
        currency.format(item.jumlah),
      ]);
    }

    sheet.appendRow([]);
    sheet.appendRow(['Total', currency.format(totalPendapatan)]);

    final List<int>? fileBytes = excel.encode();
    if (fileBytes == null) return;

    if (await Permission.storage.request().isGranted) {
    final directory = Directory('/storage/emulated/0/Download');
    final path = '${directory.path}/laporan_pendapatan.xlsx';
    final file = File(path);
    await file.writeAsBytes(fileBytes);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('File disimpan di folder Download')),
    );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Izin akses penyimpanan ditolak')),
      );
    }
  }


  Future<void> _exportToPDF() async {
    final pdf = pw.Document();
    final currency = NumberFormat.currency(locale: 'id', symbol: 'Rp ');

    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text('Laporan Pendapatan', style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 12),
              pw.Text('Tanggal: ${DateFormat('dd MMMM yyyy').format(_selectedDate)}'),
              pw.SizedBox(height: 20),
              pw.Table.fromTextArray(
                headers: ['Tanggal', 'Jumlah'],
                data: _filteredData.map((e) => [
                  DateFormat('dd/MM/yyyy').format(e.label),
                  currency.format(e.jumlah),
                ]).toList(),
              ),
              pw.SizedBox(height: 20),
              pw.Text('Total: ${currency.format(totalPendapatan)}',
                  style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
            ],
          );
        },
      ),
    );

    await Printing.layoutPdf(onLayout: (PdfPageFormat format) async => pdf.save());
  }

  @override
  Widget build(BuildContext context) {
    final currency = NumberFormat.currency(locale: 'id', symbol: 'Rp ');

    return Scaffold(
      backgroundColor: Color(0xFFF8F9FA),
      appBar: AppBar(
      title: Text(
        'Laporan Pendapatan',
        style: TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 20,
          color: Colors.white,
        ),
      ),
      backgroundColor: Colors.green.shade800,
      elevation: 0,
      centerTitle: true,
    ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF6C63FF)),
              ),
            )
          : RefreshIndicator(
              onRefresh: _loadData,
              color: Color(0xFF6C63FF),
              child: SingleChildScrollView(
                physics: AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildFilterSection(),
                    SizedBox(height: 20),
                    _buildTotalPendapatanCard(currency),
                    SizedBox(height: 20),
                    _buildChartSection(),
                    SizedBox(height: 20),
                    _buildTransaksiSection(),
                    SizedBox(height: 20),
                    _buildProdukTerlarisSection(),
                    SizedBox(height: 20),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildFilterSection() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Filter Laporan',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF2D3748),
            ),
          ),
          SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                flex: 2,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    border: Border.all(color: Color(0xFFE2E8F0)),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: DropdownButton<FilterMode>(
                    value: _filter,
                    isExpanded: true,
                    underline: SizedBox(),
                    icon: Icon(Icons.keyboard_arrow_down, color: Color(0xFF6C63FF)),
                    items: [
                      DropdownMenuItem(
                        value: FilterMode.perhari,
                        child: Text('Per Hari', style: TextStyle(fontSize: 14)),
                      ),
                      DropdownMenuItem(
                        value: FilterMode.perbulan,
                        child: Text('Per Bulan', style: TextStyle(fontSize: 14)),
                      ),
                      DropdownMenuItem(
                        value: FilterMode.semua,
                        child: Text('Semua', style: TextStyle(fontSize: 14)),
                      ),
                    ],
                    onChanged: (val) async {
                      if (val != null) {
                        setState(() => _filter = val);
                        await _loadData();
                      }
                    },
                  ),
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: ElevatedButton.icon(
                  onPressed: _pickDate,
                  icon: Icon(Icons.calendar_today, size: 18),
                  label: Text(DateFormat('dd MMM yyyy').format(_selectedDate)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green.shade600,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton.icon(
                onPressed: _exportToPDF,
                icon: Icon(Icons.picture_as_pdf),
                label: Text("Export PDF"),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red.shade700),
              ),
              SizedBox(width: 12),
              ElevatedButton.icon(
                onPressed: _exportToExcel,
                icon: Icon(Icons.table_chart),
                label: Text("Export Excel"),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green.shade700),
              ),
            ],
          ),
                  ],
      ),
    );
  }

  Widget _buildTotalPendapatanCard(NumberFormat currency) {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Color.fromARGB(211, 16, 192, 0), Color(0xFF34D399)],
        ),

        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Color(0xFF6C63FF).withOpacity(0.3),
            spreadRadius: 1,
            blurRadius: 15,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.account_balance_wallet,
              color: Colors.white,
              size: 28,
            ),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Total Pendapatan',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  currency.format(totalPendapatan),
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChartSection() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.bar_chart, color: Color(0xFF6C63FF), size: 24),
              SizedBox(width: 8),
              Text(
                'Grafik Pendapatan',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF2D3748),
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          BarChartWidget(data: _filteredData),
        ],
      ),
    );
  }

  Widget _buildTransaksiSection() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.receipt_long, color: Color(0xFF10B981), size: 24),
              SizedBox(width: 8),
              Text(
                'Detail Transaksi',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF2D3748),
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          TransaksiList(transaksi: _filteredData),
        ],
      ),
    );
  }

  Widget _buildProdukTerlarisSection() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.trending_up, color: Color(0xFFF59E0B), size: 24),
              SizedBox(width: 8),
              Text(
                'Produk Terlaris',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF2D3748),
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          ProdukTerlarisChart(data: ProdukTerlarisModel.fromJsonList(_produkTerlaris)),
        ],
      ),
    );
  }
}