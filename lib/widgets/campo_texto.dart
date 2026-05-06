import 'package:flutter/material.dart';

Widget campoTexto(
  TextEditingController controller,
  String label, {
  bool obrigatorio = true,
}) {
  return Padding(
    padding: const EdgeInsets.only(top: 10),
    child: TextFormField(
      controller: controller,
      decoration: decoracao(label),
      validator: obrigatorio
          ? (valor) {
              if (valor == null || valor.trim().isEmpty) {
                return 'Campo obrigatório';
              }
              return null;
            }
          : null,
    ),
  );
}

InputDecoration decoracao(String label) {
  return InputDecoration(
    labelText: label,
    border: const OutlineInputBorder(),
  );
}