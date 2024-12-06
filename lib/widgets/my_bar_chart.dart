import 'package:alkhal/utils/functions.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class MyBarChart extends StatefulWidget {
  final Map<String, double> cashData;

  const MyBarChart({
    super.key,
    required this.cashData,
  });

  @override
  State<StatefulWidget> createState() => MyBarChartState();
}

class MyBarChartState extends State<MyBarChart> {
  final double width = 20;
  late double maxY;

  late List<BarChartGroupData> rawBarGroups;
  late List<BarChartGroupData> showingBarGroups;

  int touchedGroupIndex = -1;

  @override
  void initState() {
    super.initState();

    final values = widget.cashData.values.toList();
    final colors = [
      Colors.deepPurple,
      Colors.brown,
      Colors.black,
    ];

    rawBarGroups = [makeGroupData(values, colors)];

    showingBarGroups = rawBarGroups;

    maxY = values.isNotEmpty ? values.reduce((a, b) => a > b ? a : b) : 20;
  }

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1.3,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: BarChart(
          BarChartData(
            maxY: maxY,
            barTouchData: BarTouchData(
              touchTooltipData: BarTouchTooltipData(
                getTooltipItem: (group, groupIndex, rod, rodIndex) {
                  final key = widget.cashData.keys.toList()[rodIndex];
                  final avg = rod.toY;
                  final value = widget.cashData.values.toList()[rodIndex];
                  return BarTooltipItem(
                    '${cashTooltipToArabic(key)}: ${formatDouble(value)}\nمتوسط: ${formatDouble(avg)}',
                    const TextStyle(color: Colors.white),
                    textDirection: TextDirection.rtl,
                    textAlign: TextAlign.center,
                  );
                },
              ),
              touchCallback: (FlTouchEvent event, response) {
                if (response == null || response.spot == null) {
                  setState(() {
                    touchedGroupIndex = -1;
                    showingBarGroups = List.of(rawBarGroups);
                  });
                  return;
                }

                touchedGroupIndex = response.spot!.touchedBarGroupIndex;

                setState(
                  () {
                    if (!event.isInterestedForInteractions) {
                      touchedGroupIndex = -1;
                      showingBarGroups = List.of(rawBarGroups);
                      return;
                    }
                    showingBarGroups = List.of(rawBarGroups);
                    if (touchedGroupIndex != -1) {
                      var sum = 0.0;
                      for (final rod
                          in showingBarGroups[touchedGroupIndex].barRods) {
                        sum += rod.toY;
                      }
                      final avg = sum /
                          showingBarGroups[touchedGroupIndex].barRods.length;

                      showingBarGroups[touchedGroupIndex] =
                          showingBarGroups[touchedGroupIndex].copyWith(
                        barRods:
                            showingBarGroups[touchedGroupIndex].barRods.map(
                          (rod) {
                            return rod.copyWith(
                              toY: avg,
                              color: Colors.orange,
                            );
                          },
                        ).toList(),
                      );
                    }
                  },
                );
              },
            ),
            titlesData: FlTitlesData(
              show: true,
              rightTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
              topTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
              bottomTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 100,
                  interval: maxY / 5,
                  getTitlesWidget: leftTitles,
                ),
              ),
            ),
            borderData: FlBorderData(
              show: true,
            ),
            barGroups: showingBarGroups,
            gridData: const FlGridData(
              show: true,
            ),
          ),
        ),
      ),
    );
  }

  Widget leftTitles(double value, TitleMeta meta) {
    const style = TextStyle(
      color: Colors.deepPurple,
      fontWeight: FontWeight.bold,
      fontSize: 14,
    );
    return Text(
      formatDouble(value),
      style: style,
    );
  }

  BarChartGroupData makeGroupData(List<double> values, List<Color> colors) {
    return BarChartGroupData(
      x: 0,
      barRods: List<BarChartRodData>.generate(
        values.length,
        (index) {
          return BarChartRodData(
            toY: values[index],
            color: colors[index],
            width: width,
          );
        },
      ),
    );
  }

  String? cashTooltipToArabic(String tooltip) {
    Map<String, String> enToArCashToolTips = {
      "cash": "كاش",
      "bills": "فواتير",
      "spendings": "مصروف",
    };
    return enToArCashToolTips[tooltip];
  }
}
