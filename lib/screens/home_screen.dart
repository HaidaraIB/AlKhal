import 'package:alkhal/cubit/cash/cash_cubit.dart';
import 'package:alkhal/utils/functions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => CashCubit(),
      child: const CashScreen(),
    );
  }
}

class CashScreen extends StatefulWidget {
  const CashScreen({super.key});

  @override
  State<CashScreen> createState() => _CashScreenState();
}

class _CashScreenState extends State<CashScreen> {
  @override
  void initState() {
    super.initState();
    BlocProvider.of<CashCubit>(context).computeCash();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CashCubit, CashState>(
      builder: (context, state) {
        if (state is LoadingCash) {
          return const Center(
            child: CircularProgressIndicator(
              color: Colors.blue,
            ),
          );
        } else if (state is CashRefreshed) {
          return Scaffold(
            body: SingleChildScrollView(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(
                      height: 50,
                    ),
                    AnimatedContainer(
                      duration: const Duration(seconds: 1),
                      curve: Curves.easeInOut,
                      child: NumberWidget(label: 'كاش', value: state.cash),
                    ),
                    const SizedBox(height: 50),
                    AnimatedContainer(
                      duration: const Duration(seconds: 1),
                      curve: Curves.easeInOut,
                      child: NumberWidget(label: 'ربح', value: state.profit),
                    ),
                    const SizedBox(height: 50),
                    AnimatedContainer(
                      duration: const Duration(seconds: 1),
                      curve: Curves.easeInOut,
                      child: NumberWidget(label: 'فواتير', value: state.bills),
                    ),
                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ),
            floatingActionButton: FloatingActionButton(
              onPressed: () {
                setState(() {
                  BlocProvider.of<CashCubit>(context).computeCash();
                });
              },
              child: const Icon(Icons.refresh),
            ),
          );
        } else {
          return const Center(
            child: Text(
              "Something went wrong!",
              style: TextStyle(fontSize: 20),
            ),
          );
        }
      },
    );
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
              style: const TextStyle(fontSize: 32),
            );
          },
        ),
      ],
    );
  }
}
