# Evaluation Rubric — Analytics Engineering Challenge

> **Internal document. Do not share with candidates.**

---

## Scoring Guide

Score each section 1–5:
- **1 — Missing**: Not attempted or fundamentally broken
- **2 — Below expectations**: Attempted but significant gaps
- **3 — Meets expectations**: Solid work with minor issues
- **4 — Exceeds expectations**: Thorough, well-considered approach
- **5 — Exceptional**: Production-quality, demonstrates mastery

---

## 1. Data Modeling (30%)

| Criteria | 1 | 3 | 5 |
|----------|---|---|---|
| **Staging models** | Missing or just SELECT * | Basic cleaning (dedupe, type cast) | Handles all edge cases: duplicates, nulls, case normalisation, future dates |
| **Mart models** | Missing or wrong grain | Correct grain, reasonable metrics | Correct grain with well-thought-out metric definitions, handles edge cases (e.g., division by zero in CTR) |
| **Dimensional modeling** | No dimensions or just raw copies | Basic dimensions with primary keys | SCDs handled (publisher name change), proper surrogate keys, denormalised where useful |
| **Grain documentation** | Not mentioned | Mentioned in model description | Explicit grain definition + uniqueness test for each model |

### Data Quality Issues to Find

The seed data contains **8 intentional issues**. Score based on how many the candidate discovers and handles:

| # | Issue | Difficulty | How to Detect |
|---|-------|-----------|---------------|
| 1 | **Duplicate events** — ~2,000 rows with same `event_id`, different `_loaded_at` | Easy | `SELECT event_id, count() FROM raw.ad_events GROUP BY event_id HAVING count() > 1` |
| 2 | **Mixed-case country codes** — `US`, `us`, `Us`, `Gb` etc. | Easy | `SELECT DISTINCT country_code FROM raw.ad_events ORDER BY country_code` |
| 3 | **NULL campaign_id** for unfilled impressions | Easy | `SELECT count() FROM raw.ad_events WHERE campaign_id IS NULL` — but this is *valid* business logic, not an error. Candidate should recognise the difference. |
| 4 | **Publisher name change** — Publisher 7 has two rows: "PC Gamer Online" and "PC Gamer Digital" with different `updated_at` | Medium | `SELECT publisher_id, count() FROM raw.publishers GROUP BY publisher_id HAVING count() > 1` |
| 5 | **Future-dated events** — ~400 events with timestamps beyond the current date | Medium | `SELECT min(event_timestamp), max(event_timestamp) FROM raw.ad_events` — future dates stand out |
| 6 | **Negative revenue** — ~150 adjustment/chargeback rows | Medium | `SELECT count() FROM raw.ad_events WHERE revenue_usd < 0` |
| 7 | **Orphaned campaign references** — campaign_ids 28, 29, 30 don't exist in `raw.campaigns` | Medium | A `relationships` test in dbt will catch this, or `SELECT DISTINCT campaign_id FROM raw.ad_events WHERE campaign_id NOT IN (SELECT campaign_id FROM raw.campaigns)` |
| 8 | **Bot traffic spike** — Publisher 13 (GameRant) has ~5,000 events concentrated in a 4-hour window on a single day (~16 days into the data window), all from Brazil/mobile/Samsung Internet | Hard | Requires aggregation by publisher + date or investigation of distribution patterns |

**Scoring:**
- Found 0–2: Score 2
- Found 3–4: Score 3
- Found 5–6: Score 4
- Found 7–8: Score 5

**Bonus:** Candidate identifies events for completed campaigns (campaigns 8 and 19 have `status = 'completed'` and `campaign_end_date` in the past, but ad events exist after those end dates). Also: `au_5_3` has `is_active = 0` but events still reference it.

---

## 2. dbt Best Practices (20%)

| Criteria | 1 | 3 | 5 |
|----------|---|---|---|
| **Source definitions** | No `source()` used | Sources defined, descriptions sparse | All sources documented with meaningful column descriptions |
| **ref() chain** | Direct table references | Staging refs marts | Clean DAG: source → staging → marts, no skipped layers |
| **Tests** | No tests | Basic unique/not_null | Comprehensive: unique, not_null, accepted_values, relationships, custom singular test |
| **Documentation** | No descriptions | Model-level descriptions | Model + column descriptions + documented business logic |
| **Naming** | Inconsistent | Follows stg_/dim_/fct_ convention | Consistent naming throughout, including columns (snake_case, no abbreviations or clear abbreviations) |
| **Config** | Default everything | Basic materialisation config | Appropriate materialisation choices for each model, view vs table trade-offs considered |
| **Packages** | None used | dbt-utils installed | Effectively uses macros from packages (e.g., `generate_surrogate_key`, `date_spine`) |

---

## 3. Dashboard & Analysis (25%)

| Criteria | 1 | 3 | 5 |
|----------|---|---|---|
| **Revenue overview** | Missing | Basic line chart or table | Time series with publisher breakdown, clear insights |
| **Fill rate** | Missing | Overall fill rate shown | Broken down by publisher, identifies outliers |
| **Own insight** | Missing | Basic chart or observation | Meaningful investigation — e.g., spots the bot traffic spike, visualises anomalies |
| **Overall design** | Cluttered or unhelpful | Readable, answers questions | Well-organized, tells a story, actionable insights |

---

## 4. Communication (10%)

| Criteria | 1 | 3 | 5 |
|----------|---|---|---|
| **DESIGN.md** | Missing | Brief notes, covers basics | Thorough: modeling rationale, DQ issues, trade-offs, production plan |
| **Commit history** | Single commit | 3-5 commits | 10+ meaningful commits showing iterative development |
| **Interview walkthrough** | Cannot explain own code | Explains main decisions | Fluently navigates code, explains reasoning, answers follow-ups |
| **Git hygiene** | No .gitignore, committed artifacts | Basic hygiene | Clean: no target/, no .env secrets, meaningful .gitignore |

---

## AI / LLM Detection Signals

The following signals may indicate heavy AI assistance. **None are disqualifying on their own** — the walkthrough is the primary verification method.

### Strong Signals
- **Single large commit** with all code — suggests generated-then-committed rather than iteratively developed
- **Walkthrough missing or evasive** — cannot explain decisions or navigate their own code fluently
- **Perfect but generic documentation** — describes concepts accurately but doesn't reference the actual data (e.g., describes deduplication strategy but doesn't mention the specific `_loaded_at` pattern)
- **Missed the bot traffic pattern** — AI tends to handle mechanical issues (dedup, nulls) but misses statistical anomalies that require actually querying the data
- **Over-engineered for the timeframe** — incremental models, complex macros, snapshot tables for every dimension in a 2–4 hour exercise suggests AI scaffolding
- **Inconsistent depth** — perfect model code but can't explain modelling decisions in the walkthrough

### Moderate Signals
- **Boilerplate-heavy DESIGN.md** — reads like a textbook rather than reflecting personal decisions
- **All 8 data quality issues found immediately** — very hard to find all without significant exploration time or reading the init script
- **No mistakes or iterations in git history** — real development involves false starts and corrections
- **Generic metric definitions** — defines fill_rate as `filled / total` without discussing edge cases like unfilled video vs display

### Assessment Protocol
1. **Review commit history first** — look for natural development progression
2. **Read DESIGN.md** — does it reference specific findings from the data, or speak in generalities?
3. **Ask Questions** — this is the strongest signal. Can they:
   - Navigate their own code without reading it for the first time?
   - Explain *why* they chose specific materialisation strategies?
   - Walk through a query they wrote to investigate a data quality issue?
   - Answer a follow-up question about their model that wasn't in the original brief?
4. **Check investigation depth** — the bot traffic pattern requires actually running aggregation queries against the data. It's very unlikely an LLM would identify this without actually querying the data.

### Follow-Up Interview Questions (if AI use is suspected)
1. "Walk me through how you discovered the traffic anomaly you flagged."
2. "Why did you choose views for staging and tables for marts? When would you change that?"
3. "If we added a new dimension — say, ad creative — how would you modify your models?"
4. "How would you handle late-arriving data in a production version of this pipeline?"
5. "Show me the query you used to investigate [specific data quality issue]."

---

## Score Sheet

| Section | Weight | Score (1-5) | Weighted |
|---------|--------|-------------|----------|
| Data Modeling | 30% | | |
| dbt Best Practices | 20% | | |
| Data Quality | 15% | | |
| Dashboard | 25% | | |
| Communication | 10% | | |
| **Total** | **100%** | | **/5.0** |

**Hire threshold:** ≥ 3.5 weighted average

**Flags:**
- [ ] Single commit (AI signal)
- [ ] Suspected heavy AI use
- [ ] Suspected of reading init-db.sql (check if they describe the exact UNION ALL structure, reference internal pipeline comments, or find all 8 issues suspiciously fast without showing exploratory queries)
