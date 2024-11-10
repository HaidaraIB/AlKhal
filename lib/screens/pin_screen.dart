import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PinScreen extends StatefulWidget {
  const PinScreen({super.key});

  @override
  State<PinScreen> createState() => _PinScreenState();
}

class _PinScreenState extends State<PinScreen> {
  final TextEditingController _pinController = TextEditingController();
  final String correctPin = "101967";

  @override
  void initState() {
    super.initState();
    _pinController.addListener(_checkPin);
  }

  @override
  void dispose() {
    _pinController.removeListener(_checkPin);
    _pinController.dispose();
    super.dispose();
  }

  void _checkPin() async {
    if (_pinController.text == correctPin) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isActivated', true);
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/sign_up');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Enter Activation PIN'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _pinController,
              decoration: const InputDecoration(labelText: 'PIN'),
              obscureText: true,
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 20),
            Text(
              'Enter the correct PIN to proceed',
              style: TextStyle(color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }
}
