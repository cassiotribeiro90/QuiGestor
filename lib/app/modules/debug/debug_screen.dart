import 'dart:math';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../shared/services/token_service.dart';

class DebugScreen extends StatelessWidget {
  const DebugScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // 🔥 Usando o Singleton manual TokenService() em vez de getIt
    final tokenService = TokenService();
    
    return Scaffold(
      appBar: AppBar(title: const Text('Debug - Token')),
      body: FutureBuilder<SharedPreferences>(
        future: SharedPreferences.getInstance(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          
          final prefs = snapshot.data!;
          final token = tokenService.getAccessToken();
          final refreshToken = tokenService.getRefreshToken();
          
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
                      _buildInfoRow('Access Token', token != null ? 'SIM' : 'NÃO'),
                      if (token != null) ...[
                        _buildInfoRow('Tamanho', '${token.length} caracteres'),
                        _buildInfoRow('Começa com', token.substring(0, min<int>(20, token.length))),
                        _buildInfoRow('Header', 'Bearer $token'),
                      ],
                      const SizedBox(height: 16),
                      _buildInfoRow('Refresh Token', refreshToken != null ? 'SIM' : 'NÃO'),
                      if (refreshToken != null) ...[
                        _buildInfoRow('Tamanho', '${refreshToken.length} caracteres'),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () async {
                  await tokenService.clearTokens();
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Tokens limpos!')),
                    );
                    Navigator.of(context).pop();
                  }
                },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                child: const Text('LIMPAR TOKENS', style: TextStyle(color: Colors.white)),
              ),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: () {
                  if (context.mounted) {
                    if (token != null) {
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Access Token Completo'),
                          content: SelectableText(token),
                          actions: [
                            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Fechar'))
                          ],
                        ),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Token não encontrado!')),
                      );
                    }
                  }
                },
                child: const Text('VER ACCESS TOKEN COMPLETO'),
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
          SizedBox(width: 120, child: Text('$label:', style: const TextStyle(fontWeight: FontWeight.bold))),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}
