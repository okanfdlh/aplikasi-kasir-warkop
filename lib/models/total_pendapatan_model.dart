class TotalPendapatan {
  final double totalToday;
  final double totalThisMonth;

  TotalPendapatan({
    required this.totalToday,
    required this.totalThisMonth,
  });

  factory TotalPendapatan.fromJson(Map<String, dynamic> json) {
    double parseDouble(dynamic v) {
      if (v == null) return 0.0;
      if (v is num) return v.toDouble();
      return double.tryParse(v.toString()) ?? 0.0;
    }

    return TotalPendapatan(
      totalToday: parseDouble(json['total_today']),
      totalThisMonth: parseDouble(json['total_this_month']),
    );
  }
}
