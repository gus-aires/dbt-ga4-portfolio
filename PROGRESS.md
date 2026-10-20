# PROGRESS

## Etapa 1 — Base e setup (em andamento)

### Feito
- `.venv` com Python 3.11.9 e `dbt-bigquery` 1.12.1 (dbt-core 1.12.5).
- Google Cloud SDK instalado; ADC (`gcloud auth application-default login`) com quota project `dbt-ga4-portfolio-510915`.
- `dbt init` rodado e estrutura movida para a raiz do repo (exemplos do init removidos).
- `dbt_project.yml` com materialização por camada: staging/intermediate = view, marts = table.
- `~/.dbt/profiles.yml` (fora do repo): OAuth, dataset base `dbt_dev`, location `US`, `maximum_bytes_billed` = 10 GB.
- `dbt debug`: todos os checks OK.
- Teste de sandbox: CREATE TABLE, INSERT e MERGE funcionaram e não há expiração padrão → **projeto NÃO está em sandbox**; incremental com `merge` é viável.
- `git init -b main`; identidade global do Git configurada com o e-mail noreply do GitHub (privacidade); primeiro commit `d0e67f1` (local, ainda sem remote).
- `CLAUDE.md` reescrito sem informações pessoais (foco em desenvolvimento + vitrine); "Dia" virou "Etapa" e "modo entrevista" virou "checagem de entendimento". Vai para o repo público.

### Decisões e porquês
- Projeto dbt na raiz do repo (não numa subpasta): quem clona roda `dbt` direto, padrão mais comum em portfólio.
- `location: US`: o dataset público do GA4 fica em US; BigQuery não consulta entre regiões.
- `maximum_bytes_billed`: trava de custo; a query falha em vez de cobrar se passar de 10 GB.
- `+schema` por camada: gera datasets `dbt_dev_staging`, `dbt_dev_intermediate`, `dbt_dev_marts` (comportamento padrão do `generate_schema_name`).
- Referência de custo: ler só `event_name` de 1 semana = ~4,3 MB.

### Pendências
- Criar o repositório público `gus-aires/dbt-ga4-portfolio` no GitHub (vazio, sem README/.gitignore/licença) e fazer push.
- Opcional: alerta de orçamento no Billing do GCP.
- Curso dbt Fundamentals (confirmar se foi feito).
- Checagem de entendimento da Etapa 1.

### Próximo passo
Criar o repositório no GitHub → push → checagem de entendimento da Etapa 1 → Etapa 2 (staging).
Nada precisa ser criado no BigQuery: o dbt cria os datasets na primeira execução.
