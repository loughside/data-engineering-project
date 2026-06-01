# ⚽ Football Analytics Data Engineering Project

A medallion architecture data warehouse built on Azure SQL Database, transforming publicly available football data into analytics-ready tables and views for consumption in Power BI.

**Stack:** Azure SQL Database | Python | dbt | Git | Visual Studio Code

🔗 **dbt Documentation:** https://loughside.github.io/data-engineering-project/

---

## 🏗️ Architecture

This project follows a medallion architecture with three layers of data transformation:

**🥉 Bronze — Raw Ingestion**
Python's `requests` library calls the football-data.org API and loads raw JSON responses into Azure SQL Database with no transformation applied. Bronze tables are append-friendly and never overwritten — they represent the data exactly as it arrived from the source.

**🥈 Silver — Cleaned & Normalised**
dbt transforms bronze data into 3NF-normalised tables. Entities are separated (areas, competitions, teams, seasons, matches), foreign keys are enforced via dbt tests, and audit timestamps are applied. Silver is owned entirely by dbt — no manual DDL.

**🥇 Gold — Dimensional Model**
Kimball-style star schema designed for BI consumption. Dimension tables are wide and denormalised for ease of use. Two fact tables capture match-level and team-match-level data at different grains.

A semantic layer of views sits on top of the gold tables, pre-joining and pre-aggregating data to answer specific analytical questions without requiring the consumer to understand the underlying model.

### Gold Views

| View                | Description                                                                                      |
| ------------------- | ------------------------------------------------------------------------------------------------ |
| `vw_season_summary` | Full season record per team per competition — overall, home, and away breakdowns in a single row |
| `vw_match_results`  | One row per match with competition, teams, scores, and result — no IDs, names only               |
| `vw_team_form`      | All matches per team ranked by recency — filter to any team to see their last 5 results          |
| `vw_head_to_head`   | Aggregated head-to-head record for every team pairing in the dataset                             |
| `vw_league_table`   | Cumulative league table at any matchday for any competition                                      |

---

## 🛠️ Stack

| Tool               | Purpose                                                                                                      |
| ------------------ | ------------------------------------------------------------------------------------------------------------ |
| Python             | API ingestion via `requests`, date dimension generation, database connectivity via `pyodbc` and `SQLAlchemy` |
| T-SQL              | DDL for bronze layer, exploratory analysis, data quality validation                                          |
| dbt                | All silver and gold transformations — version controlled, tested, and documented                             |
| Azure SQL Database | Cloud-hosted relational database (free tier)                                                                 |
| GitHub             | Version control and dbt documentation hosting via GitHub Pages                                               |
| VS Code            | Development environment with SQL Server extension and PowerShell terminal                                    |

---

## 📡 Data Source

**football-data.org** — free tier

The free tier provides access to five of Europe's top leagues:

| Competition            | Code |
| ---------------------- | ---- |
| English Premier League | PL   |
| German Bundesliga      | BL1  |
| Spanish La Liga        | PD   |
| Italian Serie A        | SA   |
| French Ligue 1         | FL1  |

Endpoints used: `competitions` and `matches`.

> ⚠️ API rate limit: 10 calls per minute.

---

## 📁 Repo Structure

```

data-engineering-project/
├── .env # Environment variables (gitignored)
├── .gitignore
├── requirements.txt # Pinned Python dependencies
├── docs/ # dbt documentation (hosted via GitHub Pages)
├── .github/workflows/ # GitHub Actions (placeholder)
├── ingestion/
│ └── src/
│ ├── clients/ # API client
│ ├── loaders/ # SQL loader
│ └── pipelines/ # competitions and matches pipelines
├── scripts/
│ └── generate_dim_date.py # Generates dim_date seed CSV
├── sql/
│ ├── schemas/ # Schema creation DDL
│ ├── bronze/ # Bronze table DDL
│ └── silver/ # Silver table DDL (reference only — managed by dbt)
├── transform/ # dbt project
│ ├── models/
│ │ ├── silver/ # 3NF normalised models
│ │ └── gold/ # Star schema + semantic views
│ └── seeds/
│ └── dim_date.csv # Date dimension seed file
└── tests/ # Python connection and API tests

```

---

## ▶️ How to Run

### Prerequisites

- Python 3.11+
- An Azure SQL Database instance
- A football-data.org API key (free tier)
- dbt-core and dbt-sqlserver installed (see `requirements.txt`)

### Setup

1. Clone the repo
2. Create and activate a virtual environment:

```powershell
python -m venv venv
.\venv\Scripts\Activate.ps1
pip install -r requirements.txt
```

3. Create a `.env` file in the project root with the following variables:

```
API_KEY=your_football_data_api_key
DB_SERVER=your_azure_sql_server
DB_NAME=your_database_name
DB_USERNAME=your_username
DB_PASSWORD=your_password
```

4. Configure your dbt profile at `~/.dbt/profiles.yml`

### Ingestion

Run from the project root:

```powershell
python -m ingestion.src.pipelines.competitions_pipeline
python -m ingestion.src.pipelines.matches_pipeline
```

### Transform

Run from inside the `transform/` directory:

```powershell
dbt seed          # Load dim_date
dbt run           # Build all models
dbt test          # Run data quality tests
dbt docs generate # Regenerate documentation
```

---

## 📋 Notes

- The football-data.org free tier does not provide player-level data or in-match events. All analysis is derived from match results only.
- This project was built as a learning exercise to transition from data analysis to data engineering. The stack mirrors common production patterns at smaller scale.

```

```
