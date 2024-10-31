import 'package:flutter/material.dart';

class ExpandableFAB extends StatefulWidget {
  const ExpandableFAB({super.key, required this.fabs, required this.body});

  final List<Widget> fabs;
  final Widget body;

  @override
  State<ExpandableFAB> createState() => _ExpandableFABState();
}

class _ExpandableFABState extends State<ExpandableFAB> {
  bool isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        heroTag: "ExpandableFAB",
        onPressed: () {
          setState(() {
            isExpanded = !isExpanded;
          });
        },
        child: const Icon(Icons.add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      body: Stack(
        children: [
          widget.body,
          AnimatedOpacity(
            opacity: isExpanded ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 250),
            child: Stack(
              children: [
                widget.fabs[0],
                widget.fabs[1],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
