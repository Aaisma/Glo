import 'package:flutter/material.dart';

class AppBackground extends StatelessWidget {
  final Widget child;
  final bool useSafeArea;
  final EdgeInsetsGeometry padding;
  final PreferredSizeWidget? appBar;

  const AppBackground({
    super.key,
    required this.child,
    this.useSafeArea = true,
    this.padding = EdgeInsets.zero,
    this.appBar,
  });

  @override
  Widget build(BuildContext context) {
    Widget content = Padding(
      padding: padding,
      child: child,
    );

    if (useSafeArea) {
      content = SafeArea(child: content);
    }

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: appBar,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/images/background.png"),
            fit: BoxFit.cover,
          ),
        ),
        child: content,
      ),
    );
  }
}
