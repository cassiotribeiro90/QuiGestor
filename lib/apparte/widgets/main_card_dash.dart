import 'package:flutter/material.dart';
import 'quigestor_card.dart';
import 'app_text.dart';

class MainCardDash extends StatelessWidget {
  final String titulo;
  final String valor;
  final IconData icone;
  final Color cor;
  final String? subtitulo;
  final bool selectable; // NOVO

  const MainCardDash({
    super.key,
    required this.titulo,
    required this.valor,
    required this.icone,
    required this.cor,
    this.subtitulo,
    this.selectable = true, // NOVO - padrão segue regra da plataforma
  });

  @override
  Widget build(BuildContext context) {
    return QuiGestorCard(
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 16,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Ícone centralizado no topo
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: cor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icone, color: cor, size: 24),
          ),
          const SizedBox(height: 8),
          
          // Título agora abaixo do ícone
          TextBody1(
            titulo,
            color: Colors.grey[600],
            maxLines: 1,
            textAlign: TextAlign.center,
            selectable: selectable,
          ),
          
          const SizedBox(height: 12),
          
          // Valor principal
          FittedBox(
            fit: BoxFit.scaleDown,
            child: TextH2(
              valor,
              color: Theme.of(context).textTheme.bodyLarge?.color,
              textAlign: TextAlign.center,
              selectable: selectable,
            ),
          ),
          
          if (subtitulo != null) ...[
            const SizedBox(height: 4),
            TextCaption(
              subtitulo!,
              color: Colors.grey[600],
              maxLines: 1,
              textAlign: TextAlign.center,
              selectable: selectable,
            ),
          ],
        ],
      ),
    );
  }
}
