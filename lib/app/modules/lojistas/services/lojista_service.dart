import '../../../../shared/api/api_client.dart';

class LojistaService {
  final ApiClient _apiClient;
  LojistaService(this._apiClient);

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

    final response = await _apiClient.get(
      '/gestor/store-usuarios',
      queryParameters: query,
    );
    
    // Garante que retorna um Map
    return response.data is Map ? response.data : {'data': response.data};
  }

  Future<Map<String, dynamic>> visualizar(int id) async {
    final response = await _apiClient.get('/gestor/store-usuarios/$id');
    return response.data;
  }

  Future<Map<String, dynamic>> criar(Map<String, dynamic> dados) async {
    final response = await _apiClient.post(
      '/gestor/store-usuarios/create',
      data: dados,
    );
    return response.data;
  }

  Future<Map<String, dynamic>> atualizar(int id, Map<String, dynamic> dados) async {
    final response = await _apiClient.put(
      '/gestor/store-usuarios/update/$id',
      data: dados,
    );
    return response.data;
  }

  Future<Map<String, dynamic>> deletar(int id) async {
    final response = await _apiClient.delete(
      '/gestor/store-usuarios/delete/$id',
    );
    return response.data;
  }

  Future<List<Map<String, dynamic>>> listarLojas() async {
    final response = await _apiClient.get('/gestor/store-usuarios/options');
    final data = response.data;
    
    if (data is Map && data.containsKey('data')) {
      return List<Map<String, dynamic>>.from(data['data']);
    }
    
    return List<Map<String, dynamic>>.from(data is List ? data : []);
  }
}
