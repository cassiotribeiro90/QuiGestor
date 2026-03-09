import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../shared/api/api_client.dart';
import '../models/loja.dart';
import 'loja_state.dart';

class LojaCubit extends Cubit<LojaState> {
  final ApiClient _apiClient;

  LojaCubit(this._apiClient) : super(LojaInitial());

  Future<void> fetchLojas() async {
    emit(LojaLoading());
    try {
      // 🔥 requiresAuth: true - envia token
      final response = await _apiClient.get('/gestor/lojas');

      final List<dynamic> data = response.data;
      final lojas = data.map((json) => Loja.fromJson(json)).toList();
      emit(LojaLoaded(lojas));
    } catch (e) {
      emit(LojaError(e.toString()));
    }
  }
}
