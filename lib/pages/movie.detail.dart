import 'package:flutter/material.dart';
import 'package:to_do_project/models/movie.dart';

// ⚠️ IMPORTANTE: Você vai precisar do 'dio' para o botão de curtir
import 'package:dio/dio.dart';

// ⚠️ Defina a base URL da sua API
// Use 10.0.2.2 para o Emulador Android
// const String API_BASE_URL = 'http://10.0.2.2:8081';
// Use localhost para rodar na web
const String API_BASE_URL = 'http://localhost:8081';

class MovieDetailPage extends StatefulWidget {
  final Movie movie;

  const MovieDetailPage({super.key, required this.movie});

  @override
  State<MovieDetailPage> createState() => _MovieDetailPageState();
}

class _MovieDetailPageState extends State<MovieDetailPage> {
  bool _isLiked = false;
  late int _likes;

  static const _primary = Color.fromARGB(255, 216, 21, 7);
  
  // <<< MUDANÇA: Adiciona o Dio para chamadas de API
  final Dio _dio = Dio(BaseOptions(baseUrl: API_BASE_URL));

  @override
  void initState() {
    super.initState();
    _likes = widget.movie.likes;
    // TODO: Você precisará de uma API para saber se o usuário JÁ curtiu este filme
    // _checkIfLiked(); 
  }

  // <<< MUDANÇA: O botão agora chama a API (de forma otimista)
  Future<void> _toggleLike() async {
    // 1. Atualiza a UI imediatamente (otimista)
    final bool newLikeState = !_isLiked;
    setState(() {
      _isLiked = newLikeState;
      _likes += newLikeState ? 1 : -1;
    });

    // 2. Tenta enviar a mudança para a API
    try {
      final String endpoint = '/api/v1/filmes/${widget.movie.id}/${newLikeState ? 'like' : 'unlike'}';
      
      // ⚠️ ATENÇÃO: Você precisa CRIAR este endpoint POST no seu Spring Boot
      await _dio.post(endpoint); 
      
      // Se a API funcionar, ótimo.
      
    } catch (e) {
      // 3. Se a API falhar, reverte a mudança na UI
      print('Erro ao atualizar curtida: $e');
      setState(() {
        _isLiked = !newLikeState; // Reverte
        _likes += newLikeState ? -1 : 1; // Reverte
      });
      // Mostra um snackbar de erro
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Erro ao registrar curtida. Tente novamente.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final movie = widget.movie;

    return Scaffold(
      appBar: AppBar(
        title: Text(movie.title),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: ListView(
        children: [
          // Capa grande (sem mudança)
          AspectRatio(
            aspectRatio: 16 / 9,
            child: Stack(
              fit: StackFit.expand,
              children: [
                Image.network(
                  movie.backdropUrl,
                  fit: BoxFit.cover,
                ),
                Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black87,
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Título + duração + gênero
                Text(
                  movie.title,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  children: [
                    // <<< MUDANÇA: 'durationMinutes' vem da API (OK)
                    _ChipInfo(icon: Icons.access_time, text: '${movie.durationMinutes} min'),
                    
                    // <<< MUDANÇA: Removidos 'genre' e 'director'
                    // _ChipInfo(icon: Icons.local_movies, text: movie.genre), // ❌ REMOVIDO
                    // _ChipInfo(icon: Icons.person, text: 'Dir: ${movie.director}'), // ❌ REMOVIDO

                    // (Opcional) Mostrar o ano de lançamento
                    _ChipInfo(icon: Icons.calendar_today, text: movie.releaseDate.year.toString()),
                  ],
                ),
                const SizedBox(height: 16),

                // Botão curtir + contagem (agora chama a API)
                Row(
                  children: [
                    IconButton(
                      onPressed: _toggleLike, // Chama a nova função async
                      icon: Icon(
                        _isLiked ? Icons.favorite : Icons.favorite_border,
                        color: _isLiked ? _primary : Colors.white,
                      ),
                    ),
                    Text('$_likes curtidas'),
                  ],
                ),

                const SizedBox(height: 16),
                const Text(
                  'Sinopse',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  movie.synopsis, // <<< MUDANÇA: 'synopsis' vem de 'descricao' (OK)
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.white70,
                  ),
                ),

                // ---
                // --- ❌ SEÇÕES REMOVIDAS POIS NÃO EXISTEM NA API ---
                // ---

                // const SizedBox(height: 16),
                // const Text(
                //   'Elenco',
                //   style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                // ),
                // const SizedBox(height: 8),
                // Wrap(
                //   spacing: 8,
                //   runSpacing: 8,
                //   children: movie.cast.map((actor) => Chip(...)).toList(),
                // ),

                // const SizedBox(height: 16),
                // const Text(
                //   'Comentários',
                //   style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                // ),
                // const SizedBox(height: 8),
                // ...movie.comments.map((c) => Container(...)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// _ChipInfo (Sem mudança)
class _ChipInfo extends StatelessWidget {
  final IconData icon;
  final String text;

  const _ChipInfo({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Chip(
      avatar: Icon(
        icon,
        size: 18,
        color: Colors.white,
      ),
      label: Text(text),
      backgroundColor: const Color(0xFF2C2929),
    );
  }
}