import 'package:flutter/material.dart';
import '../models/gestor.dart';
import '../../../../apparte/widgets/app_text.dart';
import '../../../../apparte/widgets/quigestor_card.dart';

class GestorCard extends StatelessWidget {
  final Gestor gestor;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const GestorCard({
    super.key,
    required this.gestor,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: QuiGestorCard(
        onTap: onTap,
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: theme.colorScheme.primaryContainer,
              child: Text(
                gestor.nome.substring(0, 1).toUpperCase(),
                style: TextStyle(
                  color: theme.colorScheme.onPrimaryContainer,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextH3(gestor.nome),
                  const SizedBox(height: 4),
                  TextBody2(gestor.email),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.badge_outlined, size: 14, color: Colors.grey[600]),
                      const SizedBox(width: 4),
                      Expanded(
                        child: TextCaption(
                          gestor.cpf ?? 'CPF não informado',
                          color: Colors.grey[600],
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.phone_outlined, size: 14, color: Colors.grey[600]),
                      const SizedBox(width: 4),
                      Expanded(
                        child: TextCaption(
                          gestor.telefone ?? 'Telefone não informado',
                          color: Colors.grey[600],
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  _buildNivelBadge(context, gestor.nivel),
                ],
              ),
            ),
            Column(
              children: [
                IconButton(
                  icon: const Icon(Icons.edit_outlined),
                  onPressed: onEdit,
                  visualDensity: VisualDensity.compact,
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                  onPressed: onDelete,
                  visualDensity: VisualDensity.compact,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNivelBadge(BuildContext context, String nivel) {
    Color color;
    switch (nivel.toLowerCase()) {
      case 'admin':
        color = Colors.purple;
        break;
      case 'comercial':
        color = Colors.blue;
        break;
      case 'suporte':
        color = Colors.orange;
        break;
      default:
        color = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: TextCaption(
        nivel.toUpperCase(),
        color: color,
        fontWeight: FontWeight.bold,
      ),
    );
  }
}
