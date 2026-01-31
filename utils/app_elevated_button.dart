import 'package:flutter/material.dart';

class AppElevatedButton extends StatelessWidget {
  final VoidCallback onPressed;
  final IconData? icon;
  final String title;
  const AppElevatedButton({
    super.key,
    required this.onPressed,
    this.icon,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.indigo[600],
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          icon == null
              ? SizedBox()
              : Padding(
                  padding: const EdgeInsets.only(right: 6.0),
                  child: Icon(icon!),
                ),
          Text(title, style: TextStyle(fontSize: 16)),
        ],
      ),
    );
  }
}
