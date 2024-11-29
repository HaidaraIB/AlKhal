import 'package:alkhal/cubit/spending/spending_cubit.dart';
import 'package:alkhal/screens/add_spending_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AddSpendingFab extends StatefulWidget {
  const AddSpendingFab({super.key});

  @override
  State<AddSpendingFab> createState() => _AddSpendingFabState();
}

class _AddSpendingFabState extends State<AddSpendingFab> {
  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      heroTag: "AddSpendingFAB",
      child: const Icon(Icons.add),
      onPressed: () {
        final spendingCubit = BlocProvider.of<SpendingCubit>(context);
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (newContext) {
              return BlocProvider<SpendingCubit>.value(
                value: spendingCubit,
                child: const AddSpendingScreen(),
              );
            },
          ),
        );
      },
    );
  }
}
