import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/motorista.dart';

class MotoristaService {
  final _db = Supabase.instance.client.from('motoristas');

  Future<List<Motorista>> listar() async {
    final data = await _db.select().order('nome');
    return (data as List).map((e) => Motorista.fromJson(e)).toList();
  }

  Future<Motorista> inserir(Motorista motorista) async {
    final data = await _db.insert(motorista.toJson()).select().single();
    return Motorista.fromJson(data);
  }

  Future<Motorista> atualizar(Motorista motorista) async {
    final data = await _db
        .update(motorista.toJson())
        .eq('id', motorista.id!)
        .select()
        .single();
    return Motorista.fromJson(data);
  }

  Future<void> excluir(int id) async {
    await _db.delete().eq('id', id);
  }
}
