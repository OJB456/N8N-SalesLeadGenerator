# n8n Claude Lead Gen Pipeline

> An event-driven lead qualification pipeline that turns a company intake into structured intelligence, personalized outreach, and downstream sales actions.

This project demonstrates how to combine workflow automation, PostgreSQL, Claude structured outputs, enrichment APIs, and CRM/notification integrations in a self-hosted n8n stack.

## Why this project

Sales teams need more than a raw list of companies. This pipeline normalizes an inbound lead, stores it durably, enriches its public signals, evaluates ICP fit with Claude, generates personalization, and routes the result to the systems where a sales team works.

## Architecture

```text
Webhook intake
  |
  v
Normalize and persist lead ----> PostgreSQL (leadgen.leads)
  |
  v
Discover and enrich company signals
  |
  v
Claude extraction (JSON schema) --> ICP score and reasoning
  |
  v
Claude personalization ---------> HubSpot sync and Slack alert
```

## Highlights

- **Reliable intake:** accepts common company and LinkedIn field aliases and assigns a source.
- **Structured AI output:** Claude responses are constrained by JSON Schema, making the result usable by later workflow steps.
- **Persistent data model:** PostgreSQL stores the lead, enrichment, qualification, and personalization outputs in a dedicated `leadgen` schema.
- **Composable integrations:** API keys and webhook settings are injected through environment variables rather than committed to the repository.
- **Self-hosted development:** Docker Compose runs n8n and PostgreSQL locally with health checks and persistent volumes.
- **Operational routing:** qualified leads can be synchronized to HubSpot and surfaced through Slack.

## Technology

| Layer | Tools |
| --- | --- |
| Automation | n8n workflow export |
| AI | Anthropic Claude Messages API with structured outputs |
| Data | PostgreSQL 16, SQL initialization script |
| Enrichment | Apollo and Firecrawl API integrations |
| Sales operations | HubSpot and Slack integrations |
| Runtime | Docker Compose |

## Repository map

```text
.
├── docker-compose.yml                 # Local n8n and PostgreSQL services
├── sql/init.sql                       # Schemas, tables, and indexes
├── workflows/lead-gen-pipeline.json  # Importable n8n workflow
├── schemas/                           # Claude extraction and personalization contracts
├── prompts/                           # Reusable system prompt templates
├── .env.example                       # Safe configuration template
└── README.md
```

## Quick start

### Prerequisites

- Docker Desktop with Compose
- API credentials for the services you want to enable

1. Copy the example environment file:

```bash
cp .env.example .env
```

2. Fill in the required values in `.env`:

- `ANTHROPIC_API_KEY`
- `APOLLO_API_KEY`
- `FIRECRAWL_API_KEY`
- `HUBSPOT_API_KEY`
- `SLACK_WEBHOOK_URL`
- `POSTGRES_USER`
- `POSTGRES_PASSWORD`
- `N8N_ENCRYPTION_KEY`
- `N8N_BASIC_AUTH_USER`
- `N8N_BASIC_AUTH_PASSWORD`

3. Start the stack:

```bash
docker compose up -d
```

The PostgreSQL container runs `sql/init.sql` automatically on first boot.

## Configure n8n credentials

After the services are running, open n8n at `http://localhost:5678` and authenticate with the basic auth credentials you configured.

Create the following credentials in n8n:

- **Anthropic HTTP Header Auth**
  - Header Name: `x-api-key`
  - Header Value: `{{$env.ANTHROPIC_API_KEY}}`
- **HubSpot API Key** or Bearer token credential
- **Slack webhook** can be used either with a Slack webhook credential or via `{{$env.SLACK_WEBHOOK_URL}}` in the Slack node.

## Import and run the workflow

Import the pipeline via n8n UI or CLI:

```bash
docker compose exec n8n n8n import:workflow --input=/data/workflows/lead-gen-pipeline.json
```

Activate the workflow after import. The workflow is intentionally exported inactive so it can be reviewed before processing live data.

## Webhook contract

The workflow exposes a webhook at:

```text
POST http://localhost:5678/webhook/lead-intake
```

Send a JSON payload such as:

```json
{
  "company_name": "Acme Corp",
  "domain": "acme.com",
  "linkedin_url": "https://www.linkedin.com/company/acme-corp",
  "source": "manual-intake"
}
```

Or with cURL:

```bash
curl -X POST http://localhost:5678/webhook/lead-intake \
  -H "Content-Type: application/json" \
  -d '{"company_name":"Acme Corp","domain":"acme.com","source":"manual-intake"}'
```

## Engineering notes

- Credentials are referenced through n8n environment expressions and `.env` is excluded by `.gitignore`.
- The workflow uses a dedicated database schema so automation tables remain separate from application data.
- Claude extraction and personalization contracts are versionable JSON files, keeping prompt behavior reviewable in Git.
- The Apollo discovery query, HubSpot contact update mapping, and Slack notification content are integration points ready for environment-specific configuration.

## Project status

The repository contains a working local scaffold and importable workflow. The external API credentials and final CRM field mappings are intentionally supplied by the deployer, keeping this example safe to publish and adaptable across sales stacks.

