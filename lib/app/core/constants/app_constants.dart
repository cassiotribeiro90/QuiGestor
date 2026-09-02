// lib/app/core/constants/app_constants.dart

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class AppConstants {
  // ================================================================
  // 🔥 URL BASE DA API
  // ================================================================

  /// URL base da API (com /api no final)
  static String get apiBaseUrl {
    // 🔥 Prioridade: Variável de ambiente (se configurada)
    const String envUrl = String.fromEnvironment('API_URL');
    if (envUrl.isNotEmpty) {
      return envUrl;
    }

    // 🔥 Desenvolvimento local
    if (kIsWeb) {
      return 'http://localhost:8001/api';
    }

    // 🔥 Android Emulator
    if (defaultTargetPlatform == TargetPlatform.android) {
      return 'http://10.0.2.2:8001/api';
    }

    // 🔥 iOS Simulator / MacOS / Windows / Linux
    return 'http://localhost:8001/api';
  }

  /// URL base para imagens (sem /api no final)
  static String get imageBaseUrl {
    String base = apiBaseUrl;
    if (base.endsWith('/api/')) {
      base = base.substring(0, base.length - 5);
    } else if (base.endsWith('/api')) {
      base = base.substring(0, base.length - 4);
    }
    return base;
  }

  // ================================================================
  // 🔥 ENDPOINTS
  // ================================================================

  static const String uploadEndpoint = '/upload';

  // ================================================================
  // 🔥 PASTAS DE UPLOAD
  // ================================================================

  static const String folderProducts = 'produtos';
  static const String folderCategories = 'categorias';
  static const String folderProfile = 'perfil';
  static const String folderReviews = 'avaliacoes';
  static const String folderBanners = 'banners';
  static const String folderStores = 'lojas';

  // ================================================================
  // 🔥 CONFIGURAÇÕES DE UPLOAD
  // ================================================================

  static const int maxImageSize = 5 * 1024 * 1024; // 5MB
  static const int imageQuality = 75; // 75%
  static const int imageMaxWidth = 1200;
  static const int imageMaxHeight = 1200;
  static const List<String> allowedImageExtensions = ['jpg', 'jpeg', 'png', 'webp', 'gif'];
  static const List<String> allowedImageMimes = ['image/jpeg', 'image/png', 'image/webp', 'image/gif'];
}