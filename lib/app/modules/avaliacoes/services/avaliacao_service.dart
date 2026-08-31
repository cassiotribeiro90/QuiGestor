import 'package:flutter/cupertino.dart';
import '../../../../shared/api/api_client.dart';

class AvaliacaoService {
  final ApiClient _apiClient;
  AvaliacaoService(this._apiClient);

  Future<Map<String, dynamic>> listar({
    int page = 1,
    int perPage = 20,
    Map<String, String>? filters,
  }) async {
    final query = <String, dynamic>{
      'page': page,
      'per_page': perPage,
      if (filters != null) ...filters,
    };

    debugPrint('🔍 Buscando avaliações - Page: $page, Filters: $filters');

    final response = await _apiClient.get(
      '/gestor/avaliacoes',
      queryParameters: query,
    );

    debugPrint('📦 Resposta bruta: ${response.data.runtimeType}');
    debugPrint('📦 Chaves: ${response.data.keys}');

    // Garante que retorna um Map com a estrutura esperada
    if (response.data is Map) {
      return response.data as Map<String, dynamic>;
    }

    // Se a resposta não for um Map, envolve em uma estrutura
    return {'data': response.data};
  }

  Future<Map<String, dynamic>> visualizar(int id) async {
    debugPrint('🔍 Buscando avaliação $id');

    final response = await _apiClient.get('/gestor/avaliacoes/$id');

    debugPrint('📦 Resposta do detalhe: ${response.data.runtimeType}');
    debugPrint('📦 Chaves: ${response.data.keys}');

    if (response.data is Map) {
      return response.data as Map<String, dynamic>;
    }

    return {'data': response.data};
  }

  Future<Map<String, dynamic>> atualizarStatus(int id, String status) async {
    final response = await _apiClient.put(
      '/gestor/avaliacoes/$id/status',
      data: {'status': status},
    );
    return response.data;
  }

  Future<Map<String, dynamic>> deletar(int id) async {
    final response = await _apiClient.delete(
      '/gestor/avaliacoes/$id',
    );
    return response.data;
  }
}