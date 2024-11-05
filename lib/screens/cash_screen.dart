import 'package:alkhal/cubit/cash/cash_cubit.dart';
import 'package:alkhal/utils/constants.dart';
import 'package:alkhal/utils/functions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart' as intl;

class CashScreen extends StatefulWidget {
  const CashScreen({super.key});

  @override
  State<CashScreen> createState() => _CashScreenState();
}

class _CashScreenState extends State<CashScreen>
    with SingleTickerProviderStateMixin {
  late DateTime startDate;
  late DateTime endDate;

  late Future<bool> _initArLocale;

  Future<bool> _initLocale() async {
    await initializeDateFormatting("ar_SA", null);
    return true;
  }

  @override
  void initState() {
    super.initState();
    startDate = DateTime.now();
    endDate = DateTime.now();
    BlocProvider.of<CashCubit>(context).computeCash(startDate, endDate);
    _initArLocale = _initLocale();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _initArLocale,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          return BlocBuilder<CashCubit, CashState>(
            builder: (context, state) {
              if (state is CashRefreshingFailed) {
                return buildErrorWidget(state.err);
              } else if (state is CashRefreshed) {
                return Scaffold(
                  backgroundColor: Colors.white,
                  body: RefreshIndicator(
                    onRefresh: () async {
                      await BlocProvider.of<CashCubit>(context)
                          .computeCash(startDate, endDate);
                    },
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Column(
                          children: [
                            const SizedBox(height: 20),
                            _buildDateRangeButton(context),
                            const SizedBox(height: 20),
                            _buildNumberWidgets(state),
                            const SizedBox(height: 90),
                          ],
                        ),
                      ),
                    ),
                  ),
                  floatingActionButton: FloatingActionButton(
                    onPressed: () {
                      BlocProvider.of<CashCubit>(context)
                          .computeCash(startDate, endDate);
                    },
                    child: const Icon(Icons.refresh),
                  ),
                );
              }
              return const Center(
                child: CircularProgressIndicator(
                  color: Colors.purple,
                ),
              );
            },
          );
        }
        return const Center(
          child: CircularProgressIndicator(
            color: Colors.purple,
          ),
        );
      },
    );
  }

  Widget _buildDateRangeButton(BuildContext context) {
    return ElevatedButton(
      onPressed: () => _selectDateRange(context),
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        backgroundColor: Colors.white,
        elevation: 3,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      child: Text(
        'من: ${intl.DateFormat("EEE d MMM y", "ar_SA").format(startDate)}\nإلى: ${intl.DateFormat("EEE d MMM y", "ar_SA").format(endDate)}',
        textAlign: TextAlign.center,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Colors.black87,
        ),
      ),
    );
  }

  Widget _buildNumberWidgets(CashState state) {
    return Column(
      children: [
        _buildNumberWidget('كاش', state.cash),
        const Divider(),
        _buildNumberWidget('ربح', state.profit),
        const Divider(),
        _buildNumberWidget('فواتير', state.bills),
        const Divider(),
        _buildNumberWidget('ديون', state.reminders),
      ],
    );
  }

  Widget _buildNumberWidget(String label, double value) {
    return AnimatedContainer(
      duration: const Duration(seconds: 1),
      curve: Curves.easeInOut,
      margin: const EdgeInsets.symmetric(vertical: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: NumberWidget(label: label, value: value),
    );
  }

  void _selectDateRange(BuildContext context) async {
    final DateTimeRange? pickedRange = await showDateRangePicker(
      context: context,
      initialDateRange: DateTimeRange(start: startDate, end: endDate),
      firstDate: DateTime(2023, 1, 1),
      lastDate: DateTime.now(),
    );

    if (pickedRange != null) {
      setState(() {
        startDate = pickedRange.start;
        endDate = pickedRange.end;
        BlocProvider.of<CashCubit>(context).computeCash(startDate, endDate);
      });
    }
  }
}

class NumberWidget extends StatelessWidget {
  final String label;
  final double value;

  const NumberWidget({
    super.key,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        TweenAnimationBuilder(
          tween: Tween<double>(begin: 0, end: value),
          duration: const Duration(milliseconds: 300),
          builder: (context, double val, child) {
            return Text(
              '${formatDouble(val)} ل.س',
              textDirection: TextDirection.rtl,
              style: const TextStyle(
                fontSize: 20,
                color: Colors.purple,
              ),
            );
          },
        ),
      ],
    );
  }
}
