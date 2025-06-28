import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/pendapatan_model.dart';

class ProdukTerlarisChart extends StatelessWidget {
  final List<ProdukTerlarisModel> data;

  const ProdukTerlarisChart({required this.data});

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) {
      return Container(
        height: 200,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.trending_up,
                size: 48,
                color: Colors.green[200],
              ),
              SizedBox(height: 8),
              Text(
                "Tidak ada data produk",
                style: TextStyle(
                  color: Colors.green[400],
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Ambil 5 produk terlaris saja
    final topData = data.take(5).toList();

    final maxValue = topData.map((e) => e.totalTerjual).reduce((a, b) => a > b ? a : b);

    final barGroups = topData.asMap().entries.map((entry) {
      final index = entry.key;
      final item = entry.value;
      return BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(
            toY: item.totalTerjual.toDouble(),
            gradient: LinearGradient(
              colors: [
                Color(0xFF34D399).withOpacity(0.8),
                Color(0xFF10B981),
              ],
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
            ),
            width: 20,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(4),
              topRight: Radius.circular(4),
            ),
          )
        ],
      );
    }).toList();

    return Container(
      height: 250,
      padding: EdgeInsets.all(16),
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: maxValue.toDouble() * 1.2,
          barGroups: barGroups,
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: maxValue / 5,
            getDrawingHorizontalLine: (value) {
              return FlLine(
                color: Colors.green.withOpacity(0.15),
                strokeWidth: 1,
              );
            },
          ),
          borderData: FlBorderData(show: false),
          titlesData: FlTitlesData(
            topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 60,
                getTitlesWidget: (value, meta) {
                  final index = value.toInt();
                  if (index >= 0 && index < topData.length) {
                    final productName = topData[index].productName;
                    final displayName = productName.length > 10
                        ? '${productName.substring(0, 8)}...'
                        : productName;
                    return Padding(
                      padding: EdgeInsets.only(top: 8),
                      child: Transform.rotate(
                        angle: -0.5,
                        child: Text(
                          displayName,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                            color: Colors.green[700],
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    );
                  }
                  return Text('');
                },
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 35,
                interval: maxValue / 5,
                getTitlesWidget: (value, meta) {
                  return Text(
                    value.toInt().toString(),
                    style: TextStyle(
                      color: Colors.green[700],
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
                  );
                },
              ),
            ),
          ),
          barTouchData: BarTouchData(
            enabled: true,
            touchTooltipData: BarTouchTooltipData(
              tooltipBgColor: Color(0xFF065F46),
              tooltipRoundedRadius: 8,
              tooltipPadding: EdgeInsets.all(8),
              getTooltipItem: (group, groupIndex, rod, rodIndex) {
                final product = topData[group.x];
                return BarTooltipItem(
                  '${product.productName}\n',
                  TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                    fontSize: 12,
                  ),
                  children: [
                    TextSpan(
                      text: '${product.totalTerjual} terjual',
                      style: TextStyle(
                        color: Color(0xFF34D399),
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
