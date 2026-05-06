import 'paciente.dart';
import 'veiculo.dart';
import 'motorista.dart';

class Agendamento {
  final Paciente paciente;
  final Veiculo veiculo;
  final Motorista motorista;
  final String destino;
  final DateTime dataHora;
  final String observacao;

  Agendamento({
    required this.paciente,
    required this.veiculo,
    required this.motorista,
    required this.destino,
    required this.dataHora,
    required this.observacao,
  });
}