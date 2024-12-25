import 'package:alkhal/cubit/item/item_cubit.dart';
import 'package:alkhal/cubit/item_history/item_history_cubit.dart';
import 'package:alkhal/cubit/transaction_item/transaction_item_cubit.dart';
import 'package:alkhal/models/category.dart';
import 'package:alkhal/models/item.dart';
import 'package:alkhal/models/measurement_unit.dart';
import 'package:alkhal/screens/item_history_screen.dart';
import 'package:alkhal/screens/item_sales_screen.dart';
import 'package:alkhal/screens/update_item_screen.dart';
import 'package:alkhal/utils/functions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ItemCard extends StatefulWidget {
  final Item item;
  final Category category;

  const ItemCard({
    super.key,
    required this.item,
    required this.category,
  });

  @override
  State<ItemCard> createState() => _ItemCardState();
}

class _ItemCardState extends State<ItemCard> {
  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(top: 15, right: 15, left: 15),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  onPressed: () {
                    final itemHistoryCubit =
                        BlocProvider.of<ItemHistoryCubit>(context);
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (newContext) {
                          return BlocProvider<ItemHistoryCubit>.value(
                            value: itemHistoryCubit,
                            child: Scaffold(
                              appBar: AppBar(
                                title: const Text('سجل تعديل عنصر'),
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
                Text(
                  widget.item.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 22,
                    color: Color.fromARGB(255, 147, 101, 255),
                  ),
                ),
                const SizedBox(),
              ],
            ),
            const Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    IconButton(
                      onPressed: () async {
                        final itemCubit = BlocProvider.of<ItemCubit>(context);
                        final transactionItemCubit =
                            BlocProvider.of<TransactionItemCubit>(context);
                        Map sellingsPurchases =
                            await Item.computeSellingsPurchases(
                                widget.item.id!);
                        if (context.mounted) {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (newContext) {
                                return MultiBlocProvider(
                                  providers: [
                                    BlocProvider<ItemCubit>.value(
                                      value: itemCubit,
                                    ),
                                    BlocProvider<TransactionItemCubit>.value(
                                      value: transactionItemCubit,
                                    ),
                                  ],
                                  child: ItemSalesScreen(
                                    item: widget.item,
                                    purchases: sellingsPurchases['purchases'],
                                    sellings: sellingsPurchases['sellings'],
                                  ),
                                );
                              },
                            ),
                          );
                        }
                      },
                      icon: const Icon(Icons.list),
                    ),
                    const SizedBox(),
                    IconButton(
                      onPressed: () {
                        final itemCubit = BlocProvider.of<ItemCubit>(context);
                        final itemHistoryCubit =
                            BlocProvider.of<ItemHistoryCubit>(context);
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (newContext) {
                              return MultiBlocProvider(
                                providers: [
                                  BlocProvider<ItemCubit>.value(
                                      value: itemCubit),
                                  BlocProvider<ItemHistoryCubit>.value(
                                      value: itemHistoryCubit),
                                ],
                                child: UpdateItemForm(oldItem: widget.item),
                              );
                            },
                          ),
                        );
                      },
                      icon: const Icon(Icons.edit),
                    ),
                    // IconButton(
                    // onPressed: () {
                    //   context.read<ItemCubit>().deleteItem(widget.item.id!);
                    // },
                    //   icon: const Icon(Icons.delete),
                    // ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.only(right: 16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      _buildItemFieldRow(
                        text: 'المجموعة: ',
                        spans: [
                          TextSpan(
                            text: widget.category.name,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      _buildItemFieldRow(
                        text: 'سعر الشراء: ',
                        spans: [
                          TextSpan(
                            text: formatDouble(widget.item.purchasePrice),
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const TextSpan(
                            text: ' ل.س',
                          ),
                        ],
                      ),
                      _buildItemFieldRow(
                        text: 'سعر المبيع: ',
                        spans: [
                          TextSpan(
                            text: formatDouble(widget.item.sellingPrice),
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const TextSpan(
                            text: ' ل.س',
                          ),
                        ],
                      ),
                      _buildItemFieldRow(
                        text: "الكمية: ",
                        spans: [
                          TextSpan(
                            text: formatDouble(widget.item.quantity),
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          TextSpan(
                            text:
                                ' ${MeasurementUnit.toArabic(widget.item.unit.value)}',
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildItemFieldRow({
    required String text,
    List<TextSpan> spans = const [],
  }) {
    return Row(
      children: [
        RichText(
          text: TextSpan(
            text: text,
            style: const TextStyle(
              fontSize: 17,
              color: Colors.black,
            ),
            children: spans,
          ),
        ),
      ],
    );
  }
}
