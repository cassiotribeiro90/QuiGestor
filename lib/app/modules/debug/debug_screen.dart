import 'dart:math';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../di/dependencies.dart';
import '../../../shared/services/token_service.dart';

class DebugScreen extends StatelessWidget {
  const DebugScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final tokenService = getIt<TokenService>();
    
    return Scaffold(
      appBar: AppBar(title: const Text('Debug - Token')),
      body: FutureBuilder<SharedPreferences>(
        future: SharedPreferences.getInstance(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          
          final prefs = snapshot.data!;
          final token = prefs.getString('access_token');
          
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Status do Token', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      const Divider(),
                      _buildInfoRow('Token existe', token != null ? 'SIM' : 'NÃO'),
                      if (token != null) ...[
                        _buildInfoRow('Tamanho', '${token.length} caracteres'),
                        _buildInfoRow('Começa com', token.substring(0, min<int>(20, token.length))),
                        _buildInfoRow('Header', 'Bearer $token'),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () async {
                  await tokenService.clearToken();
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Token limpo!')),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                child: const Text('LIMPAR TOKEN', style: TextStyle(color: Colors.white)),
              ),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: () async {
                  final token = tokenService.getToken();
                  if (context.mounted) {
                    if (token != null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Token: $token')),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Token não encontrado!')),
                      );
                    }
                  }
                },
                child: const Text('VER TOKEN'),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 100, child: Text('$label:', style: const TextStyle(fontWeight: FontWeight.bold))),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}
