import 'package:alkhal/widgets/my_bar_chart.dart';
import 'package:alkhal/widgets/my_pie_chart.dart';
import 'package:alkhal/widgets/pie_chart_indicator.dart';
import 'package:flutter/material.dart';

class ChartsScreen extends StatefulWidget {
  final Map<String, double> cashData;
  const ChartsScreen({
    super.key,
    this.cashData = const {
      "cash": 0,
      "remainders": 0,
      "profit": 0,
      "discounts": 0,
      "bills": 0,
      "spendings": 0,
    },
  });

  @override
  State<ChartsScreen> createState() => _ChartsScreenState();
}

class _ChartsScreenState extends State<ChartsScreen> {
  bool pieChartSelected = true;
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text("رسوم بيانية"),
        backgroundColor: theme.scaffoldBackgroundColor,
        scrolledUnderElevation: 0.0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: pieChartSelected
                ? [
                    _buildChartsButton(),
                    MyPieChart(cashData: widget.cashData),
                    const SizedBox(height: 24.0),
                    _buildPieChartLegend(),
                    const Divider(),
                  ]
                : [
                    _buildChartsButton(),
                    MyBarChart(cashData: {
                      "cash": widget.cashData['cash']!,
                      "bills": widget.cashData['bills']!,
                      "spendings": widget.cashData['spendings']!,
                    }),
                    const SizedBox(height: 24.0),
                    _buildBarChartLegend(),
                    const Divider(),
                  ],
          ),
        ),
      ),
    );
  }

  Widget _buildChartsButton() {
    return Align(
      alignment: Alignment.topRight,
      child: IconButton(
        onPressed: () {
          setState(() {
            pieChartSelected = !pieChartSelected;
          });
        },
        icon: Icon(
          pieChartSelected ? Icons.bar_chart : Icons.pie_chart,
          color: Colors.deepPurple,
        ),
      ),
    );
  }

  Widget _buildBarChartLegend() {
    return const Padding(
      padding: EdgeInsets.only(right: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Indicator(
            color: Colors.deepPurple,
            text: 'كاش',
            isSquare: true,
            isLabelToTheRight: true,
          ),
          Indicator(
            color: Colors.brown,
            text: 'فواتير',
            isSquare: true,
            isLabelToTheRight: true,
          ),
          Indicator(
            color: Colors.black,
            text: 'مصروف',
            isSquare: true,
            isLabelToTheRight: true,
          ),
        ],
      ),
    );
  }

  Widget _buildPieChartLegend() {
    return const Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        Indicator(
          color: Colors.deepPurple,
          text: 'كاش',
          isSquare: true,
        ),
        Indicator(
          color: Colors.red,
          text: 'ديون',
          isSquare: true,
        ),
        Indicator(
          color: Colors.green,
          text: 'ربح',
          isSquare: true,
        ),
        Indicator(
          color: Colors.yellow,
          text: 'حسم',
          isSquare: true,
        ),
      ],
    );
  }
}
