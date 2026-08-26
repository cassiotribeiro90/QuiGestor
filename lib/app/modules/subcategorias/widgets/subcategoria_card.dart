import 'package:flutter/material.dart';
import '../../../../apparte/widgets/app_text.dart';
import '../../../../apparte/widgets/quigestor_card.dart';
import '../models/subcategoria.dart';

class SubcategoriaCard extends StatelessWidget {
  final Subcategoria subcategoria;
  final VoidCallback onTap;

  const SubcategoriaCard({
    super.key,
    required this.subcategoria,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Cores adaptativas para dark/light
    final textColor = isDark ? Colors.white : Colors.black87;
    final subtitleColor = isDark ? Colors.grey[400] : Colors.grey[700];
    final iconColor = isDark ? Colors.grey[400] : Colors.grey[700];
    final primaryColor = theme.colorScheme.primary;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: QuiGestorCard(
        onTap: onTap,
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Ícone da subcategoria
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                child: (subcategoria.categoriaEmoji != null &&
                    subcategoria.categoriaEmoji!.isNotEmpty)
                    ? Text(
                  subcategoria.categoriaEmoji!,
                  style: const TextStyle(fontSize: 24),
                  textAlign: TextAlign.center,
                )
                    : Icon(
                  Icons.subdirectory_arrow_right,
                  color: primaryColor,
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
                  // Nome
                  TextH3(
                    subcategoria.nome,
                    maxLines: 2,
                    fontWeight: FontWeight.w600,
                    color: textColor,
                  ),
                  const SizedBox(height: 4),

                  // Categoria pai
                  if (subcategoria.categoriaNome != null &&
                      subcategoria.categoriaNome!.isNotEmpty)
                    Row(
                      children: [
                        Icon(
                          Icons.category_outlined,
                          size: 13,
                          color: iconColor,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: TextBody3(
                            subcategoria.categoriaNome!,
                            color: subtitleColor,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),

            // Ícone de ação - apenas a setinha
            Icon(
              Icons.chevron_right_rounded,
              color: isDark ? Colors.grey[500] : Colors.grey[400],
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}