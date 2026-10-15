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
interface e os textos dos itens acompanham o idioma selecionado: francês usa
os dados `/fr`, inglês usa `/en`, e pt-BR usa `/en` como origem e traduz os
textos no próprio aparelho. Como a API pode misturar idiomas até no mesmo
registro de personagem, o app identifica o idioma de cada texto antes de
traduzir. Inglês, francês e português são reconhecidos; títulos, campos
canônicos, nomes próprios e siglas são preservados. Se não for possível
identificar um texto, usa-se como alternativa o idioma esperado da API. O
primeiro uso de cada par de idiomas precisa de internet para baixar os modelos
de tradução; a identificação e as traduções seguintes são feitas no aparelho.
As traduções ficam em cache durante a sessão, e os modelos baixados permanecem
no dispositivo.

A interface também inclui uma splash screen animada antes da tela inicial,
seletor persistente de idioma e tema claro/escuro. Os caminhos técnicos dos
endpoints são usados internamente e não são exibidos nas telas.

## Instalação e execução (Android)

A plataforma Android está configurada no repositório. Os passos abaixo partem
de um computador Windows; instale os componentes uma vez e depois siga para
"Preparar e executar o projeto" sempre que baixar uma cópia nova.

### 1. Instalar as ferramentas

1. Instale o **Git for Windows**: https://git-scm.com/download/win
2. Instale o **Flutter SDK stable** seguindo o guia oficial para Windows:
   https://docs.flutter.dev/get-started/install/windows/mobile
   Extraia-o em uma pasta sem espaços, por exemplo `C:\src\flutter`, e adicione
   a pasta `bin` do Flutter ao `PATH`.
3. Instale o **Android Studio**:
   https://developer.android.com/studio
   No assistente inicial, instale o Android SDK. Em **Tools > SDK Manager**,
   confirme que estão instalados Android SDK Platform, Android SDK Platform-
   Tools e Android SDK Command-line Tools (latest).
4. Instale o **JDK 17** (o JDK incluído no Android Studio também serve) e
   confirme que `JAVA_HOME` aponta para ele.
5. Feche e reabra o terminal e aceite as licenças Android:

```powershell
flutter doctor --android-licenses
```

Responda `y` às licenças que aceitar. Depois valide a instalação:

```powershell
flutter doctor -v
```

Resolva os itens marcados como ausentes na seção Android toolchain antes de
continuar.

### 2. Obter o projeto e instalar dependências

No PowerShell, clone o repositório e entre na pasta do app:

```powershell
git clone https://github.com/MikaelCosta303/grand_line_wikidelicia.git
Set-Location .\grand_line_wikidelicia\grand_line_wiki
flutter pub get
```

Se já recebeu o código como arquivo ou pasta, não precisa clonar: abra um
terminal na pasta `grand_line_wiki` (a pasta que contém `pubspec.yaml`) e rode
`flutter pub get`.

O Flutter resolve e instala as dependências declaradas no `pubspec.yaml`,
incluindo os plugins de tradução e identificação de idioma, acesso HTTP,
armazenamento local e abertura de links. Não é necessário instalá-las
manualmente.

### 3. Executar em emulador

1. No Android Studio, abra **Device Manager**.
2. Crie um dispositivo virtual Android, baixe a imagem de sistema sugerida e
   inicie o emulador.
3. Na pasta `grand_line_wiki`, execute:

```powershell
flutter devices
flutter run
```

Se houver mais de um dispositivo, use o ID mostrado por `flutter devices`:

```powershell
flutter run -d <id-do-emulador>
```

### 4. Executar em um celular Android

1. Ative as **Opções do desenvolvedor** e a **Depuração USB** no celular.
2. Conecte-o ao computador por USB e aceite no telefone a autorização de
   depuração apresentada.
3. Confirme que `flutter devices` lista o aparelho e inicie:

```powershell
flutter devices
flutter run -d <id-do-celular>
```

O comando compila, instala e abre o app. A primeira compilação Android pode
levar alguns minutos enquanto Gradle baixa os componentes necessários.

### Tradução no primeiro uso

O app precisa de internet para consultar a API e, no primeiro uso de cada par
de idiomas de tradução, baixar os modelos do ML Kit. Os downloads são feitos
pelo próprio app; não há configuração nem chave de API de tradução para criar.
Depois que os modelos forem baixados, identificação e tradução são feitas no
aparelho. Os textos continuam sendo obtidos da API quando as telas são
carregadas.

### Gerar APK e validar

Para gerar um APK de depuração:

```powershell
flutter build apk --debug
```

Arquivo gerado: `build\app\outputs\flutter-apk\app-debug.apk`. Para instalá-lo
em um telefone conectado com ADB:

```powershell
adb install -r .\build\app\outputs\flutter-apk\app-debug.apk
```

Para verificar o código antes de executar:

```powershell
flutter analyze
flutter test
```

### Plataformas

Este repositório está pronto para executar no **Android**. O diretório de
projeto iOS não está configurado; criar uma versão iOS exige macOS, Xcode e
configuração/validação própria dos plugins ML Kit. Os plugins de identificação
e tradução usados pelo app são nativos de Android/iOS, portanto build Web ou
desktop não está configurado nem suportado pela configuração atual.

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

## Dados, tradução e imagens

Cada recurso da API tem campos diferentes. O app reconhece URLs de imagem em
chaves como `image`, `img`, `picture`, `thumbnail` e `filename`. Atualmente,
as frutas incluem imagens no campo `filename`; os dados consultados de
personagens, arcos e espadas não incluem retratos ou ilustrações em cada item.
Quando a API não fornece uma imagem, o app tenta encontrar uma imagem
correspondente no One Piece Wiki (Fandom) usando o título exato do artigo e,
em seguida, no Wikimedia Commons. No Fandom, só aceita arquivos com licença
aberta reconhecida e explicitamente declarada; no Commons, exige o nome
canônico completo no título, contexto de One Piece e evidências compatíveis
com a categoria, além de licença permitida (CC0, domínio público, CC BY ou
CC BY-SA). Licenças ausentes, não verificáveis ou restritivas são rejeitadas.

Imagens aceitas e seus metadados de atribuição são salvos no armazenamento
interno do app para reuso offline. A primeira busca requer conexão. Nem todos
os itens têm imagem apropriada; quando a correspondência ou a licença não
puder ser confirmada, o app mostra o emoji da categoria. O detalhe inclui
créditos e links da fonte/licença. O cache é removido ao limpar os dados do
app ou desinstalá-lo.

Na localização de textos, a API é a fonte de inglês e francês. Em pt-BR, o
ML Kit identifica o idioma de cada campo e traduz texto descritivo e rótulos
no dispositivo. Os modelos de tradução são obtidos sob demanda; nenhum texto é
enviado a um serviço de tradução remoto. Títulos e campos identificados como
nomes, siglas ou nomenclaturas canônicas não são traduzidos. Em textos
ambíguos, a identificação pode recorrer ao idioma esperado da API. Se a
tradução falhar, o app conserva o original e indica que ela está indisponível.

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
  data/commons_image_service.dart busca, licenças e cache de imagens
  services/description_translation_service.dart identificação/tradução local
  models/wiki_item.dart     item genérico da resposta
  screens/                  splash, início, categoria, busca e detalhe
  widgets/                  textos localizados, imagens e componentes da UI
test/widget_test.dart       testes do modelo, idiomas e categorias
```

O app usa `google_mlkit_language_id` para identificar o idioma de cada texto,
`google_mlkit_translation` para tradução local, `path_provider` para localizar
o armazenamento persistente e `url_launcher` para abrir créditos e licenças.
As dependências são instaladas com `flutter pub get`.

## Documentação técnica

A documentação detalhada de cada módulo, fluxo de dados e arquitetura do app está em [DOCUMENTACAO.md](DOCUMENTACAO.md).
