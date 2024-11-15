import 'package:alkhal/cubit/add_category_fab_visibility/add_category_fab_visibility_cubit.dart';
import 'package:alkhal/cubit/add_item_fab_visibility/add_item_fab_visibility_cubit.dart';
import 'package:alkhal/cubit/category/category_cubit.dart';
import 'package:alkhal/cubit/item/item_cubit.dart';
import 'package:alkhal/cubit/item_history/item_history_cubit.dart';
import 'package:alkhal/cubit/transaction_item/transaction_item_cubit.dart';
import 'package:alkhal/widgets/items_categories_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ItemsScreen extends StatelessWidget {
  const ItemsScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => ItemCubit(),
        ),
        BlocProvider(
          create: (context) => CategoryCubit(),
        ),
        BlocProvider(
          create: (context) => ItemHistoryCubit(),
        ),
        BlocProvider(
          create: (context) => AddItemFabVisibilityCubit(),
        ),
        BlocProvider(
          create: (context) => AddCategoryFabVisibilityCubit(),
        ),
        BlocProvider(
          create: (context) => TransactionItemCubit(),
        ),
      ],
      child: const ItemsCategoriesView(),
    );
  }
}
