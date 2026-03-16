import 'dart:math';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../apparte/widgets/app_text.dart';
import '../../../../apparte/widgets/qui_button.dart';
import '../../../shared/services/token_service.dart';

class DebugScreen extends StatelessWidget {
  const DebugScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // 🔥 Usando o Singleton manual TokenService() em vez de getIt
    final tokenService = TokenService();
    
    return Scaffold(
      appBar: AppBar(title: const TextH2('Debug - Token', fontWeight: FontWeight.bold)),
      body: FutureBuilder<SharedPreferences>(
        future: SharedPreferences.getInstance(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          
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
                      const TextH3('Status do Token', fontWeight: FontWeight.bold),
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
              QuiButton(
                label: 'LIMPAR TOKENS',
                backgroundColor: Colors.red,
                onPressed: () async {
                  await tokenService.clearTokens();
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: TextBody2('Tokens limpos!', color: Colors.white)),
                    );
                    Navigator.of(context).pop();
                  }
                },
              ),
              const SizedBox(height: 8),
              QuiButton(
                label: 'VER ACCESS TOKEN COMPLETO',
                onPressed: () {
                  if (context.mounted) {
                    if (token != null) {
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const TextH3('Access Token Completo', fontWeight: FontWeight.bold),
                          content: SelectableText(token),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context), 
                              child: const TextBody2('Fechar')
                            )
                          ],
                        ),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: TextBody2('Token não encontrado!', color: Colors.white)),
                      );
                    }
                  }
                },
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
          SizedBox(width: 120, child: TextBody2('$label:', fontWeight: FontWeight.bold)),
          Expanded(child: TextBody2(value)),
        ],
      ),
    );
  }
}
