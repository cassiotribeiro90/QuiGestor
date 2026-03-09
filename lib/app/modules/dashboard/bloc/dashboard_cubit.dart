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
    emit(DashboardLoading());


    try {
      // 🔥 requiresAuth: true (padrão) - envia token
      final response = await _apiClient.get('/gestor/dashboard');

      if (response.data['success'] == true) {
        emit(DashboardLoaded(response.data['data'] ?? {}));
      } else {
        emit(DashboardError(response.data['message'] ?? 'Erro ao carregar dashboard'));
      }
    } catch (e) {
      emit(const DashboardError('Erro de conexão'));
    }
  }
}
