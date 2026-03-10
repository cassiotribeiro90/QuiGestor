import 'package:flutter_bloc/flutter_bloc.dart';
import 'dashboard_state.dart';
import '../../../../shared/api/api_client.dart';

class DashboardCubit extends Cubit<DashboardState> {
  final ApiClient _apiClient;

  DashboardCubit(this._apiClient) : super(DashboardInitial());

  Future<void> fetchDashboard() async {
    emit(DashboardLoading());
    try {
      final response = await _apiClient.get('/gestor/dashboard');
      if (response.data['success'] == true) {
        emit(DashboardLoaded(response.data['data']));
      } else {
        emit(DashboardError(response.data['message'] ?? 'Erro ao carregar'));
      }
    } catch (e) {
      emit(DashboardError('Erro de conexão: $e'));
    }
  }
}
