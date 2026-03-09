import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

// Estados
abstract class HomeState extends Equatable {
  const HomeState();
  
  @override
  List<Object?> get props => [];
}

class HomeInitial extends HomeState {}

class HomePageChanged extends HomeState {
  final int pageIndex;
  final String pageTitle;
  final Widget pageContent;
  
  const HomePageChanged({
    required this.pageIndex,
    required this.pageTitle,
    required this.pageContent,
  });
  
  @override
  List<Object?> get props => [pageIndex, pageTitle];
}

// Cubit
class HomeCubit extends Cubit<HomeState> {
  HomeCubit() : super(HomeInitial());

  void navigateTo(int index, String title, Widget content) {
    emit(HomePageChanged(
      pageIndex: index,
      pageTitle: title,
      pageContent: content,
    ));
  }
}
