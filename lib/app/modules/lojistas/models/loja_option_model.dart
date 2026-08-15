class LojaOptionModel {
  final int id;
  final String nome;

  const LojaOptionModel({required this.id, required this.nome});

  factory LojaOptionModel.fromJson(Map<String, dynamic> json) {
    return LojaOptionModel(
      id: json['id'] as int,
      nome: json['nome'] ?? '',
    );
  }
}
