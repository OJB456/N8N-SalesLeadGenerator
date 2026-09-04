# n8n Claude Lead Gen Pipeline

Self-hosted n8n lead generation scaffolding with Claude extraction, personalization, HubSpot sync, and Slack alerts.

## What is included

- `docker-compose.yml` for `postgres` and `n8n`
- `sql/init.sql` to create `n8n` and `leadgen` schemas and the `leadgen.leads` table
- `workflows/lead-gen-pipeline.json` n8n workflow export
- `schemas/*.json` Claude structured output schemas
- `prompts/*.md` system prompt templates
- `.env.example` sample environment variables

## Setup

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

The Postgres container will run `sql/init.sql` automatically on first boot.

## n8n credential setup

After the services are running, open n8n at `http://localhost:5678` and authenticate with the basic auth credentials you configured.

Create the following credentials in n8n:

- **Anthropic HTTP Header Auth**
  - Header Name: `x-api-key`
  - Header Value: `{{$env.ANTHROPIC_API_KEY}}`
- **HubSpot API Key** or Bearer token credential
- **Slack webhook** can be used either with a Slack webhook credential or via `{{$env.SLACK_WEBHOOK_URL}}` in the Slack node.

## Import the workflow

Import the pipeline via n8n UI or CLI:

```bash
docker compose exec n8n n8n import:workflow --input=/data/workflows/lead-gen-pipeline.json
```

Activate the workflow after import.

## Webhook intake

The workflow exposes a webhook at:

```text
POST http://localhost:5678/webhook/lead-intake
```

Use JSON payloads such as:

```json
{
  "company_name": "Acme Corp",
  "domain": "acme.com",
  "linkedin_url": "https://www.linkedin.com/company/acme-corp",
  "source": "manual-intake"
}
```

## Notes

- Claude calls use `https://api.anthropic.com/v1/messages` with `output_config.format` and JSON schema enforcement.
- The pipeline stores structured lead data in `leadgen.leads`.
- Update the workflow to connect a real Apollo discovery query, HubSpot contact update logic, and Slack notification settings.
