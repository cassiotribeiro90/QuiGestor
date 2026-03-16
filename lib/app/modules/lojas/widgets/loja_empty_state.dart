// lojas/widgets/loja_empty_state.dart
import 'package:flutter/material.dart';

import '../../../../apparte/widgets/app_text.dart';

class LojaEmptyState extends StatelessWidget {
  final bool isListEmpty;
  final VoidCallback onCreatePressed;

  const LojaEmptyState({
    super.key,
    required this.isListEmpty,
    required this.onCreatePressed,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.storefront_outlined,
            size: 100,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          TextBody1(
            'Nenhuma loja encontrada',
          ),
          const SizedBox(height: 8),
          TextBody2(
            isListEmpty
                ? 'Comece criando uma loja'
                : 'Tente outros filtros de busca',
          ),
          if (isListEmpty) ...[
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: onCreatePressed,
              icon: const Icon(Icons.add),
              label: const TextH2('Criar Loja'),
            ),
          ],
        ],
      ),
    );
  }
}