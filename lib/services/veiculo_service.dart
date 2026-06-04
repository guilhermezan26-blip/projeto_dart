import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/veiculo.dart';

class VeiculoService {
  final _db = Supabase.instance.client.from('veiculos');

  Future<List<Veiculo>> listar() async {
    final data = await _db.select().order('modelo');
    return (data as List).map((e) => Veiculo.fromJson(e)).toList();
  }

  Future<Veiculo> inserir(Veiculo veiculo) async {
    final data = await _db.insert(veiculo.toJson()).select().single();
    return Veiculo.fromJson(data);
  }

  Future<Veiculo> atualizar(Veiculo veiculo) async {
    final data = await _db
        .update(veiculo.toJson())
        .eq('id', veiculo.id!)
        .select()
        .single();
    return Veiculo.fromJson(data);
  }

  Future<void> excluir(int id) async {
    await _db.delete().eq('id', id);
  }
}
