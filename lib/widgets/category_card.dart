import 'package:alkhal/cubit/category/category_cubit.dart';
import 'package:alkhal/models/category.dart';
import 'package:alkhal/widgets/category_form.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CategoryCard extends StatefulWidget {
  final Category category;

  const CategoryCard({
    super.key,
    required this.category,
  });

  @override
  State<CategoryCard> createState() => _CategoryCardState();
}

class _CategoryCardState extends State<CategoryCard> {
  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // IconButton(
            //   onPressed: () {
            //     BlocProvider.of<CategoryCubit>(context)
            //         .deleteCategory(widget.category.id!);
            //   },
            //   icon: const Icon(Icons.delete),
            // ),
            IconButton(
              onPressed: () {
                final categoryCubit = BlocProvider.of<CategoryCubit>(context);
                showModalBottomSheet(
                  context: context,
                  builder: (newContext) => BlocProvider<CategoryCubit>.value(
                    value: categoryCubit,
                    child: CategoryForm(
                      category: widget.category,
                    ),
                  ),
                  isScrollControlled: true,
                );
              },
              icon: const Icon(Icons.edit),
            ),
            Padding(
              padding: const EdgeInsets.only(
                right: 16,
              ),
              child: Text(
                widget.category.name,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
