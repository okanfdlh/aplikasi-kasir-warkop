import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../models/pendapatan_model.dart'; // Ensure this path is correct

class BarChartWidget extends StatelessWidget {
  final List<PendapatanModel> data;

  const BarChartWidget({Key? key, required this.data}) : super(key: key);

  // Define your green color palette for the chart
  static const Color _chartBarGreen = Color(0xFF4CAF50); // A clean, medium green for bars
  static const Color _chartBarGradientStart = Color(0xFF66BB6A); // Lighter green for gradient start
  static const Color _chartBarGradientEnd = Color(0xFF2E7D32); // Darker green for gradient end
  static const Color _axisLabelColor = Color(0xFF424242); // Dark grey for axis labels (good contrast on light background)
  static const Color _gridLineColor = Color(0xFFE0E0E0); // Light grey for subtle grid lines
  static const Color _tooltipBgColor = Color(0xFF2E7D32); // Dark green for tooltip background
  static const Color _tooltipAmountColor = Color(0xFFCCFF90); // Very light green for amount in tooltip

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) {
      return Container(
        height: 200,
        alignment: Alignment.center, // Use alignment for centering
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.bar_chart,
              size: 48,
              color: Colors.grey[400], // Keep grey for empty state icon
            ),
            const SizedBox(height: 8),
            Text(
              "Tidak ada data pendapatan untuk periode ini.", // More specific message
              style: TextStyle(
                color: Colors.grey[600], // Keep grey for empty state text
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    final maxValue = data.map((e) => e.jumlah).reduce((a, b) => a > b ? a : b);
    
    final barGroups = data.asMap().entries.map((entry) {
      final index = entry.key;
      final item = entry.value;
      return BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(
            toY: item.jumlah / 1000, // Assuming your values need scaling for the chart
            gradient: const LinearGradient(
              colors: [
                _chartBarGradientStart, // Start with lighter green
                _chartBarGradientEnd,   // End with darker green
              ],
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
            ),
            width: 18, // Slightly thinner bars for elegance
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(5), // Slightly more rounded corners
              topRight: Radius.circular(5),
            ),
          )
        ],
      );
    }).toList();

    final labels = data.map((e) => e.label).toList();

    return Container(
      height: 250,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16), // Adjusted padding
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: (maxValue / 1000) * 1.2, // Adds some padding above the highest bar
          barGroups: barGroups,
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: (maxValue / 1000) / 4, // Adjust interval for fewer lines
            getDrawingHorizontalLine: (value) {
              return const FlLine(
                color: _gridLineColor, // Light green/grey for grid lines
                strokeWidth: 1,
              );
            },
          ),
          borderData: FlBorderData(
            show: false, // Keeping border off for a cleaner look
          ),
          titlesData: FlTitlesData(
            show: true, // Ensure titles are shown
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 32,
                getTitlesWidget: (value, meta) {
                  final idx = value.toInt();
                  if (idx >= 0 && idx < labels.length) {
                    return Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        DateFormat('dd/MM').format(labels[idx]),
                        style: const TextStyle(
                          color: _axisLabelColor, // Darker color for readability
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    );
                  }
                  return const Text('');
                },
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 50,
                interval: (maxValue / 1000) / 4, // Match interval with horizontal grid lines
                getTitlesWidget: (value, meta) {
                  return Text(
                    '${NumberFormat.compact().format(value * 1000)}', // Show actual values
                    style: const TextStyle(
                      color: _axisLabelColor, // Darker color for readability
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
              tooltipBgColor: _tooltipBgColor, // Dark green tooltip background
              tooltipRoundedRadius: 8,
              tooltipPadding: const EdgeInsets.all(8),
              getTooltipItem: (group, groupIndex, rod, rodIndex) {
                final currency = NumberFormat.currency(locale: 'id', symbol: 'Rp ', decimalDigits: 0); // No decimal digits
                return BarTooltipItem(
                  '${DateFormat('dd MMM yyyy').format(labels[group.x])}\n', // Full date format
                  const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                    fontSize: 12,
                  ),
                  children: [
                    TextSpan(
                      text: currency.format(rod.toY * 1000),
                      style: const TextStyle(
                        color: _tooltipAmountColor, // Bright green for amount
                        fontWeight: FontWeight.bold,
                        fontSize: 14, // Slightly larger amount text
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