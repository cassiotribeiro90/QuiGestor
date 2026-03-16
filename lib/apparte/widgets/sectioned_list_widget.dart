import 'package:flutter/material.dart';
import 'app_text.dart';

class SectionedListWidget extends StatelessWidget {
  final String title;
  final List<Widget> children;
  final Widget? trailing;

  const SectionedListWidget({
    super.key,
    required this.title,
    required this.children,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextH3(title, fontWeight: FontWeight.bold),
              if (trailing != null) trailing!,
            ],
          ),
        ),
        ...children,
      ],
    );
  }
}
