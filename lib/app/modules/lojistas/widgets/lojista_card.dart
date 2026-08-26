import 'package:flutter/material.dart';
import '../../../../apparte/widgets/app_text.dart';
import '../../../../apparte/widgets/quigestor_card.dart';
import '../models/lojista_model.dart';

class LojistaCard extends StatelessWidget {
  final LojistaModel lojista;
  final VoidCallback onTap;
  final VoidCallback? onDelete;

  const LojistaCard({
    super.key,
    required this.lojista,
    required this.onTap,
    this.onDelete,
  });

  Color _getFuncaoColor(String funcao) {
    switch (funcao) {
      case 'proprietario':
        return Colors.purple;
      case 'gerente':
        return Colors.blue;
      case 'vendedor':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  String _getFuncaoLabel(String funcao) {
    switch (funcao) {
      case 'proprietario':
        return 'Proprietário';
      case 'gerente':
        return 'Gerente';
      case 'vendedor':
        return 'Vendedor';
      default:
        return funcao;
    }
  }

  IconData _getFuncaoIcon(String funcao) {
    switch (funcao) {
      case 'proprietario':
        return Icons.business_center_outlined;
      case 'gerente':
        return Icons.people_outline;
      case 'vendedor':
        return Icons.person_outline;
      default:
        return Icons.person_outline;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final statusColor = lojista.status == 1 ? Colors.green : Colors.red;
    final statusText = lojista.status == 1 ? 'Ativo' : 'Inativo';
    final funcaoColor = _getFuncaoColor(lojista.funcao);

    // Cores adaptativas para dark/light
    final textColor = isDark ? Colors.white : Colors.black87;
    final subtitleColor = isDark ? Colors.grey[400] : Colors.grey[700];
    final iconColor = isDark ? Colors.grey[400] : Colors.grey[700];

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: QuiGestorCard(
        onTap: onTap,
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center, // Centraliza verticalmente
          children: [
            // Avatar com inicial
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: funcaoColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                child: Text(
                  lojista.nome.isNotEmpty ? lojista.nome[0].toUpperCase() : '?',
                  style: TextStyle(
                    color: funcaoColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
              ),
            ),

            const SizedBox(width: 12),

            // Conteúdo principal
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min, // Para não expandir verticalmente
                children: [
                  // Nome e status
                  Row(
                    children: [
                      Expanded(
                        child: TextH3(
                          lojista.nome,
                          maxLines: 1,
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

                  // Email
                  Row(
                    children: [
                      Icon(Icons.email_outlined, size: 13, color: iconColor),
                      const SizedBox(width: 4),
                      Expanded(
                        child: TextBody3(
                          lojista.email,
                          color: subtitleColor,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),

                  // Função
                  Row(
                    children: [
                      Icon(_getFuncaoIcon(lojista.funcao), size: 13, color: iconColor),
                      const SizedBox(width: 4),
                      TextBody3(
                        _getFuncaoLabel(lojista.funcao),
                        color: subtitleColor,
                      ),
                    ],
                  ),

                  // Lojas (se houver)
                  if (lojista.lojas != null && lojista.lojas!.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Icon(Icons.storefront_outlined, size: 13, color: iconColor),
                        const SizedBox(width: 4),
                        Expanded(
                          child: TextBody3(
                            '${lojista.lojas!.length} ${lojista.lojas!.length == 1 ? 'loja' : 'lojas'}: ${lojista.lojas!.map((l) => l.nome).join(' • ')}',
                            color: subtitleColor,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
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