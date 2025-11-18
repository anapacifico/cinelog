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
                    _ChipInfo(icon: Icons.access_time, text: '${movie.durationMinutes} min'),
                    _ChipInfo(icon: Icons.calendar_today, text: movie.releaseDate.year.toString()),
                  ],
                ),
                const SizedBox(height: 16),

                Row(
                  children: [
                    IconButton(
                      onPressed: _toggleLike, 
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
                  movie.synopsis,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.white70,
                  ),
                ),

                if (movie.director != null && movie.director!.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  const Text(
                    'Diretor',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    movie.director!,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.white70,
                    ),
                  ),
                ],

                if (movie.actors != null && movie.actors!.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  const Text(
                    'Elenco',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ...movie.actors!.map((ator) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4.0),
                      child: Row(
                        children: [
                          const Icon(Icons.person, size: 20, color: _primary),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  ator.nome,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                Text(
                                  'como ${ator.personagem}',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.white70,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ],

                // <<< MUDANÇA: Seção de Comentários
                const SizedBox(height: 24),
                const Text(
                  'Comentários',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),

                // Formulário para adicionar novo comentário
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.withOpacity(0.3)),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextFormField(
                        controller: _comentarioController,
                        maxLines: 3,
                        minLines: 1,
                        enabled: !_isAddingComentario,
                        decoration: InputDecoration(
                          hintText: 'Adicione um comentário...',
                          hintStyle: const TextStyle(color: Colors.white60),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(color: Colors.white30),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(color: Colors.white30),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(color: _primary),
                          ),
                          contentPadding: const EdgeInsets.all(12),
                        ),
                        style: const TextStyle(color: Colors.white),
                      ),
                      const SizedBox(height: 8),
                      Align(
                        alignment: Alignment.centerRight,
                        child: ElevatedButton(
                          onPressed: _isAddingComentario ? null : _adicionarComentario,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _primary,
                            disabledBackgroundColor: Colors.grey.withOpacity(0.5),
                          ),
                          child: _isAddingComentario
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                  ),
                                )
                              : const Text('Enviar'),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // Lista de comentários existentes
                if (movie.comentarios != null && movie.comentarios!.isNotEmpty) ...[
                  ...movie.comentarios!.map((comentario) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12.0),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.white12),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  comentario.nomeUsuario,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: _primary,
                                  ),
                                ),
                                Text(
                                  _formatarData(comentario.dataCriacao),
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.white60,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              comentario.texto,
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.white70,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ] else ...[
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                    child: Center(
                      child: Text(
                        'Nenhum comentário ainda. Seja o primeiro!',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white60,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatarData(DateTime data) {
    final agora = DateTime.now();
    final diferenca = agora.difference(data);

    if (diferenca.inSeconds < 60) {
      return 'agora';
    } else if (diferenca.inMinutes < 60) {
      return '${diferenca.inMinutes}m atrás';
    } else if (diferenca.inHours < 24) {
      return '${diferenca.inHours}h atrás';
    } else if (diferenca.inDays < 7) {
      return '${diferenca.inDays}d atrás';
    } else {
      return '${data.day}/${data.month}/${data.year}';
    }
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