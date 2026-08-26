import 'package:flutter/material.dart';
import '../../../../apparte/widgets/app_text.dart';
import '../../../../apparte/widgets/quigestor_card.dart';
import '../models/categoria.dart';

class CategoriaCard extends StatelessWidget {
  final Categoria categoria;
  final VoidCallback onTap;
  final VoidCallback? onDelete;

  const CategoriaCard({
    super.key,
    required this.categoria,
    required this.onTap,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Cores adaptativas para dark/light
    final textColor = isDark ? Colors.white : Colors.black87;
    final subtitleColor = isDark ? Colors.grey[400] : Colors.grey[700];
    final iconColor = isDark ? Colors.grey[400] : Colors.grey[700];
    final statusColor = categoria.ativo ? Colors.green : Colors.red;
    final statusText = categoria.ativo ? 'Ativo' : 'Inativo';

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: QuiGestorCard(
        onTap: onTap,
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Ícone da categoria
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: categoria.colorValue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                child: categoria.icone != null && categoria.icone!.isNotEmpty
                    ? Text(
                  categoria.icone!,
                  style: const TextStyle(fontSize: 24),
                  textAlign: TextAlign.center,
                )
                    : Icon(
                  Icons.category_outlined,
                  color: categoria.colorValue,
                  size: 24,
                ),
              ),
            ),

            const SizedBox(width: 12),

            // Conteúdo principal
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Nome e status
                  Row(
                    children: [
                      Expanded(
                        child: TextH3(
                          categoria.nome,
                          maxLines: 2,
                          fontWeight: FontWeight.w600,
                          color: textColor,
                        ),
                      ),
                      // Chip de status
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: statusColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: TextBody3(
                          statusText,
                          color: statusColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),

                  // Ordem
                  Row(
                    children: [
                      Icon(Icons.format_list_numbered_outlined, size: 13, color: iconColor),
                      const SizedBox(width: 4),
                      TextBody3(
                        'Ordem: ${categoria.ordem}',
                        color: subtitleColor,
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Ícones de ação com alinhamento centralizado
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (onDelete != null)
                  IconButton(
                    icon: Icon(
                      Icons.delete_outline,
                      color: isDark ? Colors.grey[400] : Colors.grey[400],
                      size: 20,
                    ),
                    onPressed: onDelete,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                Icon(
                  Icons.chevron_right_rounded,
                  color: isDark ? Colors.grey[500] : Colors.grey[400],
                  size: 20,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}