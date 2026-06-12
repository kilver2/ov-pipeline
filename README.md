# MD OV Pipeline

## Projectbeschrijving

Een end-to-end datapipeline die open OV-data omzet naar een rapportagelaag voor analyse. Het project geeft inzicht in rijpatronen, marktaandeel en ritdrukte van Nederlandse OV-vervoerders, met Qbuzz als primaire stakeholder.

---

## Architectuur

```text
GTFS API          Feestdagen API
    ↓                   ↓
Python ingestion scripts (utils.py)
    ↓
Databricks - Raw layer (Delta tables via Volumes)
    ↓
dbt - Standardized layer (dims + fct)
    ↓                   ↓
Power BI            dbt - Reporting layer (gold)
(semantisch model)      ↓
                    Metabase
```

---

## Stack

| Tool | Waarom |
|--------|--------|
| Databricks | Schaalbaar lakehouse platform met Delta Tables |
| dbt | Transformaties, testen en documentatie in SQL |
| Python | Ingestion van GTFS- en API-data |
| Power BI | Semantisch model voor analisten |
| Metabase | Kant-en-klaar dashboard voor business users |
| GitHub Actions | CI/CD voor SQL linting en dbt-compilatie |

---

## Databronnen

### GTFS Nederland
Statische OV-data met ritten, routes, haltes en vervoerders via **ovapi.nl**.

### Feestdagen API
Nederlandse feestdagen via **date.nager.at**.

---

## Projectstructuur

```text
ov-pipeline/
├── ingestion/
│   ├── utils.py
│   ├── ingest_gtfs.py
│   └── ingest_feestdagen.py
│
├── dbt_ov/
│   ├── models/
│   │   ├── standardized/
│   │   └── reporting/
│   ├── macros/
│   └── tests/
│
└── .github/
    └── workflows/
        └── ci.yml
```

### Beschrijving

| Bestand / Map | Doel |
|---------------|------|
| `utils.py` | Herbruikbare functies voor Databricks |
| `ingest_gtfs.py` | GTFS-ingestion |
| `ingest_feestdagen.py` | Ingestion van feestdagen |
| `standardized/` | Dimensionele en fact-modellen |
| `reporting/` | Geaggregeerde rapportagetabellen |
| `macros/` | Herbruikbare dbt-macro's |
| `tests/` | Custom generic tests |
| `ci.yml` | GitHub Actions pipeline |

---

## Datamodel

### Standardized Layer

| Tabel | Beschrijving |
|---------|-------------|
| `dim_bureau` | Vervoerders |
| `dim_routes` | Lijnen met vervoerstype |
| `dim_haltes` | Haltes met locatiegegevens |
| `dim_kalender` | Datums met weekend- en feestdaginformatie |
| `dim_feestdagen` | Nederlandse feestdagen |
| `fct_ritten` | Feittabel met alle ritten |

### Reporting Layer

| Tabel | Beschrijving |
|---------|-------------|
| `agg_trips_per_agency` | Ritten per vervoerder |
| `agg_trips_per_day` | Ritten per dag van de week |
| `agg_trips_per_route` | Drukste routes |
| `agg_rituitval` | Geplande uitzonderingen per vervoerder |

---

## Datakwaliteit

De pipeline bevat meerdere controles om datakwaliteit te waarborgen:

- Deduplicatie via de custom `deduplicate` macro
- Opschonen van lege strings via `clean_empty_strings`
- Custom tests:
  - `no_duplicates`
  - `valid_latitude`
- Gebruik van:
  - `dbt_utils`
  - `dbt_expectations`

---

## Rapportage

### Power BI

Power BI wordt aangesloten op de **standardized layer**.

Kenmerken:

- Stermodel met relaties tussen dimensies en feiten
- DAX-measures voor KPI's
- Flexibele self-service analyse

**Voordeel:** analisten kunnen zelfstandig slicen en analyseren zonder nieuwe aggregatietabellen te bouwen.

### Metabase

Metabase wordt aangesloten op de **reporting (gold) layer**.

Kenmerken:

- Vooraf berekende businesslogica
- Geen aanvullende measures nodig
- Direct inzetbare dashboards

**Voordeel:** business users krijgen direct bruikbare inzichten zonder technische kennis.

---

## CI/CD

Bij iedere push naar de `main` branch wordt automatisch uitgevoerd:

1. **SQLFluff**
   - SQL linting op alle dbt-modellen

2. **dbt compile**
   - Validatie dat alle modellen succesvol compileren

---

## Installatie

### 1. Installeer dependencies

```bash
uv add requests pandas databricks-sdk \
databricks-sql-connector python-dotenv \
pyarrow dbt-databricks
```

### 2. Configureer omgevingsvariabelen

Maak een `.env` bestand aan:

```env
DATABRICKS_HOST=jouw-host
DATABRICKS_TOKEN=jouw-token
DATABRICKS_HTTP_PATH=jouw-http-path
```

### 3. Download GTFS-data

```powershell
Invoke-WebRequest `
  -Uri "https://gtfs.ovapi.nl/nl/gtfs-nl.zip" `
  -OutFile "gtfs-nl.zip"

Expand-Archive gtfs-nl.zip -DestinationPath data/gtfs-nl
```

### 4. Run ingestion

```bash
uv run ingestion/ingest_gtfs.py
uv run ingestion/ingest_feestdagen.py
```

### 5. Run dbt

```bash
cd dbt_ov

dbt deps
dbt run
dbt test
```

---

## Ontwerpkeuzes

### Waarom GTFS-data?

GTFS is de wereldwijde standaard voor openbaarvervoersdata en bevat meerdere entiteiten zoals routes, haltes, vervoerders en ritten. Hierdoor kan een rijke dimensionele datastructuur worden opgebouwd.

### Waarom twee rapportagetools?

#### Power BI (Standardized Layer)

- Flexibele analyseomgeving
- Semantisch model voor analisten
- Self-service BI

#### Metabase (Reporting Layer)

- Vooraf gedefinieerde inzichten
- Geen technische kennis vereist
- Snelle adoptie door business users

De businesslogica wordt slechts één keer in dbt gedefinieerd en niet verspreid over meerdere rapportagetools.

### Waarom Databricks?

Databricks biedt:

- Schaalbare verwerking van grote datasets
- Delta Tables met ACID-transacties
- Time Travel-functionaliteit
- Data lineage en governance via Unity Catalog

Hierdoor ontstaat een robuust en toekomstbestendig data-platform.