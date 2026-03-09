import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import '../../app/theme/app_text_styles.dart';

/// Componente base para todos os textos do app.
/// Permite habilitar seleção de texto automaticamente na Web (Chrome)
/// e desabilitar por padrão no Mobile (Android/iOS).
class AppText extends StatelessWidget {
  final String text;
  final TextStyle? style;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;
  final Color? color;
  final double? fontSize;
  final FontWeight? fontWeight;
  final bool selectable; // Permite habilitar/desabilitar manualmente

  const AppText(
    this.text, {
    super.key,
    this.style,
    this.textAlign,
    this.maxLines,
    this.overflow,
    this.color,
    this.fontSize,
    this.fontWeight,
    this.selectable = true, // true = segue regra da plataforma
  });

  /// Retorna se o texto deve ser selecionável baseado na plataforma
  bool get _isSelectable {
    if (!selectable) return false; // Se selectable=false, nunca é selecionável
    return kIsWeb; // Web = true, Mobile/Desktop = false
  }

  @override
  Widget build(BuildContext context) {
    final baseStyle = (style ?? const TextStyle()).copyWith(
      color: color,
      fontSize: fontSize,
      fontWeight: fontWeight,
      fontFamily: AppTextStyles.fontFamily,
    );

    // Usar SelectableText na Web, Text no mobile
    if (_isSelectable) {
      return SelectableText(
        text,
        style: baseStyle,
        textAlign: textAlign,
        maxLines: maxLines,
      );
    } else {
      return Text(
        text,
        style: baseStyle,
        textAlign: textAlign,
        maxLines: maxLines,
        overflow: overflow,
      );
    }
  }
}

/// Título principal (h1) - Maior destaque
class TextH1 extends StatelessWidget {
  final String text;
  final Color? color;
  final TextAlign? textAlign;
  final int? maxLines;
  final FontWeight? fontWeight;
  final bool selectable;
  final TextOverflow? overflow;

  const TextH1(
    this.text, {
    super.key,
    this.color,
    this.textAlign,
    this.maxLines,
    this.fontWeight,
    this.selectable = true,
    this.overflow = TextOverflow.ellipsis,
  });

  @override
  Widget build(BuildContext context) {
    return AppText(
      text,
      style: AppTextStyles.h1,
      color: color,
      textAlign: textAlign,
      maxLines: maxLines,
      fontWeight: fontWeight,
      selectable: selectable,
      overflow: overflow,
    );
  }
}

/// Título secundário (h2) - Destaque médio
class TextH2 extends StatelessWidget {
  final String text;
  final Color? color;
  final TextAlign? textAlign;
  final int? maxLines;
  final FontWeight? fontWeight;
  final bool selectable;
  final TextOverflow? overflow;

  const TextH2(
    this.text, {
    super.key,
    this.color,
    this.textAlign,
    this.maxLines,
    this.fontWeight,
    this.selectable = true,
    this.overflow = TextOverflow.ellipsis,
  });

  @override
  Widget build(BuildContext context) {
    return AppText(
      text,
      style: AppTextStyles.h2,
      color: color,
      textAlign: textAlign,
      maxLines: maxLines,
      fontWeight: fontWeight,
      selectable: selectable,
      overflow: overflow,
    );
  }
}

/// Título terciário (h3) - Destaque leve
class TextH3 extends StatelessWidget {
  final String text;
  final Color? color;
  final TextAlign? textAlign;
  final int? maxLines;
  final FontWeight? fontWeight;
  final bool selectable;
  final TextOverflow? overflow;

  const TextH3(
    this.text, {
    super.key,
    this.color,
    this.textAlign,
    this.maxLines,
    this.fontWeight,
    this.selectable = true,
    this.overflow = TextOverflow.ellipsis,
  });

  @override
  Widget build(BuildContext context) {
    return AppText(
      text,
      style: AppTextStyles.h3,
      color: color,
      textAlign: textAlign,
      maxLines: maxLines,
      fontWeight: fontWeight,
      selectable: selectable,
      overflow: overflow,
    );
  }
}

/// Corpo de texto principal (body1) - Texto normal
class TextBody1 extends StatelessWidget {
  final String text;
  final Color? color;
  final TextAlign? textAlign;
  final int? maxLines;
  final FontWeight? fontWeight;
  final bool selectable;
  final TextOverflow? overflow;

  const TextBody1(
    this.text, {
    super.key,
    this.color,
    this.textAlign,
    this.maxLines,
    this.fontWeight,
    this.selectable = true,
    this.overflow = TextOverflow.ellipsis,
  });

  @override
  Widget build(BuildContext context) {
    return AppText(
      text,
      style: AppTextStyles.body1,
      color: color,
      textAlign: textAlign,
      maxLines: maxLines,
      fontWeight: fontWeight,
      selectable: selectable,
      overflow: overflow,
    );
  }
}

/// Corpo de texto secundário (body2) - Texto menor
class TextBody2 extends StatelessWidget {
  final String text;
  final Color? color;
  final TextAlign? textAlign;
  final int? maxLines;
  final FontWeight? fontWeight;
  final bool selectable;
  final TextOverflow? overflow;

  const TextBody2(
    this.text, {
    super.key,
    this.color,
    this.textAlign,
    this.maxLines,
    this.fontWeight,
    this.selectable = true,
    this.overflow = TextOverflow.ellipsis,
  });

  @override
  Widget build(BuildContext context) {
    return AppText(
      text,
      style: AppTextStyles.body2,
      color: color,
      textAlign: textAlign,
      maxLines: maxLines,
      fontWeight: fontWeight,
      selectable: selectable,
      overflow: overflow,
    );
  }
}

/// Texto de botão - Estilo específico para botões
/// Nomeado como [AppTextButton] para evitar conflito com o widget [TextButton] do Material.
class AppTextButton extends StatelessWidget {
  final String text;
  final Color? color;
  final TextAlign? textAlign;
  final FontWeight? fontWeight;
  final bool selectable;
  final TextOverflow? overflow;

  const AppTextButton(
    this.text, {
    super.key,
    this.color,
    this.textAlign,
    this.fontWeight,
    this.selectable = false, // Botões geralmente não são selecionáveis por padrão
    this.overflow,
  });

  @override
  Widget build(BuildContext context) {
    return AppText(
      text,
      style: AppTextStyles.button,
      color: color,
      textAlign: textAlign,
      fontWeight: fontWeight,
      selectable: selectable,
      overflow: overflow,
    );
  }
}

/// Texto de legenda (caption) - Texto pequeno para auxiliar
class TextCaption extends StatelessWidget {
  final String text;
  final Color? color;
  final TextAlign? textAlign;
  final int? maxLines;
  final FontWeight? fontWeight;
  final bool selectable;
  final TextOverflow? overflow;

  const TextCaption(
    this.text, {
    super.key,
    this.color,
    this.textAlign,
    this.maxLines,
    this.fontWeight,
    this.selectable = true,
    this.overflow = TextOverflow.ellipsis,
  });

  @override
  Widget build(BuildContext context) {
    return AppText(
      text,
      style: AppTextStyles.caption,
      color: color,
      textAlign: textAlign,
      maxLines: maxLines,
      fontWeight: fontWeight,
      selectable: selectable,
      overflow: overflow,
    );
  }
}
