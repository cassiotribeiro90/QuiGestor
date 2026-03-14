import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../../../../apparte/widgets/quigestor_card.dart';
import '../../../../apparte/widgets/app_text.dart';
import '../../home/views/home_screen.dart';
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
    final statusColor = _getStatusColor();
    final String? logoUrl = (loja.logo != null && loja.logo!.isNotEmpty) 
        ? _ajustarUrl(loja.logo!) 
        : null;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: QuiGestorCard(
        onTap: onTap,
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
                          errorBuilder: (context, error, stackTrace) => AppText(loja.categoriaEmoji, fontSize: 24),
                        ),
                      )
                    : AppText(loja.categoriaEmoji, fontSize: 24),
              ),
            ),
            
            const SizedBox(width: 12),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(child: TextH3(loja.nome, maxLines: 1, fontWeight: FontWeight.w600)),
                      if (loja.destaque) ...[
                        Container(
                          margin: const EdgeInsets.only(right: 4),
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(color: Colors.amber.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                          child: const AppText('⭐', fontSize: 11),
                        ),
                      ],
                      LojaStatusChip(status: loja.status),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.category_outlined, size: 13, color: Colors.grey[600]),
                      const SizedBox(width: 4),
                      Expanded(child: TextBody3(loja.categoriaNome, color: Colors.grey[600])),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Icon(Icons.access_time_outlined, size: 13, color: Colors.grey[600]),
                      const SizedBox(width: 4),
                      TextBody3(_formatarTempoEntrega(), color: Colors.grey[600]),
                      const SizedBox(width: 12),
                      Icon(Icons.attach_money_outlined, size: 13, color: Colors.grey[600]),
                      const SizedBox(width: 4),
                      TextBody3('R\$ ${loja.pedidoMinimo.toStringAsFixed(2)}', color: Colors.grey[600], fontWeight: FontWeight.w500),
                    ],
                  ),
                ],
              ),
            ),
            
            Row(
              children: [
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.restaurant_menu_outlined),
                      onPressed: () {
                        final homeState = context.findAncestorStateOfType<HomeScreenState>();
                        if (homeState != null) {
                          homeState.openProdutosList(lojaId: loja.id, lojaNome: loja.nome);
                        }
                      },
                      color: theme.colorScheme.primary,
                      iconSize: 22,
                    ),
                    if (loja.totalProdutos > 0)
                      Positioned(
                        top: 4,
                        right: 4,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(color: theme.colorScheme.primary, shape: BoxShape.circle),
                          constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                          child: Center(child: Text('${loja.totalProdutos}', style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold))),
                        ),
                      ),
                  ],
                ),
                Icon(Icons.chevron_right_rounded, color: Colors.grey[400], size: 20),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
