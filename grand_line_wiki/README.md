# Grand Line Wiki

App Flutter baseado no wireframe mobile de alta fidelidade. Consome a
[One Piece API](https://api-onepiece.com/en) (não oficial).

## Telas

- **Início:** banner de boas-vindas e a grade com as 16 categorias.
- **Categoria:** banner com a contagem de itens, quadro "Endpoints consultados" e a lista vinda da API (puxe para baixo para atualizar).
- **Detalhe:** janela que sobe por baixo com todos os campos do item e o endpoint consultado.
- **Buscar:** busca com filtro por categoria, que consulta o endpoint de busca enquanto você digita.
- **Tema:** botão no topo alterna claro e escuro, e a escolha fica salva.

## Como rodar

Este pacote traz o código (`lib/`, `test/`, `pubspec.yaml`), mas não as pastas
de plataforma (`android/`, `ios/`). Gere-as dentro desta pasta:

```bash
flutter create . --project-name grand_line_wiki --platforms=android,ios
flutter pub get
flutter run
```

O `flutter create` não sobrescreve os arquivos que já existem aqui.

**Android, versão de release:** confirme que
`android/app/src/main/AndroidManifest.xml` tem a permissão de internet
(o Flutter só a coloca por padrão nos modos debug e profile):

```xml
<uses-permission android:name="android.permission.INTERNET"/>
```

## Endpoints consultados

Base: `https://api.api-onepiece.com/v2`

| Ação     | Caminho                      |
| -------- | ---------------------------- |
| Listar   | `/{recurso}/en`              |
| Por ID   | `/{recurso}/en/{id}`         |
| Buscar   | `/{recurso}/en/search?name=` |
| Contagem | `/{recurso}/en/count`        |

Só os recursos `characters` e `fruits` foram confirmados na documentação.
Os outros 14 seguem o mesmo padrão, mas os nomes são suposições. Se uma
categoria mostrar "endpoint não encontrado", corrija o `slug` dela em
`lib/data/categories.dart`, que é o único lugar onde ele aparece. A lista
oficial está em https://documentation.api-onepiece.com.

## Dados e imagens

Cada recurso da API tem campos diferentes, então o app não depende de um
formato fixo (`lib/models/wiki_item.dart`): procura nome, subtítulo e etiqueta
em chaves comuns e mostra todos os campos simples no detalhe. Se a resposta
trouxer um campo de imagem (`image`, `img`, `picture`, `thumbnail`...) com uma
URL, a imagem aparece no card; senão, entra o emoji da categoria. Se os nomes
dos campos da API forem outros, ajuste as listas de chaves no início desse arquivo.

## Estrutura

```
lib/
  main.dart                 ponto de entrada e tema
  theme.dart                cores, fontes e gradientes do wireframe
  theme_controller.dart     tema claro/escuro salvo no aparelho
  data/categories.dart      as 16 categorias e seus caminhos
  data/api_service.dart     cliente da API (listar, por ID, buscar, contagem)
  models/wiki_item.dart     item genérico da resposta
  screens/                  início, categoria, buscar, detalhe
  widgets/widgets.dart      banner, cards, caixa de endpoints, estados
test/widget_test.dart       testes do modelo e das categorias
```
