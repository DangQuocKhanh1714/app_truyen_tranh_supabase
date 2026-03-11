import 'package:flutter/material.dart';
import '../../core/constants.dart';

class WebLayoutWrapper extends StatelessWidget {
  final Widget child;
  const WebLayoutWrapper({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: AppConstants.maxContentWidth),
        child: child,
      ),
    );
  }
}