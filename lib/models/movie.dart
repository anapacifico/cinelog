import 'dart:convert';

// Helper para decodificar a lista da API
List<Movie> movieListFromJson(String str) =>
    List<Movie>.from(json.decode(str).map((x) => Movie.fromJson(x)));

class Movie {
  final int id;
  final String title;
  final String synopsis; // No seu DTO é 'descricao'
  final DateTime releaseDate; // No seu DTO é 'dataLancamento'
  final int durationMinutes; // No seu DTO é 'duracaoMinutos'
  final double averageRating; // No seu DTO é 'mediaAvaliacoes'
  final int likes; // No seu DTO é 'quantidadeCurtidas'
  final String backdropUrl; // No seu DTO é 'capaUrl'
  final String posterUrl; // No seu DTO é 'posterUrl'
  final List<int> genreIds; // No seu DTO é 'generos'

  Movie({
    required this.id,
    required this.title,
    required this.synopsis,
    required this.releaseDate,
    required this.durationMinutes,
    required this.averageRating,
    required this.likes,
    required this.backdropUrl,
    required this.posterUrl,
    required this.genreIds,
  });

  factory Movie.fromJson(Map<String, dynamic> json) {
    String safeUrl(String? url) {
      if (url == null || url.isEmpty) {
        return 'https://via.placeholder.com/300x450.png?text=No+Image';
      }
      // Defina sua BASE_URL aqui. Para web: localhost, para emulador: 10.0.2.2
      // const String API_BASE_URL = 'http://10.0.2.2:8081'; 
      const String API_BASE_URL = 'http://localhost:8081'; // Se for rodar na WEB

      return '$API_BASE_URL$url';
    }

    return Movie(
      id: json['id'],
      title: json['titulo'],
      synopsis: json['descricao'],
      releaseDate: DateTime.parse(json['dataLancamento']),
      durationMinutes: json['duracaoMinutos'],
      averageRating: (json['mediaAvaliacoes'] as num).toDouble(),
      likes: json['quantidadeCurtidas'],
      backdropUrl: safeUrl(json['capaUrl']), // Mapeia 'capaUrl' para 'backdropUrl'
      posterUrl: safeUrl(json['posterUrl']),
      genreIds: List<int>.from(json['generos'].map((x) => x)),
    );
  }

  // Você pode manter os campos antigos (isFeatured, etc.) se quiser
  // mas eles não virão da sua API
  bool get isFeatured =>
      true; // Lógica de mock, já que a API não tem esse campo
  int? get top10Position =>
      null; // O widget do Top10 já usa o 'index' se isso for nulo
  String get genre =>
      'Filme'; // Você teria que mapear os genreIds para nomes
}