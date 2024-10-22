import 'package:alkhal/cubit/item/item_cubit.dart';
import 'package:alkhal/models/item.dart';
import 'package:alkhal/widgets/add_category_fab.dart';
import 'package:alkhal/widgets/add_item_fab.dart';
import 'package:alkhal/widgets/expandable_fab.dart';
import 'package:alkhal/widgets/item_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class Items extends StatefulWidget {
  const Items({super.key});

  @override
  State<Items> createState() => _ItemsState();
}

class _ItemsState extends State<Items> {
  List<Widget> addFabs = const [
    Positioned(
      right: 20,
      bottom: 90,
      child: AddItemFAB(),
    ),
    Positioned(
      right: 20,
      bottom: 140,
      child: AddCategoryFAB(),
    ),
  ];
  @override
  Widget build(BuildContext context) {
    BlocProvider.of<ItemCubit>(context).loadItems();
    return BlocBuilder<ItemCubit, ItemState>(
      builder: (context, state) {
        if (state is LoadingItems) {
          return const Center(
            child: CircularProgressIndicator(
              color: Colors.blue,
            ),
          );
        } else if (state is LoadingItemsFailed) {
          return const Center(
            child: Text("Something went wrong!"),
          );
        } else if (state.items!.isNotEmpty) {
          return ExpandableFAB(
            fabs: addFabs,
            body: ListView.builder(
              itemCount: state.items!.length,
              itemBuilder: (BuildContext context, int index) {
                return ItemCard(item: state.items![index] as Item);
              },
            ),
          );
        } else {
          return ExpandableFAB(
            fabs: addFabs,
            body: const Center(
              child: Text('ليس لديك عناصر بعد'),
            ),
          );
        }
      },
    );
  }
}
