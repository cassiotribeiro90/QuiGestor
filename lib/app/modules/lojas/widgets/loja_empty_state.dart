// lojas/widgets/loja_empty_state.dart
import 'package:flutter/material.dart';

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
          Text(
            'Nenhuma loja encontrada',
            style: theme.textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(
            isListEmpty
                ? 'Comece criando uma loja'
                : 'Tente outros filtros de busca',
            style: TextStyle(color: Colors.grey[600]),
          ),
          if (isListEmpty) ...[
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: onCreatePressed,
              icon: const Icon(Icons.add),
              label: const Text('Criar Loja'),
            ),
          ],
        ],
      ),
    );
  }
}