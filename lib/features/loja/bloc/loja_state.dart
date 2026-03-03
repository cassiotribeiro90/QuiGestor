import 'package:equatable/equatable.dart';
import '../models/loja.dart';

abstract class LojaState extends Equatable {
  const LojaState();
  
  @override
  List<Object?> get props => [];
}

class LojaInitial extends LojaState {}

class LojaLoading extends LojaState {}

class LojaLoaded extends LojaState {
  final List<Loja> lojas;
  
  const LojaLoaded(this.lojas);
  
  @override
  List<Object?> get props => [lojas];
}

class LojaError extends LojaState {
  final String message;
  
  const LojaError(this.message);
  
  @override
  List<Object?> get props => [message];
}
