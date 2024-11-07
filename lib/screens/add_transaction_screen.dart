import 'package:alkhal/cubit/transaction/transaction_cubit.dart';
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
  final _reminderController = TextEditingController();
  final _notesController = TextEditingController();
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

    categories
        .sort((a, b) => (a as Category).name.compareTo((b as Category).name));
    items.sort((a, b) => (a as Item).name.compareTo((b as Item).name));

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

  Future<void> _confirmAddTransaction() async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            'تأكيد إضافة فاتورة',
            textDirection: TextDirection.rtl,
            textAlign: TextAlign.center,
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Padding(
                padding: EdgeInsets.only(bottom: 8.0),
                child: Text(
                  'أضف ملاحظات إضافية عن هذه الفاتورة',
                  textAlign: TextAlign.center,
                  textDirection: TextDirection.rtl,
                ),
              ),
              TextField(
                controller: _notesController,
                textAlign: TextAlign.right,
                textDirection: TextDirection.rtl,
                maxLines: null, // Allows the TextField to expand vertically
                decoration: InputDecoration(
                  hintText: 'أدخل ملاحظاتك هنا',
                  hintTextDirection: TextDirection.rtl,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide:
                        BorderSide(color: Theme.of(context).primaryColor),
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                ),
              )
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('إلغاء'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                await _submitForm();
              },
              child: const Text('حفظ'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      double discount = _discountController.text.isNotEmpty
          ? double.parse(_discountController.text)
          : 0;
      double reminder = _reminderController.text.isNotEmpty
          ? double.parse(_reminderController.text)
          : 0;
      List<TransactionItem> transactionItems = [];
      List<Item> itemsToUpdate = [];
      double totalPrice = 0;
      double totalProfit = 0;

      for (var si in _selectedItems) {
        Item i = si['item'];
        itemsToUpdate.add(i);
        Map res = calculateItemValues(si);
        double sellingPrice = res['sellingPrice'];
        double purchasePrice = res['purchasePrice'];
        double transactionItemQuantity = res['transactionItemQuantity'];
        if (_isSale) {
          totalProfit += sellingPrice - purchasePrice;
        }
        totalPrice += _isSale ? sellingPrice : purchasePrice;
        transactionItems.add(TransactionItem(
          itemId: si['item_id'],
          quantity: transactionItemQuantity,
          sellingPrice: i.sellingPrice,
          purchasePrice: i.purchasePrice,
        ));
      }
      Transaction transaction = Transaction(
        transactionDate: DateTime.now().toString(),
        discount: discount,
        reminder: reminder,
        isSale: _isSale ? 1 : 0,
        totalPrice: totalPrice - discount,
        totalProfit: totalProfit - (discount * totalProfit / totalPrice),
        notes: _notesController.text,
      );
      bool success =
          await BlocProvider.of<TransactionCubit>(context).addTransaction(
        transaction,
        transactionItems,
        itemsToUpdate,
      );
      if (!success) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                "حصل خطأ غير معروف، لم يتم احتساب الفاتورة!",
                textAlign: TextAlign.center,
                textDirection: TextDirection.rtl,
              ),
            ),
          );
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
        "quantity": 0.0,
        "price": 0.0,
      });
    });
  }

  void _deleteItem(int idx) {
    if (_selectedItems.length == 1) {
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
              title: RichText(
                textDirection: TextDirection.rtl,
                textAlign: TextAlign.center,
                text: TextSpan(
                  text: "الإجمالي: ",
                  style: const TextStyle(
                    fontSize: 25,
                    color: Colors.deepPurple,
                  ),
                  children: <TextSpan>[
                    TextSpan(
                      text: formatDouble(calculateTotalPrice()),
                      style: const TextStyle(
                        color: Colors.deepPurple,
                        fontWeight: FontWeight.bold,
                        fontSize: 25,
                      ),
                    ),
                  ],
                ),
              ),
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
                    _buildReminderField(),
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
              color: Colors.purple,
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
        if (value != null && value.isNotEmpty) {
          if (double.tryParse(value) == null) {
            return 'الرجاء إدخال رقم';
          }
          double totalPrice = 0;
          for (var si in _selectedItems) {
            Map res = calculateItemValues(si);
            double sellingPrice = res['sellingPrice'];
            double purchasePrice = res['purchasePrice'];
            totalPrice += _isSale ? sellingPrice : purchasePrice;
          }

          if (double.tryParse(value)! > totalPrice * 0.1) {
            return 'يجب أن يكون الحسم أقل من 10% السعر الإجمالي: ${formatDouble(totalPrice * 0.1)}';
          }
        }
        return null;
      },
    );
  }

  Widget _buildReminderField() {
    return TextFormField(
      controller: _reminderController,
      decoration: const InputDecoration(labelText: 'الباقي'),
      keyboardType: TextInputType.number,
      validator: (value) {
        if (value != null && value.isNotEmpty) {
          if (double.tryParse(value) == null) {
            return 'الرجاء إدخال رقم';
          }
          double totalPrice = 0;
          for (var si in _selectedItems) {
            Map res = calculateItemValues(si);
            double sellingPrice = res['sellingPrice'];
            double purchasePrice = res['purchasePrice'];
            totalPrice += _isSale ? sellingPrice : purchasePrice;
          }
          if (double.tryParse(value)! > totalPrice) {
            return 'يجب أن يكون الباقي أقل من السعر الإجمالي: ${formatDouble(totalPrice)}';
          }
        }
        return null;
      },
    );
  }

  Widget _buildItemListView(AsyncSnapshot<Map<String, List<Model>>> snapshot) {
    return Flexible(
      fit: FlexFit.tight,
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
      value: _selectedItems[index]['item_id'] != 0
          ? _selectedItems[index]['item_id'].toString()
          : null,
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
            }
            return true;
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
        setState(() {
          _selectedItems[index]['item_id'] = 0;
          _selectedItems[index]['category_id'] = value!;
        });
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
        _isSale &&
                (_selectedItems[index]['item'] == null ||
                    (_selectedItems[index]['item'] != null &&
                        (_selectedItems[index]['item'] as Item).unit ==
                            MeasurementUnit.kg))
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
        setState(() {
          _selectedItems[index]['price'] = double.tryParse(value);
        });
      },
    );
  }

  Widget _buildQuantityField(
      AsyncSnapshot<Map<String, List<Model>>> snapshot, int index) {
    return TextFormField(
      decoration: InputDecoration(
        label: Text(_makeUnitHintText(index), textDirection: TextDirection.rtl),
        hintText: _selectedItems[index]['item'] != null
            ? "لديك ${_makeAvailableQuantityText(_selectedItems[index]['item'])}"
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
        bool insufficientQuantity = _selectedItems[index]['item'].quantity <
            (_isSale && _selectedItems[index]['item'].unit == MeasurementUnit.kg
                ? _selectedItems[index]['quantity'] / 1000
                : _selectedItems[index]['quantity']);
        if (_isSale && insufficientQuantity) {
          return "الكمية تجاوزت المخزون";
        } else if (_isSale &&
            _selectedItems[index]['quantity'] != 0 &&
            _selectedItems[index]['price'] != 0) {
          return "لا يمكنك إدخال\nكمية وسعر معاً";
        }
        return null;
      },
      onChanged: (value) {
        setState(() {
          _selectedItems[index]['quantity'] = double.tryParse(value);
        });
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
            onPressed: _confirmAddTransaction,
            child: const Text('حفظ الفاتورة'),
          ),
        ),
      ],
    );
  }

  double calculateTotalPrice() {
    double totalPrice = 0;
    for (var si in _selectedItems) {
      Map res = calculateItemValues(si);
      double sellingPrice = res['sellingPrice'];
      double purchasePrice = res['purchasePrice'];
      totalPrice += _isSale ? sellingPrice : purchasePrice;
    }
    return totalPrice;
  }

  Map calculateItemValues(Map si) {
    if (si['item'] == null) {
      return {
        "sellingPrice": 0.0,
        "purchasePrice": 0.0,
        "transactionItemQuantity": 0.0,
      };
    }
    Item i = si['item'];
    bool isKg = i.unit == MeasurementUnit.kg;
    double sellingPrice = 0;
    double purchasePrice = 0;
    double transactionItemQuantity = 0;
    if (si['quantity'] != null && si['quantity'] != 0) {
      if (isKg) {
        int quantityFactor = _isSale ? 1000 : 1;
        transactionItemQuantity = si['quantity'] / quantityFactor;
      } else {
        transactionItemQuantity = si['quantity'];
      }
      sellingPrice = i.sellingPrice * transactionItemQuantity;
      purchasePrice = i.purchasePrice * transactionItemQuantity;
    } else if (si['price'] != null) {
      transactionItemQuantity = si['price'] / i.sellingPrice;
      sellingPrice = si['price'];
      purchasePrice = i.purchasePrice * (si['price'] / i.sellingPrice);
    }
    return {
      "sellingPrice": sellingPrice,
      "purchasePrice": purchasePrice,
      "transactionItemQuantity": transactionItemQuantity,
    };
  }

  String _makeAvailableQuantityText(Item item) {
    if (item.unit == MeasurementUnit.kg) {
      return "${formatDouble(item.quantity)} ${MeasurementUnit.toArabic(item.unit.value)}";
    } else if (item.quantity == 1) {
      return "قطعة واحدة";
    } else if (item.quantity == 2) {
      return "قطعتان";
    } else if (item.quantity >= 3 && item.quantity <= 10) {
      return "${formatDouble(item.quantity)} قطع";
    } else {
      return "${formatDouble(item.quantity)} قطعة";
    }
  }

  String _makeUnitHintText(int index) {
    String base = "الكمية ";
    String text = "";
    if (_isSale) {
      if (_selectedItems[index]['item'] != null) {
        if ((_selectedItems[index]['item'] as Item).unit ==
            MeasurementUnit.kg) {
          text = "بالغرام";
        } else {
          text = "بالقطعة";
        }
      } else {
        text = "بالغرام أو بالقطعة";
      }
    } else {
      if (_selectedItems[index]['item'] != null) {
        if ((_selectedItems[index]['item'] as Item).unit ==
            MeasurementUnit.kg) {
          text = "بالكيلو غرام";
        } else {
          text = "بالقطعة";
        }
      } else {
        text = "بالكيلو غرام أو بالقطعة";
      }
    }
    return base + text;
  }
}
