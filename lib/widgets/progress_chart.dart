import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class ProgressChart extends StatelessWidget {
  const ProgressChart({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(16.0),
      child: Column(
        children: [
          Text(
            "Your Pain Levels Over Time",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 10),
          Expanded(
            child: Row(
              children: [
                RotatedBox(
                  quarterTurns: -1,
                  child: Text(
                    "Pain Level (0-10)",  // ✅ Y-axis label
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black54),
                  ),
                ),
                Expanded(
                  child: LineChart(
                    LineChartData(
                      minY: 0,  // ✅ Ensure Y-axis starts at 0
                      maxY: 10, // ✅ Ensure Y-axis ends at 10
                      gridData: FlGridData(
                        show: true,
                        getDrawingHorizontalLine: (value) {
                          return FlLine(
                            color: Colors.grey.shade400,
                            strokeWidth: 1,
                          );
                        },
                      ),
                      titlesData: FlTitlesData(
                        leftTitles: AxisTitles(
                          axisNameSize: 20,
                          sideTitles: SideTitles(
                            showTitles: true,
                            interval: 1, // ✅ Show numbers from 0 to 10
                            reservedSize: 40,
                            getTitlesWidget: (value, meta) {
                              return Text(
                                value.toInt().toString(),
                                style: TextStyle(fontSize: 14),
                              );
                            },
                          ),
                        ),
                        bottomTitles: AxisTitles(
                          axisNameSize: 0, // ❌ Remove extra "Days" label below X-axis
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 25, // ✅ Lower X-axis values a bit
                            getTitlesWidget: (value, meta) {
                              return Padding(
                                padding: EdgeInsets.only(top: 5), // ✅ Shift X-axis values down
                                child: Text(
                                  "Day ${value.toInt()}",
                                  style: TextStyle(fontSize: 12),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                      borderData: FlBorderData(show: false),
                      lineBarsData: [
                        LineChartBarData(
                          spots: [
                            FlSpot(1, 8),
                            FlSpot(2, 7.5),
                            FlSpot(3, 6),
                            FlSpot(4, 5),
                            FlSpot(5, 4),
                            FlSpot(6, 3),
                            FlSpot(7, 2),
                          ],
                          isCurved: true,
                          gradient: LinearGradient(
                            colors: [Colors.red, Colors.blue],
                          ),
                          barWidth: 6,
                          belowBarData: BarAreaData(
                            show: false, // ❌ Removed the highlight area
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
