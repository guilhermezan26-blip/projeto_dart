import 'package:flutter/material.dart';
import '../models/paciente.dart';
import '../models/veiculo.dart';
import '../models/motorista.dart';
import '../models/destino.dart';
import '../models/agendamento.dart';
import '../services/agendamento_service.dart';
import '../services/paciente_service.dart';
import '../services/veiculo_service.dart';
import '../services/motorista_service.dart';
import '../services/destino_service.dart';
import '../widgets/cadastro_base.dart';
import '../widgets/campo_texto.dart';
import '../utils/formatadores.dart';

class AgendamentosPage extends StatefulWidget {
  const AgendamentosPage({super.key});
  @override
  State<AgendamentosPage> createState() => _AgendamentosPageState();
}

class _AgendamentosPageState extends State<AgendamentosPage> {
  final _agSvc = AgendamentoService();
  final _pacSvc = PacienteService();
  final _veicSvc = VeiculoService();
  final _motSvc = MotoristaService();
  final _destSvc = DestinoService();

  final _formKey = GlobalKey<FormState>();
  final _obsCtrl = TextEditingController();

  List<Agendamento> _agendamentos = [];
  List<Paciente> _pacientes = [];
  List<Veiculo> _veiculos = [];
  List<Motorista> _motoristas = [];
  List<Destino> _destinos = [];

  Paciente? _paciente;
  Veiculo? _veiculo;
  Motorista? _motorista;
  Destino? _destino;
  DateTime? _data;
  TimeOfDay? _hora;

  bool _carregando = true;
  bool _salvando = false;

  @override
  void initState() {
    super.initState();
    _carregar();
  }

  @override
  void dispose() {
    _obsCtrl.dispose();
    super.dispose();
  }

  Future<void> _carregar() async {
    setState(() => _carregando = true);
    try {
      final r = await Future.wait([
        _agSvc.listar(),
        _pacSvc.listar(),
        _veicSvc.listar(),
        _motSvc.listar(),
        _destSvc.listar(),
      ]);
      setState(() {
        _agendamentos = r[0] as List<Agendamento>;
        _pacientes = r[1] as List<Paciente>;
        _veiculos = r[2] as List<Veiculo>;
        _motoristas = r[3] as List<Motorista>;
        _destinos = r[4] as List<Destino>;
      });
    } catch (e) {
      _erro('Erro ao carregar: $e');
    } finally {
      if (mounted) setState(() => _carregando = false);
    }
  }

  Future<void> _escolherHora() async {
    final hora = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
          child: child!,
        );
      },
    );
    if (hora != null) setState(() => _hora = hora);
  }

  Future<void> _salvar() async {
    if (!_formKey.currentState!.validate()) return;
    if (_paciente == null || _veiculo == null || _motorista == null ||
        _destino == null || _data == null || _hora == null) {
      _erro('Preencha todos os campos');
      return;
    }
    setState(() => _salvando = true);
    try {
      final dataHora = DateTime(
        _data!.year, _data!.month, _data!.day,
        _hora!.hour, _hora!.minute,
      );
      final novo = await _agSvc.inserir(Agendamento(
        paciente: _paciente!,
        veiculo: _veiculo!,
        motorista: _motorista!,
        destino: _destino,
        destinoTexto: '${_destino!.hospital} - ${_destino!.cidade}',
        dataHora: dataHora,
        observacao: _obsCtrl.text.trim(),
      ));
      setState(() {
        _agendamentos.insert(0, novo);
        _paciente = null; _veiculo = null; _motorista = null;
        _destino = null; _data = null; _hora = null;
        _obsCtrl.clear();
      });
    } catch (e) {
      _erro('Erro ao salvar: $e');
    } finally {
      if (mounted) setState(() => _salvando = false);
    }
  }

  Future<void> _excluir(Agendamento ag) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Excluir agendamento'),
        content: Text('Excluir agendamento de ${ag.paciente.nome}?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancelar')),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Excluir'),
          ),
        ],
      ),
    ) ?? false;
    if (!ok) return;
    try {
      await _agSvc.excluir(ag.id!);
      setState(() => _agendamentos.removeWhere((a) => a.id == ag.id));
    } catch (e) {
      _erro('Erro: $e');
    }
  }

  void _erro(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: Colors.red),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CadastroBase(
      titulo: 'Agendamento de Transporte',
      form: Form(
        key: _formKey,
        child: Column(children: [
          // Paciente
          _dropSimples<Paciente>('Paciente', _pacientes, _paciente,
              (v) => v.nome, (v) => setState(() => _paciente = v)),
          // Veículo
          _dropSimples<Veiculo>('Veículo', _veiculos, _veiculo,
              (v) => '${v.modelo} - ${v.placa}', (v) => setState(() => _veiculo = v)),
          // Motorista
          _dropSimples<Motorista>('Motorista', _motoristas, _motorista,
              (v) => v.nome, (v) => setState(() => _motorista = v)),
          // Destino — dropdown simples sem Column filho
          Padding(
            padding: const EdgeInsets.only(top: 10),
            child: DropdownButtonFormField<Destino>(
              value: _destino,
              isExpanded: true,
              decoration: decoracao('Destino'),
              items: _destinos
                  .map((d) => DropdownMenuItem<Destino>(
                        value: d,
                        child: Text(
                          '${d.hospital} - ${d.cidade}',
                          overflow: TextOverflow.ellipsis,
                        ),
                      ))
                  .toList(),
              onChanged: (v) => setState(() => _destino = v),
              validator: (v) => v == null ? 'Selecione um destino' : null,
            ),
          ),
          // Card detalhes do destino selecionado
          if (_destino != null)
            Container(
              margin: const EdgeInsets.only(top: 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF1565C0).withOpacity(0.06),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFF1565C0).withOpacity(0.2)),
              ),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [
                  const Icon(Icons.location_on, size: 14, color: Color(0xFF1565C0)),
                  const SizedBox(width: 6),
                  Expanded(child: Text(
                    '${_destino!.hospital} — ${_destino!.cidade}',
                    style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                  )),
                ]),
                const SizedBox(height: 4),
                Text('Tipo: ${_destino!.tipoConsulta}',
                    style: const TextStyle(fontSize: 12, color: Colors.grey)),
                if (_destino!.observacao.isNotEmpty)
                  Text('Obs: ${_destino!.observacao}',
                      style: const TextStyle(fontSize: 12, color: Colors.grey)),
              ]),
            ),
          campoTexto(_obsCtrl, 'Observação adicional', obrigatorio: false),
          const SizedBox(height: 10),
          // Data e hora
          Row(children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () async {
                  final d = await showDatePicker(
                    context: context,
                    firstDate: DateTime.now(),
                    lastDate: DateTime(2035),
                    initialDate: DateTime.now(),
                  );
                  if (d != null) setState(() => _data = d);
                },
                icon: const Icon(Icons.date_range),
                label: Text(_data == null ? 'Escolher data' : formatarData(_data!)),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _escolherHora,
                icon: const Icon(Icons.access_time),
                label: Text(_hora == null ? 'Escolher hora' : formatarHoraOfDay(_hora!)),
              ),
            ),
          ]),
          const SizedBox(height: 12),
          FilledButton(
            onPressed: _salvando ? null : _salvar,
            child: _salvando
                ? const SizedBox(height: 18, width: 18,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                : const Text('Cadastrar agendamento'),
          ),
        ]),
      ),
      lista: _carregando
          ? const Center(child: CircularProgressIndicator())
          : _agendamentos.isEmpty
              ? const Center(child: Text('Nenhum agendamento cadastrado'))
              : ListView.builder(
                  itemCount: _agendamentos.length,
                  itemBuilder: (ctx, i) {
                    final ag = _agendamentos[i];
                    return Card(
                      child: ListTile(
                        leading: const Icon(Icons.calendar_month, color: Color(0xFF1565C0)),
                        title: Text(ag.paciente.nome,
                            style: const TextStyle(fontWeight: FontWeight.w700)),
                        subtitle: Text(
                          'Destino: ${ag.destinoDisplay}\n'
                          '${ag.destino != null ? "Tipo: ${ag.destino!.tipoConsulta}\n" : ""}'
                          'Data: ${formatarDataHora(ag.dataHora)}\n'
                          'Motorista: ${ag.motorista.nome}\n'
                          'Veículo: ${ag.veiculo.modelo} - ${ag.veiculo.placa}'
                          '${ag.observacao.isNotEmpty ? "\nObs: ${ag.observacao}" : ""}',
                        ),
                        isThreeLine: true,
                        trailing: IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _excluir(ag),
                        ),
                      ),
                    );
                  },
                ),
    );
  }

  Widget _dropSimples<T>(String label, List<T> items, T? valor,
      String Function(T) texto, void Function(T?) onChange) {
    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: DropdownButtonFormField<T>(
        value: valor,
        isExpanded: true,
        decoration: decoracao(label),
        items: items
            .map((e) => DropdownMenuItem<T>(
                  value: e,
                  child: Text(texto(e), overflow: TextOverflow.ellipsis),
                ))
            .toList(),
        onChanged: onChange,
        validator: (v) => v == null ? 'Selecione $label' : null,
      ),
    );
  }
}
