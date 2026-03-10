import 'package:flutter/material.dart';
import '../models/gestor.dart';
import '../../../../apparte/widgets/app_text.dart';

class GestorDetailScreen extends StatelessWidget {
  final Gestor gestor;
  final VoidCallback? onEdit; // ← NOVO callback

  const GestorDetailScreen({super.key, required this.gestor, this.onEdit});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalhes do Gestor'),
        actions: [
          if (onEdit != null)
            IconButton(
              icon: const Icon(Icons.edit_outlined),
              onPressed: onEdit,
              tooltip: 'Editar Gestor',
            ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Center(
            child: CircleAvatar(
              radius: 50,
              child: Icon(Icons.person, size: 50),
            ),
          ),
          const SizedBox(height: 24),
          _buildInfoSection(
            'Informações de Contato',
            [
              _buildInfoRow(Icons.email_outlined, 'E-mail', gestor.email),
              if (gestor.cpf != null && gestor.cpf!.isNotEmpty)
                _buildInfoRow(Icons.badge_outlined, 'CPF', gestor.cpf!),
              if (gestor.telefone != null && gestor.telefone!.isNotEmpty)
                _buildInfoRow(Icons.phone_outlined, 'Telefone', gestor.telefone!),
            ],
          ),
          const SizedBox(height: 24),
          _buildInfoSection(
            'Informações do Sistema',
            [
              if (gestor.criadoEm != null)
                _buildInfoRow(
                  Icons.calendar_today_outlined,
                  'Criado em',
                  _formatDate(gestor.criadoEm!),
                ),
              _buildInfoRow(
                Icons.admin_panel_settings_outlined,
                'Nível',
                _getNivelLabel(gestor.nivel),
              ),
              _buildInfoRow(
                Icons.circle,
                'Status',
                gestor.statusLabel ?? (gestor.status == 1 ? 'Ativo' : 'Inativo'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextH3(title),
        const SizedBox(height: 12),
        ...children,
      ],
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey[600]),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextCaption(label),
              TextBody1(value, fontWeight: FontWeight.bold),
            ],
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return "${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}";
  }

  String _getNivelLabel(String nivel) {
    switch (nivel.toLowerCase()) {
      case 'admin': return 'Administrador';
      case 'comercial': return 'Comercial';
      case 'suporte': return 'Suporte';
      default: return nivel;
    }
  }
}
