import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../../shared/api/api_client.dart';

// States
abstract class DashboardState extends Equatable {
  const DashboardState();

  @override
  List<Object?> get props => [];
}

class DashboardInitial extends DashboardState {}

class DashboardLoading extends DashboardState {}

class DashboardLoaded extends DashboardState {
  final Map<String, dynamic> data;

  const DashboardLoaded(this.data);

  @override
  List<Object?> get props => [data];
}

class DashboardError extends DashboardState {
  final String message;

  const DashboardError(this.message);

  @override
  List<Object?> get props => [message];
}

// Cubit
class DashboardCubit extends Cubit<DashboardState> {
  final ApiClient _apiClient;

  DashboardCubit(this._apiClient) : super(DashboardInitial());

  Future<void> fetchDashboard() async {
    // Só mostra loading se não estiver em loading já
    if (state is! DashboardLoading) {
      print('📊 [DASHBOARD] Iniciando carregamento...');
      emit(DashboardLoading());
    }

    try {
      // Opcional: Log do token para depuração
      // print('📊 [DASHBOARD] Token antes da requisição: ${_apiClient.getToken()}');
      
      print('📊 [DASHBOARD] Buscando dados...');
      final response = await _apiClient.get('/gestor/dashboard');

      print('📊 [DASHBOARD] Resposta recebida: ${response.statusCode}');

      if (response.data['success'] == true) {
        print('📊 [DASHBOARD] Dados carregados com sucesso');
        emit(DashboardLoaded(response.data['data'] ?? {}));
      } else {
        final errorMsg = response.data['message'] ?? 'Erro ao carregar dashboard';
        print('📊 [DASHBOARD] Erro: $errorMsg');
        emit(DashboardError(errorMsg));
      }
    } catch (e) {
      print('📊 [DASHBOARD] Exceção: $e');
      emit(const DashboardError('Erro de conexão'));
    }
  }
}
