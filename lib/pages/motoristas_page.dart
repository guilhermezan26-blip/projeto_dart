import 'package:flutter/material.dart';
import '../models/motorista.dart';
import '../services/motorista_service.dart';
import '../widgets/cadastro_base.dart';
import '../widgets/campo_texto.dart';

class MotoristasPage extends StatefulWidget {
  const MotoristasPage({super.key});

  @override
  State<MotoristasPage> createState() => _MotoristasPageState();
}

class _MotoristasPageState extends State<MotoristasPage> {
  final _service = MotoristaService();
  final _formKey = GlobalKey<FormState>();
  final _nomeController = TextEditingController();
  final _cnhController = TextEditingController();
  final _telefoneController = TextEditingController();

  List<Motorista> _motoristas = [];
  bool _carregando = true;
  bool _salvando = false;
  Motorista? _editando;

  @override
  void initState() {
    super.initState();
    _carregar();
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _cnhController.dispose();
    _telefoneController.dispose();
    super.dispose();
  }

  Future<void> _carregar() async {
    setState(() => _carregando = true);
    try {
      final lista = await _service.listar();
      setState(() => _motoristas = lista);
    } catch (e) {
      _mostrarErro('Erro ao carregar motoristas: $e');
    } finally {
      setState(() => _carregando = false);
    }
  }

  void _iniciarEdicao(Motorista motorista) {
    setState(() {
      _editando = motorista;
      _nomeController.text = motorista.nome;
      _cnhController.text = motorista.cnh;
      _telefoneController.text = motorista.telefone;
    });
  }

  void _cancelarEdicao() {
    setState(() {
      _editando = null;
      _nomeController.clear();
      _cnhController.clear();
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
            cnh: _cnhController.text.trim(),
            telefone: _telefoneController.text.trim(),
          ),
        );
        setState(() {
          final idx = _motoristas.indexWhere((m) => m.id == atualizado.id);
          if (idx >= 0) _motoristas[idx] = atualizado;
          _editando = null;
        });
      } else {
        final novo = await _service.inserir(
          Motorista(
            nome: _nomeController.text.trim(),
            cnh: _cnhController.text.trim(),
            telefone: _telefoneController.text.trim(),
          ),
        );
        setState(() => _motoristas.add(novo));
      }
      _nomeController.clear();
      _cnhController.clear();
      _telefoneController.clear();
    } catch (e) {
      _mostrarErro('Erro ao salvar motorista: $e');
    } finally {
      setState(() => _salvando = false);
    }
  }

  Future<void> _excluir(Motorista motorista) async {
    final confirmado = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Excluir motorista'),
        content: Text('Deseja excluir "${motorista.nome}"?'),
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
      await _service.excluir(motorista.id!);
      setState(() => _motoristas.removeWhere((m) => m.id == motorista.id));
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
      titulo: _editando != null ? 'Editar Motorista' : 'Cadastro de Motoristas',
      form: Form(
        key: _formKey,
        child: Column(
          children: [
            campoTexto(_nomeController, 'Nome do motorista'),
            campoTexto(_cnhController, 'CNH'),
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
                            : 'Cadastrar motorista'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      lista: _carregando
          ? const Center(child: CircularProgressIndicator())
          : _motoristas.isEmpty
              ? const Center(child: Text('Nenhum motorista cadastrado'))
              : ListView.builder(
                  itemCount: _motoristas.length,
                  itemBuilder: (context, index) {
                    final motorista = _motoristas[index];
                    return Card(
                      child: ListTile(
                        leading: const Icon(Icons.badge),
                        title: Text(motorista.nome),
                        subtitle: Text(
                          'CNH: ${motorista.cnh}\nTelefone: ${motorista.telefone}',
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit),
                              tooltip: 'Editar',
                              onPressed: () => _iniciarEdicao(motorista),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete),
                              tooltip: 'Excluir',
                              onPressed: () => _excluir(motorista),
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
