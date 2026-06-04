import 'package:flutter/material.dart';

Widget campoTexto(
  TextEditingController controller,
  String label, {
  bool obrigatorio = true,
  TextInputType? teclado,
  String? Function(String?)? validador,
}) {
  return Padding(
    padding: const EdgeInsets.only(top: 10),
    child: TextFormField(
      controller: controller,
      keyboardType: teclado,
      decoration: decoracao(label),
      validator: validador ??
          (obrigatorio
              ? (valor) {
                  if (valor == null || valor.trim().isEmpty) {
                    return 'Campo obrigatório';
                  }
                  return null;
                }
              : null),
    ),
  );
}

InputDecoration decoracao(String label) {
  return InputDecoration(
    labelText: label,
    border: const OutlineInputBorder(),
  );
}
