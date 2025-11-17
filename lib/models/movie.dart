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
const movies = <Movie>[
  Movie(
    id: '1',
    title: 'Crepúsculo',
    synopsis:
        'Uma adolescente se apaixona por um vampiro misterioso e vê sua vida mudar para sempre.',
    duration: '2h 2min',
    genre: 'Romance, Fantasia',
    posterUrl:
        'https://m.media-amazon.com/images/M/MV5BMTQ2NzUxMTAxN15BMl5BanBnXkFtZTcwMzEyMTIwMg@@._V1_.jpg',
    backdropUrl:
        'https://wallpapers.com/images/hd/the-twilight-saga-breaking-dawn-part-1-gruj4yd9tf1lzj39.jpg',
    cast: ['Kristen Stewart', 'Robert Pattinson', 'Taylor Lautner'],
    director: 'Catherine Hardwicke',
    comments: [
      'Clássico da adolescência!',
      'Perfeito pra maratonar numa noite chuvosa.',
    ],
    isFeatured: true,
    isRecentlyAdded: true,
    isGirlsNight: true,
    top10Position: 2,
    likes: 120,
  ),
  Movie(
    id: '2',
    title: 'Barbie',
    synopsis:
        'Barbie começa a questionar o mundo perfeito em que vive e embarca em uma jornada pelo mundo real.',
    duration: '1h 54min',
    genre: 'Comédia, Fantasia',
    posterUrl:
        'https://media.themoviedb.org/t/p/w533_and_h300_bestv2/ldFX26JW3fusyMewRoWoXYWaffw.jpg',
    backdropUrl:
        'https://brandedcontentbrasil.com.br/wp-content/uploads/2024/09/barbie.jpg',
    cast: ['Margot Robbie', 'Ryan Gosling'],
    director: 'Greta Gerwig',
    comments: [
      'Visual lindo e trilha sonora incrível!',
      'Melhor filme pra assistir com as amigas',
    ],
    isFeatured: true,
    isRecentlyAdded: true,
    isGirlsNight: true,
    top10Position: 1,
    likes: 250,
  ),
  Movie(
    id: '3',
    title: 'Meninas Malvadas',
    synopsis:
        'Uma adolescente que cresceu na África enfrenta os desafios do ensino médio americano.',
    duration: '1h 37min',
    genre: 'Comédia',
    posterUrl:
        'https://m.media-amazon.com/images/M/MV5BMjE1MDQ4MjI1OV5BMl5BanBnXkFtZTcwNzcwODAzMw@@._V1_.jpg',
    backdropUrl:
        'https://wallpapers.com/images/hd/lindsay-lohan-in-mean-girls-94332w8o49972ce5.jpg',
    cast: ['Lindsay Lohan', 'Rachel McAdams', 'Tina Fey'],
    director: 'Mark Waters',
    comments: [
      'Ícone da cultura pop!',
      'Você não pode se sentar com a gente',
    ],
    isFeatured: false,
    isRecentlyAdded: true,
    isGirlsNight: true,
    top10Position: 4,
    likes: 170,
  ),
  Movie(
    id: '4',
    title: 'A Culpa é das Estrelas',
    synopsis:
        'Dois adolescentes com câncer se apaixonam e vivem uma história de amor inesquecível.',
    duration: '2h 6min',
    genre: 'Romance, Drama',
    posterUrl:
        'https://upload.wikimedia.org/wikipedia/pt/0/08/The_Fault_in_Our_Stars_%28filme%29.jpg',
    backdropUrl:
        'https://images.justwatch.com/backdrop/179542145/s640/a-culpa-e-das-estrelas.jpg',
    cast: ['Shailene Woodley', 'Ansel Elgort'],
    director: 'Josh Boone',
    comments: [
      'Chorei do início ao fim',
      'História linda e emocionante.',
    ],
    isFeatured: true,
    isRecentlyAdded: false,
    isGirlsNight: true,
    top10Position: 3,
    likes: 210,
  ),
  Movie(
    id: '5',
    title: 'Interestelar',
    synopsis:
        'Um grupo de astronautas viaja por um buraco de minhoca em busca de um novo lar para a humanidade.',
    duration: '2h 49min',
    genre: 'Ficção científica, Drama',
    posterUrl:
        'https://m.media-amazon.com/images/M/MV5BZjdkOTU3MDktN2IxOS00OGEyLWFmMjktY2FiMmZkNWIyODZiXkEyXkFqcGdeQXVyMTMxODk2OTU@._V1_.jpg',
    backdropUrl:
        'https://images.hdqwalls.com/wallpapers/interstellar-gargantua-4k-2n.jpg',
    cast: ['Matthew McConaughey', 'Anne Hathaway', 'Jessica Chastain'],
    director: 'Christopher Nolan',
    comments: [
      'Mind blowing!',
      'Uma das melhores sci-fi já feitas.',
    ],
    isFeatured: true,
    isRecentlyAdded: false,
    isGirlsNight: false,
    top10Position: 5,
    likes: 300,
  ),
];