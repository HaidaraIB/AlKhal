import 'package:alkhal/cubit/transaction/transaction_cubit.dart';
import 'package:alkhal/cubit/transaction_cash/transaction_cash_cubit.dart';
import 'package:alkhal/cubit/transaction_item_in_cart.dart/transaction_item_in_cart_cubit.dart';
import 'package:alkhal/models/category.dart';
import 'package:alkhal/models/item.dart';
import 'package:alkhal/models/measurement_unit.dart';
import 'package:alkhal/models/model.dart';
import 'package:alkhal/models/transaction.dart';
import 'package:alkhal/models/transaction_item.dart';
import 'package:alkhal/services/database_helper.dart';
import 'package:alkhal/utils/functions.dart';
import 'package:alkhal/widgets/transaction_item_in_cart_card.dart';
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
  final _remainderController = TextEditingController();
  final _notesController = TextEditingController();

  bool _isSale = true;

  late Future<Map<String, List<Model>>> _data;

  Future<Map<String, List<Model>>> _getData() async {
    List<Model> categories = await DatabaseHelper.getAll(
      Category.tableName,
      "Category",
      orderBy: "name",
    );
    List<Model> items = await DatabaseHelper.getAll(
      Item.tableName,
      "Item",
      orderBy: "name",
    );

    return {"categories": categories, "items": items};
  }

  @override
  void dispose() {
    _discountController.dispose();
    _remainderController.dispose();
    _notesController.dispose();
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
              TextFormField(
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
              ),
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
      double discount = double.tryParse(_discountController.text) ?? 0;
      double remainder = double.tryParse(_remainderController.text) ?? 0;
      List<TransactionItem> transactionItems = [];
      List<Item> itemsToUpdate = [];
      double totalPrice = 0;
      double totalProfit = 0;
      for (var si in BlocProvider.of<TransactionItemInCartCubit>(context)
          .transactionItemMaps) {
        Item i = si['item'];
        itemsToUpdate.add(i);
        Map res = _calculateItemValues(si);
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
        remainder: remainder,
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
    if (BlocProvider.of<TransactionItemInCartCubit>(context)
            .transactionItemMaps
            .length ==
        items.length) {
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
    Map<String, dynamic> newItem = {
      "item": null,
      "item_id": 0,
      "category_id": 0,
      "quantity": 0.0,
      "price": 0.0,
    };
    context
        .read<TransactionItemInCartCubit>()
        .addTransactionItemToCart(newItem);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, List<Model>>>(
      future: _data,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return Scaffold(
            appBar: AppBar(
              title: BlocBuilder<TransactionCashCubit, TransactionCashState>(
                bloc: BlocProvider.of<TransactionCashCubit>(context),
                builder: (context, state) {
                  return RichText(
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
                          text: formatDouble(state.cash),
                          style: const TextStyle(
                            color: Colors.deepPurple,
                            fontWeight: FontWeight.bold,
                            fontSize: 25,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
              centerTitle: true,
              backgroundColor: Colors.white,
              scrolledUnderElevation: 0.0,
            ),
            backgroundColor: Colors.white,
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
                    _buildRemainderField(),
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
          for (var si in BlocProvider.of<TransactionItemInCartCubit>(context)
              .transactionItemMaps) {
            Map res = _calculateItemValues(si);
            double sellingPrice = res['sellingPrice'];
            double purchasePrice = res['purchasePrice'];
            totalPrice += _isSale ? sellingPrice : purchasePrice;
          }

          if (double.tryParse(value)! > totalPrice * 0.1) {
            return 'يجب أن يكون الحسم أقل من 10% من السعر الإجمالي: ${formatDouble(totalPrice * 0.1)}';
          }
        }
        return null;
      },
    );
  }

  Widget _buildRemainderField() {
    return TextFormField(
      controller: _remainderController,
      decoration: const InputDecoration(labelText: 'الباقي'),
      keyboardType: TextInputType.number,
      validator: (value) {
        if (value != null && value.isNotEmpty) {
          if (double.tryParse(value) == null) {
            return 'الرجاء إدخال رقم';
          }
          double totalPrice = 0;
          for (var si in BlocProvider.of<TransactionItemInCartCubit>(context)
              .transactionItemMaps) {
            Map res = _calculateItemValues(si);
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

  Widget _buildItemListView(
    AsyncSnapshot<Map<String, List<Model>>> snapshot,
  ) {
    List<Map> transactionItemMaps =
        BlocProvider.of<TransactionItemInCartCubit>(context)
            .transactionItemMaps;
    return Flexible(
      fit: FlexFit.tight,
      child:
          BlocBuilder<TransactionItemInCartCubit, TransactionItemInCartState>(
        bloc: BlocProvider.of<TransactionItemInCartCubit>(context),
        builder: (context, state) {
          return ListView.builder(
            shrinkWrap: true,
            itemCount: transactionItemMaps.length,
            itemBuilder: (context, index) {
              return TransactionItemInCartCard(
                categories: snapshot.data!['categories']!,
                isSale: _isSale,
                items: snapshot.data!['items']!,
                transactionItem: transactionItemMaps[index],
                calculateItemValues: _calculateItemValues,
              );
            },
          );
        },
      ),
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

  Map _calculateItemValues(Map si) {
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
      if (isKg && _isSale) {
        transactionItemQuantity = si['quantity'] / 1000;
      } else {
        transactionItemQuantity = si['quantity'];
      }
      sellingPrice = i.sellingPrice * transactionItemQuantity;
      purchasePrice = i.purchasePrice * transactionItemQuantity;
    } else if (si['price'] != null && si['price'] != 0) {
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
}
