import 'package:alkhal/cubit/category/category_cubit.dart';
import 'package:alkhal/models/category.dart';
import 'package:alkhal/models/model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CategoryForm extends StatefulWidget {
  final Category? category;
  final Future<List<Model>>? categoriesFuture;

  const CategoryForm({
    super.key,
    this.category,
    this.categoriesFuture,
  });

  @override
  State<CategoryForm> createState() => _CategoryFormState();
}

class _CategoryFormState extends State<CategoryForm> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.category != null) {
      _nameController.text = widget.category!.name;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Model>>(
      future: widget.categoriesFuture,
      builder: (context, snapshot) {
        if (widget.categoriesFuture != null && !snapshot.hasData) {
          return const Center(
            child: CircularProgressIndicator(
              color: Colors.purple,
            ),
          );
        }

        final existingCategories = snapshot.data ?? [];

        return SingleChildScrollView(
          padding: EdgeInsets.only(
            top: 50,
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 16,
            right: 16,
          ),
          child: Form(
            key: _formKey,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
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
                      if (existingCategories.any((category) =>
                          (category as Category).name.trim() == value.trim() &&
                          category.id != widget.category?.id)) {
                        return "هذه المجموعة موجودة مسبقاً";
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        final newCategory = Category(
                          id: widget.category?.id,
                          name: _nameController.text.trim(),
                        );
                        if (widget.category == null) {
                          BlocProvider.of<CategoryCubit>(context)
                              .addCategory(newCategory);
                        } else {
                          BlocProvider.of<CategoryCubit>(context)
                              .updateCategory(newCategory);
                        }
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
                    child: Text(widget.category == null
                        ? 'إضافة مجموعة'
                        : 'تحديث المجموعة'),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
