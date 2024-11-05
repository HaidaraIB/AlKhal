import 'package:alkhal/cubit/item/item_cubit.dart';
import 'package:alkhal/cubit/transaction/transaction_cubit.dart';
import 'package:alkhal/cubit/transaction_item/transaction_item_cubit.dart';
import 'package:alkhal/screens/add_transaction_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AddTransactionFAB extends StatefulWidget {
  const AddTransactionFAB({super.key});

  @override
  State<AddTransactionFAB> createState() => _AddTransactionFABState();
}

class _AddTransactionFABState extends State<AddTransactionFAB> {
  @override
  void initState() {
    super.initState();
    BlocProvider.of<ItemCubit>(context).loadItems();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ItemCubit, ItemState>(
      builder: (context, state) {
        return FloatingActionButton(
          heroTag: "AddTransactionFAB",
          child: const Icon(Icons.add),
          onPressed: () async {
            if (state is LoadingItems) {
              showDialog(
                context: context,
                builder: (context) {
                  return const Center(
                    child: CircularProgressIndicator(
                      color: Colors.purple,
                    ),
                  );
                },
              );
            } else if (state.items!.isNotEmpty) {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (newContext) {
                    return MultiBlocProvider(
                      providers: [
                        BlocProvider<TransactionCubit>.value(
                          value: BlocProvider.of<TransactionCubit>(context),
                        ),
                        BlocProvider<ItemCubit>.value(
                          value: BlocProvider.of<ItemCubit>(context),
                        ),
                        BlocProvider<TransactionItemCubit>.value(
                          value: BlocProvider.of<TransactionItemCubit>(context),
                        )
                      ],
                      child: const AddTransactionForm(),
                    );
                  },
                ),
              );
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                    'ليس لديك عناصر بعد!',
                    textAlign: TextAlign.center,
                    textDirection: TextDirection.rtl,
                  ),
                ),
              );
            }
          },
        );
      },
    );
  }
}
