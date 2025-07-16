import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:animate_do/animate_do.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController _storeNameController = TextEditingController();
  final TextEditingController _storeAddressController = TextEditingController();

  String storeName = "RUMAH SEDUH";
  String storeAddress = "Jl. Parit Pekir Sebelah SDN 13\nSungailiat - Bangka";
  String? storeImagePath;
  double totalHariIni = 0.0;
  String? userRole;


  @override
  void initState() {
    super.initState();
    _loadStoreInfo();
    _fetchTotalHariIni();
     _loadRole();
  }

  Future<void> _loadStoreInfo() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      storeName = prefs.getString('storeName') ?? storeName;
      storeAddress = prefs.getString('storeAddress') ?? storeAddress;
      storeImagePath = prefs.getString('storeImagePath'); // muat path gambar
    });
  }
  Future<void> _fetchTotalHariIni() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      final now = DateTime.now();

      final uri = Uri.parse(
        'https://rumahseduh.shbhosting999.my.id/api/pendapatan'
        '?type=day&year=${now.year}&month=${now.month}&day=${now.day}',
      );

      final response = await http.get(uri, headers: {
        HttpHeaders.authorizationHeader: 'Bearer $token',
      });

      if (response.statusCode == 200) {
        final List<dynamic> body = json.decode(response.body);
        setState(() {
          totalHariIni = body.fold<double>(
            0.0,
            (sum, item) => sum + double.tryParse(item['jumlah'].toString())!,
          );
        });
      } else {
        print("Gagal mengambil data pendapatan hari ini");
      }
    } catch (e) {
      print("Error: $e");
    }
  }

  Future<void> _loadRole() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final role = prefs.getString('role');
    setState(() {
      userRole = role;
    });
    print("👤 Role pengguna: $role");
  }

  Future<void> _saveStoreInfo() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('storeName', _storeNameController.text);
    await prefs.setString('storeAddress', _storeAddressController.text);
    if (storeImagePath != null) {
      await prefs.setString('storeImagePath', storeImagePath!);
    }
    _loadStoreInfo();
  }
  Future<void> _pickStoreImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('storeImagePath', image.path);
      setState(() {
        storeImagePath = image.path;
      });
    }
  }
Widget _buildCustomButtonReloading(BuildContext context, String title, IconData icon, String route) {
  return SizedBox(
    width: 150,
    height: 120,
    child: ElevatedButton(
      onPressed: () async {
        await Get.toNamed(route); // Navigasi ke halaman Orderan
        _fetchTotalHariIni();     // Refresh data saat kembali
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.green.shade800,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 6,
        shadowColor: Colors.green.shade300,
        padding: EdgeInsets.all(12),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 36, color: Colors.white),
          SizedBox(height: 10),
          Text(
            title,
            style: TextStyle(fontSize: 14, color: Colors.white),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    ),
  );
}
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text('Kasir', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.green.shade800)),
        actions: [
          IconButton(
            icon: Icon(Icons.person, color: Colors.green.shade800),
            onPressed: () => Get.toNamed('/profile'),
          ),
          IconButton(
            icon: Icon(Icons.logout, color: Colors.green.shade800),
            onPressed: () => _logout(context),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await _loadStoreInfo();
          await _fetchTotalHariIni();
        },
        child: SingleChildScrollView(
          physics: AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              FadeInDown(child: _buildInfoCard()),
              SizedBox(height: 20),
              FadeInDown(delay: Duration(milliseconds: 200), child: _buildStoreCard()),
              SizedBox(height: 30),
             Wrap(
                spacing: 20,
                runSpacing: 20,
                alignment: WrapAlignment.center,
                children: [
                  if (userRole == 'kasir' || userRole == 'owner')
                    FadeInUp(delay: Duration(milliseconds: 300), child: _buildCustomButton(context, 'Daftar Menu', Icons.menu_book, '/menu')),
                  
                  if (userRole == 'kasir' || userRole == 'owner')
                    FadeInUp(delay: Duration(milliseconds: 400), child: _buildCustomButtonReloading(context, 'Orderan', Icons.shopping_cart, '/transaksi')),

                  if (userRole == 'owner') // hanya owner
                    FadeInUp(delay: Duration(milliseconds: 500), child: _buildCustomButton(context, 'Laporan Pendapatan', Icons.attach_money, '/laporan_pendapatan')),

                  if (userRole == 'owner') // hanya owner
                    FadeInUp(delay: Duration(milliseconds: 600), child: _buildCustomButtonWithToken(context, 'Tambah Menu', Icons.add)),
                ],
              ),
              SizedBox(height: 30),
              FadeInDown(
                delay: Duration(milliseconds: 700),
                child: ElevatedButton.icon(
                  onPressed: () => _logout(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red.shade800,
                    padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    shadowColor: Colors.black,
                    elevation: 5,
                  ),
                  icon: Icon(Icons.logout, color: Colors.white),
                  label: Text("Logout", style: TextStyle(fontSize: 18, color: Colors.white)),
                ),
              ),  
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard() {
    final currency = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ');
    return AnimatedContainer(
      duration: Duration(milliseconds: 600),
      curve: Curves.easeInOut,
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.green.shade800,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 8, offset: Offset(0, 4))],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Total Penjualan Hari ini', style: TextStyle(color: Colors.white, fontSize: 16)),
              SizedBox(height: 4),
              Text(
                currency.format(totalHariIni),
                style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          Text('Versi 1.0', style: TextStyle(color: Colors.white)),
        ],
      ),
    );
  }


  Widget _buildStoreCard() {
  return Card(
    elevation: 6,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    child: Padding(
      padding: const EdgeInsets.all(12.0),
      child: Column(
        children: [
          ListTile(
            leading: GestureDetector(
              onTap: _pickStoreImage,
              child: storeImagePath != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.file(
                        File(storeImagePath!),
                        width: 40,
                        height: 40,
                        fit: BoxFit.cover,
                      ),
                    )
                  : Icon(Icons.store, color: Colors.green.shade800, size: 36),
            ),
            title: Text(storeName, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            subtitle: Text(storeAddress, style: TextStyle(height: 1.4)),
            trailing: IconButton(
              icon: Icon(Icons.edit, color: Colors.green),
              onPressed: () {
                _storeNameController.text = storeName;
                _storeAddressController.text = storeAddress;
               showDialog(
                context: context,
                builder: (_) {
                  String? tempImagePath = storeImagePath; // Simpan sementara untuk preview

                  return StatefulBuilder(
                    builder: (context, setStateDialog) {
                      return AlertDialog(
                        title: Text("Edit Informasi Toko"),
                        content: SingleChildScrollView(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              TextField(
                                controller: _storeNameController,
                                decoration: InputDecoration(labelText: "Nama Toko"),
                              ),
                              TextField(
                                controller: _storeAddressController,
                                decoration: InputDecoration(labelText: "Alamat"),
                                maxLines: 3,
                              ),
                              SizedBox(height: 10),
                              if (tempImagePath != null)
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.file(
                                    File(tempImagePath!),
                                    width: 80,
                                    height: 80,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              TextButton.icon(
                                onPressed: () async {
                                  final ImagePicker picker = ImagePicker();
                                  final XFile? image = await picker.pickImage(source: ImageSource.gallery);
                                  if (image != null) {
                                    setState(() {
                                      storeImagePath = image.path; // Final path untuk penyimpanan
                                    });
                                    setStateDialog(() {
                                      tempImagePath = image.path; // Preview di dialog
                                    });
                                  }
                                },
                                icon: Icon(Icons.image, color: Colors.green),
                                label: Text("Pilih Gambar"),
                              ),
                            ],
                          ),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: Text("Batal"),
                          ),
                          ElevatedButton(
                            onPressed: () {
                              _saveStoreInfo(); // Simpan perubahan
                              Navigator.pop(context); // Tutup dialog
                            },
                            child: Text("Simpan"),
                          ),
                        ],
                      );
                    },
                  );
                },
              );
              },
            ),
          ),
        ],
      ),
    ),
  );
}


  Widget _buildCustomButton(BuildContext context, String title, IconData icon, String route) {
    return SizedBox(
      width: 150,
      height: 120,
      child: ElevatedButton(
        onPressed: () => Get.toNamed(route),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.green.shade800,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 6,
          shadowColor: Colors.green.shade300,
          padding: EdgeInsets.all(12),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 36, color: Colors.white),
            SizedBox(height: 10),
            Text(
              title,
              style: TextStyle(fontSize: 14, color: Colors.white),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomButtonWithToken(BuildContext context, String title, IconData icon) {
    return SizedBox(
      width: 150,
      height: 120,
      child: ElevatedButton(
        onPressed: () async {
          SharedPreferences prefs = await SharedPreferences.getInstance();
          String? token = prefs.getString('token') ?? '';
          if (token.isNotEmpty) {
            Get.toNamed('/TambahMenuPage', arguments: token);
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Token tidak ditemukan, harap login terlebih dahulu')),
            );
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.green.shade800,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 6,
          shadowColor: Colors.green.shade300,
          padding: EdgeInsets.all(12),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 36, color: Colors.white),
            SizedBox(height: 10),
            Text(
              title,
              style: TextStyle(fontSize: 14, color: Colors.white),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _logout(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    Navigator.pushReplacementNamed(context, '/login');
  }
}