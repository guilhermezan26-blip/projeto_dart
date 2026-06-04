class Motorista {
  final int? id;
  final String nome;
  final String cnh;
  final String telefone;

  Motorista({
    this.id,
    required this.nome,
    required this.cnh,
    required this.telefone,
  });

  factory Motorista.fromJson(Map<String, dynamic> json) {
    return Motorista(
      id: json['id'] as int?,
      nome: json['nome'] as String,
      cnh: json['cnh'] as String,
      telefone: json['telefone'] as String,
    );
  }

  Map<String, dynamic> toJson() => {
        'nome': nome,
        'cnh': cnh,
        'telefone': telefone,
      };

  Motorista copyWith({int? id, String? nome, String? cnh, String? telefone}) {
    return Motorista(
      id: id ?? this.id,
      nome: nome ?? this.nome,
      cnh: cnh ?? this.cnh,
      telefone: telefone ?? this.telefone,
    );
  }
}
