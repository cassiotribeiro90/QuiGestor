import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../app/modules/home/views/home_screen.dart';

mixin NavigationMixin<T extends StatefulWidget> on State<T> {
  bool get isWeb => MediaQuery.of(context).size.width > 600;

  // ============================================================
  // NAVEGAÇÃO COM GO ROUTER (NOVO)
  // ============================================================

  /// Navega para uma rota usando GoRouter (com atualização de URL)
  void navigateToRoute(String route, {Object? extra}) {
    context.push(route, extra: extra);
  }

  /// Navega para uma rota substituindo a atual
  void navigateToRouteReplacement(String route, {Object? extra}) {
    context.replace(route, extra: extra);
  }

  /// Volta para a tela anterior
  void navigateBack({dynamic result}) {
    context.pop(result);
  }

  // ============================================================
  // NAVEGAÇÃO LEGADO (Web/Mobile) - Mantido para compatibilidade
  // ============================================================

  void navigateToWebContent(Widget content, String title) {
    if (isWeb) {
      final homeState = context.findAncestorStateOfType<HomeScreenState>();
      if (homeState != null) {
        homeState.navigateTo(content);
      }
    }
  }

  Future<R?> navigateToMobileScreen<R>(Widget screen) {
    return Navigator.push<R>(
      context,
      MaterialPageRoute(builder: (_) => screen),
    );
  }

  void navigateToDetail({
    required BuildContext context,
    required Widget webContent,
    required Widget mobileScreen,
    required String title,
  }) {
    if (isWeb) {
      final homeState = context.findAncestorStateOfType<HomeScreenState>();
      if (homeState != null) {
        homeState.navigateTo(webContent);
      }
    } else {
      Navigator.push(context, MaterialPageRoute(builder: (_) => mobileScreen));
    }
  }

  // ============================================================
  // MÉTODOS DE NAVEGAÇÃO ESPECÍFICOS POR MÓDULO
  // ============================================================

  /// Navega para o formulário de gestor (novo ou edição)
  void navigateToGestorForm({int? gestorId}) {
    if (gestorId != null) {
      navigateToRoute('/gestores/$gestorId');
    } else {
      navigateToRoute('/gestores/novo');
    }
  }

  /// Navega para o formulário de lojista (novo ou edição)
  void navigateToLojistaForm({int? lojistaId}) {
    if (lojistaId != null) {
      navigateToRoute('/lojistas/$lojistaId');
    } else {
      navigateToRoute('/lojistas/novo');
    }
  }

  /// Navega para o formulário de loja (novo ou edição)
  void navigateToLojaForm({int? lojaId}) {
    if (lojaId != null) {
      navigateToRoute('/lojas/$lojaId');
    } else {
      navigateToRoute('/lojas/novo');
    }
  }

  /// Navega para o formulário de categoria (novo ou edição)
  void navigateToCategoriaForm({int? categoriaId}) {
    if (categoriaId != null) {
      navigateToRoute('/categorias/$categoriaId');
    } else {
      navigateToRoute('/categorias/novo');
    }
  }

  /// Navega para o formulário de subcategoria (novo ou edição)
  void navigateToSubcategoriaForm({int? subcategoriaId, int? initialCategoriaId}) {
    if (subcategoriaId != null) {
      navigateToRoute('/subcategorias/$subcategoriaId');
    } else {
      navigateToRoute('/subcategorias/novo');
    }
  }

  /// Navega para o detalhe do pedido
  void navigateToPedidoDetalhe(int pedidoId) {
    navigateToRoute('/pedidos/$pedidoId');
  }
}