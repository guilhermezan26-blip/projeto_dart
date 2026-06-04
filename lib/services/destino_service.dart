import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/destino.dart';

class DestinoService {
  final _db = Supabase.instance.client.from('destinos');

  Future<List<Destino>> listar() async {
    final data = await _db.select().order('cidade').order('hospital');
    return (data as List).map((e) => Destino.fromJson(e)).toList();
  }

  Future<Destino> inserir(Destino destino) async {
    final data = await _db.insert(destino.toJson()).select().single();
    return Destino.fromJson(data);
  }

  Future<Destino> atualizar(Destino destino) async {
    final data = await _db
        .update(destino.toJson())
        .eq('id', destino.id!)
        .select()
        .single();
    return Destino.fromJson(data);
  }

  Future<void> excluir(int id) async {
    await _db.delete().eq('id', id);
  }
}
