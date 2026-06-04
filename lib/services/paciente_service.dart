import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/paciente.dart';

class PacienteService {
  final _db = Supabase.instance.client.from('pacientes');

  Future<List<Paciente>> listar() async {
    final data = await _db.select().order('nome');
    return (data as List).map((e) => Paciente.fromJson(e)).toList();
  }

  Future<Paciente> inserir(Paciente paciente) async {
    final data = await _db.insert(paciente.toJson()).select().single();
    return Paciente.fromJson(data);
  }

  Future<Paciente> atualizar(Paciente paciente) async {
    final data = await _db
        .update(paciente.toJson())
        .eq('id', paciente.id!)
        .select()
        .single();
    return Paciente.fromJson(data);
  }

  Future<void> excluir(int id) async {
    await _db.delete().eq('id', id);
  }
}
