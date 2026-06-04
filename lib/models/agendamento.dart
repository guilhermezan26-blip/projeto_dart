import 'paciente.dart';
import 'veiculo.dart';
import 'motorista.dart';
import 'destino.dart';

class Agendamento {
  final int? id;
  final Paciente paciente;
  final Veiculo veiculo;
  final Motorista motorista;
  final Destino? destino;
  final String destinoTexto;
  final DateTime dataHora;
  final String observacao;

  Agendamento({
    this.id,
    required this.paciente,
    required this.veiculo,
    required this.motorista,
    this.destino,
    required this.destinoTexto,
    required this.dataHora,
    required this.observacao,
  });

  factory Agendamento.fromJson(Map<String, dynamic> json) {
    return Agendamento(
      id: json['id'] as int?,
      paciente: Paciente.fromJson(json['pacientes'] as Map<String, dynamic>),
      veiculo: Veiculo.fromJson(json['veiculos'] as Map<String, dynamic>),
      motorista: Motorista.fromJson(json['motoristas'] as Map<String, dynamic>),
      destino: json['destinos'] != null
          ? Destino.fromJson(json['destinos'] as Map<String, dynamic>)
          : null,
      destinoTexto: json['destino_texto'] as String? ?? '',
      dataHora: DateTime.parse(json['data_hora'] as String).toLocal(),
      observacao: json['observacao'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'paciente_id': paciente.id,
        'veiculo_id': veiculo.id,
        'motorista_id': motorista.id,
        'destino_id': destino?.id,
        'destino_texto': destinoTexto,
        'data_hora': dataHora.toUtc().toIso8601String(),
        'observacao': observacao,
      };

  String get destinoDisplay =>
      destino != null ? '${destino!.hospital} - ${destino!.cidade}' : destinoTexto;
}
