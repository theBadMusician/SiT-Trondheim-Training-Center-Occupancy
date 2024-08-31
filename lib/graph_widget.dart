import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'data_models.dart';

class GraphWidget extends StatelessWidget {
  final DayData dayData;

  GraphWidget({required this.dayData});

  @override
  Widget build(BuildContext context) {
    List<FlSpot> spots = [];

    dayData.hours.forEach((hour, hourData) {
      int hourValue = int.parse(hour);
      if (hourValue >= 5 && hourValue <= 24) { // Filter hours within range
        hourData.minutes.forEach((minute, value) {
          double timeValue = hourValue + int.parse(minute) / 60;
          spots.add(FlSpot(timeValue, value.toDouble()));
        });
      }
    });

    return Padding(
      padding: const EdgeInsets.only(left: 8.0, right: 24.0, top: 8.0, bottom: 8.0), // Added extra padding to the right
      child: LineChart(
        LineChartData(
          minY: 0, // Fixed y-axis minimum
          maxY: 100, // Fixed y-axis maximum
          minX: 5, // Fixed x-axis minimum (05:00)
          maxX: 24, // Fixed x-axis maximum (24:00)
          gridData: FlGridData(show: true),
          titlesData: FlTitlesData(
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 16, // Reduced reserved size for x-axis
                interval: 4, // Ticks every 4 hours on x-axis
                getTitlesWidget: (value, meta) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 4.0), // Moves x-tick labels down
                    child: Text(
                      '${value.toInt()}:00',
                      style: TextStyle(fontSize: 10),
                    ),
                  );
                },
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 24, // Reduced reserved size for y-axis
                interval: 25, // Ticks every 25 points on y-axis
                getTitlesWidget: (value, meta) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 4.0), // Moves y-tick labels to the left
                    child: Text(
                      '${value.toInt()}',
                      style: TextStyle(fontSize: 10),
                    ),
                  );
                },
              ),
            ),
            topTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: false, // Hide top titles
              ),
            ),
            rightTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: false, // Hide right titles
              ),
            ),
          ),
          borderData: FlBorderData(
            show: true,
            border: Border.all(color: const Color(0xff37434d), width: 1),
          ),
          lineBarsData: [
            LineChartBarData(
              spots: spots,
              isCurved: true,
              color: Colors.blue, // Setting color to blue
              barWidth: 3,
              isStrokeCapRound: true,
              belowBarData: BarAreaData(show: true),
              dotData: FlDotData(show: false), // Hides the dots on the graph
            ),
          ],
          lineTouchData: LineTouchData(
            touchTooltipData: LineTouchTooltipData(
              tooltipPadding: const EdgeInsets.all(8.0),  // Padding around tooltip content
              tooltipMargin: 8.0,  // Space between the touch spot and the tooltip
              tooltipRoundedRadius: 8.0,  // Rounded corners for the tooltip
              tooltipBorder: BorderSide(color: Colors.grey),  // Border color for the tooltip
              getTooltipItems: (List<LineBarSpot> touchedSpots) {
                return touchedSpots.map((LineBarSpot touchedSpot) {
                  final TextStyle timeStyle = TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  );
                  final TextStyle valueStyle = TextStyle(
                    color: Colors.blue,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  );

                  // Extract time and value for display
                  final String hourMinute = '${touchedSpot.x.toInt()}:${((touchedSpot.x - touchedSpot.x.toInt()) * 60).toInt().toString().padLeft(2, '0')}';
                  final String value = '${touchedSpot.y.toInt()}%';

                  return LineTooltipItem(
                    '$hourMinute\n', timeStyle,
                    children: [
                      TextSpan(
                        text: value,
                        style: valueStyle,
                      ),
                    ],
                  );
                }).toList();
              },
            ),
          ),
        ),
      ),
    );
  }
}
