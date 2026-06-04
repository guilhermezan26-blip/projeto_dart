class Destino {
  final int? id;
  final String cidade;
  final String hospital;
  final String tipoConsulta;
  final String observacao;

  Destino({
    this.id,
    required this.cidade,
    required this.hospital,
    required this.tipoConsulta,
    required this.observacao,
  });

  factory Destino.fromJson(Map<String, dynamic> json) {
    return Destino(
      id: json['id'] as int?,
      cidade: json['cidade'] as String,
      hospital: json['hospital'] as String,
      tipoConsulta: json['tipo_consulta'] as String,
      observacao: json['observacao'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'cidade': cidade,
        'hospital': hospital,
        'tipo_consulta': tipoConsulta,
        'observacao': observacao,
      };

  Destino copyWith({
    int? id,
    String? cidade,
    String? hospital,
    String? tipoConsulta,
    String? observacao,
  }) {
    return Destino(
      id: id ?? this.id,
      cidade: cidade ?? this.cidade,
      hospital: hospital ?? this.hospital,
      tipoConsulta: tipoConsulta ?? this.tipoConsulta,
      observacao: observacao ?? this.observacao,
    );
  }

  @override
  String toString() => '$hospital - $cidade';
}
