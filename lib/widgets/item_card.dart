import 'package:alkhal/cubit/item/item_cubit.dart';
import 'package:alkhal/cubit/item_history/item_history_cubit.dart';
import 'package:alkhal/models/category.dart';
import 'package:alkhal/models/item.dart';
import 'package:alkhal/models/measurement_unit.dart';
import 'package:alkhal/models/model.dart';
import 'package:alkhal/screens/item_history_screen.dart';
import 'package:alkhal/screens/update_item_screen.dart';
import 'package:alkhal/services/database_helper.dart';
import 'package:alkhal/utils/functions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ItemCard extends StatefulWidget {
  final Item item;

  const ItemCard({super.key, required this.item});

  @override
  State<ItemCard> createState() => _ItemCardState();
}

class _ItemCardState extends State<ItemCard> {
  late Future<Model?> _getCategory;
  @override
  void didUpdateWidget(ItemCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.item.categoryId != widget.item.categoryId) {
      _refreshCategory();
    }
  }

  @override
  void initState() {
    super.initState();
    _refreshCategory();
  }

  void _refreshCategory() {
    setState(() {
      _getCategory = DatabaseHelper.getById(
          Category.tableName, "Category", widget.item.categoryId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _getCategory,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return Card(
            margin: const EdgeInsets.only(top: 15, right: 15, left: 15),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    widget.item.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      RichText(
                        text: TextSpan(
                          text: 'المجموعة: ',
                          style: const TextStyle(
                            fontSize: 17,
                            color: Colors.black,
                          ),
                          children: <TextSpan>[
                            TextSpan(
                              text: (snapshot.data! as Category).name,
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      RichText(
                        text: TextSpan(
                          text: 'سعر الشراء: ',
                          style: const TextStyle(
                              fontSize: 17, color: Colors.black),
                          children: <TextSpan>[
                            TextSpan(
                              text: formatDouble(widget.item.purchasePrice),
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            const TextSpan(
                              text: ' ل.س',
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      RichText(
                        text: TextSpan(
                          text: 'سعر المبيع: ',
                          style: const TextStyle(
                              fontSize: 17, color: Colors.black),
                          children: <TextSpan>[
                            TextSpan(
                              text: formatDouble(widget.item.sellingPrice),
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            const TextSpan(
                              text: ' ل.س',
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      RichText(
                        text: TextSpan(
                          text: 'الكمية: ',
                          style: const TextStyle(
                            fontSize: 17,
                            color: Colors.black,
                          ),
                          children: <TextSpan>[
                            TextSpan(
                              text: formatDouble(widget.item.quantity),
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            TextSpan(
                              text:
                                  ' ${MeasurementUnit.toArabic(widget.item.unit.value)}',
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (newcontext) {
                                return MultiBlocProvider(
                                  providers: [
                                    BlocProvider<ItemCubit>.value(
                                      value:
                                          BlocProvider.of<ItemCubit>(context),
                                    ),
                                    BlocProvider<ItemHistoryCubit>.value(
                                      value: BlocProvider.of<ItemHistoryCubit>(
                                          context),
                                    ),
                                  ],
                                  child: UpdateItemForm(oldItem: widget.item),
                                );
                              },
                            ),
                          );
                        },
                        icon: const Icon(Icons.edit),
                      ),
                      IconButton(
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (newcontext) {
                                return BlocProvider.value(
                                  value: BlocProvider.of<ItemHistoryCubit>(
                                      context),
                                  child: Scaffold(
                                    appBar: AppBar(
                                      title: const Text('سجل تعديل عنصر'),
                                      centerTitle: true,
                                    ),
                                    body: ItemHistoryScreen(
                                      itemId: widget.item.id!,
                                    ),
                                  ),
                                );
                              },
                            ),
                          );
                        },
                        icon: const Icon(Icons.info),
                      ),
                      // IconButton(
                      // onPressed: () {
                      //   context.read<ItemCubit>().deleteItem(widget.item.id!);
                      // },
                      //   icon: const Icon(Icons.delete),
                      // ),
                    ],
                  )
                ],
              ),
            ),
          );
        } else {
          return const Center(
            child: CircularProgressIndicator(
              color: Colors.blue,
            ),
          );
        }
      },
    );
  }
}
