import 'package:flutter/material.dart';
import '../models/paciente.dart';
import '../models/veiculo.dart';
import '../models/motorista.dart';
import '../models/agendamento.dart';
import 'agendamentos_page.dart';
import 'pacientes_page.dart';
import 'veiculos_page.dart';
import 'motoristas_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int paginaAtual = 0;

  final List<Paciente> pacientes = [];
  final List<Veiculo> veiculos = [];
  final List<Motorista> motoristas = [];
  final List<Agendamento> agendamentos = [];

  @override
  Widget build(BuildContext context) {
    final paginas = [
      AgendamentosPage(
        pacientes: pacientes,
        veiculos: veiculos,
        motoristas: motoristas,
        agendamentos: agendamentos,
      ),
      PacientesPage(pacientes: pacientes),
      VeiculosPage(veiculos: veiculos),
      MotoristasPage(motoristas: motoristas),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('SACTS'),
        centerTitle: true,
      ),
      body: IndexedStack(
        index: paginaAtual,
        children: paginas,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: paginaAtual,
        onDestinationSelected: (index) {
          setState(() {
            paginaAtual = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.calendar_month),
            label: 'Agendamento',
          ),
          NavigationDestination(
            icon: Icon(Icons.person),
            label: 'Pacientes',
          ),
          NavigationDestination(
            icon: Icon(Icons.directions_car),
            label: 'Veículos',
          ),
          NavigationDestination(
            icon: Icon(Icons.badge),
            label: 'Motoristas',
          ),
        ],
      ),
    );
  }
}