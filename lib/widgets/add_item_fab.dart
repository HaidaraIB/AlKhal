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
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (newcontext) {
              return BlocProvider<ItemCubit>.value(
                value: BlocProvider.of(context),
                child: AddItemForm(defaultCategory: defaultCategory),
              );
            },
          ),
        );
      },
    );
  }
}
