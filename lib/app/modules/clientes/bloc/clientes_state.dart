// lib/app/modules/clientes/bloc/clientes_state.dart

import 'package:equatable/equatable.dart';
import '../models/cliente.dart';

abstract class ClientesState extends Equatable {
  const ClientesState();
  @override
  List<Object?> get props => [];
}

class ClientesInitial extends ClientesState {}

class ClientesLoading extends ClientesState {}

class ClientesLoaded extends ClientesState {
  final List<Cliente> clientes;
  final int total;
  final Map<String, dynamic>? filterOptions;
  final bool hasMore;

  const ClientesLoaded({
    required this.clientes,
    required this.total,
    this.filterOptions,
    this.hasMore = false,
  });

  @override
  List<Object?> get props => [clientes, total, filterOptions, hasMore];
}

class ClientesError extends ClientesState {
  final String message;
  const ClientesError(this.message);
  @override
  List<Object?> get props => [message];
}

// Estado para operações de sucesso (atualização)
class ClienteOperationSuccess extends ClientesState {
  final String message;
  const ClienteOperationSuccess(this.message);
  @override
  List<Object?> get props => [message];
}
