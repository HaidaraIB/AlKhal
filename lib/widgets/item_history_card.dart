import 'package:alkhal/models/category.dart';
import 'package:alkhal/models/item_history.dart';
import 'package:alkhal/models/model.dart';
import 'package:alkhal/services/database_helper.dart';
import 'package:alkhal/utils/constants.dart';
import 'package:alkhal/utils/functions.dart';
import 'package:flutter/material.dart';

class ItemHistoryCard extends StatefulWidget {
  final ItemHistory itemHistory;

  const ItemHistoryCard({
    super.key,
    required this.itemHistory,
  });

  @override
  State<ItemHistoryCard> createState() => _ItemHistoryCardState();
}

class _ItemHistoryCardState extends State<ItemHistoryCard>
    with AutomaticKeepAliveClientMixin {
  late Future<Map<String, Model?>> _data;

  Future<Map<String, Model?>> _getData() async {
    Model? oldCategory = await DatabaseHelper.getById(
        Category.tableName, "Category", widget.itemHistory.oldCategoryId);
    Model? newCategory = await DatabaseHelper.getById(
        Category.tableName, "Category", widget.itemHistory.newCategoryId);
    return {
      "old_category": oldCategory,
      "new_category": newCategory,
    };
  }

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _data = _getData();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return FutureBuilder(
      future: _data,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          Category oldCategory = snapshot.data!['old_category'] as Category;
          Category newCategory = snapshot.data!['new_category'] as Category;
          return ItemHistoryCardWidget(
            oldCategoryName: oldCategory.name,
            newCategoryName: newCategory.name,
            oldName: widget.itemHistory.oldName,
            newName: widget.itemHistory.newName,
            oldPurchasePrice: widget.itemHistory.oldPurchasePrice,
            newPurchasePrice: widget.itemHistory.newPurchasePrice,
            oldSellingPrice: widget.itemHistory.oldSellingPrice,
            newSellingPrice: widget.itemHistory.newSellingPrice,
            updateDate: widget.itemHistory.updateDate,
          );
        } else {
          return const Center(
            child: CircularProgressIndicator(
              color: Colors.purple,
            ),
          );
        }
      },
    );
  }
}

class ItemHistoryCardWidget extends StatelessWidget {
  const ItemHistoryCardWidget({
    super.key,
    required this.oldCategoryName,
    required this.newCategoryName,
    required this.oldName,
    required this.newName,
    required this.newPurchasePrice,
    required this.oldPurchasePrice,
    required this.newSellingPrice,
    required this.oldSellingPrice,
    required this.updateDate,
  });

  final String oldName;
  final String newName;
  final String oldCategoryName;
  final String newCategoryName;
  final double oldSellingPrice;
  final double newSellingPrice;
  final double oldPurchasePrice;
  final double newPurchasePrice;
  final String updateDate;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.all(15),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              arDateTimeFormat.format(DateTime.parse(updateDate)),
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: Colors.blueAccent,
              ),
              textDirection: TextDirection.rtl,
            ),
            const Divider(),
            _buildChangeRow('الاسم', oldName, newName),
            _buildChangeRow('المجموعة', oldCategoryName, newCategoryName),
            _buildChangeRow('سعر الشراء', formatDouble(oldPurchasePrice),
                formatDouble(newPurchasePrice)),
            _buildChangeRow('سعر المبيع', formatDouble(oldSellingPrice),
                formatDouble(newSellingPrice)),
          ],
        ),
      ),
    );
  }

  Widget _buildChangeRow(String label, String oldValue, String newValue) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Expanded(
            child: Text(
              textDirection: TextDirection.rtl,
              oldValue == newValue ? oldValue : '$oldValue ← $newValue',
              style: TextStyle(
                fontSize: 16,
                color: oldValue == newValue ? Colors.black : Colors.green,
                fontWeight:
                    oldValue == newValue ? FontWeight.normal : FontWeight.bold,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Text(
            textDirection: TextDirection.rtl,
            '$label: ',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
