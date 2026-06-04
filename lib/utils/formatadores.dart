import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

final _fData = DateFormat('dd/MM/yyyy', 'pt_BR');
final _fHora = DateFormat('HH:mm', 'pt_BR');
final _fDataHora = DateFormat("dd/MM/yyyy 'às' HH:mm", 'pt_BR');

String formatarData(DateTime data) => _fData.format(data);
String formatarHora(DateTime data) => _fHora.format(data);
String formatarDataHora(DateTime data) => _fDataHora.format(data);

String formatarHoraOfDay(TimeOfDay hora) {
  final h = hora.hour.toString().padLeft(2, '0');
  final m = hora.minute.toString().padLeft(2, '0');
  return '$h:$m';
}
