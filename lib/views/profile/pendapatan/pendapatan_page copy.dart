// import 'package:coffeeorder/widgets/button_primary.dart';
// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
// import 'package:fl_chart/fl_chart.dart';
// import '../../models/pendapatan_model.dart';
// import '../../services/order_service.dart';
// import '../../widgets/bar_chart_widget.dart';
// import '../../widgets/produk_terlaris_chart.dart';
// import '../../widgets/transaksi_list.dart';
// import '../../utils/date_helper.dart';
// import 'package:pdf/pdf.dart';
// import 'package:pdf/widgets.dart' as pw;
// import 'package:printing/printing.dart';
// import 'dart:typed_data';
// import 'package:path_provider/path_provider.dart';
// import 'package:permission_handler/permission_handler.dart';
// import 'dart:io';
// import 'package:excel/excel.dart' as ex;

// enum FilterMode { perhari, perbulan, semua }

// class PendapatanPage extends StatefulWidget {
//   @override
//   State<PendapatanPage> createState() => _PendapatanPageState();
// }

// class _PendapatanPageState extends State<PendapatanPage> {
//   FilterMode _filter = FilterMode.perhari;
//   DateTime _selectedDate = DateTime.now();
//   bool _isLoading = true;

//   List<PendapatanModel> _dataPendapatan = [];
//   List<Map<String, dynamic>> _produkTerlaris = [];

//   @override
//   void initState() {
//     super.initState();
//     _loadData();
//     print('DATA PENDAPATAN: $_dataPendapatan');
//     print('FILTERED DATA: $_filteredData');
//     print('PRODUK TERLARIS: $_produkTerlaris');
//   }

//   Future<void> _loadData() async {
//     setState(() => _isLoading = true);
//     await fetchPendapatan();
//     await fetchProdukTerlaris();
//     setState(() => _isLoading = false);
//   }

//   Future<void> fetchPendapatan() async {
//     try {
//       final type = _filter == FilterMode.perhari
//           ? 'day'
//           : _filter == FilterMode.perbulan
//               ? 'month'
//               : 'year';

//       final data = await OrderService.fetchPendapatan(
//         type: type,
//         year: _selectedDate.year,
//         month: _filter != FilterMode.semua ? _selectedDate.month : null,
//         day: _filter == FilterMode.perhari ? _selectedDate.day : null,
//       );
//       _dataPendapatan = data;
//     } catch (e) {
//       print("Error fetching pendapatan: $e");
//     }
//   }

//   Future<void> fetchProdukTerlaris() async {
//     try {
//       final data = await OrderService.fetchProdukTerlaris(
//         year: _selectedDate.year,
//         month: _filter == FilterMode.perbulan ? _selectedDate.month : null,
//       );
//       _produkTerlaris = data
//           .map((item) => {
//                 'product_name': item.productName,
//                 'total_terjual': item.totalTerjual,
//               })
//           .toList();
//     } catch (e) {
//       print("Error fetching produk terlaris: $e");
//     }
//   }

//   Future<void> _pickDate() async {
//     final picked = await showDatePicker(
//       context: context,
//       initialDate: _selectedDate,
//       firstDate: DateTime(2024),
//       lastDate: DateTime(2100),
//       builder: (context, child) {
//         return Theme(
//           data: Theme.of(context).copyWith(
//             colorScheme: const ColorScheme.light(
//               primary: Color(0xFF6C63FF),
//               onPrimary: Colors.white,
//               surface: Colors.white,
//               onSurface: Colors.black,
//             ),
//           ),
//           child: child!,
//         );
//       },
//     );
//     if (picked != null) {
//       setState(() => _selectedDate = picked);
//       await _loadData();
//     }
//   }

//   List<PendapatanModel> get _filteredData {
//     return _dataPendapatan.where((e) {
//       if (_filter == FilterMode.perhari) {
//         return DateHelper.isSameDay(e.label, _selectedDate);
//       } else if (_filter == FilterMode.perbulan) {
//         return e.label.month == _selectedDate.month &&
//             e.label.year == _selectedDate.year;
//       }
//       return true;
//     }).toList();
//   }

//   double get totalPendapatan =>
//       _filteredData.fold(0.0, (sum, item) => sum + item.jumlah);

//   Map<String, double> get _pendapatanPerTanggal {
//     final Map<String, double> map = {};
//     for (var item in _filteredData) {
//       final key = DateFormat('yyyy-MM-dd').format(item.label);
//       map[key] = (map[key] ?? 0) + item.jumlah;
//     }
//     return map;
//   }

//   Future<void> _exportToExcel() async {
//     final excel = ex.Excel.createExcel();
//     final sheet = excel['Laporan Pendapatan'];
//     final currency = NumberFormat.currency(locale: 'id', symbol: 'Rp ');

//     sheet.appendRow(['Tanggal', 'Jumlah']);

//     for (var item in _filteredData) {
//       sheet.appendRow([
//         DateFormat('dd/MM/yyyy').format(item.label),
//         currency.format(item.jumlah),
//       ]);
//     }

//     sheet.appendRow([]);
//     sheet.appendRow(['Total', currency.format(totalPendapatan)]);

//     final List<int>? fileBytes = excel.encode();
//     if (fileBytes == null) return;

//     if (await Permission.storage.request().isGranted) {
//       final directory = Directory('/storage/emulated/0/Download');
//       final path = '${directory.path}/laporan_pendapatan.xlsx';
//       final file = File(path);
//       await file.writeAsBytes(fileBytes);
//       // ignore: use_build_context_synchronously
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('File disimpan di folder Download')),
//       );
//     } else {
//       // ignore: use_build_context_synchronously
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Izin akses penyimpanan ditolak')),
//       );
//     }
//   }

//   Future<void> _exportToPDF() async {
//     final pdf = pw.Document();
//     final currency = NumberFormat.currency(locale: 'id', symbol: 'Rp ');

//     pdf.addPage(
//       pw.Page(
//         build: (pw.Context context) {
//           return pw.Column(
//             crossAxisAlignment: pw.CrossAxisAlignment.start,
//             children: [
//               pw.Text('Laporan Pendapatan',
//                   style: pw.TextStyle(
//                       fontSize: 24, fontWeight: pw.FontWeight.bold)),
//               pw.SizedBox(height: 12),
//               pw.Text(
//                   'Tanggal: ${DateFormat('dd MMMM yyyy').format(_selectedDate)}'),
//               pw.SizedBox(height: 20),
//               // ignore: deprecated_member_use
//               pw.Table.fromTextArray(
//                 headers: ['Tanggal', 'Jumlah'],
//                 data: _filteredData
//                     .map((e) => [
//                           DateFormat('dd/MM/yyyy').format(e.label),
//                           currency.format(e.jumlah),
//                         ])
//                     .toList(),
//               ),
//               pw.SizedBox(height: 20),
//               pw.Text('Total: ${currency.format(totalPendapatan)}',
//                   style: pw.TextStyle(
//                       fontSize: 16, fontWeight: pw.FontWeight.bold)),
//             ],
//           );
//         },
//       ),
//     );

//     await Printing.layoutPdf(
//         onLayout: (PdfPageFormat format) async => pdf.save());
//   }

//   @override
//   Widget build(BuildContext context) {
//     final currency = NumberFormat.currency(locale: 'id', symbol: 'Rp ');

//     return Scaffold(
//       // backgroundColor: Color(0xFFF8F9FA),
//       appBar: AppBar(
//         automaticallyImplyLeading: false,
//         centerTitle: false,
//         title: const Text(
//           'Pendapatan',
//           style: TextStyle(
//             fontSize: 20,
//             fontFamily: 'Poppins',
//             color: Colors.white,
//           ),
//         ),
//         backgroundColor: const Color(0xff024924),
//         elevation: 0,
//         actions: [
//           IconButton(
//             icon: Image.asset(
//               'assets/ic_filter.png',
//               width: 24,
//               height: 24,
//               color: Colors.white,
//             ),
//             onPressed: () {
//               showGeneralDialog(
//                 context: context,
//                 barrierDismissible: true,
//                 barrierLabel: "Filter",
//                 transitionDuration: const Duration(milliseconds: 300),
//                 pageBuilder: (context, anim1, anim2) {
//                   return const SizedBox
//                       .shrink(); // Kosong, kita pakai transitionBuilder
//                 },
//                 transitionBuilder: (context, anim1, anim2, child) {
//                   return Stack(
//                     children: [
//                       // Background gelap langsung muncul instan
//                       GestureDetector(
//                         onTap: () => Navigator.pop(context),
//                         child: Container(
//                           color: Colors.black.withOpacity(0.3),
//                         ),
//                       ),
//                       // Modal turun smooth
//                       Align(
//                         alignment: Alignment.topCenter,
//                         child: SlideTransition(
//                           position: Tween<Offset>(
//                             begin: const Offset(0, -1), // dari atas
//                             end: Offset.zero, // ke posisi normal
//                           ).animate(CurvedAnimation(
//                             parent: anim1,
//                             curve: Curves.easeOutCubic,
//                           )),
//                           child: Padding(
//                             padding: const EdgeInsets.only(top: 40),
//                             child: Material(
//                               color: Colors.transparent,
//                               child: Container(
//                                 width: MediaQuery.of(context).size.width * 0.9,
//                                 padding: const EdgeInsets.all(16),
//                                 decoration: BoxDecoration(
//                                   color: Colors.white,
//                                   borderRadius: BorderRadius.circular(16),
//                                   boxShadow: [
//                                     BoxShadow(
//                                       color: Colors.black.withOpacity(0.2),
//                                       blurRadius: 10,
//                                       offset: const Offset(0, 5),
//                                     ),
//                                   ],
//                                 ),
//                                 child:
//                                     const FilterModalContent(), // class konten filter
//                               ),
//                             ),
//                           ),
//                         ),
//                       ),
//                     ],
//                   );
//                 },
//               );
//             },
//           )
//         ],
//       ),
//       body: _isLoading
//           ? const Center(
//               child: CircularProgressIndicator(
//                 valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF6C63FF)),
//               ),
//             )
//           : RefreshIndicator(
//               onRefresh: _loadData,
//               color: const Color(0xFF6C63FF),
//               child: SingleChildScrollView(
//                 physics: const AlwaysScrollableScrollPhysics(),
//                 padding: const EdgeInsets.all(16),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     _buildFilterSection(),
//                     const SizedBox(height: 20),
//                     _buildTotalPendapatanCard(currency),
//                     const SizedBox(height: 20),
//                     _buildChartSection(),
//                     const SizedBox(height: 20),
//                     _buildTransaksiSection(),
//                     const SizedBox(height: 20),
//                     _buildProdukTerlarisSection(),
//                     const SizedBox(height: 20),
//                   ],
//                 ),
//               ),
//             ),
//     );
//   }

//   Widget _buildFilterSection() {
//     return Container(
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(16),
//         boxShadow: [
//           BoxShadow(
//             // ignore: deprecated_member_use
//             color: Colors.grey.withOpacity(0.1),
//             spreadRadius: 1,
//             blurRadius: 10,
//             offset: const Offset(0, 2),
//           ),
//         ],
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               ElevatedButton.icon(
//                 onPressed: _exportToPDF,
//                 icon: const Icon(Icons.picture_as_pdf),
//                 label: const Text("Export PDF"),
//                 style: ElevatedButton.styleFrom(
//                     backgroundColor: Colors.red.shade700),
//               ),
//               const SizedBox(width: 12),
//               ElevatedButton.icon(
//                 onPressed: _exportToExcel,
//                 icon: const Icon(Icons.table_chart),
//                 label: const Text("Export Excel"),
//                 style: ElevatedButton.styleFrom(
//                     backgroundColor: Colors.green.shade700),
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildTotalPendapatanCard(NumberFormat currency) {
//     return Container(
//       padding: const EdgeInsets.all(20),
//       decoration: BoxDecoration(
//         gradient: const LinearGradient(
//           colors: [Color.fromARGB(211, 16, 192, 0), Color(0xFF34D399)],
//         ),
//         borderRadius: BorderRadius.circular(16),
//         boxShadow: [
//           BoxShadow(
//             // ignore: deprecated_member_use
//             color: const Color(0xFF6C63FF).withOpacity(0.3),
//             spreadRadius: 1,
//             blurRadius: 15,
//             offset: const Offset(0, 5),
//           ),
//         ],
//       ),
//       child: Row(
//         children: [
//           Container(
//             padding: const EdgeInsets.all(12),
//             decoration: BoxDecoration(
//               // ignore: deprecated_member_use
//               color: Colors.white.withOpacity(0.2),
//               borderRadius: BorderRadius.circular(12),
//             ),
//             child: const Icon(
//               Icons.account_balance_wallet,
//               color: Colors.white,
//               size: 28,
//             ),
//           ),
//           const SizedBox(width: 16),
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   'Total Pendapatan',
//                   style: TextStyle(
//                     // ignore: deprecated_member_use
//                     color: Colors.white.withOpacity(0.9),
//                     fontSize: 14,
//                     fontWeight: FontWeight.w500,
//                   ),
//                 ),
//                 const SizedBox(height: 4),
//                 Text(
//                   currency.format(totalPendapatan),
//                   style: const TextStyle(
//                     color: Colors.white,
//                     fontSize: 22,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildChartSection() {
//     return Container(
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(16),
//         boxShadow: [
//           BoxShadow(
//             // ignore: deprecated_member_use
//             color: Colors.grey.withOpacity(0.1),
//             spreadRadius: 1,
//             blurRadius: 10,
//             offset: const Offset(0, 2),
//           ),
//         ],
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           const Row(
//             children: [
//               Icon(Icons.bar_chart, color: Color(0xFF6C63FF), size: 24),
//               SizedBox(width: 8),
//               Text(
//                 'Grafik Pendapatan',
//                 style: TextStyle(
//                   fontSize: 16,
//                   fontWeight: FontWeight.w600,
//                   color: Color(0xFF2D3748),
//                 ),
//               ),
//             ],
//           ),
//           const SizedBox(height: 16),
//           BarChartWidget(data: _filteredData),
//         ],
//       ),
//     );
//   }

//   Widget _buildTransaksiSection() {
//     return Container(
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(16),
//         boxShadow: [
//           BoxShadow(
//             // ignore: deprecated_member_use
//             color: Colors.grey.withOpacity(0.1),
//             spreadRadius: 1,
//             blurRadius: 10,
//             offset: const Offset(0, 2),
//           ),
//         ],
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           const Row(
//             children: [
//               Icon(Icons.receipt_long, color: Color(0xFF10B981), size: 24),
//               SizedBox(width: 8),
//               Text(
//                 'Detail Transaksi',
//                 style: TextStyle(
//                   fontSize: 16,
//                   fontWeight: FontWeight.w600,
//                   color: Color(0xFF2D3748),
//                 ),
//               ),
//             ],
//           ),
//           const SizedBox(height: 16),
//           TransaksiList(transaksi: _filteredData),
//         ],
//       ),
//     );
//   }

//   Widget _buildProdukTerlarisSection() {
//     return Container(
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(16),
//         boxShadow: [
//           BoxShadow(
//             // ignore: deprecated_member_use
//             color: Colors.grey.withOpacity(0.1),
//             spreadRadius: 1,
//             blurRadius: 10,
//             offset: const Offset(0, 2),
//           ),
//         ],
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           const Row(
//             children: [
//               Icon(Icons.trending_up, color: Color(0xFFF59E0B), size: 24),
//               SizedBox(width: 8),
//               Text(
//                 'Produk Terlaris',
//                 style: TextStyle(
//                   fontSize: 16,
//                   fontWeight: FontWeight.w600,
//                   color: Color(0xFF2D3748),
//                 ),
//               ),
//             ],
//           ),
//           const SizedBox(height: 16),
//           ProdukTerlarisChart(
//               data: ProdukTerlarisModel.fromJsonList(_produkTerlaris)),
//         ],
//       ),
//     );
//   }
// }

// // class eksternal
// class FilterModalContent extends StatefulWidget {
//   const FilterModalContent({super.key});

//   @override
//   State<FilterModalContent> createState() => _FilterModalContentState();
// }

// class _FilterModalContentState extends State<FilterModalContent> {
//   FilterMode _filter = FilterMode.perhari;
//   DateTime _selectedDate = DateTime.now();

//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       mainAxisSize: MainAxisSize.min,
//       children: [
//         const Text(
//           'Filter Laporan',
//           style: TextStyle(
//             fontSize: 16,
//             fontWeight: FontWeight.w600,
//             color: Color(0xFF2D3748),
//           ),
//         ),
//         const SizedBox(height: 12),
//         Row(
//           children: [
//             Expanded(
//               child: Container(
//                 padding: const EdgeInsets.symmetric(horizontal: 12),
//                 decoration: BoxDecoration(
//                   border: Border.all(color: const Color(0xFFE2E8F0)),
//                   borderRadius: BorderRadius.circular(8),
//                 ),
//                 child: DropdownButton<FilterMode>(
//                   value: _filter,
//                   isExpanded: true,
//                   underline: const SizedBox(),
//                   icon: const Icon(Icons.keyboard_arrow_down,
//                       color: Color(0xFF6C63FF)),
//                   items: const [
//                     DropdownMenuItem(
//                       value: FilterMode.perhari,
//                       child: Text('Per Hari', style: TextStyle(fontSize: 14)),
//                     ),
//                     DropdownMenuItem(
//                       value: FilterMode.perbulan,
//                       child: Text('Per Bulan', style: TextStyle(fontSize: 14)),
//                     ),
//                     DropdownMenuItem(
//                       value: FilterMode.semua,
//                       child: Text('Semua', style: TextStyle(fontSize: 14)),
//                     ),
//                   ],
//                   onChanged: (val) {
//                     if (val != null) setState(() => _filter = val);
//                   },
//                 ),
//               ),
//             ),
//             const SizedBox(width: 12),
//             Expanded(
//               child: ElevatedButton.icon(
//                 onPressed: _pickDate,
//                 icon: const Icon(Icons.calendar_today, size: 18),
//                 label: Text(
//                   DateFormat('dd MMM yyyy').format(_selectedDate),
//                 ),
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: Color(0xff024924),
//                   foregroundColor: Colors.white,
//                   elevation: 0,
//                   padding: const EdgeInsets.symmetric(vertical: 12),
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(8),
//                   ),
//                 ),
//               ),
//             ),
//           ],
//         ),
//         const SizedBox(height: 12),
//         ElevatedButton(
//           onPressed: () => Navigator.pop(context),
//           style: ElevatedButton.styleFrom(
//             backgroundColor: Colors.green.shade700,
//             foregroundColor: Colors.white,
//             minimumSize: const Size.fromHeight(40),
//             shape: RoundedRectangleBorder(
//               borderRadius: BorderRadius.circular(8),
//             ),
//           ),
//           child: const Text('Pakai Filter'),
//         ),
//       ],
//     );
//   }

//   void _pickDate() async {
//     final date = await showDatePicker(
//       context: context,
//       initialDate: _selectedDate,
//       firstDate: DateTime(2000),
//       lastDate: DateTime(2100),
//     );
//     if (date != null) setState(() => _selectedDate = date);
//   }
// }

























// import 'package:coffeeorder/views/profile/pendapatan/components/filter_modal_content.dart';
// import 'package:flutter/material.dart';
// import 'package:fl_chart/fl_chart.dart';
// import 'package:get/get.dart';
// import 'package:get/get_core/src/get_main.dart';
// import 'package:intl/intl.dart';

// enum FilterMode { perhari, perbulan, semua }

// class PendapatanPage extends StatefulWidget {
//   const PendapatanPage({Key? key}) : super(key: key);
//   @override
//   State<PendapatanPage> createState() => _PendapatanPageState();
// }

// class _PendapatanPageState extends State<PendapatanPage> {
//   int _currentYear = DateTime.now().year;
//   String _currentMonth = DateFormat.MMMM('id_ID').format(DateTime.now());
//   String _selectedFilter = 'Tahunan';

//   final List<FlSpot> dummyData = const [
//     FlSpot(1, 150),
//     FlSpot(2, 200),
//     FlSpot(3, 180),
//     FlSpot(4, 250),
//     FlSpot(5, 230),
//     FlSpot(6, 300),
//     FlSpot(7, 280),
//     FlSpot(8, 350),
//     FlSpot(9, 320),
//     FlSpot(10, 400),
//     FlSpot(11, 380),
//     FlSpot(12, 450),
//   ];

//   // Fungsi untuk mendapatkan rentang tanggal minggu ini
//   String _getThisWeekRange() {
//     final now = DateTime.now();
//     final firstDayOfWeek = now.subtract(Duration(days: now.weekday - 1));
//     final lastDayOfWeek = firstDayOfWeek.add(const Duration(days: 6));

//     final formatter = DateFormat('d MMMM', 'id_ID');
//     return '${formatter.format(firstDayOfWeek)} - ${formatter.format(lastDayOfWeek)}';
//   }

//   // Fungsi untuk mendapatkan rentang tanggal bulan ini
//   String _getThisMonthRange() {
//     final now = DateTime.now();
//     final firstDayOfMonth = DateTime(now.year, now.month, 1);
//     final lastDayOfMonth = DateTime(now.year, now.month + 1, 0);

//     final formatter = DateFormat('d MMMM', 'id_ID');
//     return '${formatter.format(firstDayOfMonth)} - ${formatter.format(lastDayOfMonth)}';
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back, color: Colors.white),
//           onPressed: () => Get.back(),
//         ),
//         centerTitle: false,
//         title: const Text(
//           'Pendapatan',
//           style: TextStyle(
//             fontSize: 20,
//             fontFamily: 'Poppins',
//             color: Colors.white,
//           ),
//         ),
//         backgroundColor: const Color(0xff024924),
//         elevation: 0,
//         actions: [
//           IconButton(
//             icon: Image.asset(
//               'assets/ic_filter.png',
//               width: 24,
//               height: 24,
//               color: Colors.white,
//             ),
//             onPressed: () {
//               showGeneralDialog(
//                 context: context,
//                 barrierDismissible: true,
//                 barrierLabel: "Filter",
//                 transitionDuration: const Duration(milliseconds: 300),
//                 pageBuilder: (context, anim1, anim2) {
//                   return const SizedBox.shrink();
//                 },
//                 transitionBuilder: (context, anim1, anim2, child) {
//                   return Stack(
//                     children: [
//                       GestureDetector(
//                         onTap: () => Navigator.pop(context),
//                         child: Container(
//                           color: Colors.black.withOpacity(0.3),
//                         ),
//                       ),
//                       Align(
//                         alignment: Alignment.topCenter,
//                         child: SlideTransition(
//                           position: Tween<Offset>(
//                             begin: const Offset(0, -1),
//                             end: Offset.zero,
//                           ).animate(CurvedAnimation(
//                             parent: anim1,
//                             curve: Curves.easeOutCubic,
//                           )),
//                           child: Padding(
//                             padding: const EdgeInsets.only(top: 40),
//                             child: Material(
//                               color: Colors.transparent,
//                               child: Container(
//                                 width: MediaQuery.of(context).size.width * 0.9,
//                                 padding: const EdgeInsets.all(16),
//                                 decoration: BoxDecoration(
//                                   color: Colors.white,
//                                   borderRadius: BorderRadius.circular(16),
//                                   boxShadow: [
//                                     BoxShadow(
//                                       color: Colors.black.withOpacity(0.2),
//                                       blurRadius: 10,
//                                       offset: const Offset(0, 5),
//                                     ),
//                                   ],
//                                 ),
//                                 // Ganti baris ini dengan FilterModalContent
//                                 child: FilterModalContent(
//                                   onSelectFilter: (filter) {
//                                     setState(() {
//                                       _selectedFilter = filter;
//                                     });
//                                     // Anda bisa memuat ulang data atau melakukan sesuatu di sini
//                                     print(
//                                         'Filter yang dipilih: $_selectedFilter');
//                                   },
//                                   selectedFilter: _selectedFilter,
//                                 ),
//                               ),
//                             ),
//                           ),
//                         ),
//                       ),
//                     ],
//                   );
//                 },
//               );
//             },
//           )
//         ],
//       ),
//       body: SafeArea(
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             // const SizedBox(height: 20),
//             _buildTimeOptions(),
//             const SizedBox(height: 20),
//             _buildLineChartSection(),
//             const SizedBox(height: 90),
//             _buildExpensesList(),
//           ],
//         ),
//       ),
//     );
//   }

//   // Widget _buildAppBar() {
//   //   return Row(
//   //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//   //     children: [
//   //       Row(
//   //         children: [
//   //           // Icon panah kiri
//   //           GestureDetector(
//   //             onTap: () {
//   //               // Kurangi tahun saat panah kiri diklik
//   //               setState(() {
//   //                 _currentYear--;
//   //               });
//   //             },
//   //             child: const Icon(Icons.arrow_back_ios, color: Colors.black),
//   //           ),
//   //           const SizedBox(width: 8),
//   //           // Teks tahun yang dinamis
//   //           Text(
//   //             '$_currentYear',
//   //             style: const TextStyle(
//   //               color: Colors.black,
//   //               fontSize: 24,
//   //               fontWeight: FontWeight.bold,
//   //             ),
//   //           ),
//   //           const SizedBox(width: 8),
//   //           // Icon panah kanan
//   //           GestureDetector(
//   //             onTap: () {
//   //               // Tambah tahun saat panah kanan diklik
//   //               setState(() {
//   //                 _currentYear++;
//   //               });
//   //             },
//   //             child: const Icon(Icons.arrow_forward_ios, color: Colors.black),
//   //           ),
//   //         ],
//   //       ),
//   //       Container(
//   //         padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
//   //         decoration: BoxDecoration(
//   //           color: Colors.grey[850],
//   //           borderRadius: BorderRadius.circular(20),
//   //         ),
//   //         child: const Text(
//   //           'Tahunan',
//   //           style: TextStyle(color: Colors.black),
//   //         ),
//   //       ),
//   //     ],
//   //   );
//   // }

//   Widget _buildTimeOptions() {
//     String displayText;

//     switch (_selectedFilter) {
//       case 'Tahunan':
//         displayText = '$_currentYear';
//         break;
//       case 'Bulanan':
//         displayText = '$_currentMonth';
//         break;
//       case 'Mingguan':
//         displayText = _getThisWeekRange();
//         break;
//       case 'Periode':
//         displayText = 'Pilih Periode'; // Atau teks lain sesuai kebutuhan
//         break;
//       default:
//         displayText = '$_currentYear';
//     }

//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
//       decoration: const BoxDecoration(
//         color: Color(0xff024924),
//       ),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           GestureDetector(
//             onTap: () {
//               setState(() {
//                 if (_selectedFilter == 'Tahunan') {
//                   _currentYear--;
//                 } else if (_selectedFilter == 'Bulanan') {
//                   // Logika untuk mundur satu bulan
//                 }
//                 // tambahkan logika untuk mingguan dan periode
//               });
//             },
//             child: const Icon(Icons.arrow_back_ios, color: Colors.white),
//           ),
//           const SizedBox(width: 16),
//           Text(
//             displayText, // Menggunakan variabel yang sudah diolah
//             style: const TextStyle(
//               color: Colors.white,
//               fontSize: 20,
//               fontWeight: FontWeight.bold,
//             ),
//           ),
//           const SizedBox(width: 16),
//           // ...
//           GestureDetector(
//             onTap: () {
//               setState(() {
//                 if (_selectedFilter == 'Tahunan') {
//                   _currentYear++;
//                 } else if (_selectedFilter == 'Bulanan') {
//                   // Logika untuk maju satu bulan
//                 }
//                 // tambahkan logika untuk mingguan dan periode
//               });
//             },
//             child: const Icon(Icons.arrow_forward_ios, color: Colors.white),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildLineChartSection() {
//     return AspectRatio(
//       aspectRatio: 1.70,
//       child: Padding(
//         padding: const EdgeInsets.only(
//           right: 18,
//           left: 12,
//           top: 24,
//           bottom: 12,
//         ),
//         child: LineChart(
//           LineChartData(
//             gridData: FlGridData(
//               show: true, // Tampilkan grid untuk referensi yang lebih baik
//               drawVerticalLine: true,
//               getDrawingHorizontalLine: (value) {
//                 return const FlLine(
//                   color: Color(0xff37434d),
//                   strokeWidth: 1,
//                 );
//               },
//               getDrawingVerticalLine: (value) {
//                 return const FlLine(
//                   color: Color(0xff37434d),
//                   strokeWidth: 1,
//                 );
//               },
//             ),
//             titlesData: FlTitlesData(
//               show: true,
//               bottomTitles: AxisTitles(
//                 sideTitles: SideTitles(
//                   showTitles: true,
//                   reservedSize: 30,
//                   interval: 1,
//                   getTitlesWidget: bottomTitleWidgets,
//                 ),
//               ),
//               leftTitles: AxisTitles(
//                 sideTitles: SideTitles(
//                   showTitles: true,
//                   reservedSize: 40,
//                   interval: 100,
//                   getTitlesWidget: leftTitleWidgets,
//                 ),
//               ),
//               topTitles: const AxisTitles(
//                 sideTitles: SideTitles(showTitles: false),
//               ),
//               rightTitles: const AxisTitles(
//                 sideTitles: SideTitles(showTitles: false),
//               ),
//             ),
//             borderData: FlBorderData(
//               show: true,
//               border: Border.all(color: const Color(0xff37434d), width: 1),
//             ),
//             minX: 0,
//             maxX: 13,
//             minY: 0,
//             maxY: 500,
//             lineBarsData: [
//               LineChartBarData(
//                 spots: dummyData,
//                 isCurved: true,
//                 color: Colors.white,
//                 barWidth: 5,
//                 dotData: FlDotData(
//                   show: true, // Mengubah ini menjadi 'true'
//                   getDotPainter: (spot, percent, barData, index) =>
//                       FlDotCirclePainter(
//                     radius: 4,
//                     color: Colors.white,
//                     strokeWidth: 2,
//                     strokeColor: Colors.black,
//                   ),
//                 ),
//                 belowBarData: BarAreaData(
//                   show: false, // Mengubah ini menjadi 'false'
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

// // Tambahkan widget pembantu ini untuk label sumbu x
//   Widget bottomTitleWidgets(double value, TitleMeta meta) {
//     const style = TextStyle(
//       color: Color(0xff68737d),
//       fontWeight: FontWeight.bold,
//       fontSize: 14,
//     );
//     Widget text;
//     switch (value.toInt()) {
//       case 1:
//         text = const Text('JAN', style: style);
//         break;
//       case 4:
//         text = const Text('APR', style: style);
//         break;
//       case 7:
//         text = const Text('JUL', style: style);
//         break;
//       case 10:
//         text = const Text('OKT', style: style);
//         break;
//       default:
//         text = const Text('', style: style);
//         break;
//     }

//     return SideTitleWidget(
//       axisSide: meta.axisSide,
//       space: 8.0,
//       child: text,
//     );
//   }

// // Tambahkan widget pembantu ini untuk label sumbu y
//   Widget leftTitleWidgets(double value, TitleMeta meta) {
//     const style = TextStyle(
//       color: Color(0xff68737d),
//       fontWeight: FontWeight.bold,
//       fontSize: 14,
//     );
//     String text;
//     switch (value.toInt()) {
//       case 100:
//         text = '100';
//         break;
//       case 300:
//         text = '300';
//         break;
//       case 500:
//         text = '500';
//         break;
//       default:
//         return Container();
//     }

//     return Text(text, style: style, textAlign: TextAlign.left);
//   }

//   Widget _buildExpensesList() {
//     return Column(
//       children: [
//         _buildExpenseItem(
//             'Makan Siang Kantin', 'Rp 180.000,00', '50%', Colors.red),
//         const SizedBox(height: 16),
//         _buildExpenseItem('Paket Data', 'Rp 100.000,00', '28%', Colors.orange),
//         const SizedBox(height: 16),
//         _buildExpenseItem('Bensin', 'Rp 80.000,00', '22%', Colors.yellow),
//       ],
//     );
//   }

//   Widget _buildExpenseItem(
//       String title, String amount, String percentage, Color color) {
//     return Row(
//       children: [
//         Container(
//           width: 20,
//           height: 20,
//           decoration: BoxDecoration(
//             color: color,
//             borderRadius: BorderRadius.circular(4),
//           ),
//         ),
//         const SizedBox(width: 12),
//         Expanded(
//           child: Text(
//             title,
//             style: const TextStyle(color: Colors.black, fontSize: 16),
//           ),
//         ),
//         Text(
//           percentage,
//           style: TextStyle(color: Colors.grey[600], fontSize: 16),
//         ),
//         const SizedBox(width: 24),
//         Text(
//           amount,
//           style: const TextStyle(color: Colors.black, fontSize: 16),
//         ),
//       ],
//     );
//   }
// }

