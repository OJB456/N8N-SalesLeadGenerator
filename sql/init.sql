CREATE EXTENSION IF NOT EXISTS pgcrypto;
CREATE SCHEMA IF NOT EXISTS n8n;
CREATE SCHEMA IF NOT EXISTS leadgen;

CREATE TABLE IF NOT EXISTS leadgen.leads (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  company_name TEXT NOT NULL,
  domain TEXT UNIQUE NOT NULL,
  linkedin_url TEXT,
  source TEXT,
  industry TEXT,
  tech_stack_signals JSONB,
  pain_points JSONB,
  buying_signals JSONB,
  icp_fit_score INTEGER,
  score_reasoning TEXT,
  status TEXT DEFAULT 'new',
  outreach_subject TEXT,
  outreach_email_body TEXT,
  outreach_linkedin_dm TEXT,
  crm_synced_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ DEFAULT now()
);
CREATE INDEX IF NOT EXISTS idx_leads_status ON leadgen.leads(status);
