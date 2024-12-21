import 'package:flutter/material.dart';

class CustomAppBar extends StatelessWidget {
  final String title;
  final bool isBackButton;
  final void Function()? onBackButtonPressed;

  CustomAppBar({
    required this.title,
    required this.isBackButton,
    required this.onBackButtonPressed,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: const Text('Add Post', style: TextStyle(color: Colors.white)),
      backgroundColor: Theme.of(context).colorScheme.primary,
      leading: isBackButton
          ? IconButton(
              icon: Icon(Icons.arrow_back),
              onPressed: onBackButtonPressed,
            )
          : null,
    );
  }
}
