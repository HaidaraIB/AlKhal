import 'package:alkhal/cubit/cash/cash_cubit.dart';
import 'package:alkhal/cubit/search_bar/search_bar_cubit.dart';
import 'package:alkhal/screens/cash_screen.dart';
import 'package:alkhal/screens/items_categories_screen.dart';
import 'package:alkhal/screens/pin_screen.dart';
import 'package:alkhal/screens/settings_screen.dart';
import 'package:alkhal/screens/transactions_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'الخال',
      theme: ThemeData(
        useMaterial3: true,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const InitialScreen(),
        '/home': (context) => BlocProvider(
              create: (context) => SearchBarCubit(),
              child: const MyHomePage(),
            ),
        '/pin': (context) => const PinScreen(),
      },
    );
  }
}

class InitialScreen extends StatelessWidget {
  const InitialScreen({super.key});

  Future<bool> _checkActivation() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('isActivated') ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: _checkActivation(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(color: Colors.purple),
          );
        } else {
          if (snapshot.data == true) {
            Future.microtask(() {
              if (context.mounted) {
                Navigator.pushReplacementNamed(context, '/home');
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
      const ItemsList(),
      BlocProvider(
        create: (context) => CashCubit(),
        child: const CashScreen(),
      ),
      const TransactionsList(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
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
          IconButton(
            onPressed: () {
              Navigator.of(context).push(MaterialPageRoute(
                builder: (context) {
                  return const SettingsScreen();
                },
              ));
            },
            icon: const Icon(Icons.settings),
          )
        ],
        leading: _selectedIndex == 0
            ? IconButton(
                onPressed: () {
                  context.read<SearchBarCubit>().changeVisibility();
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
