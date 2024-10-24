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
  void initState() {
    super.initState();
    BlocProvider.of<ItemCubit>(context).loadItems();
  }

  @override
  Widget build(BuildContext context) {
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
            body: Column(
              children: [
                // const SizedBox(height: 10),
                // const Row(
                //   children: [
                //     SizedBox(width: 100),
                //     ItemsCategoriesDropDown(),
                //     SizedBox(width: 100),
                //   ],
                // ),
                // const SizedBox(height: 10),
                Expanded(
                  child: ListView.builder(
                    itemCount: state.items!.length,
                    itemBuilder: (BuildContext context, int index) {
                      return ItemCard(item: state.items![index] as Item);
                    },
                  ),
                ),
              ],
            ),
          );
        } else {
          return ExpandableFAB(
            fabs: addFabs,
            body: const Column(
              children: [
                // SizedBox(height: 10),
                // Row(
                //   children: [
                //     SizedBox(width: 100),
                //     ItemsCategoriesDropDown(),
                //     SizedBox(width: 100),
                //   ],
                // ),
                // SizedBox(height: 10),
                Center(
                  child: Text(
                    '!ليس لديك عناصر بعد',
                    style: TextStyle(fontSize: 20),
                  ),
                ),
              ],
            ),
          );
        }
      },
    );
  }
}

class ItemsCategoriesDropDown extends StatelessWidget {
  const ItemsCategoriesDropDown({super.key});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: DropdownButtonFormField<String>(
          decoration: InputDecoration(
            filled: true,
            fillColor: Theme.of(context).colorScheme.inversePrimary,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 20),
            hintText: 'Select an item',
            hintStyle: TextStyle(color: Colors.purple[300]),
          ),
          dropdownColor: Theme.of(context).colorScheme.inversePrimary,
          borderRadius: BorderRadius.circular(10),
          value: "العناصر",
          items: const [
            DropdownMenuItem(
              value: "العناصر",
              child: Text("العناصر"),
            ),
            DropdownMenuItem(
              value: "المجموعات",
              child: Text("المجموعات"),
            ),
          ],
          onChanged: (filter) => {}),
    );
  }
}
