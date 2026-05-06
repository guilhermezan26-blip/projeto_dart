import 'package:flutter/material.dart';
import '../models/veiculo.dart';
import '../widgets/cadastro_base.dart';
import '../widgets/campo_texto.dart';

class VeiculosPage extends StatefulWidget {
  final List<Veiculo> veiculos;

  const VeiculosPage({
    super.key,
    required this.veiculos,
  });

  @override
  State<VeiculosPage> createState() => _VeiculosPageState();
}

class _VeiculosPageState extends State<VeiculosPage> {
  final formKey = GlobalKey<FormState>();
  final modeloController = TextEditingController();
  final placaController = TextEditingController();
  final capacidadeController = TextEditingController();

  void salvar() {
    if (!formKey.currentState!.validate()) return;

    setState(() {
      widget.veiculos.add(
        Veiculo(
          modelo: modeloController.text,
          placa: placaController.text,
          capacidade: capacidadeController.text,
        ),
      );

      modeloController.clear();
      placaController.clear();
      capacidadeController.clear();
    });
  }

  void remover(int index) {
    setState(() {
      widget.veiculos.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return CadastroBase(
      titulo: 'Cadastro de Veículos',
      form: Form(
        key: formKey,
        child: Column(
          children: [
            campoTexto(modeloController, 'Modelo do veículo'),
            campoTexto(placaController, 'Placa'),
            campoTexto(capacidadeController, 'Capacidade'),
            const SizedBox(height: 12),
            FilledButton(
              onPressed: salvar,
              child: const Text('Cadastrar veículo'),
            ),
          ],
        ),
      ),
      lista: widget.veiculos.isEmpty
          ? const Center(child: Text('Nenhum veículo cadastrado'))
          : ListView.builder(
              itemCount: widget.veiculos.length,
              itemBuilder: (context, index) {
                final veiculo = widget.veiculos[index];

                return Card(
                  child: ListTile(
                    leading: const Icon(Icons.directions_car),
                    title: Text('${veiculo.modelo} - ${veiculo.placa}'),
                    subtitle: Text('Capacidade: ${veiculo.capacidade}'),
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