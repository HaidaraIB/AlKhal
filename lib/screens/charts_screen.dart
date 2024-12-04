import 'package:alkhal/utils/functions.dart';
import 'package:alkhal/widgets/indicator.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class ChartsScreen extends StatefulWidget {
  final Map<String, double> cashData;
  const ChartsScreen({
    super.key,
    required this.cashData,
  });

  @override
  State<ChartsScreen> createState() => _ChartsScreenState();
}

class _ChartsScreenState extends State<ChartsScreen> {
  int touchedIndex = -1;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("تحليلات بيانية"),
        backgroundColor: Colors.white,
        scrolledUnderElevation: 0.0,
      ),
      backgroundColor: Colors.white,
      body: Column(
        children: [
          _buildPieChart(),
        ],
      ),
    );
  }

  Widget _buildPieChart() {
    return AspectRatio(
      aspectRatio: 1.3,
      child: Row(
        children: <Widget>[
          Expanded(
            child: AspectRatio(
              aspectRatio: 1,
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
                        touchedIndex = pieTouchResponse
                            .touchedSection!.touchedSectionIndex;
                      });
                    },
                  ),
                  borderData: FlBorderData(
                    show: false,
                  ),
                  sectionsSpace: 0,
                  centerSpaceRadius: 40,
                  sections: showingSections(),
                ),
              ),
            ),
          ),
          const Column(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Indicator(
                color: Colors.green,
                text: 'ربح',
                isSquare: true,
              ),
              SizedBox(
                height: 4,
              ),
              Indicator(
                color: Colors.blue,
                text: 'كاش',
                isSquare: true,
              ),
              SizedBox(
                height: 4,
              ),
              Indicator(
                color: Colors.red,
                text: 'ديون',
                isSquare: true,
              ),
              SizedBox(
                height: 4,
              ),
              Indicator(
                color: Colors.yellow,
                text: 'حسم',
                isSquare: true,
              ),
              SizedBox(
                height: 18,
              ),
            ],
          ),
          const SizedBox(
            width: 28,
          ),
        ],
      ),
    );
  }

  List<PieChartSectionData> showingSections() {
    return List.generate(
      4,
      (i) {
        final isTouched = i == touchedIndex;
        final fontSize = isTouched ? 15.0 : 12.0;
        final radius = isTouched ? 60.0 : 50.0;
        const shadows = [
          Shadow(
            color: Colors.black,
            blurRadius: 5,
          )
        ];
        TextStyle titleStyle = TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.bold,
          color: Colors.white,
          shadows: shadows,
        );
        double cash = (((widget.cashData['cash']! -
                    (widget.cashData['profit']! +
                        widget.cashData['remainders']! +
                        widget.cashData['discounts']!)) *
                100) /
            widget.cashData['cash']!);
        double profit =
            ((widget.cashData['profit']! * 100) / widget.cashData['cash']!);
        double remainders =
            ((widget.cashData['remainders']! * 100) / widget.cashData['cash']!);
        double discounts =
            ((widget.cashData['discounts']! * 100) / widget.cashData['cash']!);
        switch (i) {
          case 0:
            return PieChartSectionData(
              color: Colors.green,
              value: profit,
              title: "${formatDouble(profit)}%",
              titleStyle: titleStyle,
              radius: radius,
            );
          case 1:
            return PieChartSectionData(
              color: Colors.blue,
              value: cash,
              title: "${formatDouble(cash)}%",
              titleStyle: titleStyle,
              radius: radius,
            );
          case 2:
            return PieChartSectionData(
              color: Colors.red,
              value: remainders,
              title: "${formatDouble(remainders)}%",
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
  }
}
