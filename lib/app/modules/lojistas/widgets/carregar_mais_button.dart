import 'package:flutter/material.dart';

class CarregarMaisButton extends StatelessWidget {
  final bool hasMore;
  final VoidCallback onTap;

  const CarregarMaisButton({
    super.key,
    required this.hasMore,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    if (!hasMore) {
      return const Padding(
        padding: EdgeInsets.all(16.0),
        child: Center(
          child: Text('Não há mais lojistas para carregar'),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Center(
        child: ElevatedButton(
          onPressed: onTap,
          child: const Text('Carregar mais'),
        ),
      ),
    );
  }
}
