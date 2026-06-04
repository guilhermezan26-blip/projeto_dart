import 'package:flutter/material.dart';
import '../models/veiculo.dart';
import '../services/veiculo_service.dart';
import '../widgets/cadastro_base.dart';
import '../widgets/campo_texto.dart';

class VeiculosPage extends StatefulWidget {
  const VeiculosPage({super.key});

  @override
  State<VeiculosPage> createState() => _VeiculosPageState();
}

class _VeiculosPageState extends State<VeiculosPage> {
  final _service = VeiculoService();
  final _formKey = GlobalKey<FormState>();
  final _modeloController = TextEditingController();
  final _placaController = TextEditingController();
  final _capacidadeController = TextEditingController();

  List<Veiculo> _veiculos = [];
  bool _carregando = true;
  bool _salvando = false;
  Veiculo? _editando;

  @override
  void initState() {
    super.initState();
    _carregar();
  }

  @override
  void dispose() {
    _modeloController.dispose();
    _placaController.dispose();
    _capacidadeController.dispose();
    super.dispose();
  }

  Future<void> _carregar() async {
    setState(() => _carregando = true);
    try {
      final lista = await _service.listar();
      setState(() => _veiculos = lista);
    } catch (e) {
      _mostrarErro('Erro ao carregar veículos: $e');
    } finally {
      setState(() => _carregando = false);
    }
  }

  void _iniciarEdicao(Veiculo veiculo) {
    setState(() {
      _editando = veiculo;
      _modeloController.text = veiculo.modelo;
      _placaController.text = veiculo.placa;
      _capacidadeController.text = veiculo.capacidade;
    });
  }

  void _cancelarEdicao() {
    setState(() {
      _editando = null;
      _modeloController.clear();
      _placaController.clear();
      _capacidadeController.clear();
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
            modelo: _modeloController.text.trim(),
            placa: _placaController.text.trim(),
            capacidade: _capacidadeController.text.trim(),
          ),
        );
        setState(() {
          final idx = _veiculos.indexWhere((v) => v.id == atualizado.id);
          if (idx >= 0) _veiculos[idx] = atualizado;
          _editando = null;
        });
      } else {
        final novo = await _service.inserir(
          Veiculo(
            modelo: _modeloController.text.trim(),
            placa: _placaController.text.trim(),
            capacidade: _capacidadeController.text.trim(),
          ),
        );
        setState(() => _veiculos.add(novo));
      }
      _modeloController.clear();
      _placaController.clear();
      _capacidadeController.clear();
    } catch (e) {
      _mostrarErro('Erro ao salvar veículo: $e');
    } finally {
      setState(() => _salvando = false);
    }
  }

  Future<void> _excluir(Veiculo veiculo) async {
    final confirmado = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Excluir veículo'),
        content: Text('Deseja excluir "${veiculo.modelo} - ${veiculo.placa}"?'),
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
      await _service.excluir(veiculo.id!);
      setState(() => _veiculos.removeWhere((v) => v.id == veiculo.id));
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
      titulo: _editando != null ? 'Editar Veículo' : 'Cadastro de Veículos',
      form: Form(
        key: _formKey,
        child: Column(
          children: [
            campoTexto(_modeloController, 'Modelo do veículo'),
            campoTexto(_placaController, 'Placa'),
            campoTexto(
              _capacidadeController,
              'Capacidade (nº de passageiros)',
              teclado: TextInputType.number,
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
                            : 'Cadastrar veículo'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      lista: _carregando
          ? const Center(child: CircularProgressIndicator())
          : _veiculos.isEmpty
              ? const Center(child: Text('Nenhum veículo cadastrado'))
              : ListView.builder(
                  itemCount: _veiculos.length,
                  itemBuilder: (context, index) {
                    final veiculo = _veiculos[index];
                    return Card(
                      child: ListTile(
                        leading: const Icon(Icons.directions_car),
                        title: Text('${veiculo.modelo} - ${veiculo.placa}'),
                        subtitle:
                            Text('Capacidade: ${veiculo.capacidade} passageiros'),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit),
                              tooltip: 'Editar',
                              onPressed: () => _iniciarEdicao(veiculo),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete),
                              tooltip: 'Excluir',
                              onPressed: () => _excluir(veiculo),
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
