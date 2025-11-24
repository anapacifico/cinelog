import 'dart:convert';
import 'package:to_do_project/constants.dart';

// Helper para decodificar a lista da API
List<Movie> movieListFromJson(String str) =>
    List<Movie>.from(json.decode(str).map((x) => Movie.fromJson(x)));

class Ator {
  final String nome;
  final String personagem;

  Ator({
    required this.nome,
    required this.personagem,
  });

  factory Ator.fromJson(Map<String, dynamic> json) {
    return Ator(
      nome: json['nome'] ?? 'Desconhecido',
      personagem: json['personagem'] ?? 'N/A',
    );
  }
}

class Movie {
  final int id;
  final String title;
  final String synopsis; 
  final DateTime releaseDate; 
  final int durationMinutes; 
  final double averageRating; 
  final int likes;
  final String backdropUrl; 
  final String posterUrl; 
  final List<int> genreIds; 
  final String? director; 
  final List<Ator>? actors; 

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
    this.director,
    this.actors,
  });

  factory Movie.fromJson(Map<String, dynamic> json) {
    String safeUrl(String? url) {
      if (url == null || url.isEmpty) {
        return 'https://via.placeholder.com/300x450.png?text=No+Image';
      }
      // ⚠️ IMPORTANTE: As imagens são privadas e precisam do token
      // Como Image Widget não suporta headers customizados em web,
      // usamos o token como query parameter
      // Isso requer que o backend aceite token via query param
      final baseUrl = '$API_BASE_URL$url';
      // Se usar token no query param: return '$baseUrl?token=\$token';
      // Por enquanto, retornamos a URL base
      return baseUrl;
    }

    String? director;
    List<Ator> actors = [];


    if (json['diretor'] != null) {
      director = json['diretor'];
    } else if (json['elenco'] != null && json['elenco'] is Map) {
      director = json['elenco']['diretor'];
    }

    if (json['atores'] != null && json['atores'] is List) {
      print('Atores encontrados (direto - array simples): ${json['atores']}');
      actors = (json['atores'] as List)
          .map((ator) {
            if (ator is String) {
              return Ator(nome: ator, personagem: 'N/A');
            } else if (ator is Map) {
              return Ator.fromJson(ator.cast<String, dynamic>());
            }
            return Ator(nome: 'Desconhecido', personagem: 'N/A');
          })
          .toList();
    } else if (json['elenco'] != null && json['elenco'] is List) {
      actors = (json['elenco'] as List)
          .map((ator) {
            if (ator is Map) {
              return Ator.fromJson(ator.cast<String, dynamic>());
            }
            return Ator(nome: 'Desconhecido', personagem: 'N/A');
          })
          .toList();
    } else if (json['elenco'] != null && 
               json['elenco'] is Map && 
               json['elenco']['atores'] != null) {
      actors = (json['elenco']['atores'] as List)
          .map((ator) => ator is Map 
              ? Ator.fromJson(ator.cast<String, dynamic>()) 
              : Ator(nome: ator.toString(), personagem: 'N/A'))
          .toList();
    } else {
    }

    return Movie(
      id: json['id'],
      title: json['titulo'],
      synopsis: json['descricao'],
      releaseDate: DateTime.parse(json['dataLancamento']),
      durationMinutes: json['duracaoMinutos'],
      averageRating: (json['mediaAvaliacoes'] as num).toDouble(),
      likes: json['quantidadeCurtidas'],
      backdropUrl: safeUrl(json['capaUrl']),
      posterUrl: safeUrl(json['posterUrl']),
      genreIds: List<int>.from(json['generos'].map((x) => x)),
      director: director,
      actors: actors,
    );
  }

  bool get isFeatured =>
      true; 
  int? get top10Position =>
      null;
  String get genre =>
      'Filme'; 
}