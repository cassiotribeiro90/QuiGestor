import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../shared/api/api_client.dart';

// States
abstract class UsuarioState extends Equatable {
  const UsuarioState();

  @override
  List<Object?> get props => [];
}

class UsuarioInitial extends UsuarioState {}

class UsuarioLoading extends UsuarioState {}

class UsuarioLoaded extends UsuarioState {
  final List<Map<String, dynamic>> usuarios;
  final List<Map<String, dynamic>> usuariosFiltrados;

  const UsuarioLoaded(this.usuarios, this.usuariosFiltrados);

  @override
  List<Object?> get props => [usuarios, usuariosFiltrados];
}

class UsuarioError extends UsuarioState {
  final String message;

  const UsuarioError(this.message);

  @override
  List<Object?> get props => [message];
}

// Cubit
class UsuarioCubit extends Cubit<UsuarioState> {
  final ApiClient _apiClient;

  List<Map<String, dynamic>> _todosUsuarios = [];

  UsuarioCubit(this._apiClient) : super(UsuarioInitial());

  Future<void> fetchUsuarios() async {
    emit(UsuarioLoading());

    try {
      // 🔥 requiresAuth: true (padrão) - envia token
      final response = await _apiClient.get('/gestor/gestor-usuarios');

      if (response.data['success'] == true) {
        _todosUsuarios = List<Map<String, dynamic>>.from(response.data['data']['items']);
        emit(UsuarioLoaded(_todosUsuarios, _todosUsuarios));
      } else {
        emit(UsuarioError(response.data['message'] ?? 'Erro ao carregar usuários'));
      }
    } catch (e) {
      emit(UsuarioError('Erro de conexão: $e'));
    }
  }

  void filtrar(String search, String? nivel, int? status) {
    if (_todosUsuarios.isEmpty) return;

    var filtrados = List<Map<String, dynamic>>.from(_todosUsuarios);

    // Filtro por busca
    if (search.isNotEmpty) {
      filtrados = filtrados.where((u) {
        return u['nome'].toLowerCase().contains(search.toLowerCase()) ||
               u['email'].toLowerCase().contains(search.toLowerCase()) ||
               (u['cpf']?.contains(search) ?? false);
      }).toList();
    }

    // Filtro por nível
    if (nivel != null) {
      filtrados = filtrados.where((u) => u['nivel'] == nivel).toList();
    }

    // Filtro por status
    if (status != null) {
      filtrados = filtrados.where((u) => u['status'] == status).toList();
    }

    emit(UsuarioLoaded(_todosUsuarios, filtrados));
  }
}
