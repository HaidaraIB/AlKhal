import 'package:alkhal/cubit/item/item_cubit.dart';
import 'package:alkhal/screens/add_item_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AddItemFAB extends StatelessWidget {
  const AddItemFAB({
    super.key,
    required this.defaultCategory,
  });

  final String defaultCategory;

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      heroTag: "AddItemFAB",
      child: const Icon(Icons.add),
      onPressed: () {
        final itemCubit = BlocProvider.of<ItemCubit>(context);
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (newContext) {
              return BlocProvider<ItemCubit>.value(
                value: itemCubit,
                child: AddItemForm(defaultCategory: defaultCategory),
              );
            },
          ),
        );
      },
    );
  }
}
