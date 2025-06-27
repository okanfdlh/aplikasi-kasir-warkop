class PendapatanModel {
  final DateTime label;
  final double jumlah;

  PendapatanModel({required this.label, required this.jumlah});

  factory PendapatanModel.fromJson(Map<String, dynamic> json) {
    return PendapatanModel(
      label: DateTime.parse(json['label']),
      jumlah: double.tryParse(json['jumlah'].toString()) ?? 0.0,
    );
  }

  static List<PendapatanModel> fromJsonList(List<dynamic> data) {
    return data.map((e) => PendapatanModel.fromJson(e)).toList();
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

