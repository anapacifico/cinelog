import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:to_do_project/models/movie.dart';
import 'package:to_do_project/models/avaliacao.dart';
import 'package:to_do_project/services/auth_service.dart';
import 'package:to_do_project/services/dio_service.dart';

class MovieDetailPage extends StatefulWidget {
  final Movie movie;

  const MovieDetailPage({super.key, required this.movie});

  @override
  State<MovieDetailPage> createState() => _MovieDetailPageState();
}

class _MovieDetailPageState extends State<MovieDetailPage> {
  bool _isLiked = false;
  late int _likes;
  bool _isFavorite = false;
  bool _carregandoFavorite = false;
  List<Avaliacao> _avaliacoes = [];
  bool _carregandoAvaliacoes = true;

  static const _primary = Color.fromARGB(255, 216, 21, 7);
  
  final _dioService = DioService();

  @override
  void initState() {
    super.initState();
    _likes = widget.movie.likes;
    _carregarDadosFilme();
    _carregarAvaliacoes();
    _verificarFavorito();
    _verificarLike();
  }

  Future<void> _carregarDadosFilme() async {
    try {
      final response = await _dioService.dio.get('/api/filmes/${widget.movie.id}');
      
      if (response.statusCode == 200) {
        final filmeAtualizado = Movie.fromJson(response.data);
        setState(() {
          _likes = filmeAtualizado.likes;
        });
      }
    } catch (e) {
      print('Erro ao carregar dados do filme: $e');
    }
  }

  Future<void> _verificarLike() async {
    try {
      final userId = await AuthService.getUserId();
      if (userId == null) return;

      final response = await _dioService.dio.get(
        '/api/filmes/${widget.movie.id}/check-like',
        queryParameters: {'idUser': userId},
      );

      if (response.statusCode == 200) {
        setState(() {
          _isLiked = response.data['isLiked'] ?? false;
        });
      }
    } catch (e) {
      print('Erro ao verificar like: $e');
    }
  }

  Future<void> _carregarAvaliacoes() async {
    try {
      final response = await _dioService.dio.get('/api/reviews/${widget.movie.id}');
      
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data ?? [];
        
        final usuarioLogadoId = await AuthService.getUserId();
        
        setState(() {
          _avaliacoes = data.map((e) {
            final avaliacao = Avaliacao.fromJson(e);
            
            final curtidoPeloUsuarioLogado = 
                usuarioLogadoId != null && 
                avaliacao.usuariosCurtiram.contains(usuarioLogadoId);
            
            return Avaliacao(
              id: avaliacao.id,
              rating: avaliacao.rating,
              comment: avaliacao.comment,
              idUser: avaliacao.idUser,
              username: avaliacao.username,
              filmeId: avaliacao.filmeId,
              filmeTitle: avaliacao.filmeTitle,
              qtdCurtidas: avaliacao.qtdCurtidas,
              criadoEm: avaliacao.criadoEm,
              curtidoPeloUsuario: curtidoPeloUsuarioLogado,
              usuariosCurtiram: avaliacao.usuariosCurtiram,
            );
          }).toList();
          
          _carregandoAvaliacoes = false;
        });
      }
    } catch (e) {
      print('Erro ao carregar avaliações: $e');
      setState(() => _carregandoAvaliacoes = false);
    }
  }

  Future<void> _toggleLike() async {
    final bool newLikeState = !_isLiked;
    setState(() {
      _isLiked = newLikeState;
      _likes += newLikeState ? 1 : -1;
    });

    try {
      final String endpoint = '/api/filmes/${widget.movie.id}/${newLikeState ? 'like' : 'unlike'}';
      final userId = await AuthService.getUserId();
      await _dioService.dio.post(endpoint, queryParameters: {'idUser': userId}); 
      
    } catch (e) {
      print('Erro ao atualizar curtida: $e');
      setState(() {
        _isLiked = !newLikeState; 
        _likes += newLikeState ? -1 : 1;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Erro ao registrar curtida. Tente novamente.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _verificarFavorito() async {
    try {
      final userId = await AuthService.getUserId();
      if (userId == null) return;

      final response = await _dioService.dio.get(
        '/api/favorites/check',
        queryParameters: {
          'userId': userId,
          'movieId': widget.movie.id,
        },
      );

      if (response.statusCode == 200) {
        setState(() {
          _isFavorite = response.data['isFavorite'] ?? false;
        });
      }
    } catch (e) {
      print('Erro ao verificar favorito: $e');
    }
  }

  Future<void> _toggleFavorite() async {
    final novoEstado = !_isFavorite;
    setState(() {
      _isFavorite = novoEstado;
      _carregandoFavorite = true;
    });

    try {
      final userId = await AuthService.getUserId();
      if (userId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Faça login para adicionar favoritos'),
            backgroundColor: Colors.orange,
          ),
        );
        setState(() => _isFavorite = !novoEstado);
        return;
      }

      if (novoEstado) {
        await _dioService.dio.post(
          '/api/favorites/add',
          data: {
            'idUser': userId,
            'idFilme': widget.movie.id,
          },
        );
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Adicionado aos favoritos!'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        await _dioService.dio.delete(
          '/api/favorites/remove/$userId/${widget.movie.id}',
        );
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Removido dos favoritos'),
            backgroundColor: Colors.orange,
          ),
        );
      }

      setState(() => _carregandoFavorite = false);
    } catch (e) {
      setState(() {
        _isFavorite = !novoEstado;
        _carregandoFavorite = false;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _abrirModalAvaliacao() {
    showDialog(
      context: context,
      builder: (context) => _ModalAvaliacao(
        movieId: widget.movie.id,
        dio: _dioService.dio,
        onAvaliacaoAdicionada: () {
          _carregarAvaliacoes();
        },
      ),
    );
  }

  Future<void> _curtirAvaliacao(int avaliacaoId, int indexAvaliacao) async {
    final avaliacao = _avaliacoes.firstWhere((a) => a.id == avaliacaoId);
    final estaAtualmenteCurtida = avaliacao.curtidoPeloUsuario;
  
    setState(() {
      _avaliacoes[indexAvaliacao] = Avaliacao(
        id: avaliacao.id,
        rating: avaliacao.rating,
        comment: avaliacao.comment,
        idUser: avaliacao.idUser,
        username: avaliacao.username,
        filmeId: avaliacao.filmeId,
        filmeTitle: avaliacao.filmeTitle,
        qtdCurtidas: estaAtualmenteCurtida ? avaliacao.qtdCurtidas - 1 : avaliacao.qtdCurtidas + 1,
        criadoEm: avaliacao.criadoEm,
        curtidoPeloUsuario: !estaAtualmenteCurtida,
        usuariosCurtiram: avaliacao.usuariosCurtiram,
      );
    });

    try {
      final idUsuario = await AuthService.getUserId() ?? '';
      
      await _dioService.dio.post(
        '/api/reviews/$avaliacaoId/curtir',
        data: {
          'curtir': !estaAtualmenteCurtida, 
          'idUser': idUsuario,
        },
      );
      _carregarAvaliacoes();
    } catch (e) {
      setState(() {
        _avaliacoes[indexAvaliacao] = avaliacao;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao curtir: $e')),
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
                    const SizedBox(width: 16),
                    // 🆕 Botão de Favorito
                    IconButton(
                      onPressed: _carregandoFavorite ? null : _toggleFavorite,
                      icon: Icon(
                        _isFavorite ? Icons.bookmark : Icons.bookmark_border,
                        color: _isFavorite ? _primary : Colors.white,
                      ),
                    ),
                    Text(_isFavorite ? 'Favoritado' : 'Favoritar'),
                    const Spacer(),
                    ElevatedButton.icon(
                      onPressed: _abrirModalAvaliacao,
                      icon: const Icon(Icons.star),
                      label: const Text('Avaliar'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _primary,
                      ),
                    ),
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

                // Seção de Avaliações
                const SizedBox(height: 24),
                const Text(
                  'Avaliações',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),

                if (_carregandoAvaliacoes)
                  const Center(child: CircularProgressIndicator())
                else if (_avaliacoes.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                    child: Center(
                      child: Text(
                        'Nenhuma avaliação ainda. Seja o primeiro!',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white60,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                  )
                else
                  ..._avaliacoes.asMap().entries.map((entry) {
                    int index = entry.key;
                    Avaliacao avaliacao = entry.value;
                    
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
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      avaliacao.username,
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: _primary,
                                      ),
                                    ),
                                    Row(
                                      children: List.generate(5, (idx) {
                                        return Icon(
                                          idx < avaliacao.rating
                                              ? Icons.star
                                              : Icons.star_border,
                                          size: 16,
                                          color: _primary,
                                        );
                                      }),
                                    ),
                                  ],
                                ),
                                Text(
                                  _formatarData(avaliacao.criadoEm),
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.white60,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              avaliacao.comment,
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.white70,
                              ),
                            ),
                            const SizedBox(height: 8),
                            GestureDetector(
                              onTap: () => _curtirAvaliacao(avaliacao.id, index),
                              child: Row(
                                children: [
                                  Icon(
                                    avaliacao.curtidoPeloUsuario
                                        ? Icons.thumb_up
                                        : Icons.thumb_up_outlined,
                                    size: 16,
                                    color: avaliacao.curtidoPeloUsuario
                                        ? _primary
                                        : Colors.white60,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    '${avaliacao.qtdCurtidas}',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: avaliacao.curtidoPeloUsuario
                                          ? _primary
                                          : Colors.white60,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
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

class _ModalAvaliacao extends StatefulWidget {
  final int movieId;
  final Dio dio;
  final VoidCallback onAvaliacaoAdicionada;

  const _ModalAvaliacao({
    required this.movieId,
    required this.dio,
    required this.onAvaliacaoAdicionada,
  });

  @override
  State<_ModalAvaliacao> createState() => _ModalAvaliacaoState();
}

class _ModalAvaliacaoState extends State<_ModalAvaliacao> {
  double _rating = 0;
  final TextEditingController _comentarioController = TextEditingController();
  bool _carregando = false;
  static const _primary = Color.fromARGB(255, 216, 21, 7);

  @override
  void dispose() {
    _comentarioController.dispose();
    super.dispose();
  }

  Future<void> _enviarAvaliacao() async {
    if (_rating == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecione uma avaliação')),
      );
      return;
    }

    setState(() => _carregando = true);

    try {
      final idUser = await AuthService.getUserId() ?? 'Anônimo';
      
      final userData = await AuthService.getUserData();
      final username = userData?['username'] ?? 'Usuário Anônimo';
      
      await widget.dio.post(
        '/api/reviews/add',
        data: {
          'rating': _rating,
          'comment': _comentarioController.text,
          'idUser': idUser,
          'username': username,
          'idFilme': widget.movieId,
        },
      );

      widget.onAvaliacaoAdicionada();
      
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Avaliação adicionada com sucesso!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao enviar: $e')),
      );
    } finally {
      setState(() => _carregando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.grey[900],
      title: const Text('Avaliar Filme'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 16),
            const Text(
              'Nota',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (index) {
                return GestureDetector(
                  onTap: () => setState(() => _rating = (index + 1).toDouble()),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Icon(
                      index < _rating ? Icons.star : Icons.star_border,
                      size: 40,
                      color: _primary,
                    ),
                  ),
                );
              }),
            ),
            if (_rating > 0)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  'Nota: ${_rating.toStringAsFixed(1)}',
                  style: const TextStyle(color: _primary),
                ),
              ),
            const SizedBox(height: 24),
            const Text(
              'Comentário',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _comentarioController,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: 'Compartilhe sua opinião...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Colors.white30),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: _primary),
                ),
              ),
              style: const TextStyle(color: Colors.white),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: _carregando ? null : _enviarAvaliacao,
          style: ElevatedButton.styleFrom(backgroundColor: _primary),
          child: _carregando
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Enviar'),
        ),
      ],
    );
  }
}
