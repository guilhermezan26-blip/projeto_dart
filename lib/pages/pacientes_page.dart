import 'package:flutter/material.dart';
import '../models/paciente.dart';
import '../services/paciente_service.dart';
import '../widgets/cadastro_base.dart';
import '../widgets/campo_texto.dart';

class PacientesPage extends StatefulWidget {
  const PacientesPage({super.key});

  @override
  State<PacientesPage> createState() => _PacientesPageState();
}

class _PacientesPageState extends State<PacientesPage> {
  final _service = PacienteService();
  final _formKey = GlobalKey<FormState>();
  final _nomeController = TextEditingController();
  final _susController = TextEditingController();
  final _telefoneController = TextEditingController();

  List<Paciente> _pacientes = [];
  bool _carregando = true;
  bool _salvando = false;
  Paciente? _editando;

  @override
  void initState() {
    super.initState();
    _carregar();
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _susController.dispose();
    _telefoneController.dispose();
    super.dispose();
  }

  Future<void> _carregar() async {
    setState(() => _carregando = true);
    try {
      final lista = await _service.listar();
      setState(() => _pacientes = lista);
    } catch (e) {
      _mostrarErro('Erro ao carregar pacientes: $e');
    } finally {
      setState(() => _carregando = false);
    }
  }

  void _iniciarEdicao(Paciente paciente) {
    setState(() {
      _editando = paciente;
      _nomeController.text = paciente.nome;
      _susController.text = paciente.sus;
      _telefoneController.text = paciente.telefone;
    });
  }

  void _cancelarEdicao() {
    setState(() {
      _editando = null;
      _nomeController.clear();
      _susController.clear();
      _telefoneController.clear();
      _formKey.currentState?.reset();
    });
  }

  Future<void> _salvar() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _salvando = true);
    try {
      if (_editando != null) {
        final atualizado = await _service.atualizar(
          _editando!.copyWith(
            nome: _nomeController.text.trim(),
            sus: _susController.text.trim(),
            telefone: _telefoneController.text.trim(),
          ),
        );
        setState(() {
          final idx = _pacientes.indexWhere((p) => p.id == atualizado.id);
          if (idx >= 0) _pacientes[idx] = atualizado;
          _editando = null;
        });
      } else {
        final novo = await _service.inserir(
          Paciente(
            nome: _nomeController.text.trim(),
            sus: _susController.text.trim(),
            telefone: _telefoneController.text.trim(),
          ),
        );
        setState(() => _pacientes.add(novo));
      }
      _nomeController.clear();
      _susController.clear();
      _telefoneController.clear();
    } catch (e) {
      _mostrarErro('Erro ao salvar paciente: $e');
    } finally {
      setState(() => _salvando = false);
    }
  }

  Future<void> _excluir(Paciente paciente) async {
    final confirmado = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Excluir paciente'),
        content: Text('Deseja excluir "${paciente.nome}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );
    if (confirmado != true) return;
    try {
      await _service.excluir(paciente.id!);
      setState(() => _pacientes.removeWhere((p) => p.id == paciente.id));
    } catch (e) {
      _mostrarErro('Erro ao excluir: $e');
    }
  }

  void _mostrarErro(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: Colors.red),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CadastroBase(
      titulo: _editando != null ? 'Editar Paciente' : 'Cadastro de Pacientes',
      form: Form(
        key: _formKey,
        child: Column(
          children: [
            campoTexto(_nomeController, 'Nome do paciente'),
            campoTexto(_susController, 'Cartão SUS'),
            campoTexto(
              _telefoneController,
              'Telefone',
              teclado: TextInputType.phone,
            ),
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
                        ? const SizedBox(
                            height: 18,
                            width: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : Text(_editando != null
                            ? 'Salvar alterações'
                            : 'Cadastrar paciente'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      lista: _carregando
          ? const Center(child: CircularProgressIndicator())
          : _pacientes.isEmpty
              ? const Center(child: Text('Nenhum paciente cadastrado'))
              : ListView.builder(
                  itemCount: _pacientes.length,
                  itemBuilder: (context, index) {
                    final paciente = _pacientes[index];
                    return Card(
                      child: ListTile(
                        leading: const Icon(Icons.person),
                        title: Text(paciente.nome),
                        subtitle: Text(
                          'SUS: ${paciente.sus}\nTelefone: ${paciente.telefone}',
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit),
                              tooltip: 'Editar',
                              onPressed: () => _iniciarEdicao(paciente),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete),
                              tooltip: 'Excluir',
                              onPressed: () => _excluir(paciente),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
