class PendapatanModel {
  final DateTime label;
  final double jumlah;

  PendapatanModel({required this.label, required this.jumlah});

  factory PendapatanModel.fromJson(Map<String, dynamic> json) {
    double jumlah = double.tryParse(json['jumlah'].toString()) ?? 0.0;

    // Handle "day", "week", and "month" label formats
    if (json.containsKey('year_label')) {
      // type == 'week' or 'month'
      final year = json['year_label'];
      final rawLabel = json['label'].toString();

      if (int.tryParse(rawLabel) != null) {
        final int labelInt = int.parse(rawLabel);

        if (labelInt >= 1 && labelInt <= 12) {
          // Bulan (month)
          return PendapatanModel(
            label: DateTime(year, labelInt, 1),
            jumlah: jumlah,
          );
        } else {
          // Minggu ke-N dalam tahun
          final date = _getDateFromWeekNumber(year, labelInt);
          return PendapatanModel(
            label: date,
            jumlah: jumlah,
          );
        }
      }
    }

    // Default: type == 'day' -> label = yyyy-MM-dd
    return PendapatanModel(
      label: DateTime.tryParse(json['label'].toString()) ?? DateTime(2000),
      jumlah: jumlah,
    );
  }

  static List<PendapatanModel> fromJsonList(List<dynamic> data) {
    return data.map((e) => PendapatanModel.fromJson(e)).toList();
  }

  static DateTime _getDateFromWeekNumber(int year, int week) {
    // Ambil hari Senin di minggu ke-N tahun tertentu
    final jan4 = DateTime(year, 1, 4);
    final startOfWeek = jan4.subtract(Duration(days: jan4.weekday - 1));
    return startOfWeek.add(Duration(days: (week - 1) * 7));
  }
}



class ProdukTerlarisModel {
  final String productName;
  final int totalTerjual;

  ProdukTerlarisModel({required this.productName, required this.totalTerjual});

  factory ProdukTerlarisModel.fromJson(Map<String, dynamic> json) {
    return ProdukTerlarisModel(
      productName: json['product_name'],
      totalTerjual: int.tryParse(json['total_terjual'].toString()) ?? 0,
    );
  }

  static List<ProdukTerlarisModel> fromJsonList(List<dynamic> data) {
    return data.map((e) => ProdukTerlarisModel.fromJson(e)).toList();
  }
}

