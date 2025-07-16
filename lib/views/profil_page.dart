import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String? role;
  String? storeName;
  String? storeAddress;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      role = prefs.getString('role');
      storeName = prefs.getString('storeName') ?? 'RUMAH SEDUH';
      // storeAddress = prefs.getString('storeAddress') ?? 'Alamat tidak tersedia';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profil Pengguna'),
        backgroundColor: Colors.green.shade800,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 4,
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Role: $role", style: TextStyle(fontSize: 18)),
                SizedBox(height: 10),
                Text("Nama Toko: $storeName", style: TextStyle(fontSize: 18)),
                SizedBox(height: 10),
                Text("Alamat Toko:", style: TextStyle(fontSize: 18)),
                Text("Jl.M. Safri Rachman,Sungailiat, Bangka", style: TextStyle(fontSize: 16, color: Colors.grey[700])),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
