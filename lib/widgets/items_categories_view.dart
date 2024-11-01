import 'package:alkhal/cubit/category/category_cubit.dart';
import 'package:alkhal/cubit/item/item_cubit.dart';
import 'package:alkhal/models/category.dart';
import 'package:alkhal/models/item.dart';
import 'package:alkhal/models/model.dart';
import 'package:alkhal/widgets/add_category_fab.dart';
import 'package:alkhal/widgets/add_item_fab.dart';
import 'package:alkhal/widgets/category_card.dart';
import 'package:alkhal/widgets/item_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ItemsCategoriesView extends StatefulWidget {
  const ItemsCategoriesView({super.key});

  @override
  State<ItemsCategoriesView> createState() => _ItemsCategoriesViewState();
}

class _ItemsCategoriesViewState extends State<ItemsCategoriesView>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<CategoryCubit, CategoryState>(
          listener: (context, state) {
            if (state.categories.isNotEmpty) {
              context.read<ItemCubit>().loadItems();
            }
          },
        ),
      ],
      child: Scaffold(
        appBar: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'العناصر'),
            Tab(text: 'المجموعات'),
          ],
        ),
        body: TabBarView(
          controller: _tabController,
          children: [
            _buildItemsView(context),
            _buildCategoriesView(context),
          ],
        ),
      ),
    );
  }

  Widget _buildItemsView(BuildContext context) {
    BlocProvider.of<ItemCubit>(context).loadItems();
    return BlocBuilder<ItemCubit, ItemState>(
      builder: (context, state) {
        if (state is LoadingItems) {
          return const Center(
            child: CircularProgressIndicator(
              color: Colors.blue,
            ),
          );
        } else if (state is LoadingItemsFailed) {
          return const Center(
            child: Text(
              "Something went wrong!",
              style: TextStyle(
                fontSize: 20,
              ),
            ),
          );
        } else if (state.items!.isNotEmpty) {
          return _buildView(
            fab: AddItemFAB(defaultCategory: state.filter),
            children: ListView.builder(
              itemCount: state.items!.length,
              itemBuilder: (context, index) =>
                  ItemCard(item: state.items![index] as Item),
            ),
            itemFilters: ItemsFilterDropDown(
              itemsFilter: state.filter,
              categories: state.categories,
            ),
          );
        } else {
          return _buildView(
            fab: AddItemFAB(
              defaultCategory: state.filter,
            ),
            children: Center(
              child: Text(
                '!ليس لديك ${state.filterName} بعد',
                style: const TextStyle(fontSize: 20),
              ),
            ),
            itemFilters: ItemsFilterDropDown(
              itemsFilter: state.filter,
              categories: state.categories,
            ),
          );
        }
      },
    );
  }

  Widget _buildCategoriesView(BuildContext context) {
    BlocProvider.of<CategoryCubit>(context).loadCategories();
    return BlocBuilder<CategoryCubit, CategoryState>(
      builder: (context, state) {
        if (state is LoadingCategories) {
          return const Center(
            child: CircularProgressIndicator(
              color: Colors.blue,
            ),
          );
        } else if (state is LoadingCategoriesFailed) {
          return const Center(
            child: Text(
              "Something went wrong!",
              style: TextStyle(
                fontSize: 20,
              ),
            ),
          );
        } else if (state.categories.isNotEmpty) {
          return _buildView(
            fab: const AddCategoryFAB(),
            children: ListView.builder(
              itemCount: state.categories.length,
              itemBuilder: (context, index) =>
                  CategoryCard(category: state.categories[index] as Category),
            ),
          );
        } else {
          return _buildView(
            fab: const AddCategoryFAB(),
            children: const Center(
              child: Text(
                '!ليس لديك مجموعات بعد',
                style: TextStyle(fontSize: 20),
              ),
            ),
          );
        }
      },
    );
  }

  Widget _buildView({
    required Widget children,
    required Widget fab,
    Widget itemFilters = const SizedBox(),
  }) {
    return Scaffold(
      backgroundColor: Colors.white,
      floatingActionButton: fab,
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      body: Column(
        children: [
          const SizedBox(height: 10),
          itemFilters is SizedBox
              ? itemFilters
              : Row(
                  children: [
                    const Spacer(),
                    itemFilters,
                  ],
                ),
          const SizedBox(height: 10),
          Expanded(child: children),
        ],
      ),
    );
  }
}

class ItemsFilterDropDown extends StatelessWidget {
  final String itemsFilter;
  final List<Model> categories;

  const ItemsFilterDropDown({
    super.key,
    required this.itemsFilter,
    required this.categories,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: DropdownButtonFormField<String>(
        decoration: InputDecoration(
          filled: true,
          fillColor: Theme.of(context).colorScheme.inversePrimary,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 20),
        ),
        dropdownColor: Theme.of(context).colorScheme.inversePrimary,
        borderRadius: BorderRadius.circular(10),
        value: itemsFilter,
        items: categories.map((category) {
          return DropdownMenuItem(
            value: category.id.toString(),
            child: Text((category as Category).name),
          );
        }).toList()
          ..add(const DropdownMenuItem(
            value: "all",
            child: Text("الكل"),
          )),
        onChanged: (newFilter) {
          context.read<ItemCubit>().setFilter(newFilter ?? "all");
        },
      ),
    );
  }
}
