import 'package:alkhal/cubit/transaction_cash/transaction_cash_cubit.dart';
import 'package:alkhal/cubit/transaction_item_in_cart.dart/transaction_item_in_cart_cubit.dart';
import 'package:alkhal/models/category.dart';
import 'package:alkhal/models/item.dart';
import 'package:alkhal/models/measurement_unit.dart';
import 'package:alkhal/models/model.dart';
import 'package:alkhal/utils/functions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class TransactionItemInCartCard extends StatefulWidget {
  final Map transactionItem;
  final List<Model> items;
  final List<Model> categories;
  final bool isSale;
  final Function calculateItemValues;
  const TransactionItemInCartCard({
    super.key,
    required this.transactionItem,
    required this.items,
    required this.categories,
    required this.isSale,
    required this.calculateItemValues,
  });

  @override
  State<TransactionItemInCartCard> createState() =>
      _TransactionItemInCartCardState();
}

class _TransactionItemInCartCardState extends State<TransactionItemInCartCard> {
  void _deleteItem() {
    if (BlocProvider.of<TransactionItemInCartCubit>(context)
            .transactionItemMaps
            .length ==
        1) {
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
    context
        .read<TransactionItemInCartCubit>()
        .removeTransactionItemFromCart(widget.transactionItem);
    context.read<TransactionCashCubit>().updateCash(calculateTotalPrice());
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.deepPurple[50],
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            _buildItemPriceRow(),
            _buildItemRow(),
            _buildQuantityPriceRow(),
          ],
        ),
      ),
    );
  }

  Widget _buildItemPriceRow() {
    return Padding(
      padding: const EdgeInsets.only(right: 16.0, top: 3.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          BlocBuilder<TransactionCashCubit, TransactionCashState>(
            builder: (context, state) {
              return Text.rich(
                TextSpan(
                  children: <InlineSpan>[
                    const TextSpan(text: "السعر: "),
                    TextSpan(
                      text: formatDouble(calculateTransactionItemPrice(
                          widget.transactionItem)),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    )
                  ],
                ),
                style: const TextStyle(
                  color: Colors.deepPurple,
                  fontSize: 18,
                ),
              );
            },
          )
        ],
      ),
    );
  }

  Widget _buildItemRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Expanded(
          child: _buildItemDropdown(),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _buildCategoryDropdown(),
        ),
        IconButton(
          onPressed: _deleteItem,
          icon: const Icon(Icons.delete),
        )
      ],
    );
  }

  Widget _buildItemDropdown() {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: DropdownButtonFormField<String>(
        value: widget.transactionItem['item_id'] != 0
            ? widget.transactionItem['item_id'].toString()
            : null,
        isExpanded: true,
        decoration: const InputDecoration(
          labelText: 'العنصر',
          errorStyle: TextStyle(
            color: Colors.red,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
          errorMaxLines: 3,
        ),
        onChanged: (value) {
          setState(() {
            List<Model> items = widget.items;
            int itemId = int.parse(value!);
            widget.transactionItem['item_id'] = itemId;
            for (Model i in items) {
              if ((i as Item).id == itemId) {
                widget.transactionItem['item'] = i;
                widget.transactionItem['category_id'] = i.categoryId.toString();
              }
            }
          });
        },
        items: widget.items
            .where((item) {
              if (widget.transactionItem['category_id'] != 0) {
                return (item as Item).categoryId.toString() ==
                    widget.transactionItem['category_id'];
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
          for (var i in BlocProvider.of<TransactionItemInCartCubit>(context)
              .transactionItemMaps) {
            if (distinctItems.contains(i['item_id'])) {
              return "عليك جمع العناصر المتكررة في سجل واحد";
            }
            distinctItems.add(i['item_id']);
          }
          return null;
        },
      ),
    );
  }

  Widget _buildCategoryDropdown() {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: DropdownButtonFormField<String>(
        isExpanded: true,
        value: widget.transactionItem['category_id'] != 0
            ? widget.transactionItem['category_id']
            : null,
        decoration: const InputDecoration(labelText: 'المجموعة'),
        onChanged: (value) {
          setState(() {
            widget.transactionItem['item_id'] = 0;
            widget.transactionItem['category_id'] = value!;
          });
        },
        items: widget.categories
            .map((category) => DropdownMenuItem<String>(
                  value: category.id.toString(),
                  child: Text((category as Category).name),
                ))
            .toList(),
      ),
    );
  }

  Widget _buildQuantityPriceRow() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        widget.isSale &&
                (widget.transactionItem['item'] == null ||
                    (widget.transactionItem['item'] != null &&
                        (widget.transactionItem['item'] as Item).unit ==
                            MeasurementUnit.kg))
            ? Expanded(
                child: _buildPriceField(),
              )
            : const SizedBox(),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10.0),
            child: _buildQuantityField(),
          ),
        ),
      ],
    );
  }

  Widget _buildPriceField() {
    return TextFormField(
      initialValue: widget.transactionItem['price'] != null &&
              widget.transactionItem['price'] != 0
          ? widget.transactionItem['price'].toString()
          : null,
      decoration: InputDecoration(
        label: const Text('السعر', textDirection: TextDirection.rtl),
        hintText: widget.transactionItem['item'] != null
            ? "الإجمالي ${formatDouble((widget.transactionItem['item'] as Item).quantity * (widget.transactionItem['item'] as Item).sellingPrice)} ل.س"
            : '',
        hintStyle: const TextStyle(fontSize: 15),
        errorStyle: const TextStyle(
          color: Colors.red,
          fontSize: 14,
          fontWeight: FontWeight.bold,
        ),
        errorMaxLines: 3,
      ),
      keyboardType: TextInputType.number,
      validator: (value) {
        if (widget.isSale && widget.transactionItem['quantity'] == 0) {
          if (value == null || value.isEmpty) {
            return "الرجاء إدخال كمية أو سعر";
          } else if ((double.tryParse(value) ?? 0) <= 0) {
            return "الرجاء إدخال عدد موجب";
          }
        }
        List<Model> items = widget.items;
        var insufficientQuantity = items.where((item) {
          Item i = item as Item;
          return (i.id == widget.transactionItem['item_id'] &&
              i.quantity * i.sellingPrice < widget.transactionItem['price']);
        });
        if (widget.isSale && insufficientQuantity.isNotEmpty) {
          return "الكمية تجاوزت المخزون";
        } else if (widget.transactionItem['quantity'] != 0 &&
            widget.transactionItem['price'] != 0) {
          return "لا يمكنك إدخال\nكمية وسعر معاً";
        }
        return null;
      },
      onChanged: (value) {
        widget.transactionItem['price'] = double.tryParse(value);
        context.read<TransactionCashCubit>().updateCash(calculateTotalPrice());
      },
    );
  }

  Widget _buildQuantityField() {
    return TextFormField(
      initialValue: widget.transactionItem['quantity'] != null &&
              widget.transactionItem['quantity'] != 0
          ? widget.transactionItem['quantity'].toString()
          : null,
      decoration: InputDecoration(
        label: Text(_makeUnitHintText(), textDirection: TextDirection.rtl),
        hintText: widget.transactionItem['item'] != null
            ? "لديك ${_makeAvailableQuantityText(widget.transactionItem['item'])}"
            : '',
        errorStyle: const TextStyle(
          color: Colors.red,
          fontSize: 14,
          fontWeight: FontWeight.bold,
        ),
        errorMaxLines: 3,
      ),
      keyboardType: TextInputType.number,
      validator: (value) {
        if (widget.isSale && widget.transactionItem['price'] == 0) {
          if (value == null || value.isEmpty) {
            return "الرجاء إدخال كمية أو سعر";
          } else if ((double.tryParse(value) ?? 0) <= 0) {
            return "الرجاء إدخال عدد موجب";
          }
        }
        if (widget.transactionItem['item'] != null) {
          bool insufficientQuantity = (widget.transactionItem['item'] as Item)
                  .quantity <
              (widget.isSale &&
                      widget.transactionItem['item'].unit == MeasurementUnit.kg
                  ? widget.transactionItem['quantity'] / 1000
                  : widget.transactionItem['quantity']);
          if (widget.isSale && insufficientQuantity) {
            return "الكمية تجاوزت المخزون";
          }
        }
        if (widget.isSale &&
            widget.transactionItem['quantity'] != 0 &&
            widget.transactionItem['price'] != 0) {
          return "لا يمكنك إدخال\nكمية وسعر معاً";
        }
        return null;
      },
      onChanged: (value) {
        widget.transactionItem['quantity'] = double.tryParse(value);
        context.read<TransactionCashCubit>().updateCash(calculateTotalPrice());
      },
    );
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

  String _makeUnitHintText() {
    String base = "الكمية ";
    String text = "";
    if (widget.isSale) {
      if (widget.transactionItem['item'] != null) {
        if ((widget.transactionItem['item'] as Item).unit ==
            MeasurementUnit.kg) {
          text = "بالغرام";
        } else {
          text = "بالقطعة";
        }
      } else {
        text = "بالغرام أو بالقطعة";
      }
    } else {
      if (widget.transactionItem['item'] != null) {
        if ((widget.transactionItem['item'] as Item).unit ==
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

  double calculateTotalPrice() {
    double totalPrice = 0;
    for (var si in BlocProvider.of<TransactionItemInCartCubit>(context)
        .transactionItemMaps) {
      totalPrice += calculateTransactionItemPrice(si);
    }
    return totalPrice;
  }

  double calculateTransactionItemPrice(Map si) {
    Map res = widget.calculateItemValues(si);
    double sellingPrice = res['sellingPrice'];
    double purchasePrice = res['purchasePrice'];
    return widget.isSale ? sellingPrice : purchasePrice;
  }
}
