class Paciente {
  final int? id;
  final String nome;
  final String sus;
  final String telefone;

  Paciente({
    this.id,
    required this.nome,
    required this.sus,
    required this.telefone,
  });

  factory Paciente.fromJson(Map<String, dynamic> json) {
    return Paciente(
      id: json['id'] as int?,
      nome: json['nome'] as String,
      sus: json['sus'] as String,
      telefone: json['telefone'] as String,
    );
  }

  Map<String, dynamic> toJson() => {
        'nome': nome,
        'sus': sus,
        'telefone': telefone,
      };

  Paciente copyWith({int? id, String? nome, String? sus, String? telefone}) {
    return Paciente(
      id: id ?? this.id,
      nome: nome ?? this.nome,
      sus: sus ?? this.sus,
      telefone: telefone ?? this.telefone,
    );
  }
}
