import 'package:alkhal/utils/functions.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class MyPieChart extends StatefulWidget {
  final Map cashData;
  const MyPieChart({
    super.key,
    required this.cashData,
  });

  @override
  State<MyPieChart> createState() => _MyPieChartState();
}

class _MyPieChartState extends State<MyPieChart> {
  int touchedIndex = -1;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1.3,
      child: PieChart(
        PieChartData(
          pieTouchData: PieTouchData(
            touchCallback: (FlTouchEvent event, pieTouchResponse) {
              setState(() {
                if (!event.isInterestedForInteractions ||
                    pieTouchResponse == null ||
                    pieTouchResponse.touchedSection == null) {
                  touchedIndex = -1;
                  return;
                }
                touchedIndex =
                    pieTouchResponse.touchedSection!.touchedSectionIndex;
              });
            },
          ),
          borderData: FlBorderData(show: false),
          sectionsSpace: 0,
          centerSpaceRadius: 40,
          sections: showingSections(),
        ),
      ),
    );
  }

  List<PieChartSectionData> showingSections() {
    const shadows = [
      Shadow(
        color: Colors.black,
        blurRadius: 5,
      )
    ];
    if (widget.cashData['cash']! != 0) {
      return List.generate(
        4,
        (i) {
          final isTouched = i == touchedIndex;
          final fontSize = isTouched ? 15.0 : 12.0;
          final radius = isTouched ? 60.0 : 50.0;
          final titleStyle = TextStyle(
            fontSize: fontSize,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            shadows: shadows,
          );
          final cash = (((widget.cashData['cash']! -
                      (widget.cashData['profit']! +
                          widget.cashData['remainders']! +
                          widget.cashData['discounts']!)) *
                  100) /
              widget.cashData['cash']!);
          final profit =
              ((widget.cashData['profit']! * 100) / widget.cashData['cash']!);
          final remainders = ((widget.cashData['remainders']! * 100) /
              widget.cashData['cash']!);
          final discounts = ((widget.cashData['discounts']! * 100) /
              widget.cashData['cash']!);
          switch (i) {
            case 0:
              return PieChartSectionData(
                color: Colors.deepPurple,
                value: cash,
                title: "${formatDouble(cash)}%",
                titleStyle: titleStyle,
                radius: radius,
              );
            case 1:
              return PieChartSectionData(
                color: Colors.red,
                value: remainders,
                title: "${formatDouble(remainders)}%",
                titleStyle: titleStyle,
                radius: radius,
              );
            case 2:
              return PieChartSectionData(
                color: Colors.green,
                value: profit,
                title: "${formatDouble(profit)}%",
                titleStyle: titleStyle,
                radius: radius,
              );
            case 3:
              return PieChartSectionData(
                color: Colors.yellow,
                value: discounts,
                title: "${formatDouble(discounts)}%",
                titleStyle: titleStyle,
                radius: radius,
              );
            default:
              throw Error();
          }
        },
      );
    } else {
      final isTouched = touchedIndex == 0;
      final fontSize = isTouched ? 15.0 : 12.0;
      final radius = isTouched ? 60.0 : 50.0;
      final titleStyle = TextStyle(
        fontSize: fontSize,
        fontWeight: FontWeight.bold,
        color: Colors.white,
        shadows: shadows,
      );
      return [
        PieChartSectionData(
          color: Colors.grey,
          value: 100,
          titleStyle: titleStyle,
          radius: radius,
          showTitle: false,
        ),
      ];
    }
  }
}
