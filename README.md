OV Pipeline
Projectbeschrijving
Een end-to-end datapipeline die open OV-data omzet naar een rapportagelaag voor analyse. Het project geeft inzicht in rijpatronen, marktaandeel en ritdrukte van Nederlandse OV-vervoerders, met Qbuzz als primaire stakeholder.
Architectuur
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
Stack
ToolWaaromDatabricksSchaalbaar lakehouse platform met Delta tablesdbtTransformaties, testen en documentatie in SQLPythonIngestion van GTFS en API dataPower BISemantisch model voor analistenMetabaseKant-en-klaar dashboard voor business usersGitHub ActionsCI/CD voor SQL linting en dbt compilatie
Databronnen

GTFS Nederland — statische OV data met ritten, routes, haltes en vervoerders via ovapi.nl
Feestdagen API — Nederlandse feestdagen via date.nager.at

Projectstructuur
ov-pipeline/
├── ingestion/
│   ├── utils.py              # Herbruikbare functies voor Databricks
│   ├── ingest_gtfs.py        # GTFS data ingestion
│   └── ingest_feestdagen.py  # Feestdagen API ingestion
├── dbt_ov/
│   ├── models/
│   │   ├── standardized/     # Dims en fct tabellen
│   │   └── reporting/        # Geaggregeerde gold tabellen
│   ├── macros/               # Herbruikbare SQL macros
│   └── tests/                # Custom generic tests
└── .github/
    └── workflows/
        └── ci.yml            # GitHub Actions CI pipeline
Datamodel
Standardized layer:

dim_bureau — vervoerders
dim_routes — lijnen met vervoerstype
dim_haltes — haltes met locatie
dim_kalender — datums met feestdagen en weekendinfo
dim_feestdagen — Nederlandse feestdagen
fct_ritten — feittabel met alle ritten

Reporting layer:

agg_trips_per_agency — ritten per vervoerder
agg_trips_per_day — ritten per dag van de week
agg_trips_per_route — drukste routes
agg_rituitval — geplande uitzonderingen per vervoerder

Datakwaliteit

Deduplicatie via custom deduplicate macro
Lege strings gecleand via clean_empty_strings macro
Custom tests: no_duplicates, valid_latitude
dbt_utils en dbt_expectations voor geavanceerde tests

Rapportage
Power BI — semantisch model op de standardized laag:

Relaties tussen dims en fct tabel
DAX measures voor KPIs
Voordeel: analisten kunnen zelf slicen op elke dimensie zonder nieuwe tabellen te bouwen

Metabase — dashboard op de reporting/gold laag:

Business logica al verwerkt in dbt
Geen measures nodig in de tool zelf
Voordeel: business users krijgen kant-en-klare inzichten zonder technische kennis

CI/CD
Bij elke push naar main runt automatisch:

SQLFluff — SQL linting op alle dbt modellen
dbt compile — controleert of alle modellen compileren

Hoe te runnen
1. Installeer dependencies:
bashuv add requests pandas databricks-sdk databricks-sql-connector python-dotenv pyarrow dbt-databricks
2. Maak een .env bestand aan:
DATABRICKS_HOST=jouw-host
DATABRICKS_TOKEN=jouw-token
DATABRICKS_HTTP_PATH=jouw-http-path
3. Download GTFS data:
bashInvoke-WebRequest -Uri "https://gtfs.ovapi.nl/nl/gtfs-nl.zip" -OutFile "gtfs-nl.zip"
Expand-Archive gtfs-nl.zip -DestinationPath data/gtfs-nl
4. Run ingestion scripts:
bashuv run ingestion/ingest_gtfs.py
uv run ingestion/ingest_feestdagen.py
5. Run dbt:
bashcd dbt_ov
dbt deps
dbt run
dbt test
Keuzes en motivaties
Waarom GTFS data?

GTFS is de standaard voor OV data wereldwijd en bevat meerdere entiteiten zoals routes, haltes en ritten. Dit maakt het mogelijk om een rijke dimensionele structuur te bouwen.
Waarom twee rapportagetools?

Power BI op de silver laag geeft analisten de flexibiliteit om zelf te analyseren via een semantisch model. Metabase op de gold laag geeft business users kant-en-klare inzichten zonder technische kennis. De business logica zit één keer in dbt en niet verspreid over meerdere tools.
Waarom Databricks?

Delta tables geven ACID transacties, tijdreizen en schaalbaarheid. Unity Catalog zorgt voor data governance en lineage.