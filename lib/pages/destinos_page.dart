import 'package:flutter/material.dart';
import '../models/destino.dart';
import '../services/destino_service.dart';
import '../widgets/cadastro_base.dart';
import '../widgets/campo_texto.dart';

class DestinosPage extends StatefulWidget {
  const DestinosPage({super.key});
  @override
  State<DestinosPage> createState() => _DestinosPageState();
}

class _DestinosPageState extends State<DestinosPage> {
  final _service = DestinoService();
  final _formKey = GlobalKey<FormState>();
  final _cidadeCtrl = TextEditingController();
  final _hospitalCtrl = TextEditingController();
  final _obsCtrl = TextEditingController();

  static const _tiposConsulta = [
    'Consulta Médica',
    'Exame Laboratorial',
    'Exame de Imagem',
    'Cirurgia',
    'Quimioterapia',
    'Radioterapia',
    'Fisioterapia',
    'Consulta Odontológica',
    'Consulta Psicológica',
    'Hemodiálise',
    'Retorno',
    'Outros',
  ];

  List<Destino> _destinos = [];
  bool _carregando = true;
  bool _salvando = false;
  Destino? _editando;
  String? _tipoSelecionado;

  @override
  void initState() {
    super.initState();
    _carregar();
  }

  @override
  void dispose() {
    _cidadeCtrl.dispose();
    _hospitalCtrl.dispose();
    _obsCtrl.dispose();
    super.dispose();
  }

  Future<void> _carregar() async {
    setState(() => _carregando = true);
    try {
      final lista = await _service.listar();
      setState(() => _destinos = lista);
    } catch (e) {
      _erro('Erro ao carregar: $e');
    } finally {
      if (mounted) setState(() => _carregando = false);
    }
  }

  void _iniciarEdicao(Destino d) {
    setState(() {
      _editando = d;
      _cidadeCtrl.text = d.cidade;
      _hospitalCtrl.text = d.hospital;
      _tipoSelecionado = d.tipoConsulta;
      _obsCtrl.text = d.observacao;
    });
  }

  void _cancelarEdicao() {
    setState(() {
      _editando = null;
      _tipoSelecionado = null;
      _cidadeCtrl.clear();
      _hospitalCtrl.clear();
      _obsCtrl.clear();
      _formKey.currentState?.reset();
    });
  }

  Future<void> _salvar() async {
    if (!_formKey.currentState!.validate()) return;
    if (_tipoSelecionado == null) {
      _erro('Selecione o tipo de consulta');
      return;
    }
    setState(() => _salvando = true);
    try {
      final destino = Destino(
        id: _editando?.id,
        cidade: _cidadeCtrl.text.trim(),
        hospital: _hospitalCtrl.text.trim(),
        tipoConsulta: _tipoSelecionado!,
        observacao: _obsCtrl.text.trim(),
      );
      if (_editando != null) {
        final atualizado = await _service.atualizar(destino);
        setState(() {
          final idx = _destinos.indexWhere((d) => d.id == atualizado.id);
          if (idx >= 0) _destinos[idx] = atualizado;
          _editando = null;
        });
      } else {
        final novo = await _service.inserir(destino);
        setState(() => _destinos.add(novo));
      }
      _cancelarEdicao();
    } catch (e) {
      _erro('Erro ao salvar: $e');
    } finally {
      if (mounted) setState(() => _salvando = false);
    }
  }

  Future<void> _excluir(Destino d) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Excluir destino'),
        content: Text('Excluir "${d.hospital} - ${d.cidade}"?'),
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
      await _service.excluir(d.id!);
      setState(() => _destinos.removeWhere((x) => x.id == d.id));
    } catch (e) {
      _erro('Erro ao excluir: $e');
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
      titulo: _editando != null ? 'Editar Destino' : 'Cadastro de Destinos',
      form: Form(
        key: _formKey,
        child: Column(
          children: [
            campoTexto(_cidadeCtrl, 'Cidade'),
            campoTexto(_hospitalCtrl, 'Hospital / Clínica'),
            Padding(
              padding: const EdgeInsets.only(top: 10),
              child: DropdownButtonFormField<String>(
                value: _tipoSelecionado,
                decoration: decoracao('Tipo de Consulta'),
                items: _tiposConsulta
                    .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                    .toList(),
                onChanged: (v) => setState(() => _tipoSelecionado = v),
                validator: (v) => v == null ? 'Selecione o tipo' : null,
              ),
            ),
            campoTexto(_obsCtrl, 'Observação', obrigatorio: false),
            const SizedBox(height: 12),
            Row(
              children: [
                if (_editando != null) ...[
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _salvando ? null : _cancelarEdicao,
                      child: const Text('Cancelar'),
                    ),
                  ),
                  const SizedBox(width: 8),
                ],
                Expanded(
                  child: FilledButton(
                    onPressed: _salvando ? null : _salvar,
                    child: _salvando
                        ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                        : Text(_editando != null ? 'Salvar alterações' : 'Cadastrar destino'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      lista: _carregando
          ? const Center(child: CircularProgressIndicator())
          : _destinos.isEmpty
              ? const Center(child: Text('Nenhum destino cadastrado'))
              : ListView.builder(
                  itemCount: _destinos.length,
                  itemBuilder: (ctx, i) {
                    final d = _destinos[i];
                    return Card(
                      child: ListTile(
                        leading: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: const Color(0xFF1565C0).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(Icons.location_on, color: Color(0xFF1565C0), size: 22),
                        ),
                        title: Text(d.hospital, style: const TextStyle(fontWeight: FontWeight.w700)),
                        subtitle: Text(
                          '${d.cidade} • ${d.tipoConsulta}'
                          '${d.observacao.isNotEmpty ? '\nObs: ${d.observacao}' : ''}',
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(icon: const Icon(Icons.edit, size: 20), onPressed: () => _iniciarEdicao(d), tooltip: 'Editar'),
                            IconButton(icon: const Icon(Icons.delete, size: 20, color: Colors.red), onPressed: () => _excluir(d), tooltip: 'Excluir'),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
