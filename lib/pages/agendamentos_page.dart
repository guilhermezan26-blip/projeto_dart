import 'package:flutter/material.dart';
import '../models/paciente.dart';
import '../models/veiculo.dart';
import '../models/motorista.dart';
import '../models/agendamento.dart';
import '../widgets/cadastro_base.dart';
import '../widgets/campo_texto.dart';
import '../utils/formatadores.dart';

class AgendamentosPage extends StatefulWidget {
  final List<Paciente> pacientes;
  final List<Veiculo> veiculos;
  final List<Motorista> motoristas;
  final List<Agendamento> agendamentos;

  const AgendamentosPage({
    super.key,
    required this.pacientes,
    required this.veiculos,
    required this.motoristas,
    required this.agendamentos,
  });

  @override
  State<AgendamentosPage> createState() => _AgendamentosPageState();
}

class _AgendamentosPageState extends State<AgendamentosPage> {
  final formKey = GlobalKey<FormState>();
  final destinoController = TextEditingController();
  final observacaoController = TextEditingController();

  Paciente? pacienteSelecionado;
  Veiculo? veiculoSelecionado;
  Motorista? motoristaSelecionado;
  DateTime? dataSelecionada;
  TimeOfDay? horaSelecionada;

  Future<void> escolherData() async {
    final data = await showDatePicker(
      context: context,
      firstDate: DateTime.now(),
      lastDate: DateTime(2035),
      initialDate: DateTime.now(),
    );

    if (data != null) {
      setState(() {
        dataSelecionada = data;
      });
    }
  }

  Future<void> escolherHora() async {
    final hora = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (hora != null) {
      setState(() {
        horaSelecionada = hora;
      });
    }
  }

  void salvar() {
    if (widget.pacientes.isEmpty ||
        widget.veiculos.isEmpty ||
        widget.motoristas.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Cadastre paciente, veículo e motorista antes do agendamento',
          ),
        ),
      );
      return;
    }

    if (!formKey.currentState!.validate()) return;

    if (pacienteSelecionado == null ||
        veiculoSelecionado == null ||
        motoristaSelecionado == null ||
        dataSelecionada == null ||
        horaSelecionada == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Preencha todos os dados do agendamento'),
        ),
      );
      return;
    }

    final dataHora = DateTime(
      dataSelecionada!.year,
      dataSelecionada!.month,
      dataSelecionada!.day,
      horaSelecionada!.hour,
      horaSelecionada!.minute,
    );

    setState(() {
      widget.agendamentos.add(
        Agendamento(
          paciente: pacienteSelecionado!,
          veiculo: veiculoSelecionado!,
          motorista: motoristaSelecionado!,
          destino: destinoController.text,
          dataHora: dataHora,
          observacao: observacaoController.text,
        ),
      );

      pacienteSelecionado = null;
      veiculoSelecionado = null;
      motoristaSelecionado = null;
      dataSelecionada = null;
      horaSelecionada = null;
      destinoController.clear();
      observacaoController.clear();
    });
  }

  void remover(int index) {
    setState(() {
      widget.agendamentos.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return CadastroBase(
      titulo: 'Agendamento de Transporte',
      form: Form(
        key: formKey,
        child: Column(
          children: [
            DropdownButtonFormField<Paciente>(
              value: pacienteSelecionado,
              decoration: decoracao('Paciente'),
              items: widget.pacientes.map((paciente) {
                return DropdownMenuItem(
                  value: paciente,
                  child: Text(paciente.nome),
                );
              }).toList(),
              onChanged: (valor) {
                setState(() {
                  pacienteSelecionado = valor;
                });
              },
            ),
            const SizedBox(height: 10),
            DropdownButtonFormField<Veiculo>(
              value: veiculoSelecionado,
              decoration: decoracao('Veículo'),
              items: widget.veiculos.map((veiculo) {
                return DropdownMenuItem(
                  value: veiculo,
                  child: Text('${veiculo.modelo} - ${veiculo.placa}'),
                );
              }).toList(),
              onChanged: (valor) {
                setState(() {
                  veiculoSelecionado = valor;
                });
              },
            ),
            const SizedBox(height: 10),
            DropdownButtonFormField<Motorista>(
              value: motoristaSelecionado,
              decoration: decoracao('Motorista'),
              items: widget.motoristas.map((motorista) {
                return DropdownMenuItem(
                  value: motorista,
                  child: Text(motorista.nome),
                );
              }).toList(),
              onChanged: (valor) {
                setState(() {
                  motoristaSelecionado = valor;
                });
              },
            ),
            campoTexto(destinoController, 'Destino'),
            campoTexto(
              observacaoController,
              'Observação',
              obrigatorio: false,
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: escolherData,
                    icon: const Icon(Icons.date_range),
                    label: Text(
                      dataSelecionada == null
                          ? 'Escolher data'
                          : formatarData(dataSelecionada!),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: escolherHora,
                    icon: const Icon(Icons.access_time),
                    label: Text(
                      horaSelecionada == null
                          ? 'Escolher hora'
                          : formatarHora(horaSelecionada!),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            FilledButton(
              onPressed: salvar,
              child: const Text('Cadastrar agendamento'),
            ),
          ],
        ),
      ),
      lista: widget.agendamentos.isEmpty
          ? const Center(child: Text('Nenhum agendamento cadastrado'))
          : ListView.builder(
              itemCount: widget.agendamentos.length,
              itemBuilder: (context, index) {
                final agendamento = widget.agendamentos[index];

                return Card(
                  child: ListTile(
                    leading: const Icon(Icons.calendar_month),
                    title: Text(agendamento.paciente.nome),
                    subtitle: Text(
                      'Destino: ${agendamento.destino}\n'
                      'Data: ${formatarDataHora(agendamento.dataHora)}\n'
                      'Motorista: ${agendamento.motorista.nome}\n'
                      'Veículo: ${agendamento.veiculo.modelo} - ${agendamento.veiculo.placa}',
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () => remover(index),
                    ),
                  ),
                );
              },
            ),
    );
  }
}