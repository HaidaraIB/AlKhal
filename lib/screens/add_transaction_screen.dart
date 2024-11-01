import 'package:alkhal/cubit/item/item_cubit.dart';
import 'package:alkhal/cubit/transaction/transaction_cubit.dart';
import 'package:alkhal/cubit/transaction_item/transaction_item_cubit.dart';
import 'package:alkhal/models/category.dart';
import 'package:alkhal/models/item.dart';
import 'package:alkhal/models/measurement_unit.dart';
import 'package:alkhal/models/model.dart';
import 'package:alkhal/models/transaction.dart';
import 'package:alkhal/models/transaction_item.dart';
import 'package:alkhal/services/database_helper.dart';
import 'package:alkhal/utils/functions.dart';
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
      "item_id": 0,
      "category_id": 0,
      "quantity": 0.0,
      "price": 0.0,
    }
  ];
  late Future<Map<String, List<Model>>> _data;

  Future<Map<String, List<Model>>> _getData() async {
    List<Model> categories =
        await DatabaseHelper.getAll(Category.tableName, "Category");
    List<Model> items = await DatabaseHelper.getAll(Item.tableName, "Item");
    return {"categories": categories, "items": items};
  }

  @override
  void dispose() {
    _discountController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _data = _getData();
  }

  Future<void> _submitForm(List<Model> items) async {
    if (_formKey.currentState!.validate()) {
      List<Item> itemsToSave = [];
      double totalPrice = 0;
      double totalProfit = 0;
      if (_selectedItems.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              "عليك إضافة عنصر واحد على الأقل!",
              textAlign: TextAlign.center,
              textDirection: TextDirection.rtl,
            ),
          ),
        );
        return;
      }
      for (var si in _selectedItems) {
        for (Model i in items) {
          if ((i as Item).id == si['item_id']) {
            itemsToSave.add(i);
            double sellingPrice = 0;
            double purchasePrice = 0;
            if (si['quantity'] != 0) {
              sellingPrice = i.sellingPrice *
                  ((i.unit == MeasurementUnit.kg && _isSale)
                      ? si['quantity'] / 1000
                      : si['quantity']);
              purchasePrice = i.purchasePrice *
                  ((i.unit == MeasurementUnit.kg && _isSale)
                      ? si['quantity'] / 1000
                      : si['quantity']);
            } else {
              sellingPrice = si['price'];
              purchasePrice = i.purchasePrice * (si['price'] / i.sellingPrice);
              totalProfit += sellingPrice - purchasePrice;
            }
            totalPrice += _isSale ? sellingPrice : purchasePrice;
            break;
          }
        }
      }

      double discount = _discountController.text.isNotEmpty
          ? double.parse(_discountController.text)
          : 0;
      Transaction transaction = Transaction(
        transactionDate: DateTime.now().toString(),
        discount: discount,
        isSale: _isSale ? 1 : 0,
        totalPrice: totalPrice - discount,
        totalProfit: totalProfit - (discount * totalProfit / totalPrice),
      );

      int? transactionId = await BlocProvider.of<TransactionCubit>(context)
          .addTransaction(transaction);
      if (transactionId == -1) return;

      for (var i in _selectedItems) {
        Item item = itemsToSave[_selectedItems.indexOf(i)];
        bool isKg = (item.unit == MeasurementUnit.kg);
        double quantity = 0;
        if (_isSale && i['price'] != 0) {
          if (isKg) {
            quantity = (i['price'] / item.sellingPrice) * 1000;
          } else {
            quantity = (i['price'] / item.sellingPrice);
          }
        } else if (!_isSale && isKg) {
          quantity = i['quantity'] * 1000;
        } else {
          quantity = i['quantity'];
        }
        TransactionItem transactionItem = TransactionItem(
          itemId: i['item_id'],
          quantity: quantity,
          transactionId: transactionId!,
        );
        if (mounted) {
          BlocProvider.of<TransactionItemCubit>(context)
              .addTransactionItem(transactionItem);
          if (_isSale) {
            if (i['quantity'] != 0) {
              item.quantity -= isKg ? i['quantity'] / 1000 : i['quantity'];
            } else {
              item.quantity -= i['price'] / item.sellingPrice;
            }
          } else {
            item.quantity += i['quantity'];
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
            textAlign: TextAlign.center,
            textDirection: TextDirection.rtl,
          ),
        ),
      );
      return;
    }
    setState(() {
      _selectedItems.add({
        "item": null,
        "item_id": 0,
        "category_id": 0,
        "quantity": 0,
        "price": 0,
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
    return FutureBuilder<Map<String, List<Model>>>(
      future: _data,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('إضافة فاتورة'),
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
                        _buildSwitchLabel("فاتورة محل", !_isSale),
                        Switch(
                          value: _isSale,
                          onChanged: (value) {
                            setState(() {
                              _isSale = value;
                            });
                          },
                        ),
                        _buildSwitchLabel("فاتورة زبون", _isSale),
                      ],
                    ),
                    _buildDiscountField(),
                    const SizedBox(height: 10),
                    _buildItemListView(snapshot),
                    _buildActionButtons(snapshot),
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

  Widget _buildSwitchLabel(String text, bool isActive) {
    return Text(
      text,
      style: TextStyle(
        fontSize: isActive ? 20 : 15,
        color: isActive ? Colors.deepPurple : Colors.black,
        fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
      ),
    );
  }

  Widget _buildDiscountField() {
    return TextFormField(
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
    );
  }

  Widget _buildItemListView(AsyncSnapshot<Map<String, List<Model>>> snapshot) {
    return Expanded(
      child: ListView.builder(
        shrinkWrap: true,
        itemCount: _selectedItems.length,
        itemBuilder: (context, index) {
          return Card(
            color: Colors.deepPurple[50],
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  _buildItemRow(snapshot, index),
                  _buildQuantityPriceRow(snapshot, index),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildItemRow(
      AsyncSnapshot<Map<String, List<Model>>> snapshot, int index) {
    return Row(
      children: [
        Expanded(
          child: _buildItemDropdown(snapshot, index),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _buildCategoryDropdown(snapshot, index),
        ),
        IconButton(
          onPressed: () => _deleteItem(index),
          icon: const Icon(Icons.delete),
        )
      ],
    );
  }

  Widget _buildItemDropdown(
      AsyncSnapshot<Map<String, List<Model>>> snapshot, int index) {
    return DropdownButtonFormField<String>(
      isExpanded: true,
      decoration: const InputDecoration(labelText: 'العنصر'),
      onChanged: (value) {
        setState(() {
          List<Model> items = snapshot.data!['items']!;
          int itemId = int.parse(value!);
          _selectedItems[index]['item_id'] = itemId;
          for (Model i in items) {
            if ((i as Item).id == itemId) {
              _selectedItems[index]['item'] = i;
              _selectedItems[index]['category_id'] = i.categoryId.toString();
            }
          }
        });
      },
      items: snapshot.data!['items']!
          .where((item) {
            if (_selectedItems[index]['category_id'] != 0) {
              return (item as Item).categoryId.toString() ==
                  _selectedItems[index]['category_id'];
            } else {
              return true;
            }
          })
          .map((item) => DropdownMenuItem<String>(
                value: item.id.toString(),
                child: Text(
                  (item as Item).name,
                ),
              ))
          .toList(),
      validator: (value) {
        if (value == null) {
          return "الرجاء اختيار عنصر";
        }
        List<int> distinctItems = [];
        for (var i in _selectedItems) {
          if (distinctItems.contains(i['item_id'])) {
            return "عليك جمع العناصر المتكررة\nفي سجل واحد";
          }
          distinctItems.add(i['item_id']);
        }
        return null;
      },
    );
  }

  Widget _buildCategoryDropdown(
      AsyncSnapshot<Map<String, List<Model>>> snapshot, int index) {
    return DropdownButtonFormField<String>(
      isExpanded: true,
      value: _selectedItems[index]['category_id'] != 0
          ? _selectedItems[index]['category_id']
          : null,
      decoration: const InputDecoration(labelText: 'المجموعة'),
      onChanged: (value) {
        setState(() => _selectedItems[index]['category_id'] = value!);
      },
      items: snapshot.data!['categories']!
          .map((category) => DropdownMenuItem<String>(
                value: category.id.toString(),
                child: Text((category as Category).name),
              ))
          .toList(),
    );
  }

  Widget _buildQuantityPriceRow(
      AsyncSnapshot<Map<String, List<Model>>> snapshot, int index) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _isSale
            ? Expanded(
                child: _buildPriceField(snapshot, index),
              )
            : const SizedBox(),
        const SizedBox(width: 10),
        Expanded(
          child: _buildQuantityField(snapshot, index),
        ),
        const SizedBox(width: 10),
      ],
    );
  }

  Widget _buildPriceField(
      AsyncSnapshot<Map<String, List<Model>>> snapshot, int index) {
    return TextFormField(
      decoration: InputDecoration(
        label: const Text('السعر', textDirection: TextDirection.rtl),
        hintText: _selectedItems[index]['item'] != null
            ? "الإجمالي ${formatDouble(_selectedItems[index]['item'].quantity * _selectedItems[index]['item'].sellingPrice)} ل.س"
            : '',
        hintStyle: const TextStyle(fontSize: 15),
      ),
      keyboardType: TextInputType.number,
      validator: (value) {
        if (_isSale && _selectedItems[index]['quantity'] == 0) {
          if (value == null || value.isEmpty) {
            return "الرجاء إدخال كمية أو سعر";
          } else if (int.tryParse(value)! <= 0) {
            return "الرجاء إدخال عدد موجب";
          }
        }
        List<Model> items = snapshot.data!["items"]!;
        var insufficientQuantity = items.where((item) {
          Item i = item as Item;
          return (i.id == _selectedItems[index]['item_id'] &&
              i.quantity * i.sellingPrice < _selectedItems[index]['price']);
        });
        if (_isSale && insufficientQuantity.isNotEmpty) {
          return "الكمية تجاوزت المخزون";
        } else if (_selectedItems[index]['quantity'] != 0 &&
            _selectedItems[index]['price'] != 0) {
          return "لا يمكنك إدخال\nكمية وسعر معاً";
        }
        return null;
      },
      onChanged: (value) {
        if (value.isNotEmpty) {
          setState(() {
            _selectedItems[index]['price'] = double.tryParse(value);
          });
        }
      },
    );
  }

  Widget _buildQuantityField(
      AsyncSnapshot<Map<String, List<Model>>> snapshot, int index) {
    return TextFormField(
      decoration: InputDecoration(
        label: Text('الكمية ${_isSale ? "غرام أو قطعة" : "كيلو غرام أو قطعة"}',
            textDirection: TextDirection.rtl),
        hintText: _selectedItems[index]['item'] != null
            ? "لديك ${formatDouble(_selectedItems[index]['item'].quantity)} ${MeasurementUnit.toArabic(_selectedItems[index]['item'].unit.value)}"
            : '',
      ),
      keyboardType: TextInputType.number,
      validator: (value) {
        if (_isSale && _selectedItems[index]['price'] == 0) {
          if (value == null || value.isEmpty) {
            return "الرجاء إدخال كمية أو سعر";
          } else if (int.tryParse(value)! <= 0) {
            return "الرجاء إدخال عدد موجب";
          }
        }
        List<Model> items = snapshot.data!["items"]!;
        var insufficientQuantity = items.where((item) {
          Item i = item as Item;
          return (i.id == _selectedItems[index]['item_id'] &&
              i.quantity <
                  (_isSale && i.unit == MeasurementUnit.kg
                      ? _selectedItems[index]['quantity'] / 1000
                      : _selectedItems[index]['quantity']));
        });
        if (_isSale && insufficientQuantity.isNotEmpty) {
          return "الكمية تجاوزت المخزون";
        } else if (_isSale &&
            _selectedItems[index]['quantity'] != 0 &&
            _selectedItems[index]['price'] != 0) {
          return "لا يمكنك إدخال\nكمية وسعر معاً";
        }
        return null;
      },
      onChanged: (value) {
        if (value.isNotEmpty) {
          setState(() {
            _selectedItems[index]['quantity'] = double.tryParse(value);
          });
        }
      },
    );
  }

  Widget _buildActionButtons(AsyncSnapshot<Map<String, List<Model>>> snapshot) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        ElevatedButton(
          onPressed: () => _addItem(snapshot.data!['items']!),
          child: const Text('إضافة عنصر'),
        ),
        const SizedBox(height: 10.0),
        SizedBox(
          height: 50.0,
          width: 150.0,
          child: ElevatedButton(
            onPressed: () => _submitForm(snapshot.data!['items']!),
            child: const Text('حفظ الفاتورة'),
          ),
        ),
      ],
    );
  }
}
