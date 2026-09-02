// lib/shared/utils/image_helper.dart

import '../../app/core/constants/app_constants.dart';

class ImageHelper {
  /// 🔥 Converte caminho relativo para URL completa
  static String getFullImageUrl(String? path) {
    if (path == null || path.isEmpty) return '';

    // Se já for URL completa, retorna como está
    if (path.startsWith('http://') || path.startsWith('https://')) {
      return path;
    }

    // Remove barra inicial se existir
    final cleanPath = path.startsWith('/') ? path.substring(1) : path;

    return '${AppConstants.imageBaseUrl}/$cleanPath';
  }

  /// 🔥 Extrai caminho relativo de uma URL completa
  static String? extractPath(String? url) {
    if (url == null || url.isEmpty) return null;

    // Se já for caminho relativo, retorna como está
    if (!url.startsWith('http://') && !url.startsWith('https://')) {
      return url.startsWith('/') ? url.substring(1) : url;
    }

    try {
      final uri = Uri.parse(url);
      final path = uri.path;
      return path.startsWith('/') ? path.substring(1) : path;
    } catch (e) {
      return url;
    }
  }

  /// 🔥 Obtém a URL base das imagens
  static String get imageBaseUrl => AppConstants.imageBaseUrl;
}