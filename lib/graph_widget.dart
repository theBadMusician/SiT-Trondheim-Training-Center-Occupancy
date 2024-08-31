import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'data_models.dart';

class GraphWidget extends StatefulWidget {
  final DayData dayData;

  GraphWidget({required this.dayData});

  @override
  _GraphWidgetState createState() => _GraphWidgetState();
}

class _GraphWidgetState extends State<GraphWidget> {
  late double nearestQuarterHour;
  late double nearestValue;
  bool showDefaultTooltip = true; // Flag to manage default tooltip display

  @override
  void initState() {
    super.initState();
    nearestQuarterHour = _getNearestQuarterHour(); // Calculate nearest 15-minute mark
    nearestValue = _getNearestValue(nearestQuarterHour); // Get the value at the nearest quarter hour
  }

  // Calculate the nearest 15-minute mark to the current time
  double _getNearestQuarterHour() {
    final now = DateTime.now();
    int minutes = (now.minute ~/ 15) * 15;
    if (now.minute % 15 >= 8) {
      minutes += 15;
    }
    double hour = now.hour + minutes / 60.0;
    return hour.clamp(5.0, 24.0); // Ensure it is within the valid range
  }

  // Get the value at the nearest quarter hour from the graph data
  double _getNearestValue(double hour) {
    for (var hourData in widget.dayData.hours.entries) {
      int hourValue = int.parse(hourData.key);
      if (hourValue + 0.25 >= hour) {
        for (var minuteEntry in hourData.value.minutes.entries) {
          double minuteValue = hourValue + int.parse(minuteEntry.key) / 60;
          if ((minuteValue - hour).abs() < 0.125) { // Check if within 15 minutes
            return minuteEntry.value.toDouble();
          }
        }
      }
    }
    return 0.0;
  }

  @override
  Widget build(BuildContext context) {
    List<FlSpot> spots = [];

    widget.dayData.hours.forEach((hour, hourData) {
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
      child: LayoutBuilder(
        builder: (context, constraints) {
          // Calculate dot position based on chart dimensions and data values
          final double x = constraints.maxWidth * (nearestQuarterHour - 5) / (24 - 5);
          // Correct y-position calculation by inverting and scaling
          print(nearestValue);
          final double y = constraints.maxHeight * (1 - nearestValue / 100);

          return Stack(
            children: [
              LineChart(
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
                    handleBuiltInTouches: true,
                    touchCallback: (FlTouchEvent event, LineTouchResponse? touchResponse) {
                      if (event is FlTapUpEvent || event is FlLongPressEnd) {
                        setState(() {
                          showDefaultTooltip = false; // Hide default tooltip on touch
                        });
                      }
                    },
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
              // Conditionally show the red dot and tooltip
              if (showDefaultTooltip)
                Positioned(
                  left: x, // Adjust for dot radius
                  top: y,  // Correct for dot radius
                  child: CustomPaint(
                    painter: _RedDotPainter(),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

// Custom painter to draw a red dot
class _RedDotPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.red
      ..style = PaintingStyle.fill;

    // Draw a red dot at the origin of the canvas
    canvas.drawCircle(Offset.zero, 5, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
