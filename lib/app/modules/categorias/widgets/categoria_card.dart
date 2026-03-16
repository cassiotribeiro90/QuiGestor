import 'package:flutter/material.dart';
import '../../../../apparte/widgets/app_text.dart';
import '../../../../apparte/widgets/quigestor_card.dart';
import '../models/categoria.dart';

class CategoriaCard extends StatelessWidget {
  final Categoria categoria;
  final VoidCallback onTap;

  const CategoriaCard({
    super.key,
    required this.categoria,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: QuiGestorCard(
        onTap: onTap,
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: categoria.colorValue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: categoria.icone != null && categoria.icone!.isNotEmpty
                    ? TextH2(
                        categoria.icone!,
                        textAlign: TextAlign.center,
                      )
                    : Icon(
                        Icons.category_outlined,
                        color: categoria.colorValue,
                        size: 28,
                      ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: TextBody1(
                          categoria.nome,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (categoria.destaque)
                        Container(
                          margin: const EdgeInsets.only(right: 8),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.amber.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const TextBody3('⭐'),
                        ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: categoria.ativo
                              ? Colors.green.withOpacity(0.1)
                              : Colors.grey.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: TextBody3(
                          categoria.statusLabel,
                          color: categoria.ativo ? Colors.green : Colors.grey,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  if (categoria.descricao != null && categoria.descricao!.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    TextBody3(
                      categoria.descricao!,
                      maxLines: 1,
                      color: Colors.grey[600],
                    ),
                  ],
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.sort,
                        size: 14,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(width: 4),
                      TextBody3(
                        'Ordem: ${categoria.ordem}',
                        color: Colors.grey[400],
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              color: Colors.grey[400],
            ),
          ],
        ),
      ),
    );
  }
}
