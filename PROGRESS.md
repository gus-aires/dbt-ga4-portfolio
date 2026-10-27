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

### ✅ `stg_ga4__events` rodada 1 concluída (2026-10-27) — escrita pelo usuário
- 11 colunas planas: event_name, user_pseudo_id, country, device_category, traffic_source/medium/campaign, event_date (parse_date), event_at (timestamp_micros), transaction_id, purchase_revenue_usd.
- Primeiro `dbt show` e `dbt run` rodados pelo próprio usuário no terminal do VS Code (`.venv\Scripts\dbt.exe ...`). View criada em `dbt_dev_staging` (0 bytes processados).
- Prova da granularidade: fonte e modelo com **328.463** linhas (01–07/11/2020). `count(*)` leu 0 bytes (metadados).
- Custo: cada consulta à view lê ~34,6 MB. Comparativo (dry run): `select *` 1 semana 254,9 MB; 11 colunas 92 dias 453,6 MB; `select *` 92 dias 3.583,7 MB → colunas e período se multiplicam.
- Descoberta: `transaction_id` é NULL em todas as compras (dataset ofuscado; 14 purchases em 01/11/2020) → não serve de chave nem para teste `not_null`. Registrar como limitação no README.
- Checagem: confundiu o papel da CTE `source` (achava que escolhia colunas) e o `_TABLE_SUFFIX` ("filtra colunas"); esclarecido com a "linha de montagem" e a distinção entre a função `{{ source() }}` e a CTE chamada `source`. Resposta final correta: `_TABLE_SUFFIX` corta linhas pelo intervalo de datas.

### Histórico: `stg_ga4__events` (rodada 1, colunas planas)
- Arquivo criado pelo usuário em `models/staging/ga4/stg_ga4__events.sql` (ainda não compila; não commitado).
- 2 tentativas revisadas. Dica nível 3 entregue: CTE `source` pronta + `renamed` com 2 colunas de exemplo (`event_at`, `country`). Falta completar as demais colunas da rodada 1.
- Pontos de atenção recorrentes: aspas simples = texto (nomes de coluna/CTE sem aspas); papel de cada CTE (source = nomes originais, renamed = `expr as novo_nome`); `where` × `having`; erro de digitação `_TABBLE_SUFFIX`.
- Rodada 2 (extrair parâmetros do `event_params` sem multiplicar linhas) ainda não iniciada.

### Aquecimento no console do BigQuery (2026-10-22) — concluído, escrito pelo usuário
1. Eventos por `event_name` (page_view 9.767, user_engagement 8.667, view_item 3.380 em 01/11/2020) — 5 tentativas.
2. 10 eventos com `event_name`, `geo.country as country`, `device.category as device_category` — 4 tentativas.
3. Usuários distintos por país (US 1.096, India 223, Canada 165) — 3 tentativas.
- Regras fixadas: ordem das cláusulas; `*` substitui a lista; aspas simples = valor; `order by`/`group by` compostos; funções dentro do `select`; STRUCT com um ponto; `as` na mesma linha; granularidade primeiro; regra do `group by` (dimensão ou agregação); `count(distinct x)`; custo = colunas lidas, `limit` não reduz custo.
- Analogia do usuário que funcionou: STRUCT = variável de dataLayer no GTM (acesso com ponto). Ponte para a rodada 2: `items.0` no GTM × `UNNEST` + busca por chave no SQL.
- Atenção: erros de digitação em nomes (`_TABBLE_SUFFIX`, `device_categiry`) — reforçar "nome de coluna é contrato".

### Pendências
- Opcional: alerta de orçamento no Billing do GCP.
- Curso dbt Fundamentals (confirmar se foi feito).

### Próximo passo
Rodada 2 do `stg_ga4__events`: extrair `ga_session_id`, `ga_session_number`, `page_location`, `page_referrer` do `event_params` sem multiplicar linhas (UNNEST em subconsulta escalar; ponte com `items.0` do GTM). Depois: macro `get_event_param`, testes e descrições no `_ga4__models.yml`.

### Pendências futuras (sem urgência)
- Python 3.11: bibliotecas Google deixam de dar suporte em 2027-10-24 (FutureWarning no dbt). Avaliar upgrade para 3.12+ antes disso.
Nada precisa ser criado no BigQuery: o dbt cria os datasets na primeira execução.
