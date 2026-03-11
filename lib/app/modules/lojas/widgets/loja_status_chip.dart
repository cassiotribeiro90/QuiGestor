// lojas/widgets/loja_status_chip.dart
import 'package:flutter/material.dart';

class LojaStatusChip extends StatelessWidget {
  final String status;

  const LojaStatusChip({super.key, required this.status});

  Color _getStatusColor() {
    switch (status) {
      case 'ativo': return Colors.green;
      case 'inativo': return Colors.grey;
      case 'fechado': return Colors.red;
      case 'revisao': return Colors.orange;
      default: return Colors.grey;
    }
  }

  String _getStatusLabel() {
    switch (status) {
      case 'ativo': return 'Ativo';
      case 'inativo': return 'Inativo';
      case 'fechado': return 'Fechado';
      case 'revisao': return 'Revisão';
      default: return status;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: _getStatusColor().withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        _getStatusLabel(),
        style: TextStyle(
          color: _getStatusColor(),
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}