import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/agendamento.dart';

class AgendamentoService {
  final _db = Supabase.instance.client.from('agendamentos');

  Future<List<Agendamento>> listar() async {
    final data = await _db
        .select('*, pacientes(*), veiculos(*), motoristas(*), destinos(*)')
        .order('data_hora', ascending: false);
    return (data as List).map((e) => Agendamento.fromJson(e)).toList();
  }

  Future<Agendamento> inserir(Agendamento agendamento) async {
    final inserted = await _db
        .insert(agendamento.toJson())
        .select('*, pacientes(*), veiculos(*), motoristas(*), destinos(*)')
        .single();
    return Agendamento.fromJson(inserted);
  }

  Future<void> excluir(int id) async {
    await _db.delete().eq('id', id);
  }
}
