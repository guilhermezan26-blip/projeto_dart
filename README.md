# SACTS v3 — Sistema de Agendamento e Controle de Transporte em Saúde

## 🗄️ SQL para atualizar o banco (execute no Supabase → SQL Editor)

```sql
-- Tabela de destinos (NOVA)
create table destinos (
  id bigserial primary key,
  cidade text not null,
  hospital text not null,
  tipo_consulta text not null,
  horario text not null,
  observacao text default '',
  created_at timestamptz default now()
);

-- Adicionar colunas na tabela agendamentos
alter table agendamentos
  add column if not exists destino_id bigint references destinos(id) on delete set null,
  add column if not exists destino_texto text default '';

-- Liberar acesso à nova tabela
alter table destinos enable row level security;
create policy "permitir tudo" on destinos for all using (true) with check (true);

-- Criar usuário admin (execute separado no SQL Editor)
-- OU crie pelo painel: Authentication → Users → Add user
-- E-mail: admin@sacts.com
-- Senha: Admin321@
```

## 👤 Criar usuário admin

No painel do Supabase:
**Authentication → Users → Add user → Create new user**
- E-mail: `admin@sacts.com`
- Senha: `Admin321@`

## 📱 Gerar APK

```bash
flutter clean
flutter pub get
flutter build apk --debug
```

O APK estará em: `build\app\outputs\flutter-apk\app-debug.apk`

## ⚙️ Credenciais Supabase

Arquivo: `lib/config/supabase_config.dart`
