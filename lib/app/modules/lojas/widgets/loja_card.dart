import 'package:flutter/material.dart';
import '../models/loja.dart';
import '../../../../apparte/widgets/app_text.dart';

class LojaCard extends StatelessWidget {
  final Loja loja;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final bool showDivider;

  const LojaCard({
    super.key,
    required this.loja,
    required this.onTap,
    required this.onEdit,
    this.showDivider = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Column(
      children: [
        if (showDivider)
          const Divider(
            height: 1,
            indent: 0,
          ),
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  // Logo da Loja
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: loja.statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      image: loja.logo != null 
                        ? DecorationImage(
                            image: NetworkImage(loja.logo!),
                            fit: BoxFit.cover,
                          )
                        : null,
                    ),
                    child: loja.logo == null 
                      ? Center(
                          child: TextH2(
                            loja.nome.substring(0, 1).toUpperCase(),
                            color: loja.statusColor,
                          ),
                        )
                      : null,
                  ),
                  const SizedBox(width: 12),
                  
                  // Informações
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: TextH2(
                                loja.nome,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            _buildStatusBadge(loja),
                          ],
                        ),
                        const SizedBox(height: 4),
                        TextBody2(
                          '${loja.categoria} • ${loja.cidade}/${loja.uf}',
                        ),
                        if (loja.verificado)
                          Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Row(
                              children: [
                                const Icon(Icons.verified, size: 14, color: Colors.blue),
                                const SizedBox(width: 4),
                                TextCaption('Verificada', color: Colors.blue[700]),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                  
                  // Ações
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        margin: const EdgeInsets.only(right: 8),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.edit_outlined, size: 20),
                          color: theme.colorScheme.primary,
                          onPressed: onEdit,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatusBadge(Loja loja) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: loja.statusColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        loja.statusLabel.toUpperCase(),
        style: TextStyle(
          color: loja.statusColor,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
