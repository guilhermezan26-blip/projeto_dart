import 'package:flutter/material.dart';
import '../models/motorista.dart';
import '../widgets/cadastro_base.dart';
import '../widgets/campo_texto.dart';

class MotoristasPage extends StatefulWidget {
  final List<Motorista> motoristas;

  const MotoristasPage({
    super.key,
    required this.motoristas,
  });

  @override
  State<MotoristasPage> createState() => _MotoristasPageState();
}

class _MotoristasPageState extends State<MotoristasPage> {
  final formKey = GlobalKey<FormState>();
  final nomeController = TextEditingController();
  final cnhController = TextEditingController();
  final telefoneController = TextEditingController();

  void salvar() {
    if (!formKey.currentState!.validate()) return;

    setState(() {
      widget.motoristas.add(
        Motorista(
          nome: nomeController.text,
          cnh: cnhController.text,
          telefone: telefoneController.text,
        ),
      );

      nomeController.clear();
      cnhController.clear();
      telefoneController.clear();
    });
  }

  void remover(int index) {
    setState(() {
      widget.motoristas.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return CadastroBase(
      titulo: 'Cadastro de Motoristas',
      form: Form(
        key: formKey,
        child: Column(
          children: [
            campoTexto(nomeController, 'Nome do motorista'),
            campoTexto(cnhController, 'CNH'),
            campoTexto(telefoneController, 'Telefone'),
            const SizedBox(height: 12),
            FilledButton(
              onPressed: salvar,
              child: const Text('Cadastrar motorista'),
            ),
          ],
        ),
      ),
      lista: widget.motoristas.isEmpty
          ? const Center(child: Text('Nenhum motorista cadastrado'))
          : ListView.builder(
              itemCount: widget.motoristas.length,
              itemBuilder: (context, index) {
                final motorista = widget.motoristas[index];

                return Card(
                  child: ListTile(
                    leading: const Icon(Icons.badge),
                    title: Text(motorista.nome),
                    subtitle: Text(
                      'CNH: ${motorista.cnh}\nTelefone: ${motorista.telefone}',
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