# QuiGestor

Sistema de gestão inteligente para o ecossistema Qui. Aplicativo desenvolvido em Flutter para administração de lojas, gestores, lojistas e pedidos.

## 📱 Sobre o Projeto

O QuiGestor é um aplicativo administrativo que permite gerenciar todo o ecossistema Qui de forma centralizada. Com ele é possível:

- 👤 **Gerenciar Gestores** - CRUD completo de administradores do sistema
- 🏪 **Gerenciar Lojistas** - Controle de usuários lojistas
- 🛍️ **Gerenciar Lojas** - Cadastro e monitoramento de lojas
- 📦 **Acompanhar Pedidos** - Visualização e gerenciamento de pedidos
- 📊 **Dashboard** - Visão geral com métricas e indicadores
- 🌓 **Tema Claro/Escuro** - Alternância de tema com persistência

## 🚀 Tecnologias Utilizadas

- **Flutter** (3.x) - Framework principal
- **Dio** - Cliente HTTP para requisições à API
- **Flutter Bloc** - Gerenciamento de estado
- **SharedPreferences** - Armazenamento local
- **Equatable** - Comparação de objetos

## 📋 Pré-requisitos

- Flutter SDK (versão 3.x)
- Dart SDK (versão 3.x)
- Backend QuiGestor API rodando (Yii2)
- Android Studio / VS Code (opcional)

## 🔧 Instalação

1. **Clone o repositório**
```bash
git clone https://github.com/seu-usuario/quigestor.git
cd quigestor
```


## 🏗️ Estrutura
```bash
lib/
├── app/
│   ├── modules/           # Módulos funcionais
│   │   ├── auth/          # Autenticação
│   │   ├── dashboard/      # Dashboard principal
│   │   ├── gestores/       # CRUD de gestores
│   │   ├── home/           # Tela inicial com menu
│   │   ├── loja/           # Gerenciamento de lojas
│   │   ├── settings/       # Configurações
│   │   ├── theme/          # Gerenciamento de tema
│   │   └── usuarios/       # Gerenciamento de usuários
│   ├── routes/             # Configuração de rotas
│   └── theme/              # Temas e estilos globais
├── apparte/                # Widgets reutilizáveis
│   └── widgets/
│       ├── app_text.dart       # Componentes de texto
│       ├── gradient_button.dart # Botão gradiente
│       ├── pagination_widget.dart # Componente de paginação
│       └── quigestor_card.dart  # Card personalizado
├── core/                   # Utilitários e widgets core
├── shared/                 # Serviços compartilhados
│   ├── api/                # Cliente HTTP e interceptors
│   └── services/           # Serviços (token, etc)
└── main.dart               # Ponto de entrada
```


## 🎨 Design System

O QuiGestor segue um design minimalista com

    Cores principais:

        - primary: Roxo suave (#5E5CE6)
        - secondary: Verde-água (#00C2A0)
        - accent: Coral (#FF6B6B)
        
    Tipografia: Fonte Poppins
    Componentes: Sem cards, apenas linhas divisórias (estilo WhatsApp)

    Responsivo: Layout adaptativo para web e mobile

## 🔐 Funcionalidades de Autenticação

    - Login com email e senha
    - Token JWT com refresh automático
    - Persistência de sessão
    - Logout automático em caso de token inválido
    - Interceptor para refresh token

    📄 Módulo de Gestores (CRUD)

O módulo de gestores implementa:

    - Listagem com paginação e busca
    - Filtros por nível (admin/comercial/suporte) e status (ativo/inativo)
    - Criação de novos gestores
    - Edição de gestores existentes
    - Exclusão com confirmação
    - Detalhes do gestor

## 🌓 Tema Claro/Escuro

O aplicativo suporta alternância entre tema claro e escuro, com persistência da preferência do usuário via SharedPreferences.
📱 Layout Responsivo

    - Web: Menu lateral fixo com largura de 260px, conteúdo centralizado (max-width 1000px)
    - Mobile: AppBar com drawer tradicional
    - Breakpoint: 800px


📄 Licença

Este projeto está sob a licença MIT. Veja o arquivo LICENSE para mais detalhes.

### 👨‍💻 Autor Cassio.
