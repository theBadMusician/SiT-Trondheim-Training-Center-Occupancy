import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'data_models.dart'; // Assuming this is where DayData is defined
import 'red_dot_painter.dart'; // New file for custom painter

/// A widget that displays a line graph for a given day's data.
class GraphWidget extends StatefulWidget {
  // Data for a specific day that is displayed on the graph
  final DayData dayData;

  /// Creates a [GraphWidget] with the provided day's data.
  GraphWidget({required this.dayData});

  @override
  _GraphWidgetState createState() => _GraphWidgetState();
}

/// State class for [GraphWidget].
class _GraphWidgetState extends State<GraphWidget> {
  late double nearestQuarterHour;  // Stores the nearest quarter-hour mark relative to current time
  late double nearestValue;  // Stores the value at the nearest quarter-hour
  bool showDefaultTooltip = true;  // Flag to manage default tooltip display

  @override
  void initState() {
    super.initState();
    // Initialize the nearest quarter-hour and its value
    nearestQuarterHour = _getNearestQuarterHour();  // Calculate nearest 15-minute mark
    nearestValue = _getNearestValue(nearestQuarterHour);  // Get the value at the nearest quarter-hour
  }

  /// Calculates the nearest quarter-hour mark to the current time.
  double _getNearestQuarterHour() {
    final now = DateTime.now();
    // Calculate the nearest 15-minute increment
    int minutes = (now.minute ~/ 15) * 15;
    if (now.minute % 15 >= 8) {
      minutes += 15;  // Round up if past the halfway mark of the quarter
    }
    // Convert time to a decimal format for hours
    double hour = now.hour + minutes / 60.0;
    return hour.clamp(5.0, 24.0);  // Ensure it is within the valid range of the graph (5:00 to 24:00)
  }

  /// Gets the value from the graph data at the nearest quarter-hour.
  double _getNearestValue(double hour) {
    // Iterate over the hours in the day data
    for (var hourData in widget.dayData.hours.entries) {
      int hourValue = int.parse(hourData.key);
      // Check if within the hour and the next quarter-hour
      if (hourValue + 0.25 >= hour) {
        for (var minuteEntry in hourData.value.minutes.entries) {
          // Calculate minute value as a decimal hour
          double minuteValue = hourValue + int.parse(minuteEntry.key) / 60;
          if ((minuteValue - hour).abs() < 0.125) {  // Check if within 15 minutes
            return minuteEntry.value.toDouble();
          }
        }
      }
    }
    return 0.0;  // Default to 0 if no close match found
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 8.0, right: 24.0, top: 8.0, bottom: 8.0),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final double x = _calculateDotPositionX(constraints.maxWidth);
          final double y = _calculateDotPositionY(constraints.maxHeight);

          return Stack(
            children: [
              _buildLineChart(),
              if (showDefaultTooltip)
                _buildRedDot(x, y),
            ],
          );
        },
      ),
    );
  }

  /// Helper method to calculate the X position of the red dot on the chart.
  double _calculateDotPositionX(double maxWidth) {
    return maxWidth * (nearestQuarterHour - 5) / (24 - 5);
  }

  /// Helper method to calculate the Y position of the red dot on the chart.
  double _calculateDotPositionY(double maxHeight) {
    return maxHeight * (1 - nearestValue / 100);
  }

  /// Widget to build the line chart.
  Widget _buildLineChart() {
    List<FlSpot> spots = _prepareChartData();
    return LineChart(
      LineChartData(
        minY: 0,
        maxY: 100,
        minX: 5,
        maxX: 24,
        gridData: FlGridData(show: true),
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 16,
              interval: 4,
              getTitlesWidget: (value, meta) {
                return Padding(
                  padding: const EdgeInsets.only(top: 4.0),
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
              reservedSize: 24,
              interval: 25,
              getTitlesWidget: (value, meta) {
                return Padding(
                  padding: const EdgeInsets.only(right: 4.0),
                  child: Text(
                    '${value.toInt()}',
                    style: TextStyle(fontSize: 10),
                  ),
                );
              },
            ),
          ),
          topTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          rightTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: false),
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
            color: Colors.blue,
            barWidth: 3,
            isStrokeCapRound: true,
            belowBarData: BarAreaData(show: true),
            dotData: FlDotData(show: false),
          ),
        ],
        lineTouchData: LineTouchData(
          handleBuiltInTouches: true,
          touchTooltipData: _buildTooltipData(),
          touchCallback: (FlTouchEvent event, LineTouchResponse? touchResponse) {
            if (event is FlTapUpEvent || event is FlLongPressEnd) {
              setState(() {
                showDefaultTooltip = false;
              });
            }
          },
        ),
      ),
    );
  }

  /// Helper method to prepare the data points for the chart.
  List<FlSpot> _prepareChartData() {
    List<FlSpot> spots = [];
    widget.dayData.hours.forEach((hour, hourData) {
      int hourValue = int.parse(hour);
      if (hourValue >= 5 && hourValue <= 24) {
        hourData.minutes.forEach((minute, value) {
          double timeValue = hourValue + int.parse(minute) / 60;
          spots.add(FlSpot(timeValue, value.toDouble()));
        });
      }
    });
    return spots;
  }

  /// Helper method to configure tooltip data.
  LineTouchTooltipData _buildTooltipData() {
    return LineTouchTooltipData(
      tooltipPadding: const EdgeInsets.all(8.0),
      tooltipMargin: 8.0,
      tooltipRoundedRadius: 8.0,
      tooltipBorder: BorderSide(color: Colors.grey),
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
    );
  }

  /// Widget to build the red dot that indicates the nearest quarter-hour value.
  Widget _buildRedDot(double x, double y) {
    return Positioned(
      left: x,
      top: y,
      child: CustomPaint(
        painter: RedDotPainter(),
      ),
    );
  }
}
