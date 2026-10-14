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

O projeto já inclui a plataforma Android. Para testar em um celular, ative a
depuração USB no aparelho, conecte-o ao computador e autorize a conexão:

```bash
flutter devices
flutter run -d <id-do-celular>
```

O `flutter run` compila, instala e abre o app no dispositivo escolhido. A tela
de abertura aparece antes da tela inicial. Para gerar um APK de depuração
manualmente:

```bash
flutter build apk --debug
```

O APK fica em `build/app/outputs/flutter-apk/app-debug.apk`.

Para desenvolver para iOS, gere a pasta `ios/` em um Mac com Xcode instalado.

Baixe as dependências com `flutter pub get`. Para iniciar o app usando o
dispositivo conectado, execute `flutter run`.

**Android, versão de release:** mantenha a permissão de internet em
`android/app/src/main/AndroidManifest.xml`:

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

## Documentação técnica

A documentação detalhada de cada módulo, fluxo de dados e arquitetura do app está em [DOCUMENTACAO.md](DOCUMENTACAO.md).
