import 'package:flutter/material.dart';

import '../components/top_navigation.dart';

class HistoryPage extends StatelessWidget {
  const HistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage("assets/images/background.png"),
          fit: BoxFit.cover,
        ),
      ),
      child: const Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: Column(
            children: [
              TopNavigation(),
              Expanded(child: Center(child: Text("History Page"))),
            ],
          ),
        ),
      ),
    );
  }
}
