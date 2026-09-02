// lib/app/modules/clientes/widgets/cliente_card.dart

import 'package:flutter/material.dart';
import '../../../../apparte/widgets/app_text.dart';
import '../../../../apparte/widgets/quigestor_card.dart';
import '../models/cliente.dart';
import '../../../../shared/utils/image_helper.dart';

class ClienteCard extends StatelessWidget {
  final Cliente cliente;
  final VoidCallback onTap;

  const ClienteCard({
    super.key,
    required this.cliente,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final statusColor = _getStatusColor(cliente.status);
    final textColor = isDark ? Colors.white : Colors.black87;
    final subtitleColor = isDark ? Colors.grey[400] : Colors.grey[600];
    final iconColor = isDark ? Colors.grey[400] : Colors.grey[600];

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: QuiGestorCard(
        onTap: onTap,
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Avatar com inicial ou imagem
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                child: cliente.avatar != null && cliente.avatar!.isNotEmpty
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.network(
                          ImageHelper.getFullImageUrl(cliente.avatar),
                          width: 48,
                          height: 48,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Text(
                            cliente.nome.isNotEmpty
                                ? cliente.nome[0].toUpperCase()
                                : '?',
                            style: TextStyle(
                              color: statusColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                            ),
                          ),
                        ),
                      )
                    : Text(
                        cliente.nome.isNotEmpty
                            ? cliente.nome[0].toUpperCase()
                            : '?',
                        style: TextStyle(
                          color: statusColor,
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
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Nome e status
                  Row(
                    children: [
                      Expanded(
                        child: TextH3(
                          cliente.nome,
                          maxLines: 1,
                          fontWeight: FontWeight.w600,
                          color: textColor,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: statusColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: TextBody3(
                          cliente.statusLabel ?? cliente.status,
                          color: statusColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),

                  // Email ou telefone
                  if (cliente.email != null && cliente.email!.isNotEmpty)
                    Row(
                      children: [
                        Icon(Icons.email_outlined, size: 13, color: iconColor),
                        const SizedBox(width: 4),
                        Expanded(
                          child: TextBody3(
                            cliente.email!,
                            color: subtitleColor,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),

                  if (cliente.telefone != null && cliente.telefone!.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Icon(Icons.phone_outlined, size: 13, color: iconColor),
                        const SizedBox(width: 4),
                        TextBody3(
                          cliente.telefone!,
                          color: subtitleColor,
                        ),
                      ],
                    ),
                  ],

                  // Total de pedidos e gasto
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Icon(Icons.shopping_bag_outlined, size: 13, color: iconColor),
                      const SizedBox(width: 4),
                      TextBody3(
                        '${cliente.totalPedidos} pedidos',
                        color: subtitleColor,
                      ),
                      const SizedBox(width: 12),
                      Icon(Icons.attach_money_outlined, size: 13, color: iconColor),
                      const SizedBox(width: 4),
                      TextBody3(
                        'R\$ ${cliente.totalGasto.toStringAsFixed(2)}',
                        color: subtitleColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Setinha
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

  Color _getStatusColor(String status) {
    switch (status) {
      case 'ativo':
        return Colors.green;
      case 'inativo':
        return Colors.grey;
      case 'bloqueado':
        return Colors.red;
      case 'pendente':
        return Colors.orange;
      case 'convidado':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }
}
