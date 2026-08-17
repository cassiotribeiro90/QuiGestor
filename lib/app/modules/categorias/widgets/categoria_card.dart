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
    return QuiGestorCard(
      onTap: onTap,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), // Reduzido para 4
      child: Row(
        children: [
          Container(
            width: 32, // Reduzido de 36
            height: 32, // Reduzido de 36
            decoration: BoxDecoration(
              color: categoria.colorValue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(6), 
            ),
            child: Center(
              child: categoria.icone != null && categoria.icone!.isNotEmpty
                  ? Text(
                      categoria.icone!,
                      style: const TextStyle(fontSize: 16), // Reduzido
                      textAlign: TextAlign.center,
                    )
                  : Icon(
                      Icons.category_outlined,
                      color: categoria.colorValue,
                      size: 16, // Reduzido de 18
                    ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  categoria.nome,
                  style: const TextStyle(
                    fontSize: 11, // Fonte menor
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 1),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 4,
                        vertical: 1,
                      ),
                      decoration: BoxDecoration(
                        color: categoria.ativo
                            ? Colors.green.withOpacity(0.1)
                            : Colors.grey.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        categoria.statusLabel,
                        style: TextStyle(
                          color: categoria.ativo ? Colors.green : Colors.grey,
                          fontSize: 7, // Ainda menor
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '#${categoria.ordem}',
                      style: TextStyle(
                        color: Colors.grey[400],
                        fontSize: 7,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
