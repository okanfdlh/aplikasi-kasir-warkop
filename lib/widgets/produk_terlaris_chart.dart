import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/pendapatan_model.dart';

class ProdukTerlarisChart extends StatelessWidget {
  final List<ProdukTerlarisModel> data;

  const ProdukTerlarisChart({required this.data});

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) return Text("Tidak ada data produk");

    final barGroups = data.asMap().entries.map((entry) {
      final index = entry.key;
      final item = entry.value;
      return BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(
            toY: item.totalTerjual.toDouble(),
            color: Colors.orange,
            width: 16,
          )
        ],
      );
    }).toList();

    return SizedBox(
      height: 200,
      child: BarChart(
        BarChartData(
          barGroups: barGroups,
          titlesData: FlTitlesData(
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  final index = value.toInt();
                  if (index >= 0 && index < data.length) {
                    return Text(
                      data[index].productName,
                      style: TextStyle(fontSize: 10),
                      overflow: TextOverflow.ellipsis,
                    );
                  }
                  return Text('');
                },
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, _) => Text(value.toInt().toString()),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
