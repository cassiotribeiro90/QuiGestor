import 'package:flutter/material.dart';
import '../../app/theme/app_text_styles.dart';

/// Componente base para todos os textos do app.
/// Não herda diretamente de [Text] porque [Text] não permite herança de forma simples 
/// para sobrescrever parâmetros (quase todos os campos são finais e privados).
/// Em vez disso, compomos o [Text] dentro deste widget.
class AppText extends StatelessWidget {
  final String text;
  final TextStyle? style;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;
  final Color? color;
  final double? fontSize;
  final FontWeight? fontWeight;

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
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: (style ?? const TextStyle()).copyWith(
        color: color,
        fontSize: fontSize,
        fontWeight: fontWeight,
        fontFamily: AppTextStyles.fontFamily,
      ),
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
    );
  }
}

/// Título principal (h1) - Maior destaque
class TextH1 extends StatelessWidget {
  final String text;
  final Color? color;
  final TextAlign? textAlign;
  final int? maxLines;
  final FontWeight? fontWeight;

  const TextH1(
    this.text, {
    super.key,
    this.color,
    this.textAlign,
    this.maxLines,
    this.fontWeight,
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
      overflow: TextOverflow.ellipsis,
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

  const TextH2(
    this.text, {
    super.key,
    this.color,
    this.textAlign,
    this.maxLines,
    this.fontWeight,
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
      overflow: TextOverflow.ellipsis,
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

  const TextH3(
    this.text, {
    super.key,
    this.color,
    this.textAlign,
    this.maxLines,
    this.fontWeight,
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
      overflow: TextOverflow.ellipsis,
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

  const TextBody1(
    this.text, {
    super.key,
    this.color,
    this.textAlign,
    this.maxLines,
    this.fontWeight,
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
      overflow: TextOverflow.ellipsis,
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

  const TextBody2(
    this.text, {
    super.key,
    this.color,
    this.textAlign,
    this.maxLines,
    this.fontWeight,
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
      overflow: TextOverflow.ellipsis,
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

  const AppTextButton(
    this.text, {
    super.key,
    this.color,
    this.textAlign,
    this.fontWeight,
  });

  @override
  Widget build(BuildContext context) {
    return AppText(
      text,
      style: AppTextStyles.button,
      color: color,
      textAlign: textAlign,
      fontWeight: fontWeight,
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

  const TextCaption(
    this.text, {
    super.key,
    this.color,
    this.textAlign,
    this.maxLines,
    this.fontWeight,
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
      overflow: TextOverflow.ellipsis,
    );
  }
}
