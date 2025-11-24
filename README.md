# 🎬 Cinelog - Aplicação Flutter para Catálogo de Filmes

Uma aplicação Flutter moderna que consome dois microserviços independentes para gerenciar autenticação de usuários e catálogo de filmes com reviews, avaliações e sistema de favoritos.

## 🏗️ Arquitetura de Microserviços

O projeto foi desenvolvido com arquitetura de **dois microserviços especializados**:

```
┌─────────────────────────────────────────────────────────────┐
│                  APLICAÇÃO FLUTTER (CLIENT)                 │
│                                                               │
│  • Login / Cadastro                                          │
│  • Listagem de Filmes                                        │
│  • Reviews e Avaliações                                      │
│  • Favoritos e Likes                                         │
│  • Perfil do Usuário                                         │
└─────────────────────────────────────────────────────────────┘
           │                                    │
           ▼                                    ▼
┌──────────────────────────┐    ┌──────────────────────────┐
│  🔐 AUTH MICROSERVICE    │    │  🎬 FILMES MICROSERVICE  │
│  (Porta 8080)            │    │  (Porta 8081)            │
├──────────────────────────┤    ├──────────────────────────┤
│ ✅ POST /auth/register   │    │ ✅ GET /api/filmes       │
│ ✅ POST /auth/login      │    │ ✅ GET /api/filmes/{id}  │
│ ✅ Logout                │    │ ✅ POST /api/filmes      │
│                          │    │ ✅ DELETE /api/filmes/{id}
│ 📊 Banco: NoSQL          │    │ ✅ POST /api/reviews     │
│    (MongoDB)             │    │ ✅ GET /api/reviews/{id} │
│                          │    │ ✅ POST /api/favorites   │
│                          │    │ ✅ POST /api/filmes/like │
│                          │    │                          │
│                          │    │ 📊 Banco: SQL            │
│                          │    │    (PostgreSQL/MySQL)    │
└──────────────────────────┘    └──────────────────────────┘
```

### Serviço de Autenticação (NoSQL - MongoDB)
- **Porta**: 8080
- **Tecnologia**: Node.js / Spring Boot
- **Banco de Dados**: MongoDB (NoSQL)
- **Responsabilidades**:
  - Registro de novos usuários
  - Login e autenticação JWT
  - Gerenciamento de tokens
  - Dados de usuário (perfil, email, senha)

### Serviço de Filmes (SQL - PostgreSQL/MySQL)
- **Porta**: 8081
- **Tecnologia**: Node.js / Spring Boot
- **Banco de Dados**: PostgreSQL / MySQL (SQL)
- **Responsabilidades**:
  - Catálogo de filmes (CRUD)
  - Reviews e avaliações (5 estrelas)
  - Sistema de favoritos
  - Sistema de likes/curtidas
  - Filmes por gênero
  - Top 10 filmes

## 🛠️ Tecnologias Utilizadas

### Frontend
- **Flutter** 3.9.2+
- **Dart**
- **HTTP Client**: `dio` 5.4.3 (chamadas REST)
- **Storage Local**: `shared_preferences` (persistência de dados)
- **Image Picker**: `image_picker` 1.1.2 (upload de imagens)

### Backend (Infraestrutura)
- **Microserviço Auth**: Node.js / Spring Boot
  - Banco: MongoDB (NoSQL)
  - Autenticação: JWT (JSON Web Tokens)
  
- **Microserviço Filmes**: Node.js / Spring Boot
  - Banco: PostgreSQL / MySQL (SQL)
  - ORM: Hibernate / Sequelize

## 📦 Dependências do Projeto

```yaml
dependencies:
  flutter:
    sdk: flutter
  http: ^1.1.0              # Cliente HTTP alternativo
  dio: ^5.4.3+1             # Cliente HTTP principal (com interceptadores)
  image_picker: ^1.1.2      # Seleção de imagens da galeria
  mime: ^1.0.5              # Tipos MIME para uploads
  http_parser: ^4.0.2       # Parser de headers HTTP
  shared_preferences: ^2.2.2 # Persistência local (tokens, user data)
  cupertino_icons: ^1.0.8   # Ícones iOS/Material
```

## 🚀 Como Executar

### 1. Pré-requisitos
```bash
# Instalar Flutter
flutter --version

# Instalar dependências
flutter pub get
```

### 2. Configuração de Endpoints

O arquivo `lib/constants.dart` centraliza todas as configurações de URL:

```dart
// Para Android Emulador:
const String API_BASE_URL = 'http://10.0.2.2:8081';      # Microserviço Filmes
const String AUTH_BASE_URL = 'http://10.0.2.2:8080';     # Microserviço Auth

// Para Web/Desktop (descomentar):
// const String API_BASE_URL = 'http://localhost:8081';
// const String AUTH_BASE_URL = 'http://localhost:8080';
```

**Nota**: `10.0.2.2` é o IP especial do Android Emulator para acessar `localhost` da máquina host.

### 3. Executar a Aplicação

```bash
# Android Emulator
flutter run

# iOS Simulator
flutter run -d ios

# Web
flutter run -d chrome
```

## 📱 Funcionalidades Principais

### Autenticação (Serviço NoSQL)
- ✅ Registro de novo usuário
- ✅ Login com email/usuário e senha
- ✅ Logout
- ✅ Persistência de token JWT em SharedPreferences
- ✅ Recuperação de dados do usuário

**Endpoints**:
```
POST   /auth/register      # Criar conta
POST   /auth/login         # Efetuar login
POST   /auth/logout        # Desconectar
```

### Catálogo de Filmes (Serviço SQL)
- ✅ Listagem de todos os filmes
- ✅ Filtro por gênero (Ação, Comédia, Drama, etc.)
- ✅ Top 10 filmes mais bem avaliados
- ✅ Filmes recentes
- ✅ Detalhes completos do filme (sinopse, duração, atores, diretor)
- ✅ Adicionar novos filmes (com upload de imagem)
- ✅ Deletar filmes

**Endpoints**:
```
GET    /api/filmes                     # Listar todos os filmes
GET    /api/filmes/{id}                # Detalhes do filme
GET    /api/filmes/adicionados/{userId} # Filmes criados pelo usuário
POST   /api/filmes                     # Criar novo filme
DELETE /api/filmes/{id}                # Deletar filme
```

### Sistema de Avaliações (Serviço SQL)
- ✅ Avaliar filmes com nota (1-5 estrelas)
- ✅ Deixar comentário no review
- ✅ Curtir reviews de outros usuários
- ✅ Listar reviews do filme

**Endpoints**:
```
GET    /api/reviews/{filmId}           # Listar reviews do filme
POST   /api/reviews/add                # Criar novo review
POST   /api/reviews/{id}/curtir        # Curtir um review
DELETE /api/reviews/{id}               # Deletar review
```

### Sistema de Favoritos (Serviço SQL)
- ✅ Adicionar filme aos favoritos
- ✅ Remover dos favoritos
- ✅ Listar filmes favoritos
- ✅ Verificar status de favorito com ícone de coração

**Endpoints**:
```
POST   /api/favorites/add                    # Adicionar aos favoritos
DELETE /api/favorites/remove/{userId}/{movieId} # Remover dos favoritos
GET    /api/favorites/check                  # Verificar status
GET    /api/filmes/{id}/favoritos            # Listar favoritos
```

### Sistema de Likes (Serviço SQL)
- ✅ Curtir/descurtir filmes
- ✅ Contador de curtidas
- ✅ Verificação de like persistente

**Endpoints**:
```
POST   /api/filmes/{id}/like           # Curtir filme
POST   /api/filmes/{id}/unlike         # Descurtir filme
GET    /api/filmes/{id}/check-like     # Verificar status
```

### Perfil do Usuário (Serviço SQL + NoSQL)
- ✅ Exibir dados do usuário (email, nome)
- ✅ Listar filmes criados pelo usuário (paginado)
- ✅ Deletar filmes próprios
- ✅ Logout

## 🏃 Fluxo de Dados

### 1. Autenticação (NoSQL)
```
App ─────┐
         │
         ├─> Validar email/usuário ─> MongoDB
         │
         ├─> Gerar JWT ─────────────> LocalStorage (SharedPreferences)
         │
         └─> Salvar user_id e dados
```

### 2. Consumo de Filmes (SQL)
```
App ─────┐
         │
         ├─> GET /api/filmes ────────> Banco SQL (PostgreSQL/MySQL)
         │
         ├─> Desserializar JSON ────> Movie Model
         │
         └─> Renderizar na UI
```

### 3. Verificação de Estado (SQL)
```
App ─────┐
         │
         ├─> initState() ─────────────┐
         │                            │
         │         ┌──────────────────┘
         │         │
         ├─> _verificarLike() ────────> GET /api/filmes/{id}/check-like
         │
         ├─> _verificarFavorito() ───> GET /api/favorites/check
         │
         └─> setState() ─────────────> Atualizar UI
```

## 📁 Estrutura do Projeto

```
cinelog/
├── lib/
│   ├── constants.dart              # 🔑 Configurações globais (URLs dos microserviços)
│   ├── main.dart                   # Entrada da aplicação
│   │
│   ├── models/
│   │   ├── movie.dart             # Modelo de Filme
│   │   ├── avaliacao.dart         # Modelo de Avaliação/Review
│   │   ├── genero.dart            # Modelo de Gênero
│   │   └── new_movie_request.dart # DTO para criar filme
│   │
│   ├── services/
│   │   └── auth_service.dart      # 🔐 Serviço de autenticação (integra com Microserviço NoSQL)
│   │
│   └── pages/
│       ├── login.dart              # Tela de login
│       ├── cadastro.dart           # Tela de registro
│       ├── home.dart               # Tela principal com filmes
│       ├── movie.detail.dart       # Detalhes do filme + reviews
│       ├── AddMoviePage.dart       # Adicionar novo filme
│       └── profile.dart            # Perfil do usuário + gerenciar filmes
│
├── pubspec.yaml                   # Dependências do projeto
└── README.md                      # Este arquivo
```

## 🔄 Fluxo de Desenvolvimento

### 1. **Autenticação** (Microserviço NoSQL - MongoDB)
```dart
// Fazer login
final response = await AuthService.login(
  login: 'usuario@email.com',
  senha: '12345678',
);

if (response['sucesso']) {
  // Token salvo em SharedPreferences
  // Redirecionar para Home
}
```

### 2. **Listar Filmes** (Microserviço SQL)
```dart
final dio = Dio(BaseOptions(baseUrl: API_BASE_URL));
final response = await dio.get('/api/filmes');

final movies = movieListFromJson(response.data);
// Renderizar lista na UI
```

### 3. **Verificar Estado ao Carregar Página**
```dart
@override
void initState() {
  super.initState();
  _verificarLike();      // Checar se usuário curtiu o filme
  _verificarFavorito();  // Checar se está nos favoritos
}
```

## 🔐 Segurança

### Tokens JWT
- ✅ Token armazenado em `SharedPreferences` (persistência)
- ✅ Token incluído em headers `Authorization: Bearer <token>` nas requisições
- ✅ Limpeza de tokens ao fazer logout

### Validação de Entrada
- ✅ Email validado no formato correto
- ✅ Senha com requisitos mínimos
- ✅ Formulários com validação em tempo real

## 🐛 Solução de Problemas

### "Falha ao conectar ao servidor"
- Verificar se os microserviços estão rodando nas portas 8080 e 8081
- No Android Emulator, usar `10.0.2.2` em vez de `localhost`
- Na Web, usar `localhost`

### "Token inválido"
- Fazer logout e login novamente
- Verificar se o token JWT não expirou
- Limpar cache da aplicação

### "Filme não salvo"
- Verificar conexão com banco SQL
- Verificar se o usuário tem permissão para adicionar filmes
- Validar dados do formulário

## 🎨 Design e UX

- **Tema escuro** com destaque em vermelho (`#D81507`)
- **Responsivo** para diferentes tamanhos de tela
- **Animações suaves** nas transições
- **Feedback visual** com SnackBars e modais

## 📊 Banco de Dados

### Microserviço Auth (NoSQL - MongoDB)
**Coleção: users**
```json
{
  "_id": ObjectId,
  "email": "usuario@email.com",
  "nome": "João Silva",
  "senha": "hash_bcrypt",
  "createdAt": ISODate,
  "updatedAt": ISODate
}
```

### Microserviço Filmes (SQL - PostgreSQL/MySQL)
**Tabela: filmes**
```sql
CREATE TABLE filmes (
  id INT PRIMARY KEY AUTO_INCREMENT,
  title VARCHAR(255) NOT NULL,
  synopsis TEXT,
  releaseDate DATE,
  durationMinutes INT,
  averageRating DECIMAL(3,1),
  likes INT DEFAULT 0,
  backdropUrl VARCHAR(500),
  posterUrl VARCHAR(500),
  genreIds JSON,
  director VARCHAR(255),
  createdBy INT,
  createdAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE reviews (
  id INT PRIMARY KEY AUTO_INCREMENT,
  filmId INT NOT NULL,
  userId INT NOT NULL,
  rating INT CHECK (rating >= 1 AND rating <= 5),
  comment TEXT,
  likes INT DEFAULT 0,
  createdAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (filmId) REFERENCES filmes(id)
);

CREATE TABLE favorites (
  id INT PRIMARY KEY AUTO_INCREMENT,
  userId INT NOT NULL,
  filmId INT NOT NULL,
  createdAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  UNIQUE KEY (userId, filmId),
  FOREIGN KEY (filmId) REFERENCES filmes(id)
);
```

## 🚀 Deploy

### Android
```bash
flutter build apk --release
# Arquivo gerado: build/app/outputs/flutter-app.apk
```

### iOS
```bash
flutter build ios --release
```

### Web
```bash
flutter build web --release
# Servir com: python -m http.server --directory build/web
```

## 📝 Licença

Este projeto é de código aberto e está disponível sob a licença MIT.

## 👨‍💻 Desenvolvedor

Desenvolvido por **Eduardo** como projeto de portfólio.

## 📧 Contato

Para dúvidas ou sugestões, entre em contato através do GitHub.

---

**⭐ Se este projeto foi útil para você, considere dar uma estrela!**
