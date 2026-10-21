# CLAUDE.md — Projeto de portfólio dbt + BigQuery (GA4)

## 1. Objetivo do projeto

Projeto pessoal de desenvolvimento em **engenharia de analytics** com **dbt + BigQuery**, usando dados de GA4. Tenho domínio de GA4 (eventos, parâmetros, sessões, atribuição) e SQL avançado, e pouca prática com dbt (modelagem em camadas, testes, modelos incrementais, documentação).

Objetivos, nesta ordem:

1. **Aprender dbt de verdade**, a ponto de explicar e defender cada decisão técnica.
2. **Ter um repositório público no GitHub** que mostre o projeto.

Se tiver que escolher entre ir mais rápido e eu entender, escolha eu entender.

## 2. Regras de colaboração (MUITO IMPORTANTE)

### O que você FAZ por mim
- Setup do ambiente: venv, instalação do `dbt-bigquery`, `profiles.yml`, `dbt init`, `.gitignore`.
- Arquivos de configuração e YAML: `dbt_project.yml`, `sources.yml`, `schema.yml` (testes e descrições), `packages.yml`.
- Rodar comandos (`dbt debug`, `dbt run`, `dbt test`, `dbt build`, `dbt docs generate`) e interpretar os erros comigo.
- Commits e push no Git. Commits de setup/config/YAML feitos por você levam a linha `Co-Authored-By: Claude`; commits de modelos SQL e macros escritos por mim saem **sem** essa linha.
- Rascunho do README (que eu revisarei).

### O que EU escrevo e você revisa
- **Todos os modelos SQL** (staging, intermediate, marts), o modelo incremental e as macros.
- Antes de cada modelo, descreva o objetivo e me dê **dicas progressivas**, não a solução:
  1. Primeiro: o que o modelo precisa entregar (granularidade, colunas, regra de negócio).
  2. Se eu travar: uma dica conceitual.
  3. Se eu ainda travar: um trecho parcial ou pseudocódigo.
  4. Solução completa só se eu pedir explicitamente com "me mostra a solução".
- Ao revisar meu SQL, aponte erros, riscos (duplicação, granularidade errada, custo de query) e alternativas. Seja direto, sem elogio vazio.

### Como explicar
- **Em todo SQL (meu ou seu), detalhe o que cada comando e cláusula faz**, para fixação. Ex.: o que o `UNNEST` faz, por que o `QUALIFY`, o que a window function calcula.
- Explique conceitos de dbt sempre ligando ao "porquê" de negócio e de engenharia (ex.: por que staging é 1:1 com a fonte, por que marts não leem direto da source).
- Conversa em **português**. Código, nomes de modelos, commits e README em **inglês**.

### Checagem de entendimento
Ao final de **cada etapa** do plano, me faça **3 perguntas técnicas** sobre o que acabamos de construir (ex.: "Por que esse modelo é incremental e qual a estratégia de unique_key?"). Avalie minhas respostas e aponte lacunas.

Regra de ouro: **não faça commit de um modelo que eu não consiga explicar em voz alta.**

## 3. Stack e ambiente

- Sistema: **Windows**, terminal no VS Code.
- **Python 3.11** + ambiente virtual (`.venv`).
- **dbt Core** com adapter **dbt-bigquery**.
- **BigQuery**, autenticação via `gcloud auth application-default login` (OAuth, sem chave JSON).
- **Git + GitHub** para versionamento.
- **Looker Studio** para o dashboard final.

### Fonte de dados
Dataset público de GA4 de e-commerce:
`bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_*`
(tabelas diárias particionadas por sufixo `_TABLE_SUFFIX`, dados de nov/2020 a jan/2021, localização `US`).

### Custo
- Use filtros por `_TABLE_SUFFIX` durante o desenvolvimento para limitar o volume lido.
- O `profiles.yml` tem `maximum_bytes_billed` como trava de custo por query.
- O projeto do BigQuery **não está em sandbox** (verificado: MERGE/INSERT funcionam), então modelos incrementais com `merge` são viáveis.

### Segurança
- **Nunca** versione `profiles.yml`, credenciais, IDs sensíveis ou a pasta `.venv`.

## 4. Arquitetura alvo

```
models/
  staging/ga4/
    _ga4__sources.yml
    _ga4__models.yml
    stg_ga4__events.sql          -- 1 linha por evento, colunas tipadas e renomeadas
  intermediate/
    int_ga4__sessions.sql        -- 1 linha por sessão (user_pseudo_id + ga_session_id)
    int_ga4__user_journeys.sql   -- sequência de eventos/páginas por sessão
  marts/
    fct_sessions.sql             -- fato de sessões (incremental)
    fct_ecommerce_funnel.sql     -- funil view_item → add_to_cart → begin_checkout → purchase
    mart_channel_performance.sql -- sessões, conversões e receita por source/medium/campaign
macros/
  get_event_param.sql            -- extrai parâmetro do event_params por chave e tipo
```

Convenções: prefixos `stg_`, `int_`, `fct_`, `dim_`, `mart_`; staging materializado como view; marts como table ou incremental.

## 5. Plano (5 etapas)

### Etapa 1 — Base e setup
- [ ] Curso dbt Fundamentals (posso tirar dúvidas).
- [x] Criar venv, instalar `dbt-bigquery`, rodar `dbt init`, configurar `profiles.yml`.
- [x] `dbt debug` passando.
- [x] Verificar sandbox e impacto em DML.
- [x] `.gitignore`, repositório no GitHub, primeiro commit.
- [ ] Checagem de entendimento.

### Etapa 2 — Staging
- [ ] Declarar a source do GA4 com descrição e freshness (se fizer sentido).
- [ ] **Eu escrevo** `stg_ga4__events` com UNNEST dos parâmetros principais.
- [ ] **Eu escrevo** a macro `get_event_param` e refatoro o staging para usá-la.
- [ ] Testes: `not_null`, `accepted_values` (ex.: event_name), descrições das colunas.
- [ ] Checagem de entendimento.

### Etapa 3 — Intermediate e marts
- [ ] **Eu escrevo** `int_ga4__sessions` (atenção à chave de sessão e à granularidade).
- [ ] **Eu escrevo** `fct_ecommerce_funnel` e `mart_channel_performance`.
- [ ] Testes: `unique` + `not_null` nas chaves, `relationships` entre camadas.
- [ ] Commits ao longo da etapa.
- [ ] Checagem de entendimento.

### Etapa 4 — Nível avançado
- [ ] **Eu escrevo** `fct_sessions` como incremental (discutir `unique_key`, `incremental_strategy`, partição e clustering no BigQuery).
- [ ] Teste customizado (singular test), por exemplo: receita nunca negativa, ou funil nunca com mais compras que visualizações.
- [ ] `dbt docs generate` e revisão da linhagem.
- [ ] Dashboard no Looker Studio em cima dos marts.
- [ ] Checagem de entendimento.

### Etapa 5 — Vitrine
- [ ] README em inglês: problema de negócio, arquitetura, diagrama/linhagem, decisões de modelagem, como rodar, principais insights, prints.
- [ ] Revisão final do repositório (nomes, descrições, testes passando com `dbt build`).
- [ ] Revisão geral: 10 perguntas sobre o projeto inteiro.

## 6. Protocolo de cada sessão

1. Ao iniciar, leia este `CLAUDE.md` e o `PROGRESS.md`.
2. Diga em 2–3 linhas onde paramos e qual é o próximo passo.
3. Ao encerrar, atualize o `PROGRESS.md` com: o que foi feito, decisões tomadas e o porquê, dúvidas em aberto e próximo passo.

## 7. Definição de pronto do projeto

- `dbt build` roda do zero sem erros.
- Todo modelo tem descrição e pelo menos os testes de chave.
- Existe pelo menos 1 modelo incremental, 1 macro e 1 teste singular.
- README permite entender o projeto em 2 minutos.
- **Eu consigo explicar cada modelo, cada teste e cada decisão sem consultar nada.**
