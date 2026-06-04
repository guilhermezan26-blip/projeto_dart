class Veiculo {
  final int? id;
  final String modelo;
  final String placa;
  final String capacidade;

  Veiculo({
    this.id,
    required this.modelo,
    required this.placa,
    required this.capacidade,
  });

  factory Veiculo.fromJson(Map<String, dynamic> json) {
    return Veiculo(
      id: json['id'] as int?,
      modelo: json['modelo'] as String,
      placa: json['placa'] as String,
      capacidade: json['capacidade'] as String,
    );
  }

  Map<String, dynamic> toJson() => {
        'modelo': modelo,
        'placa': placa,
        'capacidade': capacidade,
      };

  Veiculo copyWith({
    int? id,
    String? modelo,
    String? placa,
    String? capacidade,
  }) {
    return Veiculo(
      id: id ?? this.id,
      modelo: modelo ?? this.modelo,
      placa: placa ?? this.placa,
      capacidade: capacidade ?? this.capacidade,
    );
  }
}
