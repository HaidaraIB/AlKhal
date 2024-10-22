import 'package:alkhal/cubit/category/category_cubit.dart';
import 'package:alkhal/widgets/add_category_form.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AddCategoryFAB extends StatelessWidget {
  const AddCategoryFAB({super.key});

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      heroTag: "AddCategoryFAB",
      mini: true,
      child: const Icon(Icons.label),
      onPressed: () {
        showModalBottomSheet(
          context: context,
          builder: (newContext) => BlocProvider<CategoryCubit>.value(
            value: BlocProvider.of<CategoryCubit>(context),
            child: const AddCategoryForm(),
          ),
          isScrollControlled: true,
        );
      },
    );
  }
}
