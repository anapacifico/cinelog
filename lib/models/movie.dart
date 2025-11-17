// lib/models/movie.dart

class Movie {
  final String id;
  final String title;
  final String synopsis;
  final String duration;
  final String genre;
  final String posterUrl;
  final String backdropUrl;
  final List<String> cast;
  final String director;
  final List<String> comments;
  final bool isFeatured;
  final bool isRecentlyAdded;
  final bool isGirlsNight;
  final int? top10Position;
  final int likes;

  const Movie({
    required this.id,
    required this.title,
    required this.synopsis,
    required this.duration,
    required this.genre,
    required this.posterUrl,
    required this.backdropUrl,
    required this.cast,
    required this.director,
    required this.comments,
    this.isFeatured = false,
    this.isRecentlyAdded = false,
    this.isGirlsNight = false,
    this.top10Position,
    this.likes = 0,
  });
}

// Lista de filmes fake pra montar a home
const List<Movie> movies = [
  Movie(
    id: 'parasite',
    title: 'Parasita',
    synopsis:
        'A família Kim encontra uma maneira de se infiltrar na vida da abastada família Park, desencadeando eventos inesperados.',
    duration: '2h 12min',
    genre: 'Suspense, Drama',
    posterUrl:
        'https://image.tmdb.org/t/p/w500/7IiTTgloJzvGI1TAYymCfbfl3vT.jpg',
    backdropUrl:
        'https://image.tmdb.org/t/p/original/ApiBzeaa95TNYliSbQ8pJv4Fje7.jpg',
    cast: ['Song Kang-ho', 'Cho Yeo-jeong', 'Choi Woo-shik'],
    director: 'Bong Joon-ho',
    comments: [
      'Satírico e afiado até o último segundo.',
      'É impossível sair indiferente.',
    ],
    isFeatured: true,
    isRecentlyAdded: true,
    top10Position: 1,
    likes: 482,
  ),

  Movie(
    id: 'cidade-de-deus',
    title: 'Cidade de Deus',
    synopsis:
        'Buscapé e Dadinho crescem na violência da favela carioca e trilham caminhos radicalmente diferentes.',
    duration: '2h 10min',
    genre: 'Crime, Drama',
    posterUrl:
        'https://upload.wikimedia.org/wikipedia/pt/1/10/Cidade_de_Deus_%28filme%29.jpg',
    backdropUrl:
        'https://images.justwatch.com/backdrop/284200978/s1440/cidade-de-deus.jpg',
    cast: ['Alexandre Rodrigues', 'Leandro Firmino', 'Douglas Silva'],
    director: 'Fernando Meirelles',
    comments: [
      'Cinema brasileiro no auge.',
      'Visualmente potente e brutal.',
    ],
    isFeatured: true,
    top10Position: 2,
    likes: 395,
  ),

  Movie(
    id: 'retrato-jovem-chamas',
    title: 'Retrato de uma Jovem em Chamas',
    synopsis:
        'No século XVIII, uma pintora é contratada para fazer o retrato de uma jovem prestes a se casar, mas surge um amor proibido.',
    duration: '2h 1min',
    genre: 'Romance, Drama',
    posterUrl:
        'https://upload.wikimedia.org/wikipedia/pt/3/3d/Portrait_de_la_jeune_fille_en_feu.png',
    backdropUrl:
        'https://images.justwatch.com/backdrop/135776730/s1440/portrait-of-a-lady-on-fire.jpg',
    cast: ['Noémie Merlant', 'Adèle Haenel'],
    director: 'Céline Sciamma',
    comments: [
      'Poético, delicado e arrebatador.',
      'Fotografia impecável.',
    ],
    isGirlsNight: true,
    isRecentlyAdded: true,
    top10Position: 3,
    likes: 268,
  ),

  Movie(
    id: 'lady-bird',
    title: 'Lady Bird',
    synopsis:
        'Christine “Lady Bird” McPherson navega a transição para a vida adulta enfrentando amizades, amor e conflitos com a mãe.',
    duration: '1h 34min',
    genre: 'Comédia dramática',
    posterUrl:
        'https://upload.wikimedia.org/wikipedia/en/6/6b/Lady_Bird_poster.jpg',
    backdropUrl:
        'https://images.justwatch.com/backdrop/174162565/s1440/lady-bird.jpg',
    cast: ['Saoirse Ronan', 'Laurie Metcalf', 'Timothée Chalamet'],
    director: 'Greta Gerwig',
    comments: [
      'Retrato honesto da adolescência.',
      'Trilha sonora deliciosa.',
    ],
    isGirlsNight: true,
    isRecentlyAdded: true,
    top10Position: 4,
    likes: 241,
  ),

  Movie(
    id: 'la-la-land',
    title: 'La La Land',
    synopsis:
        'Uma atriz e um pianista de jazz perseguem seus sonhos em Los Angeles enquanto enfrentam escolhas difíceis.',
    duration: '2h 8min',
    genre: 'Musical, Romance',
    posterUrl:
        'https://upload.wikimedia.org/wikipedia/en/a/ab/La_La_Land_%28film%29.png',
    backdropUrl:
        'https://images.justwatch.com/backdrop/245322082/s1440/la-la-land.jpg',
    cast: ['Emma Stone', 'Ryan Gosling'],
    director: 'Damien Chazelle',
    comments: [
      'Visual e música em perfeita sintonia.',
      'Um conto moderno sobre sonhos.',
    ],
    isFeatured: true,
    isGirlsNight: true,
    top10Position: 5,
    likes: 376,
  ),

  Movie(
    id: 'moonlight',
    title: 'Moonlight: Sob a Luz do Luar',
    synopsis:
        'A jornada de Chiron da infância à vida adulta enquanto descobre sua identidade e busca afeto.',
    duration: '1h 51min',
    genre: 'Drama',
    posterUrl:
        'https://upload.wikimedia.org/wikipedia/en/8/84/Moonlight_%282016_film%29.png',
    backdropUrl:
        'https://images.justwatch.com/backdrop/184012756/s1440/moonlight.jpg',
    cast: ['Mahershala Ali', 'Trevante Rhodes', 'Naomie Harris'],
    director: 'Barry Jenkins',
    comments: [
      'Sensível e poderoso.',
      'Direção impecável.',
    ],
    top10Position: 6,
    likes: 289,
  ),

  Movie(
    id: 'nomadland',
    title: 'Nomadland',
    synopsis:
        'Fern adota uma vida nômade moderna após o colapso econômico de sua cidade, cruzando os Estados Unidos em uma van.',
    duration: '1h 48min',
    genre: 'Drama',
    posterUrl:
        'https://upload.wikimedia.org/wikipedia/en/0/0a/Nomadland_poster.jpeg',
    backdropUrl:
        'https://images.justwatch.com/backdrop/241125864/s1440/nomadland.jpg',
    cast: ['Frances McDormand', 'David Strathairn'],
    director: 'Chloé Zhao',
    comments: [
      'Contemplativo e humano.',
      'Fotografia que abraça o pôr do sol americano.',
    ],
    isRecentlyAdded: true,
    top10Position: 7,
    likes: 198,
  ),

  Movie(
    id: 'godfather',
    title: 'O Poderoso Chefão',
    synopsis:
        'O patriarca da família Corleone prepara seu filho relutante para assumir os negócios da máfia.',
    duration: '2h 55min',
    genre: 'Crime, Drama',
    posterUrl: 'https://upload.wikimedia.org/wikipedia/en/1/1c/Godfather_ver1.jpg',
    backdropUrl:
        'https://images.justwatch.com/backdrop/153361336/s1440/the-godfather.jpg',
    cast: ['Marlon Brando', 'Al Pacino', 'James Caan'],
    director: 'Francis Ford Coppola',
    comments: [
      'Clássico absoluto.',
      'Cada cena é icônica.',
    ],
    isFeatured: true,
    top10Position: 8,
    likes: 520,
  ),

  Movie(
    id: 'amelie',
    title: 'O Fabuloso Destino de Amélie Poulain',
    synopsis:
        'Amélie decide mudar a vida das pessoas ao seu redor enquanto descobre a própria felicidade.',
    duration: '2h 2min',
    genre: 'Romance, Fantasia',
    posterUrl: 'https://upload.wikimedia.org/wikipedia/en/5/53/Amelie_poster.jpg',
    backdropUrl:
        'https://images.justwatch.com/backdrop/178804676/s1440/amelie.jpg',
    cast: ['Audrey Tautou', 'Mathieu Kassovitz'],
    director: 'Jean-Pierre Jeunet',
    comments: [
      'Encantador e otimista.',
      'Paris nunca esteve tão mágica.',
    ],
    isGirlsNight: true,
    top10Position: 9,
    likes: 257,
  ),

  Movie(
    id: 'whiplash',
    title: 'Whiplash: Em Busca da Perfeição',
    synopsis:
        'Um jovem baterista encara o treinamento intenso de um professor implacável para alcançar o topo do jazz.',
    duration: '1h 47min',
    genre: 'Drama, Música',
    posterUrl: 'https://upload.wikimedia.org/wikipedia/en/0/01/Whiplash_poster.jpg',
    backdropUrl:
        'https://images.justwatch.com/backdrop/178682874/s1440/whiplash.jpg',
    cast: ['Miles Teller', 'J.K. Simmons'],
    director: 'Damien Chazelle',
    comments: [
      'Intenso do começo ao fim.',
      'J.K. Simmons em seu auge.',
    ],
    isFeatured: true,
    top10Position: 10,
    likes: 344,
  ),
  
];

/// Helper pra lista de Top 10 na home
List<Movie> get top10Movies {
  final list = movies
      .where((m) => m.top10Position != null && m.top10Position! > 0)
      .toList()
    ..sort((a, b) => a.top10Position!.compareTo(b.top10Position!));

  return list.take(10).toList();
}
