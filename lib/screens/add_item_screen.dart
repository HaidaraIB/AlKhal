import 'package:alkhal/cubit/item/item_cubit.dart';
import 'package:alkhal/models/category.dart';
import 'package:alkhal/models/item.dart';
import 'package:alkhal/models/measurement_unit.dart';
import 'package:alkhal/models/model.dart';
import 'package:alkhal/services/database_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AddItemForm extends StatefulWidget {
  const AddItemForm({
    super.key,
    required this.defaultCategory,
  });
  final String defaultCategory;

  @override
  State<AddItemForm> createState() => _AddItemFormState();
}

class _AddItemFormState extends State<AddItemForm> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _unitController = TextEditingController();
  final _categoryController = TextEditingController();
  final _quantityController = TextEditingController();
  final _purchasePriceController = TextEditingController();
  final _sellingPriceController = TextEditingController();

  late Future<List<Model>> _getCategories;
  @override
  void initState() {
    super.initState();
    _categoryController.text = widget.defaultCategory;
    _getCategories = DatabaseHelper.getAll(Category.tableName, "Category");
  }

  @override
  void dispose() {
    _nameController.dispose();
    _unitController.dispose();
    _categoryController.dispose();
    _quantityController.dispose();
    _purchasePriceController.dispose();
    _sellingPriceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _getCategories,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('إضافة عنصر'),
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
                        controller: _nameController,
                        decoration: const InputDecoration(labelText: 'الاسم'),
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'الرجاء إدخال اسم';
                          }
                          var i = BlocProvider.of<ItemCubit>(context)
                              .items
                              .where((element) {
                            Item i = element as Item;
                            if (i.name == value) {
                              return true;
                            }
                            return false;
                          });
                          if (i.isNotEmpty) {
                            return "هذا العنصر موجود مسبقاً";
                          }
                          return null;
                        },
                      ),
                      DropdownButtonFormField<String>(
                        isExpanded: true,
                        value: _categoryController.text != "all"
                            ? _categoryController.text
                            : null,
                        onChanged: (value) {
                          setState(
                            () => _categoryController.text = value!.toString(),
                          );
                        },
                        items: snapshot.data!
                            .map(
                              (category) => DropdownMenuItem<String>(
                                value: category.id.toString(),
                                child: Text((category as Category).name),
                              ),
                            )
                            .toList(),
                        decoration:
                            const InputDecoration(labelText: 'المجموعة'),
                        validator: (value) {
                          if (value == null) {
                            return "الرجاء اختيار مجموعة";
                          }
                          return null;
                        },
                      ),
                      DropdownButtonFormField<String>(
                        value: _unitController.text.isNotEmpty
                            ? _unitController.text
                            : null,
                        onChanged: (value) {
                          setState(
                              () => _unitController.text = value!.toString());
                        },
                        items: MeasurementUnit.values.map((unit) {
                          return DropdownMenuItem<String>(
                            value: unit.value,
                            child: Text(MeasurementUnit.toArabic(unit.value)),
                          );
                        }).toList(),
                        decoration: const InputDecoration(labelText: 'الواحدة'),
                        validator: (value) {
                          if (value == null) {
                            return 'الرجاء اختيار واحدة';
                          }
                          return null;
                        },
                        isExpanded: true,
                      ),
                      TextFormField(
                        scrollPadding: EdgeInsets.only(
                          bottom: MediaQuery.of(context).viewInsets.bottom,
                        ),
                        controller: _quantityController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(labelText: 'الكمية'),
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'الرجاء اختيار كمية';
                          }
                          if (double.tryParse(value) == null) {
                            return 'الرجاء إدخال رقم';
                          }
                          return null;
                        },
                      ),
                      TextFormField(
                        scrollPadding: EdgeInsets.only(
                          bottom: MediaQuery.of(context).viewInsets.bottom,
                        ),
                        controller: _purchasePriceController,
                        keyboardType: TextInputType.number,
                        decoration:
                            const InputDecoration(labelText: 'سعر الشراء'),
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'الرجاء إدخال سعر شراء';
                          } else if (double.tryParse(value) == null) {
                            return 'الرجاء إدخال رقم';
                          } else if (double.tryParse(value)! <= 0) {
                            return 'الرجاء إدخال عدد موجب تماماً';
                          } else if (double.tryParse(
                                      _sellingPriceController.text) !=
                                  null &&
                              double.tryParse(_sellingPriceController.text)! <=
                                  double.tryParse(value)!) {
                            return 'سعر الشراء يجب أن يكون أصغر من سعر المبيع';
                          }
                          return null;
                        },
                      ),
                      TextFormField(
                        scrollPadding: EdgeInsets.only(
                          bottom: MediaQuery.of(context).viewInsets.bottom,
                        ),
                        controller: _sellingPriceController,
                        keyboardType: TextInputType.number,
                        decoration:
                            const InputDecoration(labelText: 'سعر المبيع'),
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'الرجاء إدخال سعر مبيع';
                          } else if (double.tryParse(value) == null) {
                            return 'الرجاء إدخال رقم';
                          } else if (double.tryParse(value)! <= 0) {
                            return 'الرجاء إدخال عدد موجب تماماً';
                          } else if (double.tryParse(
                                      _purchasePriceController.text) !=
                                  null &&
                              double.tryParse(_purchasePriceController.text)! >=
                                  double.tryParse(value)!) {
                            return 'سعر المبيع يجب أن يكون أكبر من سعر الشراء';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      ElevatedButton(
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            final newItem = Item(
                              categoryId: int.parse(_categoryController.text),
                              name: _nameController.text,
                              unit: MeasurementUnit.fromString(
                                  _unitController.text),
                              quantity: double.parse(_quantityController.text),
                              purchasePrice:
                                  double.parse(_purchasePriceController.text),
                              sellingPrice:
                                  double.parse(_sellingPriceController.text),
                            );
                            BlocProvider.of<ItemCubit>(context)
                                .addItem(newItem);
                            Navigator.pop(context);
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
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
