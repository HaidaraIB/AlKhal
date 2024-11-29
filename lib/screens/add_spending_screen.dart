import 'package:alkhal/cubit/spending/spending_cubit.dart';
import 'package:alkhal/models/spending.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AddSpendingScreen extends StatefulWidget {
  const AddSpendingScreen({super.key});

  @override
  State<AddSpendingScreen> createState() => _AddSpendingScreenState();
}

class _AddSpendingScreenState extends State<AddSpendingScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _notesController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('إضافة مصروف'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                TextFormField(
                  scrollPadding: EdgeInsets.only(
                    bottom: MediaQuery.of(context).viewInsets.bottom,
                  ),
                  controller: _amountController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'المبلغ'),
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'الرجاء إدخال مبلغ';
                    }
                    if (double.tryParse(value) == null) {
                      return 'الرجاء إدخال رقم';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _notesController,
                  textAlign: TextAlign.right,
                  textDirection: TextDirection.rtl,
                  maxLines:
                      null, // Allows the TextFormField to expand vertically
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
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      final newSpending = Spending(
                        amount: double.parse(_amountController.text),
                        notes: _notesController.text,
                        spendingDate: DateTime.now().toString(),
                      );
                      BlocProvider.of<SpendingCubit>(context)
                          .addSpending(newSpending);
                      Navigator.pop(context);
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
                  child: const Text('إضافة'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
