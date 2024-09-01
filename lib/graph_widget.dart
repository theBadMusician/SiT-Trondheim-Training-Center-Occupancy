import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'data_models.dart'; // Assuming this is where DayData is defined
import 'red_dot_painter.dart'; // New file for custom painter

/// A widget that displays a line graph for a given day's data.
class GraphWidget extends StatefulWidget {
  // Data for a specific day that is displayed on the graph
  final DayData dayData;

  /// Creates a [GraphWidget] with the provided day's data.
  const GraphWidget({super.key, required this.dayData});

  @override
  GraphWidgetState createState() => GraphWidgetState();
}

/// State class for [GraphWidget].
class GraphWidgetState extends State<GraphWidget> {
  late double nearestQuarterHour; // Stores the nearest quarter-hour mark relative to current time
  late int nearestMinutes; // Stores the nearest quarter-minutes value to current time
  late int nearestValue; // Stores the value at the nearest quarter-hour

  @override
  void initState() {
    super.initState();
    _updateNearestQuarterAndValue(); // Initialize nearest quarter-hour and value
  }

  @override
  void didUpdateWidget(covariant GraphWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.dayData != oldWidget.dayData) {
      _updateNearestQuarterAndValue(); // Recalculate nearest quarter-hour and value on data change
    }
  }

  void _updateNearestQuarterAndValue() {
    var nearestQuarterData = _getNearestQuarterHour();
    nearestQuarterHour = nearestQuarterData.$1;
    nearestMinutes = nearestQuarterData.$2;
    nearestValue = _getNearestValue(nearestQuarterHour, nearestMinutes);
  }

  /// Calculates the nearest quarter-hour mark to the current time.
  (double, int) _getNearestQuarterHour() {
    final now = DateTime.now();
    // Calculate the nearest 15-minute increment
    int minutes = (now.minute ~/ 15) * 15;
    if (now.minute % 15 >= 8) {
      minutes += 15; // Round up if past the halfway mark of the quarter
    }
    // Convert time to a decimal format for hours
    double hour = now.hour + minutes / 60.0;
    return (hour.clamp(5.0, 24.0), minutes); // Ensure it is within the valid range of the graph (5:00 to 24:00)
  }

  /// Gets the value from the graph data at the nearest quarter-hour.
  int _getNearestValue(double hour, int minutes) {
    String hourKey = (hour.floor()).toString() ?? "12";
    HourData hourEntry = widget.dayData.hours[hourKey]!;
    int minuteEntry = hourEntry.minutes[minutes.toString()]!; // Value
    return minuteEntry;
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
        gridData: const FlGridData(show: true),
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
                    style: const TextStyle(fontSize: 10),
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
                    style: const TextStyle(fontSize: 10),
                  ),
                );
              },
            ),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          rightTitles: const AxisTitles(
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
            dotData: const FlDotData(show: false),
          ),
        ],
        lineTouchData: LineTouchData(
          handleBuiltInTouches: true,
          touchTooltipData: _buildTooltipData(),
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
      tooltipBorder: const BorderSide(color: Colors.grey),
      getTooltipItems: (List<LineBarSpot> touchedSpots) {
        return touchedSpots.map((LineBarSpot touchedSpot) {
          const TextStyle timeStyle = TextStyle(
            color: Colors.red,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          );
          const TextStyle valueStyle = TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          );

          final String hourMinute = '${touchedSpot.x.toInt()}:${((touchedSpot.x - touchedSpot.x.toInt()) * 60).toInt().toString().padLeft(2, '0')}';
          final String value = '${touchedSpot.y.toInt()}%';

          return LineTooltipItem(
            '$hourMinute\n',
            timeStyle,
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
      left: x + 9,
      top: y - 9,
      child: CustomPaint(
        painter: RedDotPainter(y - 10),
      ),
    );
  }
}
