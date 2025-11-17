class NewMovieRequest {
  final String titulo;
  final String descricao;
  final DateTime dataLancamento;
  final int duracaoMinutos;
  final List<int> generosId;
  final String capaUrl;
  final String idUser; 

  NewMovieRequest({
    required this.titulo,
    required this.descricao,
    required this.dataLancamento,
    required this.duracaoMinutos,
    required this.generosId,
    required this.capaUrl,
    required this.idUser,
  });

  Map<String, dynamic> toJson() {
    return {
      'titulo': titulo,
      'descricao': descricao,
      'dataLancamento': dataLancamento.toIso8601String().split('T').first,
      'duracaoMinutos': duracaoMinutos,
      'generosId': generosId,
      'capaUrl': capaUrl,
      'idUser': idUser,
    };
  }
}