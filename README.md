# SACTS — Sistema de Agendamento e Controle de Transporte em Saúde

Aplicativo mobile desenvolvido em **Flutter** com backend **Supabase** para gerenciar o transporte de pacientes para consultas e exames médicos. Desenvolvido para uso em secretarias de saúde municipais.

---

## 📱 Funcionalidades

- **Login** com autenticação segura via Supabase Auth
- **Pacientes** — cadastro, edição e exclusão com cartão SUS e telefone
- **Destinos** — cadastro de hospitais/clínicas com cidade e tipo de consulta
- **Veículos** — cadastro com modelo, placa e capacidade
- **Motoristas** — cadastro com CNH e telefone
- **Agendamentos** — criação de viagens vinculando paciente, motorista, veículo e destino com data e hora

---

## 🛠️ Tecnologias

| Tecnologia | Uso |
|---|---|
| Flutter 3.x | Framework mobile |
| Dart | Linguagem de programação |
| Supabase | Backend, banco de dados e autenticação |
| PostgreSQL | Banco de dados relacional |
| Material Design 3 | Interface do usuário |

---

## 🔑 Acesso ao sistema

| Campo | Valor |
|---|---|
| E-mail | `admin@sacts.com` |
| Senha | `Admin321@` |

---

## 📁 Estrutura do projeto

```
lib/
├── config/
│   └── supabase_config.dart
├── models/
│   ├── agendamento.dart
│   ├── destino.dart
│   ├── motorista.dart
│   ├── paciente.dart
│   └── veiculo.dart
├── pages/
│   ├── agendamentos_page.dart
│   ├── destinos_page.dart
│   ├── home_page.dart
│   ├── login_page.dart
│   ├── motoristas_page.dart
│   ├── pacientes_page.dart
│   └── veiculos_page.dart
├── services/
│   ├── agendamento_service.dart
│   ├── destino_service.dart
│   ├── motorista_service.dart
│   ├── paciente_service.dart
│   └── veiculo_service.dart
├── utils/
│   └── formatadores.dart
├── widgets/
│   ├── cadastro_base.dart
│   └── campo_texto.dart
├── app.dart
└── main.dart
```

---

## 📄 Licença

Este projeto está sob a licença MIT.
