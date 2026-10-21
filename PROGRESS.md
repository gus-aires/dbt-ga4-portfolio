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
- `git init -b main`; identidade global do Git configurada com o e-mail noreply do GitHub (privacidade); primeiro commit `d0e67f1`.
- Repositório público criado: https://github.com/gus-aires/dbt-ga4-portfolio (push inicial feito; Git Credential Manager autenticado).
- `CLAUDE.md` reescrito sem informações pessoais (foco em desenvolvimento + vitrine); "Dia" virou "Etapa" e "modo entrevista" virou "checagem de entendimento". Vai para o repo público.

### Decisões e porquês
- Projeto dbt na raiz do repo (não numa subpasta): quem clona roda `dbt` direto, padrão mais comum em portfólio.
- `location: US`: o dataset público do GA4 fica em US; BigQuery não consulta entre regiões.
- `maximum_bytes_billed`: trava de custo; a query falha em vez de cobrar se passar de 10 GB.
- `+schema` por camada: gera datasets `dbt_dev_staging`, `dbt_dev_intermediate`, `dbt_dev_marts` (comportamento padrão do `generate_schema_name`).
- Referência de custo: ler só `event_name` de 1 semana = ~4,3 MB.

### Checagem de entendimento — Etapa 1
- Q1 (profiles.yml vs dbt_project.yml): não lembrou → explicado. Revisar.
- Q2 (location US / maximum_bytes_billed): parcial — limite de bytes ok (custo, não "cota"); location não lembrou → explicado.
- Q3 (view vs table por camada): não lembrou → explicado. Revisar.
- Refazer as 3 perguntas rapidamente no início da próxima sessão.

## Etapa 2 — Staging (em andamento)

### Feito
- `models/staging/ga4/_ga4__sources.yml`: source `ga4.events` → `bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_*`. Sem freshness (amostra congelada, último dia 2021-01-31).
- Volume de referência: ~26 mil eventos e ~20 MB por dia; ~1,8 GB nos 92 dias.
- Conceitos explicados: o que é dbt (T do ELT, ref/source, Jinja, materializações, testes, docs); SQL básico/intermediário comparado ao Looker Studio; window functions com exemplos GA4 (row_number, lag/lead, first_value, QUALIFY); roteiro "granularidade primeiro".

### Em andamento: `stg_ga4__events` (rodada 1, colunas planas)
- Arquivo criado pelo usuário em `models/staging/ga4/stg_ga4__events.sql` (ainda não compila; não commitado).
- 2 tentativas revisadas. Dica nível 3 entregue: CTE `source` pronta + `renamed` com 2 colunas de exemplo (`event_at`, `country`). Falta completar as demais colunas da rodada 1.
- Pontos de atenção recorrentes: aspas simples = texto (nomes de coluna/CTE sem aspas); papel de cada CTE (source = nomes originais, renamed = `expr as novo_nome`); `where` × `having`; erro de digitação `_TABBLE_SUFFIX`.
- Rodada 2 (extrair parâmetros do `event_params` sem multiplicar linhas) ainda não iniciada.

### Pendências
- Opcional: alerta de orçamento no Billing do GCP.
- Curso dbt Fundamentals (confirmar se foi feito).

### Próximo passo
Completar a rodada 1 do `stg_ga4__events` a partir da dica nível 3 → revisar → `dbt run -s stg_ga4__events` → comparar contagem de linhas com a fonte → rodada 2 (event_params).
Sugestão: praticar consultas curtas direto no console do BigQuery para ganhar fluência de sintaxe com feedback imediato.
Nada precisa ser criado no BigQuery: o dbt cria os datasets na primeira execução.
