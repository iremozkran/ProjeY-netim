import 'package:flutter/material.dart';

class CustomContainer extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;
  const CustomContainer(
      {super.key,
      required this.child,
      this.padding = const EdgeInsets.all(32)});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
              color: const Color.fromARGB(47, 199, 199, 199), width: 2),
          color: const Color.fromARGB(59, 228, 228, 228)),
      child: child,
    );
  }
}
