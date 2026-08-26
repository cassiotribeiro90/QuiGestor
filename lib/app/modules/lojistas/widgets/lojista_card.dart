import 'package:flutter/material.dart';
import '../models/lojista_model.dart';
import '../../../core/constants/icon_constants.dart';

class LojistaCard extends StatelessWidget {
  final LojistaModel lojista;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const LojistaCard({
    super.key,
    required this.lojista,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final statusColor = lojista.status == 1 ? Colors.green : Colors.red;
    final statusText = lojista.status == 1 ? 'Ativo' : 'Inativo';

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: _getFuncaoColor(lojista.funcao),
          child: Text(lojista.nome.isNotEmpty ? lojista.nome[0].toUpperCase() : '?'),
        ),
        title: SelectionArea(child: Text(lojista.nome)),
        subtitle: SelectionArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(lojista.email),
              const SizedBox(height: 4),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: _getFuncaoColor(lojista.funcao).withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      _getFuncaoLabel(lojista.funcao),
                      style: TextStyle(
                        fontSize: 12,
                        color: _getFuncaoColor(lojista.funcao),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      statusText,
                      style: TextStyle(
                        fontSize: 12,
                        color: statusColor,
                      ),
                    ),
                  ),
                ],
              ),
              if (lojista.lojas != null && lojista.lojas!.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 4.0),
                  child: Text(
                    'Lojas: ${lojista.lojas!.map((l) => l.nome).join(', ')}',
                    style: const TextStyle(fontSize: 12),
                  ),
                ),
            ],
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(AppIcons.edit, color: Colors.blue),
              onPressed: onEdit,
              tooltip: 'Editar',
            ),
            IconButton(
              icon: const Icon(AppIcons.delete, color: Colors.red),
              onPressed: onDelete,
              tooltip: 'Excluir',
            ),
          ],
        ),
        isThreeLine: true,
      ),
    );
  }

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
}
