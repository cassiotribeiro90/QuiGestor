import 'package:quigestor/shared/api/api_client.dart';

class SubcategoriaService {
  final ApiClient _apiClient;
  SubcategoriaService(this._apiClient);

  Future<Map<String, dynamic>> listar({
    int page = 1,
    int perPage = 50,
    Map<String, String>? filters,
  }) async {
    final query = <String, dynamic>{
      'page': page,
      'per_page': perPage,
      if (filters != null) ...filters,
    };

    final response = await _apiClient.get('/gestor/subcategorias', queryParameters: query);
    return response.data;
  }

  Future<Map<String, dynamic>> visualizar(int id) async {
    final response = await _apiClient.get('/gestor/subcategoria/view', queryParameters: {'id': id});
    return response.data;
  }

  Future<Map<String, dynamic>> criar(Map<String, dynamic> dados) async {
    final response = await _apiClient.post('/gestor/subcategoria/create', data: dados);
    return response.data;
  }

  Future<Map<String, dynamic>> atualizar(int id, Map<String, dynamic> dados) async {
    final response = await _apiClient.put('/gestor/subcategoria/update', data: dados, queryParameters: {'id': id});
    return response.data;
  }

  Future<Map<String, dynamic>> deletar(int id) async {
    final response = await _apiClient.delete('/gestor/subcategoria/delete', queryParameters: {'id': id});
    return response.data;
  }
}
