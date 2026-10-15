# Documentação do código do Grand Line Wiki

Este documento descreve a arquitetura, os fluxos de dados e a finalidade de cada arquivo do projeto Flutter `grand_line_wiki`.

## Visão geral

O Grand Line Wiki é um app de consulta de informações sobre o universo de One Piece. Ele consulta uma API REST pública e apresenta os dados em telas organizadas por categoria, com suporte a busca, detalhamento de itens, alternância de tema claro/escuro e interface em português (Brasil), inglês e francês. A preferência de idioma fica salva no aparelho. Nomes próprios, siglas e nomenclaturas canônicas permanecem originais. Francês usa os dados da API em francês e inglês usa inglês; como a API pode misturar idiomas nos próprios registros (inclusive em `/characters/en`), o app identifica o idioma de cada texto antes de traduzi-lo para o idioma selecionado. A identificação reconhece inglês, francês e português. Títulos, nomes de campos canônicos e termos reconhecidos como nomes ou siglas são preservados. Quando o idioma de um texto curto não puder ser identificado, é usado como alternativa o idioma esperado pela API. O primeiro uso de cada par de idiomas precisa baixar os modelos necessários com conexão à internet; depois, identificação e tradução funcionam no aparelho.

O fluxo principal da aplicação é:

1. O usuário acessa a tela inicial.
2. Escolhe uma categoria (por exemplo: personagens, frutas, bandos ou espadas).
3. A tela solicita dados para a API via `OnePieceApi`.
4. O resultado é convertido em objetos `WikiItem`.
5. A UI renderiza listas, cards e detalhes com base nesses objetos.

## Estrutura do projeto

```text
grand_line_wiki/
├── lib/
│   ├── main.dart
│   ├── language_controller.dart
│   ├── theme.dart
│   ├── theme_controller.dart
│   ├── data/
│   │   ├── api_service.dart
│   │   ├── commons_image_service.dart
│   │   └── categories.dart
│   ├── services/
│   │   └── description_translation_service.dart
│   ├── models/
│   │   └── wiki_item.dart
│   ├── screens/
│   │   ├── category_screen.dart
│   │   ├── detail_sheet.dart
│   │   ├── home_screen.dart
│   │   ├── home_shell.dart
│   │   ├── search_screen.dart
│   │   └── splash_screen.dart
│   └── widgets/
│       ├── item_description.dart
│       ├── item_image.dart
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

## Preparar o ambiente e executar (Windows/Android)

O repositório já contém a configuração Android. Para configurar um computador
novo, instale:

1. **Git for Windows**: https://git-scm.com/download/win
2. **Flutter SDK stable**: siga
   https://docs.flutter.dev/get-started/install/windows/mobile. Extraia o SDK
   em um caminho sem espaços (por exemplo, `C:\src\flutter`) e adicione
   `C:\src\flutter\bin` ao `PATH`.
3. **Android Studio**: https://developer.android.com/studio. No assistente
   inicial ou em **Tools > SDK Manager**, instale Android SDK Platform,
   Android SDK Platform-Tools e Android SDK Command-line Tools (latest).
4. **JDK 17**: pode ser o JDK incluído com Android Studio. Configure `JAVA_HOME`
   para esse JDK.

Abra um novo PowerShell, aceite as licenças do SDK e verifique o ambiente:

```powershell
flutter doctor --android-licenses
flutter doctor -v
```

Aceite as licenças solicitadas e resolva os itens ausentes em Android
toolchain antes de compilar.

Clone o repositório e instale todas as dependências Flutter na pasta que
contém `pubspec.yaml`:

```powershell
git clone https://github.com/MikaelCosta303/grand_line_wikidelicia.git
Set-Location .\grand_line_wikidelicia\grand_line_wiki
flutter pub get
```

Se o projeto já estiver no computador, basta abrir o PowerShell na pasta
`grand_line_wiki` e executar `flutter pub get`. Esse comando baixa as
dependências do `pubspec.yaml`; não instale plugins Dart/Flutter separadamente.

Para executar em um emulador, inicie/crie um dispositivo virtual em **Android
Studio > Device Manager**. Para executar em um aparelho físico, habilite
Opções do desenvolvedor e Depuração USB no telefone, conecte-o por USB e
autorize o computador. Em ambos os casos, confira o ID e execute:

```powershell
flutter devices
flutter run -d <id-do-dispositivo>
```

Se só houver um dispositivo disponível, `flutter run` escolhe-o
automaticamente. A primeira compilação pode demorar enquanto Gradle instala os
componentes Android. O Flutter compila, instala e abre o aplicativo.

Para compilar e instalar manualmente um APK de depuração:

```powershell
flutter build apk --debug
adb install -r .\build\app\outputs\flutter-apk\app-debug.apk
```

Para analisar e testar antes de compartilhar alterações:

```powershell
flutter analyze
flutter test
```

É necessária conexão à internet para dados e imagens remotos. No primeiro uso
de cada par de idiomas de tradução, o ML Kit baixa os modelos de idioma; o
próprio app faz esse download e não requer chave de API de tradução. Depois, a
identificação e a tradução funcionam no dispositivo. A plataforma atualmente
configurada neste repositório é Android; iOS exige macOS, Xcode e configuração
adicional, e Web/desktop não é suportado pelos plugins nativos ML Kit usados.

## Arquitetura geral

### 1. Entrada da aplicação

Arquivo: `lib/main.dart`

- Inicializa os bindings do Flutter.
- Inicia o app com o widget `GrandLineApp`.
- Carrega o idioma e o tema salvos antes de criar a interface.
- O `GrandLineApp` escuta `themeController` e aplica o tema claro/escuro conforme a configuração ativa.
- A tela inicial da aplicação é `SplashScreen`, que apresenta a marca e faz a transição para `HomeShell`.

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
- Representar falhas como `ApiException`, com mensagens localizadas na tela.

Endpoints suportados:

- `GET /v2/{resource}/{language}`
- `GET /v2/{resource}/{language}/{id}`
- `GET /v2/{resource}/{language}/search?name=`
- `GET /v2/{resource}/{language}/count`

O código de idioma é `fr` para francês e `en` para inglês ou pt-BR. O cache
de listas separa as respostas por categoria e idioma.

Métodos principais:

- `list(Category c, {bool refresh = false})`
- `byId(Category c, String id)`
- `search(Category c, String name)`
- `count(Category c)`

A instância global `api` é exposta ao restante da aplicação para que todas as telas usem o mesmo cliente.

### 6. Idiomas, identificação e tradução dos dados

Arquivos principais:

- `lib/language_controller.dart`: mantém e persiste o idioma selecionado na interface.
- `lib/services/description_translation_service.dart`: identifica o idioma do texto e coordena a tradução local.
- `lib/widgets/item_description.dart`: widget `LocalizedText`, usado para mostrar valores traduzidos em listas e detalhes.

O seletor oferece português (Brasil), inglês e francês e salva a escolha com `SharedPreferences`. O idioma selecionado também determina os dados pedidos à API: `fr` para francês e `en` para inglês ou pt-BR. A interface em si é localizada por arquivos ARB e classes geradas em `lib/l10n/`.

A API pode misturar idiomas dentro da mesma resposta — por exemplo, um registro de personagem em `/characters/en` pode conter valores em francês. Antes de traduzir cada valor, `DescriptionTranslationService` usa o ML Kit Language Identification no aparelho para reconhecer inglês, francês ou português. Se o texto já estiver no idioma selecionado, ele é exibido sem tradução. Quando o identificador não reconhece um texto curto ou ambíguo, o serviço usa como fallback o idioma esperado da API (`en` ou `fr`).

Para traduzir, o serviço usa o ML Kit On-Device Translation. Os modelos são baixados sob demanda para cada par de idiomas necessário e reutilizados no aparelho. A primeira utilização do par requer conexão à internet; a identificação e as traduções são processadas localmente, e as traduções são mantidas em cache durante a sessão. Nenhum texto é enviado a um serviço de tradução remoto.

A tradução é aplicada a descrições, outros valores textuais descritivos e rótulos dinâmicos nos cards, resultados de busca e detalhes. Títulos não são traduzidos. Campos usados como identificadores, nomes, siglas ou nomenclaturas canônicas são excluídos; nomes próprios e siglas identificados dentro de um texto são protegidos enquanto o restante é traduzido. Em caso de erro, a interface mantém o texto original e informa que a tradução não está disponível.

Dependências relacionadas a esse fluxo:

- `google_mlkit_language_id`: detecção local do idioma de cada texto.
- `google_mlkit_translation`: tradução local e modelos de idioma.
- `shared_preferences`: persistência do idioma selecionado.

As interfaces em pt-BR, inglês e francês são mantidas nos arquivos ARB em
`lib/l10n/`; elas não dependem de tradução automática. A tradução automática
é aplicada somente aos dados textuais vindos da API. Para nomes ou expressões
que o identificador não reconheça como siglas automaticamente, `WikiItem`
também fornece termos protegidos derivados dos campos de nome, alias e título.

## Modelo de dados

### 7. Estrutura genérica dos itens da API

Arquivo: `lib/models/wiki_item.dart`

A API da One Piece é heterogênea: cada recurso tem campos diferentes. Por isso, o app não usa uma classe rígida para cada tipo de item.

A classe `WikiItem` encapsula um mapa `Map<String, dynamic>` em `raw` e expõe propriedades derivadas:

- `id`
- `title`
- `subtitle`
- `tag`
- `imageUrl`
- `description`
- `fields`
- `protectedNames`
- `subtitleFieldKey`
- `tagFieldKey`

A lógica usa listas de chaves tentativas para encontrar o nome, subtítulo, etiqueta e imagem no JSON. Exemplos:

- `titleKeys`: `name`, `title`, `roman_name`, `label`, etc.
- `subtitleKeys`: `job`, `type`, `description`, `origin`, etc.
- `tagKeys`: `bounty`, `type`, `status`, `saga`, `number`, etc.
- `imageKeys`: `image`, `img`, `picture`, `thumbnail`, `filename`, etc.

Essa abordagem torna o app resiliente a pequenas variações no formato da API.
O modelo também classifica valores que podem ser traduzidos e preserva chaves de nomes, IDs, siglas e nomenclaturas canônicas.

## Telas do app

### 8. Shell da navegação

Arquivo: `lib/screens/home_shell.dart`

- Define a navegação principal em duas abas:
  - Início
  - Buscar
- Usa `IndexedStack` para manter o estado das telas ao alternar entre abas.
- A barra inferior é um `NavigationBar` com ícones e labels.

### 9. Tela de abertura

Arquivo: `lib/screens/splash_screen.dart`

- Mostra a marca Grand Line Wiki, o indicador de carregamento e o tema/idioma já carregados na inicialização.
- Após 1,6 segundo, faz uma transição em fade para `HomeShell`.
- Não consulta a API nem bloqueia a abertura à espera de conteúdo remoto.

### 10. Tela inicial

Arquivo: `lib/screens/home_screen.dart`

- Renderiza o banner de boas-vindas.
- Lista as 16 categorias em um `SliverGrid`.
- Quando o usuário toca em uma categoria, navega para `CategoryScreen`.
- Utiliza componentes reutilizáveis da pasta `widgets`.

### 11. Tela de categoria

Arquivo: `lib/screens/category_screen.dart`

- Carrega os dados de uma categoria específica.
- Exibe:
  - cabeçalho com nome e emoji
  - banner principal
  - lista de itens
- As rotas e caminhos consultados não são exibidos na interface.
- Usa `FutureBuilder` para controlar carregamento, erro e estado vazio.
- Implementa `RefreshIndicator` para recarregar os dados da categoria com `refresh: true`.
- Ao tocar em um item, abre a `DetailSheet`.

### 12. Modal de detalhe

Arquivo: `lib/screens/detail_sheet.dart`

- Abre uma folha modal a partir da parte inferior da tela.
- Mostra:
  - imagem/emoji da categoria
  - nome do item
  - categoria e campos extras do retorno da API
- Faz uma segunda chamada `byId` para tentar obter dados mais completos do item, mesmo que a listagem tenha sido parcial.
- Mantém os dados da listagem caso a consulta de ID falhe.
- Traduz valores descritivos e rótulos de campos no idioma selecionado, identificando o idioma de origem de cada texto.
- Preserva títulos, campos identificados como nomes/categorias canônicas e siglas.
- Usa imagens já carregadas em cache local e exibe créditos/licenças do Commons quando aplicável.

### 13. Tela de busca

Arquivo: `lib/screens/search_screen.dart`

- Possui campo de texto para pesquisa.
- Permite selecionar uma categoria para buscar.
- Usa `Timer` com debounce de 400 ms para evitar consultas excessivas enquanto digita.
- Aplica o mesmo padrão de `FutureBuilder`/estado de carregamento/erro/vazio.
- Consulta o endpoint de busca da categoria selecionada, por exemplo:
  - `GET /v2/characters/{language}/search?name=...`
- Exibe os resultados em lista e permite abrir o detalhe do item.

## Componentes reutilizáveis

### 14. Biblioteca de widgets

Arquivo: `lib/widgets/widgets.dart`

Essa é a camada visual compartilhada da aplicação. Os principais componentes incluem:

- `HeroBanner`: banner principal com gradiente, ondas e texto.
- `AppHeader`: cabeçalho com título, voltar, seletor de idioma e botão de tema.
- `CategoryThumb`: thumbnail de item, com imagem da API ou emoji como fallback.
- `ItemImage`: carrega imagem local obtida da API ou de uma fonte externa aprovada; usa emoji como fallback.
- `LocalizedText`: identifica e traduz textos descritivos, subtítulos, etiquetas e rótulos no aparelho conforme o idioma selecionado.
- `Tag`: rótulo no formato de chip.
- `ItemRow`: card de lista para item da categoria.
- `SectionTitle`: título de seção com estilo visual consistente.
- `LoadingView`, `EmptyView`, `ErrorView`: estados reutilizáveis do app.

Também há alguns widgets de animação:

- `Spin`: rotação contínua para o ícone de bússola.
- `Bob`: movimento vertical suave para simular flutuação.

## Serviços e estado global

### 15. Tema global e estado do app

Mesmo sem usar um gerenciador de estado complexo, o app mantém alguns estados globais simples:

- `themeController`: controle do tema e persistência local.
- `languageController`: idioma da interface e persistência local.
- `api`: cliente único para todas as chamadas da API.
- `descriptionTranslationService`: identificação do idioma e tradução offline de textos em inglês, francês ou português para o idioma selecionado, com modelos baixados sob demanda no primeiro uso de cada par.
- `commonsImageService`: procura imagens da API, do One Piece Wiki/Fandom e do Wikimedia Commons; persiste arquivos aceitos e seus metadados em `getApplicationSupportDirectory()/item_images`.

Para imagens, o `WikiItem.imageUrl` fornecido pela API é a primeira opção. Sem imagem na resposta, o serviço consulta primeiro o artigo de título exato na API MediaWiki do One Piece Wiki (Fandom) e verifica o conteúdo de licença da página do arquivo. Só aceita licenças abertas reconhecidas e declaradas; arquivos sem licença verificável ou com licença restritiva são recusados. Se não houver imagem válida, consulta o Wikimedia Commons, onde exige o nome canônico completo no título, contexto explícito de One Piece, termos coerentes com a categoria e licença permitida (CC0, domínio público, CC BY ou CC BY-SA). Se a evidência não for suficiente, mantém o emoji em vez de exibir uma correspondência duvidosa.

As imagens aceitas e respectivos créditos/licenças ficam em cache persistente para uso offline depois da primeira carga. O cache usa uma chave versionada para não reaproveitar imagens obtidas com critérios antigos. A tela de detalhe apresenta a fonte, o crédito e links para o arquivo e licença. `path_provider` localiza o armazenamento do app e `url_launcher` abre os links. Limpar os dados do app ou desinstalá-lo remove esse cache.

Dependências relacionadas às imagens:

- `path_provider`: caminho do armazenamento persistente privado do app.
- `url_launcher`: abertura das páginas de arquivo e licença.
- `http`: consulta das APIs MediaWiki e download dos arquivos.

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
- ausência de tradução ou de imagem compatível
- idioma de um campo curto não identificado, com uso do idioma esperado da API como fallback

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
- troca e persistência da preferência de idioma
- preservação de nomes e siglas, com tradução de campos descritivos e rótulos
- identificação de idiomas diferentes em campos de personagens e tradução para o idioma selecionado
- abertura da tela inicial a partir da splash screen
- cache persistente de imagens licenciadas e atribuição
- aceitação de imagem Fandom somente quando a licença aberta e a atribuição exigida puderem ser verificadas
- rejeição de imagens do Fandom sem licença reutilizável
- rejeição de imagens do Commons sem evidência compatível de nome/categoria/licença
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
