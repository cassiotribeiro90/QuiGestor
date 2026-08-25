import 'dart:io';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as shelf_io;

void main() async {
  final ip = InternetAddress.anyIPv4;
  final port = int.parse(Platform.environment['PORT'] ?? '8000');

  // Handler que serve arquivos estáticos ou redireciona para index.html
  Future<Response> _staticHandler(Request request) async {
    var path = request.url.path;
    if (path.isEmpty) path = 'index.html';

    final file = File(path);
    if (await file.exists()) {
      // 🔥 Serve o arquivo real
      return Response.ok(
        await file.readAsBytes(),
        headers: {
          'Content-Type': _getContentType(path),
          'Cache-Control': 'no-cache',
        },
      );
    }

    // 🔥 Fallback SPA: serve index.html para rotas não encontradas
    final indexFile = File('index.html');
    if (await indexFile.exists()) {
      return Response.ok(
        await indexFile.readAsBytes(),
        headers: {'Content-Type': 'text/html'},
      );
    }

    return Response.notFound('Arquivo não encontrado');
  }

  final handler = const Pipeline()
      .addMiddleware(logRequests())
      .addHandler(_staticHandler);

  final server = await shelf_io.serve(handler, ip, port);
  print('✅ Servidor SPA rodando em: http://${server.address.address}:${server.port}');
  print('📋 Arquivos estáticos são servidos normalmente, rotas SPA redirecionam para index.html');
}

String _getContentType(String path) {
  if (path.endsWith('.html')) return 'text/html';
  if (path.endsWith('.css')) return 'text/css';
  if (path.endsWith('.js')) return 'application/javascript';
  if (path.endsWith('.json')) return 'application/json';
  if (path.endsWith('.png')) return 'image/png';
  if (path.endsWith('.jpg') || path.endsWith('.jpeg')) return 'image/jpeg';
  if (path.endsWith('.svg')) return 'image/svg+xml';
  if (path.endsWith('.ico')) return 'image/x-icon';
  if (path.endsWith('.woff')) return 'font/woff';
  if (path.endsWith('.woff2')) return 'font/woff2';
  return 'application/octet-stream';
}