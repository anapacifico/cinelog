// lib/pages/home.dart
import 'package:flutter/material.dart';
import 'package:to_do_project/models/movie.dart';
import 'package:to_do_project/pages/AddMoviePage.dart';
import 'package:to_do_project/pages/movie.detail.dart';

const Color kCinelogPrimary = Color.fromARGB(255, 216, 21, 7);

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final featured = movies.where((m) => m.isFeatured).toList();
    final recent = movies.where((m) => m.isRecentlyAdded).toList();
    final girlsNight = movies.where((m) => m.isGirlsNight).toList();
    final top10 = movies
        .where((m) => m.top10Position != null)
        .toList()
      ..sort((a, b) => (a.top10Position ?? 999) - (b.top10Position ?? 999));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Cinelog'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 16),
            child: Icon(Icons.person_outline),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 24),
        children: [
          _buildSectionTitle('Em destaque'),
          _FeaturedCarousel(movies: featured),

          _buildSectionTitle('Adicionados recentemente'),
          _HorizontalMovieList(movies: recent),

          _buildSectionTitle('Girls Night'),
          _HorizontalMovieList(movies: girlsNight),

          _buildSectionTitle('Top 10 do Cinelog'),
          _Top10List(movies: top10),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddMoviePage()),
          );
        },
        backgroundColor: kCinelogPrimary,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class _FeaturedCarousel extends StatelessWidget {
  final List<Movie> movies;

  const _FeaturedCarousel({required this.movies});

  @override
  Widget build(BuildContext context) {
    if (movies.isEmpty) return const SizedBox.shrink();

    return SizedBox(
      height: 260,
      child: PageView.builder(
        controller: PageController(viewportFraction: 0.85),
        itemCount: movies.length,
        itemBuilder: (context, index) {
          final movie = movies[index];
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => MovieDetailPage(movie: movie),
                ),
              );
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(18),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    _MovieImage(url: movie.backdropUrl),
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
                    Positioned(
                      left: 16,
                      right: 16,
                      bottom: 16,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            movie.title,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            movie.synopsis,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 13,
                              color: Colors.white70,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _HorizontalMovieList extends StatelessWidget {
  final List<Movie> movies;

  const _HorizontalMovieList({required this.movies});

  @override
  Widget build(BuildContext context) {
    if (movies.isEmpty) return const SizedBox.shrink();

    return SizedBox(
      height: 190,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: movies.length,
        itemBuilder: (context, index) {
          final movie = movies[index];
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => MovieDetailPage(movie: movie),
                ),
              );
            },
            child: Container(
              width: 120,
              margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: _MovieImage(url: movie.posterUrl),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    movie.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 13),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _Top10List extends StatelessWidget {
  final List<Movie> movies;

  const _Top10List({required this.movies});

  @override
  Widget build(BuildContext context) {
    if (movies.isEmpty) {
      return const _EmptyTop10State();
    }

    return SizedBox(
      height: 270,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: movies.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final movie = movies[index];
          final position = movie.top10Position ?? index + 1;

          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => MovieDetailPage(movie: movie),
                ),
              );
            },
            child: _Top10Card(movie: movie, position: position),
          );
        },
      ),
    );
  }
}

class _Top10Card extends StatelessWidget {
  final Movie movie;
  final int position;

  const _Top10Card({required this.movie, required this.position});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 170,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(18),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  _MovieImage(url: movie.posterUrl),
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
                  Positioned(
                    top: 12,
                    left: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.65),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '#${position.toString().padLeft(2, '0')}',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    left: 12,
                    right: 12,
                    bottom: 12,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          movie.title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          movie.genre,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            movie.synopsis,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyTop10State extends StatelessWidget {
  const _EmptyTop10State();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1F1F1F),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: kCinelogPrimary.withOpacity(0.35)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.movie_filter_outlined, size: 32, color: kCinelogPrimary),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'Ainda estamos selecionando o Top 10',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Volte em breve para descobrir os filmes mais aclamados pela comunidade Cinelog.',
                  style: TextStyle(color: Colors.white70),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MovieImage extends StatelessWidget {
  final String url;
  final BoxFit fit;
  final Alignment alignment;

  const _MovieImage({
    required this.url,
    this.fit = BoxFit.cover,
    this.alignment = Alignment.center,
  });

  @override
  Widget build(BuildContext context) {
    return Image.network(
      url,
      fit: fit,
      alignment: alignment,
      width: double.infinity,
      errorBuilder: (context, error, stackTrace) => Container(
        color: const Color(0xFF1E1E1E),
        alignment: Alignment.center,
        child: const Icon(
          Icons.broken_image_outlined,
          color: Colors.white30,
          size: 32,
        ),
      ),
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        final value = loadingProgress.expectedTotalBytes != null
            ? loadingProgress.cumulativeBytesLoaded /
                loadingProgress.expectedTotalBytes!
            : null;
        return Center(
          child: CircularProgressIndicator(
            value: value,
            valueColor: const AlwaysStoppedAnimation(kCinelogPrimary),
          ),
        );
      },
    );
  }
}
