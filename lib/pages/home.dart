import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:CineLog/models/movie.dart';
import 'package:CineLog/pages/AddMoviePage.dart';
import 'package:CineLog/pages/movie.detail.dart';
import 'package:CineLog/pages/profile.dart';
import 'package:CineLog/services/dio_service.dart';
const Color kCinelogPrimary = Color.fromARGB(255, 216, 21, 7);

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _dioService = DioService();

  List<Movie> _top10Filmes = [];
  List<Movie> _recentesFilmes = [];
  List<Movie> _generoComediaFilmes = [];
  List<Movie> _generoAcaoFilmes = [];

  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchData(); 
  }

  Future<void> _fetchData() async {
    try {
      setState(() {
        _isLoading = true; 
        _errorMessage = null;
      });

      try {
        final recentesResponse = await _dioService.dio.get('/api/filmes/recentes');
        final List<dynamic> recentesData = recentesResponse.data;
        setState(() {
          _recentesFilmes =
              recentesData.map((data) => Movie.fromJson(data)).toList();
        });
      } catch (e) {
        print('Erro ao carregar recentes: $e');
      }

      try {
        final responses = await Future.wait([
          _dioService.dio.get('/api/filmes/top10'),
          _dioService.dio.get('/api/filmes/genero/Comédia'),
          _dioService.dio.get('/api/filmes/genero/Ação'),
        ]);

        final List<dynamic> top10Data = responses[0].data;
        final List<dynamic> generoData = responses[1].data['content'];
        final List<dynamic> generoAcaoData = responses[2].data['content'];

        setState(() {
          _top10Filmes = top10Data.map((data) => Movie.fromJson(data)).toList();
          _generoComediaFilmes =
              generoData.map((data) => Movie.fromJson(data)).toList();
          _generoAcaoFilmes =
              generoAcaoData.map((data) => Movie.fromJson(data)).toList();
          
          _isLoading = false;
        });
      } catch (e) {
        print('Erro ao carregar outros filmes: $e');
        setState(() {
          _isLoading = false;
        });
      }
    } on DioException catch (e) {
      setState(() {
        _errorMessage = 'Falha ao carregar filmes: ${e.message}';
        _isLoading = false;
      });
      print('Erro Dio: $e');
    } catch (e) {
      setState(() {
        _errorMessage = 'Ocorreu um erro inesperado: $e';
        _isLoading = false;
      });
      print('Erro genérico: $e');
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('CineLog'),
        actions: [
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ProfilePage()),
              );
            },
            child: Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Icon(
                Icons.person_outline,
                color: Colors.white,
                size: 28,
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddMoviePage()),
          ).then((_) {
            _fetchData();
          });
        },
        backgroundColor: kCinelogPrimary,
        child: const Icon(Icons.add),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation(kCinelogPrimary),
        ),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, color: Colors.red, size: 50),
              const SizedBox(height: 16),
              Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white70),
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: _fetchData, 
                icon: const Icon(Icons.refresh),
                label: const Text('Tentar Novamente'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: kCinelogPrimary,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _fetchData,
      color: kCinelogPrimary,
      child: ListView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.only(bottom: 24),
        children: [
          _buildSectionTitle('Em destaque'),
          _FeaturedCarousel(movies: _recentesFilmes), 

          _buildSectionTitle('Adicionados recentemente'),
          _HorizontalMovieList(movies: _recentesFilmes),

          _buildSectionTitle('Comédias'),
          _HorizontalMovieList(movies: _generoComediaFilmes),

          _buildSectionTitle('Ação'), 
          _HorizontalMovieList(movies: _generoAcaoFilmes),

          _buildSectionTitle('Top 10 do CineLog'),
          _Top10List(movies: _top10Filmes),
        ],
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

class _FeaturedCarousel extends StatefulWidget {
  final List<Movie> movies;

  const _FeaturedCarousel({required this.movies});

  @override
  State<_FeaturedCarousel> createState() => _FeaturedCarouselState();
}

class _FeaturedCarouselState extends State<_FeaturedCarousel> {
  late final PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: 0.85);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _goToPrevious() {
    _pageController.previousPage(
        duration: const Duration(milliseconds: 260), curve: Curves.easeOut);
  }

  void _goToNext() {
    _pageController.nextPage(
        duration: const Duration(milliseconds: 260), curve: Curves.easeOut);
  }

  @override
  Widget build(BuildContext context) {
    if (widget.movies.isEmpty) return const SizedBox.shrink();

    return SizedBox(
      height: 260,
      child: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(
              parent: PageScrollPhysics(),
            ),
            itemCount: widget.movies.length,
            itemBuilder: (context, index) {
              final movie = widget.movies[index];

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
                        _MovieImage(url: movie.posterUrl),
                        Container(
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [Colors.transparent, Colors.black87],
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
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
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
          if (widget.movies.length > 1) ...[
            Positioned(
                left: 0,
                top: 0,
                bottom: 0,
                child: Center(
                    child: _ArrowButton(
                        icon: Icons.chevron_left, onTap: _goToPrevious))),
            Positioned(
                right: 0,
                top: 0,
                bottom: 0,
                child: Center(
                    child: _ArrowButton(
                        icon: Icons.chevron_right, onTap: _goToNext))),
          ],
        ],
      ),
    );
  }
}

class _HorizontalMovieList extends StatefulWidget {
  final List<Movie> movies;

  const _HorizontalMovieList({required this.movies});

  @override
  State<_HorizontalMovieList> createState() => _HorizontalMovieListState();
}

class _HorizontalMovieListState extends State<_HorizontalMovieList> {
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollBy(double offset) {
    if (!_scrollController.hasClients) return;
    final position = _scrollController.position;
    final target = (_scrollController.offset + offset)
        .clamp(position.minScrollExtent, position.maxScrollExtent);
    _scrollController.animateTo(
      target,
      duration: const Duration(milliseconds: 260),
      curve: Curves.easeOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.movies.isEmpty) return const SizedBox.shrink();

    return SizedBox(
      height: 200,
      child: Stack(
        children: [
          ListView.builder(
            controller: _scrollController,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: widget.movies.length,
            itemBuilder: (context, index) {
              final movie = widget.movies[index];
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
                  margin:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: _MovieImage(url: movie.backdropUrl),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        movie.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          if (widget.movies.length > 1) ...[
            Positioned(
                left: 0,
                top: 0,
                bottom: 0,
                child: Center(
                    child: _ArrowButton(
                        icon: Icons.chevron_left, onTap: () => _scrollBy(-160)))),
            Positioned(
                right: 0,
                top: 0,
                bottom: 0,
                child: Center(
                    child: _ArrowButton(
                        icon: Icons.chevron_right, onTap: () => _scrollBy(160)))),
          ],
        ],
      ),
    );
  }
}

class _Top10List extends StatefulWidget {
  final List<Movie> movies;

  const _Top10List({required this.movies});

  @override
  State<_Top10List> createState() => _Top10ListState();
}

class _Top10ListState extends State<_Top10List> {
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollBy(double offset) {
    if (!_scrollController.hasClients) return;
    final position = _scrollController.position;
    final target = (_scrollController.offset + offset)
        .clamp(position.minScrollExtent, position.maxScrollExtent);
    _scrollController.animateTo(
      target,
      duration: const Duration(milliseconds: 260),
      curve: Curves.easeOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.movies.isEmpty) {
      return const _EmptyTop10State();
    }

    return SizedBox(
      height: 270,
      child: Stack(
        children: [
          ListView.separated(
            controller: _scrollController,
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: widget.movies.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final movie = widget.movies[index];
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
          if (widget.movies.length > 1) ...[
            Positioned(
                left: 0,
                top: 0,
                bottom: 0,
                child: Center(
                    child: _ArrowButton(
                        icon: Icons.chevron_left, onTap: () => _scrollBy(-190)))),
            Positioned(
                right: 0,
                top: 0,
                bottom: 0,
                child: Center(
                    child: _ArrowButton(
                        icon: Icons.chevron_right, onTap: () => _scrollBy(190)))),
          ],
        ],
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
                  _MovieImage(url: movie.backdropUrl),
                  Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.transparent, Colors.black87],
                      ),
                    ),
                  ),
                  Positioned(
                    top: 12,
                    left: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 4),
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
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Ainda estamos selecionando o Top 10',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                SizedBox(height: 8),
                Text(
                  'Volte em breve para descobrir os filmes mais aclamados pela comunidade CineLog.',
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

class _ArrowButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _ArrowButton({
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.4),
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          size: 22,
          color: Colors.white,
        ),
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
    BoxFit? fit,
    Alignment? alignment,
  }) : fit = fit ?? BoxFit.cover,
       alignment = alignment ?? Alignment.center;

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
    );
  }
}