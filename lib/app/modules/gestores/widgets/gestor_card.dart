import 'package:flutter/material.dart';
import '../models/gestor.dart';
import '../../../../apparte/widgets/app_text.dart';

class GestorCard extends StatelessWidget {
  final Gestor gestor;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final bool showDivider;
  final bool showNivelBadge;

  const GestorCard({
    super.key,
    required this.gestor,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
    this.showDivider = true,
    this.showNivelBadge = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final nivelColor = _getNivelColor(context, gestor.nivel);
    
    return Column(
      children: [
        if (showDivider)
          const Divider(
            height: 1,
            indent: 0,
          ),
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  // Avatar com cor baseada no NÍVEL (igual à badge)
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: nivelColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: TextH2(
                        gestor.nome.substring(0, 1).toUpperCase(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  
                  // Informações
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: TextH3(
                                gestor.nome,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            if (showNivelBadge) _buildNivelBadge(context, gestor.nivel),
                          ],
                        ),
                        const SizedBox(height: 4),
                        TextBody2(
                          gestor.email,
                        ),
                      ],
                    ),
                  ),
                  
                  // Ações
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(
                          Icons.edit_outlined,
                          color: theme.disabledColor,
                          size: 20,
                        ),
                        onPressed: onEdit,
                        visualDensity: VisualDensity.compact,
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        icon: Icon(
                          Icons.delete_outline,
                          color: theme.colorScheme.error,
                          size: 20,
                        ),
                        onPressed: onDelete,
                        visualDensity: VisualDensity.compact,
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Color _getNivelColor(BuildContext context, String nivel) {
    final theme = Theme.of(context);
    switch (nivel.toLowerCase()) {
      case 'admin':
        return theme.colorScheme.primary;
      case 'comercial':
        return theme.colorScheme.secondary;
      case 'suporte':
        return theme.colorScheme.tertiary;
      default:
        return theme.disabledColor;
    }
  }

  Widget _buildNivelBadge(BuildContext context, String nivel) {
    final color = _getNivelColor(context, nivel);
    String label;
    
    switch (nivel.toLowerCase()) {
      case 'admin':
        label = 'ADM';
        break;
      case 'comercial':
        label = 'COM';
        break;
      case 'suporte':
        label = 'SUP';
        break;
      default:
        label = nivel.length > 3 ? nivel.substring(0, 3).toUpperCase() : nivel.toUpperCase();
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
