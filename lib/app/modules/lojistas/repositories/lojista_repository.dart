import '../models/lojista_model.dart';
import '../models/loja_option_model.dart';
import '../services/lojista_service.dart';

class LojistaRepository {
  final LojistaService _service;
  LojistaRepository(this._service);

  Future<(List<LojistaModel>, int)> listar({
    int? lojaId,
    String? funcao,
    int? status,
    String? search,
    int page = 1,
    int perPage = 20,
  }) async {
    final data = await _service.listar(
      lojaId: lojaId,
      funcao: funcao,
      status: status,
      search: search,
      page: page,
      perPage: perPage,
    );

    // Ajuste para lidar com a estrutura da resposta da API Yii2
    final responseData = data['data'] ?? data;
    final itemsData = responseData['items'] ?? [];
    final paginationData = responseData['pagination'] ?? {'total': 0};

    final items = (itemsData as List)
        .map((e) => LojistaModel.fromJson(e))
        .toList();

    final total = (paginationData['total'] ?? 0) as int;
    return (items, total);
  }

  Future<LojistaModel> visualizar(int id) async {
    final data = await _service.visualizar(id);
    return LojistaModel.fromJson(data['data']);
  }

  Future<LojistaModel> criar(Map<String, dynamic> dados) async {
    final data = await _service.criar(dados);
    if (data['success'] == true) {
      return LojistaModel.fromJson(data['data']);
    } else {
      throw Exception(data['errors'] ?? 'Erro ao criar lojista');
    }
  }

  Future<LojistaModel> atualizar(int id, Map<String, dynamic> dados) async {
    final data = await _service.atualizar(id, dados);
    if (data['success'] == true) {
      return LojistaModel.fromJson(data['data']);
    } else {
      throw Exception(data['errors'] ?? 'Erro ao atualizar lojista');
    }
  }

  Future<void> deletar(int id) async {
    final data = await _service.deletar(id);
    if (data['success'] != true) {
      throw Exception(data['message'] ?? 'Erro ao deletar lojista');
    }
  }

  Future<List<LojaOptionModel>> listarLojas() async {
    final data = await _service.listarLojas();
    return data.map((e) => LojaOptionModel.fromJson(e)).toList();
  }
}
