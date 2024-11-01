import 'package:alkhal/cubit/item_history/item_history_cubit.dart';
import 'package:alkhal/models/item_history.dart';
import 'package:alkhal/utils/constants.dart';
import 'package:alkhal/widgets/item_history_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ItemHistoryScreen extends StatefulWidget {
  const ItemHistoryScreen({
    super.key,
    required this.itemId,
  });
  final int itemId;

  @override
  State<ItemHistoryScreen> createState() => _ItemHistoryScreenState();
}

class _ItemHistoryScreenState extends State<ItemHistoryScreen> {
  @override
  void initState() {
    super.initState();
    BlocProvider.of<ItemHistoryCubit>(context).loadHistory(widget.itemId);
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ItemHistoryCubit, ItemHistoryState>(
      builder: (context, state) {
        if (state is LoadingHistory) {
          return const Center(
            child: CircularProgressIndicator(
              color: Colors.blue,
            ),
          );
        } else if (state is LoadingHistoryFailed) {
          return buildErrorWidget(state.err);
        } else if (state.itemHistory.isNotEmpty) {
          return ListView.builder(
            itemCount: state.itemHistory.length,
            itemBuilder: (BuildContext context, int index) {
              return ItemHistoryCard(
                itemHistory: state.itemHistory[index] as ItemHistory,
              );
            },
          );
        } else {
          return const Center(
            child: Text(
              "السجل فارغ",
              style: TextStyle(fontSize: 20),
            ),
          );
        }
      },
    );
  }
}
