# Grand Line Wiki

App Flutter baseado no wireframe mobile de alta fidelidade. Consome a
[One Piece API](https://api-onepiece.com/en) (não oficial).

## Telas

- **Início:** banner de boas-vindas e a grade com as 16 categorias.
- **Categoria:** banner com a contagem de itens e a lista vinda da API (puxe para baixo para atualizar).
- **Detalhe:** janela com os dados do item, sem exibir detalhes técnicos da API.
- **Buscar:** busca com filtro por categoria, que consulta o endpoint de busca enquanto você digita.
- **Tema:** botão no topo alterna claro e escuro, e a escolha fica salva.
- **Idiomas:** menu no topo alterna entre português (Brasil), inglês e francês; a escolha fica salva.

Nomes próprios, siglas e nomenclaturas canônicas permanecem no original. A
interface e os textos descritivos dos itens acompanham o idioma selecionado:
francês usa os dados `/fr`, inglês usa `/en`, e em pt-BR os campos textuais da
API são traduzidos no próprio aparelho. Como a API pode misturar idiomas até
no mesmo registro de personagem, o app identifica o idioma de cada texto antes
de traduzi-lo. Termos identificados como nomes e siglas são preservados. O
primeiro uso de cada idioma de tradução precisa de internet para baixar os
modelos; depois, a tradução funciona no dispositivo.

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

## Rotas usadas internamente

Base: `https://api.api-onepiece.com/v2`

| Ação     | Caminho                          |
| -------- | -------------------------------- |
| Listar   | `/{recurso}/{idioma}`            |
| Por ID   | `/{recurso}/{idioma}/{id}`       |
| Buscar   | `/{recurso}/{idioma}/search?name=` |
| Contagem | `/{recurso}/{idioma}/count`      |

O idioma é `fr` para a interface francesa e `en` para inglês e português
(Brasil).

Só os recursos `characters` e `fruits` foram confirmados na documentação.
Os outros 14 seguem o mesmo padrão, mas os nomes são suposições. Se uma
categoria mostrar "endpoint não encontrado", corrija o `slug` dela em
`lib/data/categories.dart`, que é o único lugar onde ele aparece. A lista
oficial está em https://documentation.api-onepiece.com.

## Dados e imagens

Cada recurso da API tem campos diferentes. O app reconhece URLs de imagem em
chaves como `image`, `img`, `picture`, `thumbnail` e `filename`. Atualmente,
as frutas incluem imagens no campo `filename`; os dados consultados de
personagens, arcos e espadas não incluem retratos ou ilustrações em cada item.
Quando a resposta não tem imagem, o card mostra o emoji da categoria. A
normalização desses campos fica em `lib/models/wiki_item.dart`. Se a API não
fornecer uma imagem, o app procura pelo nome original no Wikimedia Commons e só
usa arquivos com licença CC0, domínio público, CC BY ou CC BY-SA. Imagens
carregadas e seus créditos/licenças ficam salvos no armazenamento do app para
reutilização offline. A busca exige conexão na primeira carga, e nem todos os
itens necessariamente têm uma imagem apropriada; os itens sem imagem continuam
com o emoji de categoria. Para reduzir correspondências incorretas, o arquivo
precisa ter o nome canônico completo no título e evidências de que pertence a
One Piece e à categoria do item; se esses sinais não forem suficientes, o app
prefere não exibir uma imagem.

Antes do Commons, o app consulta também a API MediaWiki do One Piece Wiki
(Fandom) pelo título exato do artigo e usa a imagem principal apenas quando a
página do arquivo declara explicitamente uma licença reutilizável aceita.
Arquivos com licenças ausentes, não verificadas ou de uso restrito são
descartados. Para imagens de ambas as fontes, o detalhe mostra os links e
créditos/licenças; o cache é removido ao limpar os dados do app ou desinstalá-lo.

## Estrutura

```
lib/
  main.dart                 ponto de entrada e tema
  theme.dart                cores, fontes e gradientes do wireframe
  theme_controller.dart     tema claro/escuro salvo no aparelho
  language_controller.dart  idioma selecionado e persistência local
  l10n/                     traduções em pt-BR, inglês e francês
  data/categories.dart      as 16 categorias e seus caminhos
  data/api_service.dart     cliente da API (listar, por ID, buscar, contagem)
  models/wiki_item.dart     item genérico da resposta
  screens/                  início, categoria, buscar, detalhe
  widgets/widgets.dart      banner, cabeçalho, cards e estados
test/widget_test.dart       testes do modelo, idiomas e categorias
```

## Documentação técnica

A documentação detalhada de cada módulo, fluxo de dados e arquitetura do app está em [DOCUMENTACAO.md](DOCUMENTACAO.md).
