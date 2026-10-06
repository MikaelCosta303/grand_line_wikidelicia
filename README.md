# Grand Line Wiki

Wiki de **One Piece** feita em Flutter, baseada em um wireframe mobile de alta
fidelidade. O app consome a [One Piece API](https://api-onepiece.com/en) (API
não oficial) e organiza o conteúdo em 16 categorias: personagens, Akuma no Mi,
bandos, espadas, sagas, episódios e mais.

> O código do app fica na pasta [`grand_line_wiki/`](grand_line_wiki).

## Funcionalidades

- **Início:** banner de boas-vindas e grade com as 16 categorias.
- **Categoria:** banner com a contagem de itens, quadro "Endpoints consultados"
  e a lista vinda da API. Puxe para baixo para atualizar.
- **Detalhe:** janela que sobe por baixo com todos os campos do item e o
  endpoint consultado.
- **Buscar:** busca por nome com filtro de categoria. Consulta a API enquanto
  você digita (com espera de 400 ms depois da última tecla).
- **Tema claro/escuro:** botão no topo alterna o tema, e a escolha fica salva
  no aparelho.

## Tecnologias

| Item | Uso |
| --- | --- |
| [Flutter](https://flutter.dev) (Dart `>=3.5.0 <4.0.0`) | Interface, Material 3 |
| [`http`](https://pub.dev/packages/http) | Chamadas à API |
| [`google_fonts`](https://pub.dev/packages/google_fonts) | Fontes Pirata One (títulos) e Nunito (texto) |
| [`shared_preferences`](https://pub.dev/packages/shared_preferences) | Guardar o tema escolhido |

## Como rodar

Pré-requisito: [Flutter instalado](https://docs.flutter.dev/get-started/install)
com um SDK Dart compatível.

```bash
git clone https://github.com/MikaelCosta303/grand_line_wikidelicia.git
cd grand_line_wikidelicia/grand_line_wiki
flutter pub get
flutter run            # escolha o dispositivo na lista
```

Para rodar numa plataforma específica: `flutter run -d chrome` (web) ou
`flutter run -d windows`.

### Android e iOS

O repositório traz as pastas `web/` e `windows/`, mas **não** `android/` nem
`ios/`. Para gerá-las, rode dentro de `grand_line_wiki/`:

```bash
flutter create . --project-name grand_line_wiki --platforms=android,ios
```

O comando não sobrescreve arquivos que já existem.

**Android, versão de release:** confirme que
`android/app/src/main/AndroidManifest.xml` tem a permissão de internet (o
Flutter só a inclui por padrão nos modos debug e profile):

```xml
<uses-permission android:name="android.permission.INTERNET"/>
```

## Testes

```bash
cd grand_line_wiki
flutter test
```

Os testes (`test/widget_test.dart`) cobrem a leitura de dados do `WikiItem`
(nome, subtítulo, etiqueta, id, imagem e valores aninhados) e a montagem dos
quatro endpoints das 16 categorias.

## Como o app funciona

```
Tela  ──►  api (OnePieceApi)  ──►  One Piece API
 ▲              │
 │              ▼
 └─────  WikiItem (item genérico)
```

1. As telas (`screens/`) pedem dados à instância `api` de `OnePieceApi`.
2. `OnePieceApi` monta a URL a partir do `slug` da categoria, faz o GET
   (limite de 20 s), converte falhas em `ApiException` com mensagem em
   português e guarda a lista de cada categoria em cache na memória.
3. Cada resposta vira uma lista de `WikiItem`. Como cada recurso da API tem
   campos diferentes, o `WikiItem` não depende de um formato fixo: procura
   nome, subtítulo, etiqueta e imagem em chaves comuns e mostra todos os
   campos simples no detalhe.
4. Os componentes de `widgets/` desenham banner, cards, estados de
   carregamento/vazio/erro e o quadro de endpoints.

### Endpoints consultados

Base: `https://api.api-onepiece.com/v2`

| Ação | Caminho |
| --- | --- |
| Listar | `/{recurso}/en` |
| Por ID | `/{recurso}/en/{id}` |
| Buscar | `/{recurso}/en/search?name=` |
| Contagem | `/{recurso}/en/count` |

## Estrutura do projeto

```
grand_line_wiki/
├── lib/
│   ├── main.dart                 ponto de entrada; carrega o tema e monta o app
│   ├── theme.dart                paletas clara/escura, fontes e gradientes
│   ├── theme_controller.dart     tema claro/escuro salvo no aparelho
│   ├── data/
│   │   ├── categories.dart       as 16 categorias e seus caminhos (slugs)
│   │   └── api_service.dart      cliente da API (listar, por ID, buscar, contagem)
│   ├── models/
│   │   └── wiki_item.dart        item genérico da resposta da API
│   ├── screens/
│   │   ├── home_shell.dart       abas Início e Buscar (barra inferior)
│   │   ├── home_screen.dart      grade de categorias
│   │   ├── category_screen.dart  lista de uma categoria
│   │   ├── detail_sheet.dart     janela de detalhe do item
│   │   └── search_screen.dart    busca com filtro de categoria
│   └── widgets/
│       └── widgets.dart          banner, cabeçalho, cards, caixas de endpoint, estados
├── test/widget_test.dart         testes do modelo e das categorias
├── web/  windows/                pastas das plataformas já incluídas
└── pubspec.yaml                  dependências do projeto
```

## Ajustes comuns

**Uma categoria mostra "endpoint não encontrado".** Só os recursos
`characters` e `fruits` foram confirmados na documentação da API; os outros 14
seguem o mesmo padrão, mas os nomes são suposições. Corrija o `slug` da
categoria em `lib/data/categories.dart`, que é o único lugar onde ele aparece.
A lista oficial de recursos está em
[documentation.api-onepiece.com](https://documentation.api-onepiece.com).

**Nome, subtítulo, etiqueta ou imagem não aparecem como esperado.** Ajuste as
listas de chaves no início de `lib/models/wiki_item.dart` (`_titleKeys`,
`_subtitleKeys`, `_tagKeys`, `_imageKeys`) para os nomes de campo que a API
realmente usa.

**Mudar as cores.** As paletas clara e escura ficam em `lib/theme.dart`, na
classe `Palette`.

## Documentação do código

Todo o código em `lib/` tem comentários no formato dartdoc (`///`). Para gerar
um site de documentação navegável:

```bash
cd grand_line_wiki
dart doc
```

O resultado vai para `grand_line_wiki/doc/api`.

## Créditos e aviso

Os dados vêm da [One Piece API](https://api-onepiece.com/en), uma API não
oficial. One Piece © Eiichiro Oda.
