import 'package:flutter/material.dart';
import '../models/paciente.dart';
import '../widgets/cadastro_base.dart';
import '../widgets/campo_texto.dart';

class PacientesPage extends StatefulWidget {
  final List<Paciente> pacientes;

  const PacientesPage({
    super.key,
    required this.pacientes,
  });

  @override
  State<PacientesPage> createState() => _PacientesPageState();
}

class _PacientesPageState extends State<PacientesPage> {
  final formKey = GlobalKey<FormState>();
  final nomeController = TextEditingController();
  final susController = TextEditingController();
  final telefoneController = TextEditingController();

  void salvar() {
    if (!formKey.currentState!.validate()) return;

    setState(() {
      widget.pacientes.add(
        Paciente(
          nome: nomeController.text,
          sus: susController.text,
          telefone: telefoneController.text,
        ),
      );

      nomeController.clear();
      susController.clear();
      telefoneController.clear();
    });
  }

  void remover(int index) {
    setState(() {
      widget.pacientes.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return CadastroBase(
      titulo: 'Cadastro de Pacientes',
      form: Form(
        key: formKey,
        child: Column(
          children: [
            campoTexto(nomeController, 'Nome do paciente'),
            campoTexto(susController, 'Cartão SUS'),
            campoTexto(telefoneController, 'Telefone'),
            const SizedBox(height: 12),
            FilledButton(
              onPressed: salvar,
              child: const Text('Cadastrar paciente'),
            ),
          ],
        ),
      ),
      lista: widget.pacientes.isEmpty
          ? const Center(child: Text('Nenhum paciente cadastrado'))
          : ListView.builder(
              itemCount: widget.pacientes.length,
              itemBuilder: (context, index) {
                final paciente = widget.pacientes[index];

                return Card(
                  child: ListTile(
                    leading: const Icon(Icons.person),
                    title: Text(paciente.nome),
                    subtitle: Text(
                      'SUS: ${paciente.sus}\nTelefone: ${paciente.telefone}',
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