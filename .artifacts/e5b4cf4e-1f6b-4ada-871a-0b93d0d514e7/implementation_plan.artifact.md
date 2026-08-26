# Implementação do Módulo de Clientes

Este plano descreve a criação do módulo de Clientes no quiGestor, seguindo o padrão do módulo de Pedidos.

## Mudanças Propostas

### Módulo de Clientes

#### [NEW] [cliente.dart](file:///C:/Users/cassi/projetos/quigestor/lib/app/modules/clientes/models/cliente.dart)
Modelo de dados para Clientes com suporte a JSON.

#### [NEW] [clientes_state.dart](file:///C:/Users/cassi/projetos/quigestor/lib/app/modules/clientes/bloc/clientes_state.dart)
Estados do Cubit para listagem e operações de clientes.

#### [NEW] [clientes_cubit.dart](file:///C:/Users/cassi/projetos/quigestor/lib/app/modules/clientes/bloc/clientes_cubit.dart)
Lógica de negócio para busca, filtragem e paginação de clientes.

#### [NEW] [cliente_card.dart](file:///C:/Users/cassi/projetos/quigestor/lib/app/modules/clientes/widgets/cliente_card.dart)
Componente visual para exibição resumida do cliente na lista.

#### [NEW] [clientes_list_screen.dart](file:///C:/Users/cassi/projetos/quigestor/lib/app/modules/clientes/views/clientes_list_screen.dart)
Tela de listagem principal com filtros e scroll infinito.

#### [NEW] [cliente_form_screen.dart](file:///C:/Users/cassi/projetos/quigestor/lib/app/modules/clientes/views/cliente_form_screen.dart)
Tela de edição de dados do cliente.

### Core e Roteamento

#### [MODIFY] [app_router.dart](file:///C:/Users/cassi/projetos/quigestor/lib/app/routes/app_router.dart)
Adição das rotas `/clientes` e `/clientes/:id`.

#### [MODIFY] [dependencies.dart](file:///C:/Users/cassi/projetos/quigestor/lib/app/di/dependencies.dart)
Registro do `ClientesCubit` no GetIt.

## Plano de Verificação

### Verificação Manual
1.  Acessar a rota `/clientes` e verificar a listagem inicial.
2.  Testar a paginação (scroll infinito).
3.  Aplicar filtros e verificar se a lista é atualizada.
4.  Clicar em um cliente para abrir a tela de edição.
5.  Alterar um campo e salvar, verificando o feedback (SnackBar) e o retorno à lista.
