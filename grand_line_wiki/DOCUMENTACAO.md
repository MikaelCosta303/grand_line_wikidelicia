# Documentação do código do Grand Line Wiki

Este documento descreve a arquitetura, os fluxos de dados e a finalidade de cada arquivo do projeto Flutter `grand_line_wiki`.

## Visão geral

O Grand Line Wiki é um app de consulta de informações sobre o universo de One Piece. Ele consulta uma API REST pública e apresenta os dados em telas organizadas por categoria, com suporte a busca, detalhamento de itens e alternância de tema claro/escuro.

O fluxo principal da aplicação é:

1. O usuário acessa a tela inicial.
2. Escolhe uma categoria (por exemplo: personagens, frutas, baladas, armas etc.).
3. A tela solicita dados para a API via `OnePieceApi`.
4. O resultado é convertido em objetos `WikiItem`.
5. A UI renderiza listas, cards e detalhes com base nesses objetos.

## Estrutura do projeto

```text
grand_line_wiki/
├── lib/
│   ├── main.dart
│   ├── theme.dart
│   ├── theme_controller.dart
│   ├── data/
│   │   ├── api_service.dart
│   │   └── categories.dart
│   ├── models/
│   │   └── wiki_item.dart
│   ├── screens/
│   │   ├── category_screen.dart
│   │   ├── detail_sheet.dart
│   │   ├── home_screen.dart
│   │   ├── home_shell.dart
│   │   └── search_screen.dart
│   └── widgets/
│       └── widgets.dart
├── test/
│   └── widget_test.dart
├── README.md
├── analysis_options.yaml
├── pubspec.yaml
├── web/
├── windows/
└── DOCUMENTACAO.md
```

## Arquitetura geral

### 1. Entrada da aplicação

Arquivo: `lib/main.dart`

- Inicializa os bindings do Flutter.
- Carrega o tema salvo no armazenamento local.
- Inicia o app com o widget `GrandLineApp`.
- O `GrandLineApp` escuta `themeController` e aplica o tema claro/escuro conforme a configuração ativa.
- A tela principal da aplicação é `HomeShell`.

### 2. Tema visual

Arquivo: `lib/theme.dart`

- Define a paleta `Palette` para os modos claro e escuro.
- Centraliza as fontes, gradients e estilo global da aplicação.
- Exporta a função `buildTheme(Brightness brightness)` para criar o `ThemeData` do Material 3.
- A fonte principal para títulos utiliza `google_fonts` com estilo pirata, enquanto o texto geral usa a fonte Nunito.

### 3. Persistência do tema

Arquivo: `lib/theme_controller.dart`

- Controla o tema atual com `ThemeMode`.
- Usa `SharedPreferences` para salvar a escolha entre claro e escuro.
- Possui a lógica de alternância (`toggle`) e carregamento customizado (`load`).
- Em caso de falha no armazenamento, o app cai no tema do sistema.

## Camada de dados

### 4. Definição das categorias

Arquivo: `lib/data/categories.dart`

- Guarda a lista de 16 categorias disponíveis no app.
- Cada categoria é representada pelo modelo `Category`.
- Cada instância contém:
  - `name`: nome exibido na UI
  - `emoji`: ícone associado
  - `slug`: nome do recurso no endpoint da API
  - `confirmed`: flag para indicar se o slug foi validado pela documentação oficial
- Também expõe propriedades como:
  - `listPath`
  - `idPath`
  - `searchPath`
  - `countPath`

Esses valores são usados pela API e pelas telas de categoria e busca. O slug é o único ponto central da configuração do endpoint de cada recurso.

### 5. Cliente da API

Arquivo: `lib/data/api_service.dart`

A classe principal é `OnePieceApi`.

Responsabilidades:

- Montar URLs com base no host e no slug da categoria.
- Fazer requisições HTTP com timeout.
- Normalizar respostas em listas de `WikiItem`.
- Guardar resultados em cache em memória para evitar chamadas repetidas desnecessárias.
- Traduzir erros para `ApiException` com mensagens amigáveis em português.

Endpoints suportados:

- `GET /v2/{resource}/en`
- `GET /v2/{resource}/en/{id}`
- `GET /v2/{resource}/en/search?name=`
- `GET /v2/{resource}/en/count`

Métodos principais:

- `list(Category c, {bool refresh = false})`
- `byId(Category c, String id)`
- `search(Category c, String name)`
- `count(Category c)`

A instância global `api` é exposta ao restante da aplicação para que todas as telas usem o mesmo cliente.

## Modelo de dados

### 6. Estrutura genérica dos itens da API

Arquivo: `lib/models/wiki_item.dart`

A API da One Piece é heterogênea: cada recurso tem campos diferentes. Por isso, o app não usa uma classe rígida para cada tipo de item.

A classe `WikiItem` encapsula um mapa `Map<String, dynamic>` em `raw` e expõe propriedades derivadas:

- `id`
- `title`
- `subtitle`
- `tag`
- `imageUrl`
- `fields`

A lógica usa listas de chaves tentativas para encontrar o nome, subtítulo, etiqueta e imagem no JSON. Exemplos:

- `titleKeys`: `name`, `title`, `roman_name`, `label`, etc.
- `subtitleKeys`: `job`, `type`, `description`, `origin`, etc.
- `tagKeys`: `bounty`, `type`, `status`, `saga`, `number`, etc.
- `imageKeys`: `image`, `img`, `picture`, `thumbnail`, etc.

Essa abordagem torna o app resiliente a pequenas variações no formato da API.

## Telas do app

### 7. Shell da navegação

Arquivo: `lib/screens/home_shell.dart`

- Define a navegação principal em duas abas:
  - Início
  - Buscar
- Usa `IndexedStack` para manter o estado das telas ao alternar entre abas.
- A barra inferior é um `NavigationBar` com ícones e labels.

### 8. Tela inicial

Arquivo: `lib/screens/home_screen.dart`

- Renderiza o banner de boas-vindas.
- Lista as 16 categorias em um `SliverGrid`.
- Quando o usuário toca em uma categoria, navega para `CategoryScreen`.
- Utiliza componentes reutilizáveis da pasta `widgets`.

### 9. Tela de categoria

Arquivo: `lib/screens/category_screen.dart`

- Carrega os dados de uma categoria específica.
- Exibe:
  - cabeçalho com nome e emoji
  - banner principal
  - quadro de endpoints consultados
  - lista de itens
- Usa `FutureBuilder` para controlar carregamento, erro e estado vazio.
- Implementa `RefreshIndicator` para recarregar os dados da categoria com `refresh: true`.
- Ao tocar em um item, abre a `DetailSheet`.

### 10. Modal de detalhe

Arquivo: `lib/screens/detail_sheet.dart`

- Abre uma folha modal a partir da parte inferior da tela.
- Mostra:
  - imagem/emoji da categoria
  - nome do item
  - categoria e campos extras do retorno da API
  - endpoint usado para buscar o registro
- Faz uma segunda chamada `byId` para tentar obter dados mais completos do item, mesmo que a listagem tenha sido parcial.
- Mantém os dados da listagem caso a consulta de ID falhe.

### 11. Tela de busca

Arquivo: `lib/screens/search_screen.dart`

- Possui campo de texto para pesquisa.
- Permite selecionar uma categoria para buscar.
- Usa `Timer` com debounce de 400 ms para evitar consultas excessivas enquanto digita.
- Aplica o mesmo padrão de `FutureBuilder`/estado de carregamento/erro/vazio.
- Consulta o endpoint de busca da categoria selecionada, por exemplo:
  - `GET /v2/characters/en/search?name=...`
- Exibe os resultados em lista e permite abrir o detalhe do item.

## Componentes reutilizáveis

### 12. Biblioteca de widgets

Arquivo: `lib/widgets/widgets.dart`

Essa é a camada visual compartilhada da aplicação. Os principais componentes incluem:

- `HeroBanner`: banner principal com gradiente, ondas e texto.
- `AppHeader`: cabeçalho com título, botão de voltar e botão de tema.
- `CategoryThumb`: thumbnail de item, com imagem da API ou emoji como fallback.
- `Tag`: rótulo no formato de chip.
- `ItemRow`: card de lista para item da categoria.
- `EndpointBox`: painel com os endpoints da categoria.
- `EndpointPill`: mini painel do endpoint em uso na busca.
- `SectionTitle`: título de seção com estilo visual consistente.
- `LoadingView`, `EmptyView`, `ErrorView`: estados reutilizáveis do app.

Também há alguns widgets de animação:

- `Spin`: rotação contínua para o ícone de bússola.
- `Bob`: movimento vertical suave para simular flutuação.

## Serviços e estado global

### 13. Tema global e estado do app

Mesmo sem usar um gerenciador de estado complexo, o app mantém alguns estados globais simples:

- `themeController`: controle do tema e persistência local.
- `api`: cliente único para todas as chamadas da API.

Isso simplifica a arquitetura e reduz duplicação de código.

## Fluxo de dados em resumo

```text
Usuário
   ↓
HomeScreen / SearchScreen / CategoryScreen
   ↓
OnePieceApi.list / search / byId / count
   ↓
HTTP GET em https://api.api-onepiece.com/v2
   ↓
JSON bruto
   ↓
WikiItem.fromJson
   ↓
Modelos usados na UI
   ↓
Widgets e telas
```

## Tratamento de erros

A aplicação tenta tratar os cenários mais comuns:

- API indisponível
- timeout de rede
- endpoint inexistente
- resposta vazia
- JSON em formato inesperado
- falha ao carregar imagem

Quando o erro acontece, os componentes `ErrorView` e `ApiException` convertem isso em mensagens legíveis para o usuário sem quebrar a tela.

## Personalização e manutenção

### Ajustar categorias

Para corrigir um endpoint errado, basta modificar a lista em `lib/data/categories.dart`.

### Ajustar campos da API

Se a API mudar o nome dos campos (`name`, `title`, `image`, etc.), edite as listas no início de `lib/models/wiki_item.dart`.

### Alterar visual do app

Os estilos visuais estão centralizados em `lib/theme.dart` e `lib/widgets/widgets.dart`.

## Testes

Arquivo: `test/widget_test.dart`

Os testes cobrem:

- leitura de dados de `WikiItem`
- extração de nome, subtítulo e demais campos
- montagem correta dos endpoints para cada categoria

## Observações finais

Este projeto é uma aplicação Flutter relativamente enxuta, com arquitetura em camadas simples:

- dados (`data/`)
- modelo (`models/`)
- interfaces (`screens/`)
- componentes visuais (`widgets/`)
- configuração visual e global (`theme.dart`, `theme_controller.dart`)

A abordagem prioriza legibilidade, facilidade de manutenção e adaptação a uma API heterogênea, como é o caso da One Piece API.
