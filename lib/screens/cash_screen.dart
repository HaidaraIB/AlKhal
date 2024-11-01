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
  late DateTime selectedDate;

  late Future<bool> _initArLocale;

  Future<bool> _initLocale() async {
    await initializeDateFormatting("ar_SA", null);
    return true;
  }

  @override
  void initState() {
    super.initState();
    selectedDate = DateTime.now();
    BlocProvider.of<CashCubit>(context).computeCash(selectedDate);
    _initArLocale = _initLocale();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _initArLocale,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return BlocBuilder<CashCubit, CashState>(
            builder: (context, state) {
              if (state is CashRefreshingFailed) {
                return buildErrorWidget(state.err);
              } else if (state is CashRefreshed) {
                return Scaffold(
                  backgroundColor: Colors.white,
                  body: SingleChildScrollView(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const SizedBox(
                            height: 10,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              TextButton(
                                onPressed: () => _selectDate(context),
                                style: ButtonStyle(
                                  backgroundColor: WidgetStatePropertyAll(
                                    Theme.of(context)
                                        .colorScheme
                                        .inversePrimary,
                                  ),
                                ),
                                child: Text(
                                  intl.DateFormat("EEEE d MMMM y", "ar_SA")
                                      .format(selectedDate),
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 30),
                          AnimatedContainer(
                            duration: const Duration(seconds: 1),
                            curve: Curves.easeInOut,
                            child:
                                NumberWidget(label: 'كاش', value: state.cash),
                          ),
                          const SizedBox(height: 50),
                          AnimatedContainer(
                            duration: const Duration(seconds: 1),
                            curve: Curves.easeInOut,
                            child:
                                NumberWidget(label: 'ربح', value: state.profit),
                          ),
                          const SizedBox(height: 50),
                          AnimatedContainer(
                            duration: const Duration(seconds: 1),
                            curve: Curves.easeInOut,
                            child: NumberWidget(
                                label: 'فواتير', value: state.bills),
                          ),
                          const SizedBox(height: 100),
                        ],
                      ),
                    ),
                  ),
                  floatingActionButton: FloatingActionButton(
                    onPressed: () {
                      BlocProvider.of<CashCubit>(context)
                          .computeCash(selectedDate);
                    },
                    child: const Icon(Icons.refresh),
                  ),
                );
              } else {
                return const Center(
                  child: CircularProgressIndicator(
                    color: Colors.blue,
                  ),
                );
              }
            },
          );
        } else {
          return const Center(
            child: CircularProgressIndicator(
              color: Colors.blue,
            ),
          );
        }
      },
    );
  }

  void _selectDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2023, 1, 1),
      lastDate: DateTime.now(),
    );
    if (pickedDate != null && pickedDate != selectedDate) {
      setState(() {
        selectedDate = pickedDate;
        BlocProvider.of<CashCubit>(context).computeCash(selectedDate);
      });
    }
  }
}

class NumberWidget extends StatelessWidget {
  final String label;
  final double value;

  const NumberWidget({super.key, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 40,
            fontWeight: FontWeight.bold,
          ),
        ),
        TweenAnimationBuilder(
          tween: Tween<double>(begin: 0, end: value),
          duration: const Duration(milliseconds: 300),
          builder: (context, double val, child) {
            return Text(
              '${formatDouble(val)} ل.س',
              textDirection: TextDirection.rtl,
              style: const TextStyle(
                fontSize: 30,
              ),
            );
          },
        ),
      ],
    );
  }
}
