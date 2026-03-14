import 'package:flutter/material.dart';
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

  @override
  Widget build(BuildContext context) {
    final statusColor = _getStatusColor();

    return Padding(
      // 🔥 Padding externo reduzido: 12px em vez de 16px
      padding: const EdgeInsets.only(bottom: 12),
      child: QuiGestorCard(
        onTap: onTap,
        // 🔥 Padding interno do card reduzido: 12px em vez de 16px
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ========== EMOJI/ÍCONE DA CATEGORIA ==========
            Container(
              width: 48, // 🔥 Reduzido de 56px para 48px
              height: 48,
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10), // 🔥 Reduzido de 12px para 10px
              ),
              child: Center(
                child: AppText(
                  loja.categoriaEmoji, // 🔥 Agora extrai só o emoji!
                  fontSize: 24, // 🔥 Aumentado para destacar o emoji
                ),
              ),
            ),
            
            // 🔥 Espaço reduzido: 12px em vez de 16px
            const SizedBox(width: 12),

            // ========== INFORMAÇÕES DA LOJA ==========
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Linha 1: Nome + Status + Destaque
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Nome da loja
                      Expanded(
                        child: TextH3(
                          loja.nome,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      
                      // Badge de destaque (se for destaque)
                      if (loja.destaque) ...[
                        Container(
                          margin: const EdgeInsets.only(right: 4),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6, // 🔥 Reduzido
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.amber.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const AppText(
                            '⭐',
                            fontSize: 11,
                          ),
                        ),
                      ],
                      
                      // Badge de status (usando o chip separado)
                      LojaStatusChip(status: loja.status),
                    ],
                  ),
                  
                  // 🔥 Espaço reduzido: 4px em vez de 8px
                  const SizedBox(height: 4),

                  // Linha 2: Categoria (sem emoji) + Cidade
                  Row(
                    children: [
                      // Ícone de categoria
                      Icon(
                        Icons.category_outlined,
                        size: 13, // 🔥 Reduzido
                        color: Colors.grey[600],
                      ),
                      const SizedBox(width: 4),
                      
                      // Nome da categoria (sem emoji)
                      Expanded(
                        child: TextBody3(
                          loja.categoriaNome, // 🔥 Novo getter
                          color: Colors.grey[600],
                        ),
                      ),
                      
                      const SizedBox(width: 8),
                      
                      // Ícone de localização
                      Icon(
                        Icons.location_on_outlined,
                        size: 13,
                        color: Colors.grey[600],
                      ),
                      const SizedBox(width: 4),
                      
                      // Cidade/UF
                      TextBody3(
                        '${loja.cidade}/${loja.uf}',
                        color: Colors.grey[600],
                      ),
                    ],
                  ),
                  
                  // 🔥 Espaço reduzido: 2px em vez de 4px
                  const SizedBox(height: 2),

                  // Linha 3: Tempo de entrega + Pedido mínimo
                  Row(
                    children: [
                      // Ícone de tempo
                      Icon(
                        Icons.access_time_outlined,
                        size: 13,
                        color: Colors.grey[600],
                      ),
                      const SizedBox(width: 4),
                      
                      // Tempo de entrega
                      TextBody3(
                        _formatarTempoEntrega(),
                        color: Colors.grey[600],
                      ),
                      
                      const SizedBox(width: 12), // 🔥 Reduzido de 16px para 12px
                      
                      // Ícone de dinheiro
                      Icon(
                        Icons.attach_money_outlined,
                        size: 13,
                        color: Colors.grey[600],
                      ),
                      const SizedBox(width: 4),
                      
                      // Pedido mínimo
                      TextBody3(
                        'R\$ ${loja.pedidoMinimo.toStringAsFixed(2)}',
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            // ========== SETA DE NAVEGAÇÃO ==========
            Padding(
              // 🔥 Ajuste fino na posição da seta
              padding: const EdgeInsets.only(left: 8),
              child: Icon(
                Icons.chevron_right_rounded,
                color: Colors.grey[400],
                size: 20, // 🔥 Reduzido de 24px para 20px
              ),
            ),
          ],
        ),
      ),
    );
  }
}
