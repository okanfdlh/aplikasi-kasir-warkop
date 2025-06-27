import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../models/pendapatan_model.dart';

class BarChartWidget extends StatelessWidget {
  final List<PendapatanModel> data;

  const BarChartWidget({required this.data});

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) return Text("Tidak ada data pendapatan");

    final barGroups = data.asMap().entries.map((entry) {
      final index = entry.key;
      final item = entry.value;
      return BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(
            toY: item.jumlah / 1000,
            color: Colors.green,
            width: 16,
          )
        ],
      );
    }).toList();

    final labels = data.map((e) => e.label).toList();

    return SizedBox(
      height: 200,
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          barGroups: barGroups,
          titlesData: FlTitlesData(
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  final idx = value.toInt();
                  if (idx >= 0 && idx < labels.length) {
                    return Text(DateFormat('MM-dd').format(labels[idx]));
                  }
                  return Text('');
                },
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 40,
                getTitlesWidget: (value, _) => Text('${(value * 1000).toInt()}'),
              ),
            ),
          ),
        ),
      ),
    );
  }
}