class Genero {
  final int id;
  final String nome;

  Genero({required this.id, required this.nome});

  factory Genero.fromJson(Map<String, dynamic> json) {
    return Genero(
      id: json['id'],
      nome: json['genero'],
    );
  }
}