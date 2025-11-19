class Avaliacao {
  final int id;
  final double rating;
  final String comment;
  final String idUser;
  final String username;
  final int filmeId;
  final String filmeTitle;
  final int qtdCurtidas;
  final DateTime criadoEm;
  final bool curtidoPeloUsuario;
  final List<String> usuariosCurtiram;

  Avaliacao({
    required this.id,
    required this.rating,
    required this.comment,
    required this.idUser,
    required this.username,
    required this.filmeId,
    required this.filmeTitle,
    required this.qtdCurtidas,
    required this.criadoEm,
    this.curtidoPeloUsuario = false,
    this.usuariosCurtiram = const [],
  });

  factory Avaliacao.fromJson(Map<String, dynamic> json) {
    return Avaliacao(
      id: json['id'],
      rating: (json['rating'] as num).toDouble(),
      comment: json['comment'] ?? '',
      idUser: json['idUser'] ?? '',
      username: json['username'] ?? 'Usuário Anônimo',
      filmeId: json['filmeId'],
      filmeTitle: json['filmeTitle'] ?? '',
      qtdCurtidas: json['qtdCurtidas'] ?? 0,
      criadoEm: DateTime.parse(json['criadoEm']),
      curtidoPeloUsuario: json['curtidoPeloUsuario'] ?? false,
      usuariosCurtiram: List<String>.from(json['usuariosCurtiram'] ?? []),
    );
  }

  Map<String, dynamic> toJson() => {
        'rating': rating,
        'comment': comment,
        'idUser': idUser,
        'username': username,
        'filmeId': filmeId,
      };
}
