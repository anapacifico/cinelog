// lib/pages/movie_detail.dart
import 'package:flutter/material.dart';
import 'package:to_do_project/models/movie.dart';

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

  @override
  void initState() {
    super.initState();
    _likes = widget.movie.likes;
  }

  void _toggleLike() {
    setState(() {
      _isLiked = !_isLiked;
      _likes += _isLiked ? 1 : -1;
    });
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
          // Capa grande
          AspectRatio(
            aspectRatio: 16 / 9,
            child: Stack(
              fit: StackFit.expand,
              children: [
                Image.network(
                  movie.backdropUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    color: const Color(0xFF1E1E1E),
                    alignment: Alignment.center,
                    child: const Icon(Icons.broken_image_outlined, size: 48),
                  ),
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    final value = loadingProgress.expectedTotalBytes != null
                        ? loadingProgress.cumulativeBytesLoaded /
                            loadingProgress.expectedTotalBytes!
                        : null;
                    return Center(
                      child: CircularProgressIndicator(value: value),
                    );
                  },
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
                    _ChipInfo(icon: Icons.access_time, text: movie.duration),
                    _ChipInfo(icon: Icons.local_movies, text: movie.genre),
                    _ChipInfo(icon: Icons.person, text: 'Dir: ${movie.director}'),
                  ],
                ),
                const SizedBox(height: 16),

                // Botão curtir + contagem
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

                const SizedBox(height: 16),
                const Text(
                  'Elenco',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: movie.cast
                      .map(
                        (actor) => Chip(
                          label: Text(actor),
                          backgroundColor: const Color(0xFF2C2929),
                        ),
                      )
                      .toList(),
                ),

                const SizedBox(height: 16),
                const Text(
                  'Comentários',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                ...movie.comments.map(
                  (c) => Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2C2929),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(c),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
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
