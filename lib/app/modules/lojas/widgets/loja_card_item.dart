import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../apparte/widgets/quigestor_card.dart';
import '../../../../apparte/widgets/app_text.dart';
import '../models/loja.dart';
import 'loja_status_chip.dart';

class LojaCardItem extends StatelessWidget {
  final Loja loja;
  final VoidCallback onTap;

  const LojaCardItem({
    super.key,
    required this.loja,
    required this.onTap,
  });

  String _formatarTempoEntrega() {
    if (loja.tempoEntregaMin == loja.tempoEntregaMax) {
      return '${loja.tempoEntregaMin} min';
    }
    return '${loja.tempoEntregaMin}-${loja.tempoEntregaMax} min';
  }

  Color _getStatusColor() {
    switch (loja.status) {
      case 'ativo': return Colors.green;
      case 'inativo': return Colors.grey;
      case 'fechado': return Colors.red;
      case 'revisao': return Colors.orange;
      default: return Colors.grey;
    }
  }

  String _ajustarUrl(String url) {
    if (url.isEmpty) return url;
    if (!url.contains('localhost') && !url.contains('10.0.2.2')) return url;
    final bool isAndroid = !kIsWeb && defaultTargetPlatform == TargetPlatform.android;
    if (isAndroid) {
      return url.replaceAll('localhost', '10.0.2.2');
    } else {
      return url.replaceAll('10.0.2.2', 'localhost');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final statusColor = _getStatusColor();
    final String? logoUrl = (loja.logo != null && loja.logo!.isNotEmpty)
        ? _ajustarUrl(loja.logo!)
        : null;

    // Cores adaptativas para dark/light
    final textColor = isDark ? Colors.white : Colors.black87;
    final subtitleColor = isDark ? Colors.grey[400] : Colors.grey[700];
    final iconColor = isDark ? Colors.grey[400] : Colors.grey[700];
    final chevronColor = isDark ? Colors.grey[500] : Colors.grey[400];

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: QuiGestorCard(
        onTap: onTap,
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Avatar com logo ou emoji
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                child: logoUrl != null
                    ? ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    logoUrl,
                    width: 48,
                    height: 48,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => TextH3(
                      loja.categoriaEmoji,
                      textAlign: TextAlign.center,
                      color: textColor,
                    ),
                  ),
                )
                    : TextH3(
                  loja.categoriaEmoji,
                  textAlign: TextAlign.center,
                  color: textColor,
                ),
              ),
            ),

            const SizedBox(width: 12),

            // Conteúdo principal
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Nome, destaque e status
                  Row(
                    children: [
                      Expanded(
                        child: TextH3(
                          loja.nome,
                          maxLines: 1,
                          fontWeight: FontWeight.w600,
                          color: textColor,
                        ),
                      ),
                      if (loja.destaque) ...[
                        Container(
                          margin: const EdgeInsets.only(right: 4),
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.amber.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: TextBody3(
                            '⭐',
                            color: isDark ? Colors.amber[300] : Colors.amber[700],
                          ),
                        ),
                      ],
                      LojaStatusChip(status: loja.status),
                    ],
                  ),
                  const SizedBox(height: 4),

                  // Categoria
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
                          loja.categoriaNome,
                          color: subtitleColor,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),

                  // Tempo de entrega e pedido mínimo
                  Row(
                    children: [
                      Icon(
                        Icons.access_time_outlined,
                        size: 13,
                        color: iconColor,
                      ),
                      const SizedBox(width: 4),
                      TextBody3(
                        _formatarTempoEntrega(),
                        color: subtitleColor,
                      ),
                      const SizedBox(width: 12),
                      Icon(
                        Icons.attach_money_outlined,
                        size: 13,
                        color: iconColor,
                      ),
                      const SizedBox(width: 4),
                      TextBody3(
                        'R\$ ${loja.pedidoMinimo.toStringAsFixed(2)}',
                        color: subtitleColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Ações - botão de produtos e setinha
            Row(
              children: [
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    IconButton(
                      icon: Icon(
                        Icons.restaurant_menu_outlined,
                        color: theme.colorScheme.primary,
                      ),
                      onPressed: () {
                        // Navegar para a tela de produtos da loja
                        context.push('/lojas/${loja.id}/produtos');
                      },
                      iconSize: 22,
                    ),
                    if (loja.totalProdutos > 0)
                      Positioned(
                        top: 4,
                        right: 4,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primary,
                            shape: BoxShape.circle,
                          ),
                          constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                          child: Center(
                            child: TextBody3(
                              '${loja.totalProdutos}',
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 10,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
                Icon(
                  Icons.chevron_right_rounded,
                  color: chevronColor,
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