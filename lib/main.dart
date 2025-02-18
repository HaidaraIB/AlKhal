import 'package:alkhal/cubit/add_category_fab_visibility/add_category_fab_visibility_cubit.dart';
import 'package:alkhal/cubit/add_item_fab_visibility/add_item_fab_visibility_cubit.dart';
import 'package:alkhal/cubit/add_transaction_fab_visibility/add_transaction_fab_visibility_cubit.dart';
import 'package:alkhal/cubit/cash/cash_cubit.dart';
import 'package:alkhal/cubit/category/category_cubit.dart';
import 'package:alkhal/cubit/date_range/date_range_cubit.dart';
import 'package:alkhal/cubit/item/item_cubit.dart';
import 'package:alkhal/cubit/item_history/item_history_cubit.dart';
import 'package:alkhal/cubit/search_bar/search_bar_cubit.dart';
import 'package:alkhal/cubit/transaction/transaction_cubit.dart';
import 'package:alkhal/cubit/transaction_item/transaction_item_cubit.dart';
import 'package:alkhal/cubit/user/user_cubit.dart';
import 'package:alkhal/models/user.dart';
import 'package:alkhal/screens/cash_screen.dart';
import 'package:alkhal/screens/log_in_screen.dart';
import 'package:alkhal/screens/pin_screen.dart';
import 'package:alkhal/screens/settings_screen.dart';
import 'package:alkhal/screens/sign_up_screen.dart';
import 'package:alkhal/screens/transactions_screen.dart';
import 'package:alkhal/services/workmanager_helper.dart';
import 'package:alkhal/widgets/items_categories_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:workmanager/workmanager.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  Workmanager().initialize(callbackDispatcher, isInDebugMode: true);
  Workmanager().registerPeriodicTask("dbSyncTask", "dbSyncTask");
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => UserCubit(),
      child: MaterialApp(
        title: 'الخال',
        theme: ThemeData(
          useMaterial3: true,
        ),
        initialRoute: '/',
        routes: {
          '/': (context) => const InitialScreen(),
          '/home': (context) => MultiBlocProvider(
                providers: [
                  BlocProvider(
                    create: (context) => SearchBarCubit(),
                  ),
                  BlocProvider(
                    create: (context) => CashCubit(),
                  ),
                  BlocProvider(
                    create: (context) => DateRangeCubit(),
                  ),
                ],
                child: const MyHomePage(),
              ),
          '/pin': (context) => const PinScreen(),
          '/sign_up': (context) => const SignupPage(),
          '/login': (context) => const LoginPage(),
        },
      ),
    );
  }
}

class InitialScreen extends StatelessWidget {
  const InitialScreen({super.key});

  Future<bool> _checkActivation() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('isActivated') ?? false;
  }

  Future<Map<String, bool>> _runChecks() async {
    final bool isActivated = await _checkActivation();
    final bool isSigned = await User.checkSigned();
    return {
      "signed": isSigned,
      "activated": isActivated,
    };
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, bool>>(
      future: _runChecks(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(
              color: Colors.purple,
            ),
          );
        } else {
          if (snapshot.data!['activated'] as bool) {
            Future.microtask(() {
              if (context.mounted) {
                if (snapshot.data!['signed'] as bool) {
                  Navigator.pushReplacementNamed(context, '/home');
                  return;
                }
                Navigator.pushReplacementNamed(context, '/sign_up');
              }
            });
          } else {
            Future.microtask(() {
              if (context.mounted) {
                Navigator.pushReplacementNamed(context, '/pin');
              }
            });
          }
          return Container();
        }
      },
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _selectedIndex = 1;
  List<Widget> _widgetOptions = [];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  void initState() {
    super.initState();
    _widgetOptions = <Widget>[
      MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (context) => ItemCubit(),
          ),
          BlocProvider(
            create: (context) => CategoryCubit(),
          ),
          BlocProvider(
            create: (context) => ItemHistoryCubit(),
          ),
          BlocProvider(
            create: (context) => AddItemFabVisibilityCubit(),
          ),
          BlocProvider(
            create: (context) => AddCategoryFabVisibilityCubit(),
          ),
          BlocProvider(
            create: (context) => TransactionItemCubit(),
          ),
        ],
        child: const ItemsCategoriesView(),
      ),
      MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (context) => TransactionCubit(),
          ),
          BlocProvider(
            create: (context) => TransactionItemCubit(),
          ),
        ],
        child: const CashScreen(),
      ),
      MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (context) => TransactionCubit(),
          ),
          BlocProvider(
            create: (context) => AddTransactionFabVisibilityCubit(),
          ),
          BlocProvider(
            create: (context) => ItemCubit(),
          ),
          BlocProvider(
            create: (context) => TransactionItemCubit(),
          ),
        ],
        child: const TransactionsScreen(),
      ),
    ];
    initializeDateFormatting("ar_SA", null);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        scrolledUnderElevation: 0.0,
        title: const Text(
          "الخال",
          style: TextStyle(
            fontSize: 40,
            fontWeight: FontWeight.bold,
            fontFamily: "me",
            color: Colors.deepPurple,
          ),
        ),
        centerTitle: true,
        actions: [
          _selectedIndex == 1
              ? IconButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (newContext) {
                          return PopScope(
                            child: const SettingsScreen(),
                            onPopInvokedWithResult: (didPop, result) =>
                                BlocProvider.of<CashCubit>(context)
                                    .popSettingsScreen(),
                          );
                        },
                      ),
                    );
                  },
                  icon: const Icon(Icons.settings),
                )
              : const SizedBox()
        ],
        leading: _selectedIndex == 0
            ? IconButton(
                onPressed: () {
                  BlocProvider.of<SearchBarCubit>(context).changeVisibility();
                },
                icon: const Icon(Icons.search),
              )
            : null,
      ),
      body: Center(
        child: _widgetOptions.elementAt(_selectedIndex),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.storage),
            label: 'عناصر',
            tooltip: 'عناصر',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.attach_money),
            label: 'كاش',
            tooltip: 'كاش',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.payment),
            label: 'فواتير',
            tooltip: "فواتير",
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.deepPurple,
        onTap: _onItemTapped,
        showSelectedLabels: true,
        showUnselectedLabels: false,
      ),
    );
  }
}
