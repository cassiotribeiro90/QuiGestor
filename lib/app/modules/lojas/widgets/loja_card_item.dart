// lojas/widgets/loja_card_item.dart
import 'package:flutter/material.dart';
import '../../../../apparte/widgets/quigestor_card.dart';
import '../models/loja.dart';
import 'loja_status_chip.dart';

class LojaCardItem extends StatelessWidget {
  final Loja loja;
  final VoidCallback onTap;

  const LojaCardItem({super.key, required this.loja, required this.onTap});

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
                color: _getStatusColor().withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: loja.logo != null
                    ? ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    loja.logo!,
                    width: 40,
                    height: 40,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Icon(
                      Icons.store,
                      color: _getStatusColor(),
                    ),
                  ),
                )
                    : Text(
                  loja.nome[0].toUpperCase(),
                  style: TextStyle(
                    color: _getStatusColor(),
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
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
                        child: Text(
                          loja.nome,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      if (loja.destaque)
                        Container(
                          margin: const EdgeInsets.only(right: 8),
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.amber.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Text('⭐', style: TextStyle(fontSize: 12)),
                        ),
                      LojaStatusChip(status: loja.status),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.category_outlined, size: 14, color: Colors.grey[600]),
                      const SizedBox(width: 4),
                      Text(loja.categoria, style: TextStyle(color: Colors.grey[600], fontSize: 13)),
                      const SizedBox(width: 12),
                      Icon(Icons.location_on_outlined, size: 14, color: Colors.grey[600]),
                      const SizedBox(width: 4),
                      Text('${loja.cidade}/${loja.uf}', style: TextStyle(color: Colors.grey[600], fontSize: 13)),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Icon(Icons.access_time_outlined, size: 14, color: Colors.grey[600]),
                      const SizedBox(width: 4),
                      Text(_formatarTempoEntrega(), style: TextStyle(color: Colors.grey[600], fontSize: 13)),
                      const SizedBox(width: 12),
                      Icon(Icons.attach_money_outlined, size: 14, color: Colors.grey[600]),
                      const SizedBox(width: 4),
                      Text('R\$ ${loja.pedidoMinimo.toStringAsFixed(2)}',
                          style: TextStyle(color: Colors.grey[600], fontSize: 13)),
                    ],
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded, color: Colors.grey[400]),
          ],
        ),
      ),
    );
  }
}