class AppConfig {
  static const int defaultPerPage = 10;

  // AUTH
  static const String LOGIN = '/gestor/gestor-usuarios/login';
  static const String REFRESH_TOKEN = '/gestor/gestor-usuarios/refresh-token';

  // DASHBOARD
  static const String DASHBOARD = '/gestor/dashboard';

  // GESTORES
  static const String GESTORES = '/gestor/gestor-usuarios';
  static const String GESTOR_CREATE = '/gestor/gestor-usuarios/create';
  static const String GESTOR_UPDATE = '/gestor/gestor-usuarios/update'; // + /$id
  static const String GESTOR_DELETE = '/gestor/gestor-usuarios/delete'; // + /$id
  
  // LOJAS
  static const String LOJAS = '/gestor/lojas';
  static const String LOJA_CREATE = '/gestor/lojas/create';
  static const String LOJA_UPDATE = '/gestor/lojas/update'; // + /$id
  static const String LOJA_DELETE = '/gestor/lojas/delete'; // + /$id

  // CATEGORIAS
  static const String CATEGORIAS = '/gestor/categorias';
  static const String CATEGORIA_CREATE = '/gestor/categorias/create';
  static const String CATEGORIA_UPDATE = '/gestor/categorias/update'; // + /$id
  static const String CATEGORIA_DELETE = '/gestor/categorias/delete'; // + /$id
}
