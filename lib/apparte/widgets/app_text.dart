import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import '../../app/theme/app_text_styles.dart';

/// Componente base para todos os textos do app.
class AppText extends StatelessWidget {
  final String text;
  final TextStyle? style;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;
  final Color? color;
  final double? fontSize;
  final FontWeight? fontWeight;
  final bool selectable;

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
    this.selectable = true,
  });

  bool get _isSelectable {
    if (!selectable) return false;
    return kIsWeb;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    Color? effectiveColor = color;
    if (effectiveColor == null && style != null) {
      if (style == AppTextStyles.h1 || 
          style == AppTextStyles.h2 || 
          style == AppTextStyles.h3) {
        effectiveColor = theme.textTheme.titleLarge?.color;
      } else if (style == AppTextStyles.body1) {
        effectiveColor = theme.textTheme.bodyLarge?.color;
      } else if (style == AppTextStyles.body2) {
        effectiveColor = theme.textTheme.bodyMedium?.color;
      } else if (style == AppTextStyles.body3) {
        effectiveColor = theme.textTheme.bodySmall?.color;
      } else if (style == AppTextStyles.caption) {
        effectiveColor = theme.textTheme.bodySmall?.color;
      } else if (style == AppTextStyles.button) {
        effectiveColor = theme.colorScheme.onPrimary;
      }
    }

    final baseStyle = (style ?? const TextStyle()).copyWith(
      color: effectiveColor,
      fontSize: fontSize,
      fontWeight: fontWeight,
      fontFamily: AppTextStyles.fontFamily,
      overflow: TextOverflow.fade,
    );

    if (_isSelectable) {
      return SelectableText(
        text,
        style: baseStyle,
        textAlign: textAlign,
        maxLines: maxLines ?? 1,
      );
    } else {
      return Text(
        text,
        style: baseStyle,
        textAlign: textAlign,
        maxLines: maxLines ?? 1,
        overflow: overflow ?? TextOverflow.fade,
      );
    }
  }
}

class TextH1 extends StatelessWidget {
  final String text;
  final Color? color;
  final TextAlign? textAlign;
  final int? maxLines;
  final FontWeight? fontWeight;
  final bool selectable;

  const TextH1(
    this.text, {
    super.key,
    this.color,
    this.textAlign,
    this.maxLines,
    this.fontWeight,
    this.selectable = true,
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
      overflow: TextOverflow.fade,
    );
  }
}

class TextH2 extends StatelessWidget {
  final String text;
  final Color? color;
  final TextAlign? textAlign;
  final int? maxLines;
  final FontWeight? fontWeight;
  final bool selectable;

  const TextH2(
    this.text, {
    super.key,
    this.color,
    this.textAlign,
    this.maxLines,
    this.fontWeight,
    this.selectable = true,
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
      overflow: TextOverflow.fade,
    );
  }
}

class TextH3 extends StatelessWidget {
  final String text;
  final Color? color;
  final TextAlign? textAlign;
  final int? maxLines;
  final FontWeight? fontWeight;
  final bool selectable;

  const TextH3(
    this.text, {
    super.key,
    this.color,
    this.textAlign,
    this.maxLines,
    this.fontWeight,
    this.selectable = true,
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
      overflow: TextOverflow.fade,
    );
  }
}

class TextBody1 extends StatelessWidget {
  final String text;
  final Color? color;
  final TextAlign? textAlign;
  final int? maxLines;
  final FontWeight? fontWeight;
  final bool selectable;

  const TextBody1(
    this.text, {
    super.key,
    this.color,
    this.textAlign,
    this.maxLines,
    this.fontWeight,
    this.selectable = true,
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
      overflow: TextOverflow.fade,
    );
  }
}

class TextBody2 extends StatelessWidget {
  final String text;
  final Color? color;
  final TextAlign? textAlign;
  final int? maxLines;
  final FontWeight? fontWeight;
  final bool selectable;

  const TextBody2(
    this.text, {
    super.key,
    this.color,
    this.textAlign,
    this.maxLines,
    this.fontWeight,
    this.selectable = true,
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
      overflow: TextOverflow.fade,
    );
  }
}

class TextBody3 extends StatelessWidget {
  final String text;
  final Color? color;
  final TextAlign? textAlign;
  final int? maxLines;
  final FontWeight? fontWeight;
  final bool selectable;

  const TextBody3(
    this.text, {
    super.key,
    this.color,
    this.textAlign,
    this.maxLines,
    this.fontWeight,
    this.selectable = true,
  });

  @override
  Widget build(BuildContext context) {
    return AppText(
      text,
      style: AppTextStyles.body3,
      color: color,
      textAlign: textAlign,
      maxLines: maxLines,
      fontWeight: fontWeight,
      selectable: selectable,
      overflow: TextOverflow.fade,
    );
  }
}

class AppTextButton extends StatelessWidget {
  final String text;
  final Color? color;
  final TextAlign? textAlign;
  final FontWeight? fontWeight;
  final bool selectable;

  const AppTextButton(
    this.text, {
    super.key,
    this.color,
    this.textAlign,
    this.fontWeight,
    this.selectable = false,
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
      overflow: TextOverflow.fade,
    );
  }
}

class TextCaption extends StatelessWidget {
  final String text;
  final Color? color;
  final TextAlign? textAlign;
  final int? maxLines;
  final FontWeight? fontWeight;
  final bool selectable;

  const TextCaption(
    this.text, {
    super.key,
    this.color,
    this.textAlign,
    this.maxLines,
    this.fontWeight,
    this.selectable = true,
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
      overflow: TextOverflow.fade,
    );
  }
}
