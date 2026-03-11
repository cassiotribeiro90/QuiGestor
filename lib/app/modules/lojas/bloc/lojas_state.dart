import 'package:equatable/equatable.dart';
import '../models/loja.dart';

abstract class LojasState extends Equatable {
  const LojasState();

  @override
  List<Object?> get props => [];
}

class LojasInitial extends LojasState {}

class LojasLoading extends LojasState {}

class LojasLoaded extends LojasState {
  final List<Loja> lojas;
  final List<Loja> lojasFiltradas;
  final Map<String, dynamic>? pagination;

  const LojasLoaded({
    required this.lojas,
    required this.lojasFiltradas,
    this.pagination,
  });

  @override
  List<Object?> get props => [lojas, lojasFiltradas, pagination];
}

class LojasError extends LojasState {
  final String message;

  const LojasError(this.message);

  @override
  List<Object?> get props => [message];
}

class LojaOperationSuccess extends LojasState {
  final String message;
  final Loja? loja;

  const LojaOperationSuccess({required this.message, this.loja});

  @override
  List<Object?> get props => [message, loja];
}

class LojaOperationLoading extends LojasState {
  const LojaOperationLoading();
}