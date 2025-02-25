import 'package:alkhal/cubit/item/item_cubit.dart';
import 'package:alkhal/cubit/item_history/item_history_cubit.dart';
import 'package:alkhal/models/category.dart';
import 'package:alkhal/models/item.dart';
import 'package:alkhal/models/item_history.dart';
import 'package:alkhal/services/database_helper.dart';
import 'package:alkhal/utils/functions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class UpdateItemForm extends StatefulWidget {
  const UpdateItemForm({
    super.key,
    required this.oldItem,
  });
  final Item oldItem;

  @override
  State<UpdateItemForm> createState() => _AddItemFormState();
}

class _AddItemFormState extends State<UpdateItemForm> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _categoryController = TextEditingController();
  final _sellingPriceController = TextEditingController();
  final _purchasePriceController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _categoryController.dispose();
    _sellingPriceController.dispose();
    _purchasePriceController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: DatabaseHelper.getAll(Category.tableName, "Category"),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('تعديل عنصر'),
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
                        decoration: InputDecoration(
                          labelText: 'الاسم',
                          hintText: widget.oldItem.name,
                        ),
                        validator: (value) {
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
                          } else if (_nameController.text.isEmpty &&
                              _categoryController.text.isEmpty &&
                              _sellingPriceController.text.isEmpty &&
                              _purchasePriceController.text.isEmpty) {
                            return "عليك تعديل حقل واحد على الأقل";
                          }
                          return null;
                        },
                      ),
                      DropdownButtonFormField<String>(
                        isExpanded: true,
                        value: _categoryController.text.isNotEmpty
                            ? _categoryController.text
                            : widget.oldItem.categoryId.toString(),
                        onChanged: (value) {
                          setState(() {
                            if (value!.toString() !=
                                widget.oldItem.categoryId.toString()) {
                              _categoryController.text = value.toString();
                            }
                          });
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
                          if (_nameController.text.isEmpty &&
                              _categoryController.text.isEmpty &&
                              _sellingPriceController.text.isEmpty &&
                              _purchasePriceController.text.isEmpty) {
                            return "عليك تعديل حقل واحد على الأقل";
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
                        decoration: InputDecoration(
                          labelText: 'سعر الشراء',
                          hintText: formatDouble(widget.oldItem.purchasePrice),
                        ),
                        validator: (value) {
                          if (_nameController.text.isEmpty &&
                              _categoryController.text.isEmpty &&
                              _sellingPriceController.text.isEmpty &&
                              _purchasePriceController.text.isEmpty) {
                            return "عليك تعديل حقل واحد على الأقل";
                          } else if (value!.isEmpty) {
                            return null;
                          }
                          var newSellingPrice =
                              double.tryParse(_sellingPriceController.text);
                          var newPurchasePrice = double.tryParse(value);
                          if (newPurchasePrice == null) {
                            return 'الرجاء إدخال رقم';
                          } else if (newPurchasePrice <= 0) {
                            return 'الرجاء إدخال عدد موجب تماماً';
                          } else if ((newSellingPrice != null &&
                                  newSellingPrice <= newPurchasePrice) ||
                              (newSellingPrice == null &&
                                  widget.oldItem.sellingPrice <=
                                      newPurchasePrice)) {
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
                        decoration: InputDecoration(
                          labelText: 'سعر المبيع',
                          hintText: formatDouble(widget.oldItem.sellingPrice),
                        ),
                        validator: (value) {
                          if (_nameController.text.isEmpty &&
                              _categoryController.text.isEmpty &&
                              _sellingPriceController.text.isEmpty &&
                              _purchasePriceController.text.isEmpty) {
                            return "عليك تعديل حقل واحد على الأقل";
                          } else if (value!.isEmpty) {
                            return null;
                          }
                          var newPurchasePrice =
                              double.tryParse(_purchasePriceController.text);
                          var newSellingPrice = double.tryParse(value);
                          if (newSellingPrice == null) {
                            return 'الرجاء إدخال رقم';
                          } else if (newSellingPrice <= 0) {
                            return 'الرجاء إدخال عدد موجب تماماً';
                          } else if ((newPurchasePrice != null &&
                                  newPurchasePrice >= newSellingPrice) ||
                              (newPurchasePrice == null &&
                                  widget.oldItem.purchasePrice >=
                                      newSellingPrice)) {
                            return 'سعر المبيع يجب أن يكون أكبر من سعر الشراء';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      ElevatedButton(
                        onPressed: () async {
                          if (_formKey.currentState!.validate()) {
                            final newItem = Item(
                              id: widget.oldItem.id,
                              categoryId:
                                  int.tryParse(_categoryController.text) ??
                                      widget.oldItem.categoryId,
                              name: _nameController.text.isEmpty
                                  ? widget.oldItem.name
                                  : _nameController.text,
                              unit: widget.oldItem.unit,
                              quantity: widget.oldItem.quantity,
                              purchasePrice: double.tryParse(
                                      _purchasePriceController.text) ??
                                  widget.oldItem.purchasePrice,
                              sellingPrice: double.tryParse(
                                      _sellingPriceController.text) ??
                                  widget.oldItem.sellingPrice,
                            );
                            BlocProvider.of<ItemHistoryCubit>(context)
                                .addItemHistory(
                              ItemHistory(
                                updateDate: DateTime.now().toString(),
                                itemId: widget.oldItem.id!,
                                newCategoryId:
                                    int.tryParse(_categoryController.text) ??
                                        widget.oldItem.categoryId,
                                oldCategoryId: widget.oldItem.categoryId,
                                newName: _nameController.text.isEmpty
                                    ? widget.oldItem.name
                                    : _nameController.text,
                                oldName: widget.oldItem.name,
                                newPurchasePrice: double.tryParse(
                                        _purchasePriceController.text) ??
                                    widget.oldItem.purchasePrice,
                                oldPurchasePrice: widget.oldItem.purchasePrice,
                                newSellingPrice: double.tryParse(
                                        _sellingPriceController.text) ??
                                    widget.oldItem.sellingPrice,
                                oldSellingPrice: widget.oldItem.sellingPrice,
                              ),
                            );
                            await BlocProvider.of<ItemCubit>(context)
                                .updateItem(newItem);
                            if (context.mounted) {
                              Navigator.pop(context);
                            }
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
            child: CircularProgressIndicator(
              color: Colors.purple,
            ),
          );
        }
      },
    );
  }
}
