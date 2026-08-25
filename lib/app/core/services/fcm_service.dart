import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart'; // ← ESSENCIAL para kIsWeb

class FcmService {
  static final FcmService _instance = FcmService._internal();
  factory FcmService() => _instance;
  FcmService._internal();

  bool _initialized = false;

  // 🔥 Inicialização não-bloqueante
  Future<void> init() async {
    if (_initialized) return;

    // Usa Future.microtask para não bloquear a UI
    Future.microtask(() async {
      try {
        if (kIsWeb) {
          debugPrint('🌐 [FCM] Inicializando para Web...');
          await _initWeb();
        } else {
          debugPrint('📱 [FCM] Inicializando para Mobile...');
          await _initMobile();
        }
        _initialized = true;
        debugPrint('✅ [FCM] Inicializado com sucesso');
      } catch (e) {
        debugPrint('⚠️ [FCM] Erro na inicialização: $e');
        _initialized = true; // evita tentar novamente
      }
    });
  }

  // ========== INICIALIZAÇÃO WEB ==========
  Future<void> _initWeb() async {
    try {
      final messaging = FirebaseMessaging.instance;

      // Solicita permissão (exibe popup do navegador)
      final settings = await messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );

      debugPrint('🔔 [FCM Web] Permissão: ${settings.authorizationStatus}');

      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        final token = await messaging.getToken();
        if (token != null) {
          debugPrint('📱 [FCM Web] Token: ${token.substring(0, 20)}...');
        }
      }

      // Listener para mensagens em foreground
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        debugPrint('📨 [FCM Web] Mensagem recebida: ${message.notification?.title}');
      });

      debugPrint('✅ [FCM Web] Configurado com sucesso');

    } catch (e) {
      debugPrint('⚠️ [FCM Web] Erro: $e');
    }
  }

  // ========== INICIALIZAÇÃO MOBILE ==========
  Future<void> _initMobile() async {
    try {
      final messaging = FirebaseMessaging.instance;
      final settings = await messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );

      debugPrint('🔔 [FCM Mobile] Permissão: ${settings.authorizationStatus}');

      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        final token = await messaging.getToken();
        if (token != null) {
          debugPrint('📱 [FCM Mobile] Token: ${token.substring(0, 20)}...');
        }
      }

      // Listener para mensagens em foreground
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        debugPrint('📨 [FCM Mobile] Mensagem recebida: ${message.notification?.title}');
      });

      debugPrint('✅ [FCM Mobile] Configurado com sucesso');

    } catch (e) {
      debugPrint('⚠️ [FCM Mobile] Erro: $e');
    }
  }

  Future<void> sendTokenToBackend(String authToken) async {}
  String? get token => null;
}
