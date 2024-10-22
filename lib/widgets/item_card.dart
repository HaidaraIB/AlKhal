import 'package:alkhal/models/category.dart';
import 'package:alkhal/models/item.dart';
import 'package:alkhal/models/measurement_unit.dart';
import 'package:alkhal/services/database_helper.dart';
import 'package:alkhal/utils/functions.dart';
import 'package:flutter/material.dart';

class ItemCard extends StatefulWidget {
  final Item item;

  const ItemCard({super.key, required this.item});

  @override
  State<ItemCard> createState() => _ItemCardState();
}

class _ItemCardState extends State<ItemCard> {
  Category? category;
  @override
  void initState() {
    super.initState();
    DatabaseHelper.getById(
            Category.tableName, "Category", widget.item.categoryId)
        .then(
      (value) => setState(() {
        category = value as Category;
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    TextStyle infoTextStyle = const TextStyle(
      fontSize: 15,
    );
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
                    style: const TextStyle(fontSize: 17, color: Colors.black),
                    children: <TextSpan>[
                      TextSpan(
                        text: category?.name,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'سعر الشراء: ${widget.item.purchasePrice.toInt()} ل.س',
                  style: infoTextStyle,
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'سعر المبيع: ${widget.item.sellingPrice.toInt()} ل.س',
                  style: infoTextStyle,
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'الكمية: ${formatDouble(widget.item.quantity)} ${MeasurementUnit.toArabic(widget.item.unit.value)}',
                  style: infoTextStyle,
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.edit),
                ),
                IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.info),
                ),
                IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.delete),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
