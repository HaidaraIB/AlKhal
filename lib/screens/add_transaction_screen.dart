import 'package:alkhal/cubit/item/item_cubit.dart';
import 'package:alkhal/cubit/transaction/transaction_cubit.dart';
import 'package:alkhal/cubit/transaction_item/transaction_item_cubit.dart';
import 'package:alkhal/models/item.dart';
import 'package:alkhal/models/measurement_unit.dart';
import 'package:alkhal/models/model.dart';
import 'package:alkhal/models/transaction.dart';
import 'package:alkhal/models/transaction_item.dart';
import 'package:alkhal/services/database_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AddTransactionForm extends StatefulWidget {
  const AddTransactionForm({super.key});

  @override
  State<AddTransactionForm> createState() => _AddTransactionFormState();
}

class _AddTransactionFormState extends State<AddTransactionForm> {
  final _formKey = GlobalKey<FormState>();
  final _discountController = TextEditingController();
  bool _isSale = true;

  final List<Map<String, dynamic>> _selectedItems = [
    {
      "item": null,
      "item_id": 1,
      "quantity": 0,
    }
  ];
  late Future<List<Model>> _getItems;
  @override
  void initState() {
    super.initState();
    _getItems = DatabaseHelper.getAll(Item.tableName, "Item");
  }

  Future<void> _submitForm(List<Model> items) async {
    if (_formKey.currentState!.validate()) {
      List<Item> itemsToSave = [];
      double totalPrice = 0;
      double totalProfit = 0;
      for (var si in _selectedItems) {
        for (Model i in items) {
          if ((i as Item).id == si['item_id']) {
            itemsToSave.add(i);
            double sellingPrice = (i.sellingPrice *
                (i.unit == MeasurementUnit.kg
                    ? si['quantity'] / 1000
                    : si['quantity']));
            double purchasePrice = (i.purchasePrice *
                (i.unit == MeasurementUnit.kg
                    ? si['quantity'] / 1000
                    : si['quantity']));
            totalPrice += _isSale ? sellingPrice : purchasePrice;
            if (_isSale) {
              totalProfit += sellingPrice - purchasePrice;
            }
            break;
          }
        }
      }
      double discount = _discountController.text != ""
          ? double.parse(_discountController.text)
          : 0;
      Transaction transaction = Transaction(
          date: DateTime.now().toIso8601String(),
          discount: discount,
          isSale: _isSale ? 1 : 0,
          totalPrice: totalPrice - discount,
          totalProfit: totalProfit - (discount * totalProfit / totalPrice));
      int? transactionId = await BlocProvider.of<TransactionCubit>(context)
          .addTransaction(transaction);
      if (transactionId == -1) {
        return;
      }
      for (var i in _selectedItems) {
        TransactionItem transactionItem = TransactionItem(
          itemId: i['item_id'],
          quantity: i['quantity'],
          transactionId: transactionId!,
        );
        if (mounted) {
          BlocProvider.of<TransactionItemCubit>(context)
              .addTransactionItem(transactionItem);
          Item item = itemsToSave[_selectedItems.indexOf(i)];
          if (_isSale) {
            item.quantity -= item.unit == MeasurementUnit.kg
                ? i['quantity'] / 1000
                : i['quantity'];
          } else {
            item.quantity += item.unit == MeasurementUnit.kg
                ? i['quantity'] / 1000
                : i['quantity'];
          }
          BlocProvider.of<ItemCubit>(context).updateItem(item);
        }
      }
      if (mounted) {
        Navigator.pop(context);
      }
    }
  }

  void _addItem(List<Model> items) {
    if (_selectedItems.length == items.length) {
      String itemsCountSnackBarMsg = items.length == 1
          ? 'عنصر واحد'
          : (items.length == 2 ? "عنصرين" : '${items.length} عناصر');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "لديك في المخزون الرئيسي $itemsCountSnackBarMsg فقط",
          ),
        ),
      );
      return;
    }
    setState(() {
      _selectedItems.add({
        "item_id": 1,
        "quantity": 0,
      });
    });
  }

  void _deleteItem(int idx) {
    setState(() {
      _selectedItems.removeAt(idx);
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _getItems,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('إضافة فاتورة'),
              centerTitle: true,
            ),
            body: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Switch(
                          value: _isSale,
                          onChanged: (value) {
                            setState(() {
                              _isSale = value;
                            });
                          },
                        ),
                        const Text(
                          "فاتورة زبون؟",
                          style: TextStyle(fontSize: 17),
                        ),
                      ],
                    ),
                    TextFormField(
                      controller: _discountController,
                      decoration: const InputDecoration(labelText: 'الحسم'),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value != null &&
                            value.isNotEmpty &&
                            double.tryParse(value) == null) {
                          return 'الرجاء إدخال رقم';
                        }
                        return null;
                      },
                    ),
                    Expanded(
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: _selectedItems.length,
                        itemBuilder: (context, index) {
                          return Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Expanded(
                                child: TextFormField(
                                  decoration: InputDecoration(
                                    label: const Text(
                                      'الكمية (غرام أو قطعة)',
                                      textDirection: TextDirection.rtl,
                                    ),
                                    hintText: _selectedItems[index]['item'] !=
                                            null
                                        ? "لديك ${_selectedItems[index]['item'].quantity.toString()} ${MeasurementUnit.toArabic(_selectedItems[index]['item'].unit.value)}"
                                        : '',
                                  ),
                                  keyboardType: TextInputType.number,
                                  validator: (value) {
                                    if (value == null ||
                                        value.isEmpty ||
                                        int.tryParse(value) == 0) {
                                      return "الرجاء إدخال كمية";
                                    }
                                    var unSufficientQuantity =
                                        snapshot.data!.where((item) {
                                      Item i = item as Item;
                                      return ((i.id ==
                                              _selectedItems[index]
                                                  ['item_id']) &&
                                          (i.quantity <
                                              (i.unit == MeasurementUnit.kg
                                                  ? _selectedItems[index]
                                                          ['quantity'] /
                                                      1000
                                                  : _selectedItems[index]
                                                      ['quantity'])));
                                    });
                                    if (_isSale &&
                                        unSufficientQuantity.isNotEmpty) {
                                      return "الكمية تجاوزت المخزون";
                                    }
                                    return null;
                                  },
                                  onChanged: (value) {
                                    if (value.isNotEmpty) {
                                      setState(() {
                                        _selectedItems[index]['quantity'] =
                                            double.tryParse(value);
                                      });
                                    }
                                  },
                                ),
                              ),
                              const SizedBox(
                                width: 10,
                              ),
                              Expanded(
                                child: DropdownButtonFormField<String>(
                                  decoration: const InputDecoration(
                                    labelText: 'العنصر',
                                  ),
                                  onChanged: (value) {
                                    setState(() {
                                      int itemId = int.parse(value!);
                                      _selectedItems[index]['item_id'] = itemId;
                                      for (Model i in snapshot.data!) {
                                        if ((i as Item).id == itemId) {
                                          _selectedItems[index]['item'] = i;
                                        }
                                      }
                                    });
                                  },
                                  items: snapshot.data!
                                      .map(
                                        (item) => DropdownMenuItem<String>(
                                          value: item.id.toString(),
                                          child: Text((item as Item).name),
                                        ),
                                      )
                                      .toList(),
                                  validator: (value) {
                                    if (value == null) {
                                      return "الرجاء اختيار عنصر";
                                    }
                                    List<int> distinctItems = [];
                                    for (var i in _selectedItems) {
                                      if (distinctItems
                                          .contains(i['item_id'])) {
                                        return "عليك جمع العناصر المتكررة\nفي سجل واحد";
                                      }
                                      distinctItems.add(i['item_id']);
                                    }
                                    return null;
                                  },
                                ),
                              ),
                              IconButton(
                                onPressed: () => _deleteItem(index),
                                icon: const Icon(Icons.delete),
                              )
                            ],
                          );
                        },
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        ElevatedButton(
                          onPressed: () => _addItem(snapshot.data!),
                          child: const Text('إضافة عنصر'),
                        ),
                        const SizedBox(
                          height: 10.0,
                        ),
                        SizedBox(
                          height: 50.0,
                          width: 150.0,
                          child: ElevatedButton(
                            onPressed: () => _submitForm(snapshot.data!),
                            child: const Text('حفظ الفاتورة'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
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
