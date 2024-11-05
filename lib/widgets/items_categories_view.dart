import 'package:alkhal/cubit/add_item_fab_visibility/add_item_fab_visibility_cubit.dart';
import 'package:alkhal/cubit/category/category_cubit.dart';
import 'package:alkhal/cubit/item_history/item_history_cubit.dart';
import 'package:alkhal/cubit/search_bar/search_bar_cubit.dart';
import 'package:alkhal/models/model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:alkhal/cubit/item/item_cubit.dart';
import 'package:alkhal/models/item.dart';
import 'package:alkhal/cubit/add_category_fab_visibility/add_category_fab_visibility_cubit.dart';
import 'package:alkhal/models/category.dart';
import 'package:alkhal/utils/constants.dart';
import 'package:alkhal/widgets/add_category_fab.dart';
import 'package:alkhal/widgets/add_item_fab.dart';
import 'package:alkhal/widgets/category_card.dart';
import 'package:alkhal/widgets/item_card.dart';

class ItemsCategoriesView extends StatefulWidget {
  const ItemsCategoriesView({super.key});

  @override
  State<ItemsCategoriesView> createState() => _ItemsCategoriesViewState();
}

class _ItemsCategoriesViewState extends State<ItemsCategoriesView>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final ScrollController _itemsScrollController = ScrollController();
  final ScrollController _categoriesScrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _categoriesScrollController.dispose();
    _itemsScrollController.dispose();
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
    context
        .read<AddItemFabVisibilityCubit>()
        .listenToScrolling(_itemsScrollController);
    BlocProvider.of<ItemCubit>(context).loadItems();
    BlocProvider.of<SearchBarCubit>(context).loadVisibility();
    return BlocBuilder<ItemCubit, ItemState>(
      builder: (context, state) {
        if (state is LoadingItems) {
          return const Center(
            child: CircularProgressIndicator(
              color: Colors.blue,
            ),
          );
        } else if (state is LoadingItemsFailed) {
          return buildErrorWidget(state.err);
        } else if (state.items!.isNotEmpty) {
          return _buildView(
            fab: BlocBuilder<AddItemFabVisibilityCubit,
                AddItemFabVisibilityState>(
              builder: (context, newState) {
                return Visibility(
                  visible: newState.isVisible,
                  child: AddItemFAB(
                    defaultCategory: state.filter,
                  ),
                );
              },
            ),
            children: ListView.builder(
              controller: _itemsScrollController,
              itemCount: state.items!.length,
              itemBuilder: (context, index) => ItemCard(
                item: state.items![index] as Item,
                category: state.categories.firstWhere((category) {
                  return (category as Category).id ==
                      (state.items![index] as Item).categoryId;
                }) as Category,
              ),
            ),
            itemFilters: ItemsFilterDropDown(
              itemsFilter: state.filter,
              categories: state.categories,
            ),
            searchBar: BlocBuilder<SearchBarCubit, SearchBarState>(
              builder: (context, newState) {
                if (newState is SearchBarVisibility) {
                  if (newState.isVisible) {
                    return _buildAutocomplete(state.items!, state.categories);
                  } else {
                    return const SizedBox();
                  }
                } else {
                  return const SizedBox();
                }
              },
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
            searchBar: BlocBuilder<SearchBarCubit, SearchBarState>(
              builder: (context, newState) {
                if (newState is SearchBarVisibility) {
                  if (newState.isVisible) {
                    return _buildAutocomplete(state.items!, state.categories);
                  } else {
                    return const SizedBox();
                  }
                } else {
                  return const SizedBox();
                }
              },
            ),
          );
        }
      },
    );
  }

  Widget _buildAutocomplete(List<Model> items, List<Model> categories) {
    return Autocomplete<Model>(
      optionsBuilder: (TextEditingValue textEditingValue) {
        if (textEditingValue.text.isEmpty) {
          return const Iterable<Model>.empty();
        }
        return items.where((Model item) {
          return (item as Item)
              .name
              .toLowerCase()
              .contains(textEditingValue.text.toLowerCase());
        });
      },
      displayStringForOption: (Model item) => (item as Item).name,
      onSelected: (Model selectedItem) {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (newContext) {
              return MultiBlocProvider(
                providers: [
                  BlocProvider.value(
                    value: BlocProvider.of<ItemCubit>(context),
                  ),
                  BlocProvider.value(
                    value: BlocProvider.of<ItemHistoryCubit>(context),
                  ),
                ],
                child: Scaffold(
                  appBar: AppBar(
                    title: const Text("نتيجة بحث عنصر"),
                  ),
                  body: ItemCard(
                    item: selectedItem as Item,
                    category: categories.firstWhere((category) {
                      return (category as Category).id ==
                          selectedItem.categoryId;
                    }) as Category,
                  ),
                ),
              );
            },
          ),
        );
      },
      fieldViewBuilder: (context, controller, focusNode, onFieldSubmitted) {
        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: TextField(
            textDirection: TextDirection.rtl,
            controller: controller,
            focusNode: focusNode,
            decoration: InputDecoration(
              hintText: 'بحث العناصر',
              hintTextDirection: TextDirection.rtl,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildCategoriesView(BuildContext context) {
    context
        .read<AddCategoryFabVisibilityCubit>()
        .listenToScrolling(_categoriesScrollController);
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
          return buildErrorWidget(state.err);
        } else if (state.categories.isNotEmpty) {
          return _buildView(
            fab: BlocBuilder<AddCategoryFabVisibilityCubit,
                AddCategoryFabVisibilityState>(
              builder: (context, newState) {
                return Visibility(
                  visible: newState.isVisible,
                  child: const AddCategoryFAB(),
                );
              },
            ),
            children: ListView.builder(
              controller: _categoriesScrollController,
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
    Widget searchBar = const SizedBox(),
  }) {
    return Scaffold(
      backgroundColor: Colors.white,
      floatingActionButton: fab,
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      body: Column(
        children: [
          const SizedBox(height: 10),
          searchBar,
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
        isExpanded: true,
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
