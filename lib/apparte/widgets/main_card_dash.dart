import 'package:flutter/material.dart';
import 'quigestor_card.dart';
import 'app_text.dart';

class MainCardDash extends StatelessWidget {
  final String titulo;
  final String valor;
  final IconData icone;
  final Color cor;
  final String? subtitulo;

  const MainCardDash({
    super.key,
    required this.titulo,
    required this.valor,
    required this.icone,
    required this.cor,
    this.subtitulo,
  });

  @override
  Widget build(BuildContext context) {
    return QuiGestorCard(
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 8, // Reduzido de 16 para 8 para diminuir a altura
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center, // Centraliza verticalmente dentro do card
        crossAxisAlignment: CrossAxisAlignment.center, // Centraliza horizontalmente
        mainAxisSize: MainAxisSize.min, // Faz a coluna ocupar apenas o espaço necessário
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center, // Centraliza ícone e título na linha
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: cor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icone, color: cor, size: 22),
              ),
              const SizedBox(width: 8),
              Flexible(
                child: TextBody2(
                  titulo,
                  color: Colors.grey[600],
                  maxLines: 1,
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: TextH2(
              valor,
              color: Theme.of(context).textTheme.bodyLarge?.color,
              textAlign: TextAlign.center,
            ),
          ),
          if (subtitulo != null) ...[
            const SizedBox(height: 2),
            TextCaption(
              subtitulo!,
              color: Colors.grey[600],
              maxLines: 1,
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }
}
