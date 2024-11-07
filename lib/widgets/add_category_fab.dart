import 'package:alkhal/cubit/category/category_cubit.dart';
import 'package:alkhal/models/category.dart';
import 'package:alkhal/services/database_helper.dart';
import 'package:alkhal/widgets/category_form.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AddCategoryFAB extends StatelessWidget {
  const AddCategoryFAB({super.key});

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      heroTag: "AddCategoryFAB",
      child: const Icon(Icons.add),
      onPressed: () {
        final categoryCubit = BlocProvider.of<CategoryCubit>(context);
        showModalBottomSheet(
          context: context,
          builder: (newContext) => BlocProvider<CategoryCubit>.value(
            value: categoryCubit,
            child: CategoryForm(
              categoriesFuture:
                  DatabaseHelper.getAll(Category.tableName, "Category"),
            ),
          ),
          isScrollControlled: true,
        );
      },
    );
  }
}
