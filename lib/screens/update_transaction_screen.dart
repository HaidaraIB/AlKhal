import 'package:alkhal/cubit/transaction/transaction_cubit.dart';
import 'package:alkhal/cubit/transaction_item/transaction_item_cubit.dart';
import 'package:alkhal/models/model.dart';
import 'package:alkhal/models/transaction.dart';
import 'package:alkhal/models/transaction_item.dart';
import 'package:alkhal/utils/constants.dart';
import 'package:alkhal/utils/functions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class UpdateTransactionScreen extends StatefulWidget {
  final Transaction transaction;
  const UpdateTransactionScreen({
    super.key,
    required this.transaction,
  });

  @override
  State<UpdateTransactionScreen> createState() =>
      _UpdateTransactionScreenState();
}

class _UpdateTransactionScreenState extends State<UpdateTransactionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _discountController = TextEditingController();
  final _remainderController = TextEditingController();
  final _notesController = TextEditingController();

  @override
  void initState() {
    super.initState();
    BlocProvider.of<TransactionItemCubit>(context)
        .loadItems(transactionId: widget.transaction.id);
    _remainderController.text = widget.transaction.remainder.toString();
    _discountController.text = widget.transaction.discount.toString();
    _notesController.text = widget.transaction.notes;
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TransactionItemCubit, TransactionItemState>(
      bloc: BlocProvider.of<TransactionItemCubit>(context),
      builder: (context, state) {
        if (state is LoadingTransactionItems) {
          return const Center(
            child: CircularProgressIndicator(
              color: Colors.purple,
            ),
          );
        } else if (state is LoadingTransactionItemsFailed) {
          return buildErrorWidget(state.err);
        } else if (state is TransactionItemList &&
            state.transactionItems.isNotEmpty) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('تعديل فاتورة'),
            ),
            body: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      _buildDiscountField(state.transactionItems),
                      _buildRemainderField(state.transactionItems),
                      const SizedBox(
                        height: 10,
                      ),
                      _buildNotesField(context),
                      const SizedBox(
                        height: 10,
                      ),
                      ElevatedButton(
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            final newTransaction = Transaction(
                              id: widget.transaction.id,
                              discount:
                                  double.tryParse(_discountController.text) ??
                                      widget.transaction.discount,
                              isSale: widget.transaction.isSale,
                              notes: _notesController.text,
                              remainder:
                                  double.tryParse(_remainderController.text) ??
                                      widget.transaction.remainder,
                              totalPrice: widget.transaction.totalPrice,
                              totalProfit: widget.transaction.totalProfit,
                              transactionDate:
                                  widget.transaction.transactionDate,
                            );
                            BlocProvider.of<TransactionCubit>(context)
                                .updateTransaction(newTransaction);
                            Navigator.of(context).pop();
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.deepPurple,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24.0,
                            vertical: 16.0,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                        ),
                        child: const Text('تعديل'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        } else {
          return const Center(
            child: Text(
              'ليس لديك عناصر بعد!',
              textDirection: TextDirection.rtl,
              style: TextStyle(fontSize: 20),
            ),
          );
        }
      },
    );
  }

  TextFormField _buildNotesField(BuildContext context) {
    return TextFormField(
      controller: _notesController,
      textAlign: TextAlign.right,
      textDirection: TextDirection.rtl,
      validator: (value) {
        if (_remainderController.text ==
                widget.transaction.remainder.toString() &&
            _discountController.text ==
                widget.transaction.discount.toString() &&
            _notesController.text == widget.transaction.notes) {
          return "عليك تعديل حقل واحد على الأقل";
        }
        return null;
      },
      maxLines: null, // Allows the TextField to expand vertically
      decoration: InputDecoration(
        hintText: 'أدخل ملاحظاتك هنا',
        hintTextDirection: TextDirection.rtl,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Theme.of(context).primaryColor),
          borderRadius: BorderRadius.circular(12.0),
        ),
      ),
    );
  }

  Widget _buildDiscountField(List<Model> transactionItems) {
    return TextFormField(
      controller: _discountController,
      decoration: const InputDecoration(labelText: 'الحسم'),
      keyboardType: TextInputType.number,
      validator: (value) {
        if (_remainderController.text ==
                widget.transaction.remainder.toString() &&
            _discountController.text ==
                widget.transaction.discount.toString() &&
            _notesController.text == widget.transaction.notes) {
          return "عليك تعديل حقل واحد على الأقل";
        } else if (value != null && value.isNotEmpty) {
          if (double.tryParse(value) == null) {
            return 'الرجاء إدخال رقم';
          }
          double totalPrice = 0;
          for (Model ti in transactionItems) {
            ti = ti as TransactionItem;
            totalPrice += widget.transaction.isSale == 1
                ? ti.sellingPrice * ti.quantity
                : ti.purchasePrice * ti.quantity;
          }

          if (double.tryParse(value)! > totalPrice * 0.1) {
            return 'يجب أن يكون الحسم أقل من 10% السعر الإجمالي: ${formatDouble(totalPrice * 0.1)}';
          }
        }
        return null;
      },
    );
  }

  Widget _buildRemainderField(List<Model> transactionItems) {
    return TextFormField(
      controller: _remainderController,
      decoration: const InputDecoration(labelText: 'الباقي'),
      keyboardType: TextInputType.number,
      validator: (value) {
        if (_remainderController.text ==
                widget.transaction.remainder.toString() &&
            _discountController.text ==
                widget.transaction.discount.toString() &&
            _notesController.text == widget.transaction.notes) {
          return "عليك تعديل حقل واحد على الأقل";
        } else if (value != null && value.isNotEmpty) {
          if (double.tryParse(value) == null) {
            return 'الرجاء إدخال رقم';
          }
          double totalPrice = 0;
          for (Model ti in transactionItems) {
            ti = ti as TransactionItem;
            totalPrice += widget.transaction.isSale == 1
                ? ti.sellingPrice * ti.quantity
                : ti.purchasePrice * ti.quantity;
          }
          if (double.tryParse(value)! > totalPrice) {
            return 'يجب أن يكون الباقي أقل من السعر الإجمالي: ${formatDouble(totalPrice)}';
          }
        }
        return null;
      },
    );
  }
}
