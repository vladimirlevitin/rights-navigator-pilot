# Codex Facebook collection — credit-efficient workflow

## Current responsibility

The active Facebook collector is **Codex controlling the official Chrome extension and the user's existing Facebook session**.

The Workspace/Agent named **«Коллектор» is currently inactive and must not be treated as the Facebook collector**. Do not assign Facebook browsing to it and do not describe it as doing this work.

Collector identity in saved benchmark files remains `codex-chrome-v1` unless the schema is intentionally changed later.

## Main goal

Use Codex credits almost entirely for the one capability we actually need from Codex: reading the Facebook group in the live Chrome session and reliably extracting real `question -> Tatiana answer` pairs.

Do **not** spend Codex reasoning on legal research, product analysis, source verification, database design, code changes, Supabase changes, or evaluation of Navigator answers. Those tasks are handled outside the collection pass.

## One task = one batch

For each collection run:

1. Open/continue the existing Facebook group session in Chrome.
2. Stay in the same browser session for the whole run.
3. Scan posts sequentially until **10 new accepted cases** are collected.
4. Save all 10 accepted cases in **one JSON file** under `benchmarks/inbox/` using the existing `codex-chrome-v1` schema.
5. Save skipped/rejected items only as short reasons, without long analysis.
6. Commit/push the single batch.
7. Stop. Do not continue collecting the next batch until the current 10 have been reviewed and the Navigator has been adjusted if needed.

Do not create a separate Codex task/chat/run per question.

## What counts as an accepted case

Accept a case when all of the following are true:

- it is a real user question in the Facebook group;
- Tatiana's answer is visibly and reliably attached to that question;
- the full relevant text can be read; expand the post/thread when needed;
- the case is within the broad social/labor/benefits/housing/tax-rights scope used by Rights Navigator;
- it is not a duplicate or near-duplicate of an already saved case;
- names, phone numbers, email addresses and other unnecessary personal identifiers are not stored.

Prefer cases that contain concrete conditions, exceptions, deadlines, documents, procedural failures, interactions between benefits, or a practical "what do I do now?" problem.

## Skip quickly

Skip without extended reasoning when the case is clearly one of these:

- no visible Tatiana answer;
- ambiguous relationship between the answer and the original question;
- duplicate/near-duplicate;
- purely medical question with no social/labor-rights issue;
- visa/citizenship/consular question outside the current pilot;
- consumer dispute unrelated to the pilot;
- ordinary discussion, gratitude, politics, or a standalone informational post rather than a question-answer pair;
- question/answer cannot be expanded enough to capture the full relevant meaning.

A skip reason should be one short sentence. Do not write a legal explanation for a skipped case.

## Chrome-use rules

- Use the existing logged-in Facebook session.
- It is allowed to expand a post, "see more", "view more replies", and the relevant comment thread when necessary to establish the complete question and Tatiana's complete answer.
- Do not open user profiles or external links just to enrich a case.
- Do not collect private-contact information.
- Do not intentionally bypass access controls or use stealth/evasion techniques.
- Keep the browser flow sequential; do not start parallel browsing agents for the same group.

## Credit-saving rules

### 1. No legal analysis during collection

Codex must **not** decide whether Tatiana is legally correct. Copy the case accurately and move on.

Do not:

- search BTL, gov.il or Kol Zchut;
- compare Tatiana with official law;
- propose knowledge cards;
- propose routing changes;
- explain what the case teaches the product;
- grade Navigator.

### 2. No code or Supabase work during collection

Do not edit application code, migrations, Edge Functions, database rows, prompts or schemas during the collection task.

The only repository write should normally be the new benchmark inbox JSON (and, if an existing batch-run script is explicitly invoked, its run-output JSON).

### 3. Keep output terse

At the end report only:

- inbox filename;
- accepted count;
- skipped count;
- commit SHA;
- any collection error that prevented a full batch.

Do not produce a long narrative summary of the ten cases unless explicitly asked.

### 4. Reuse context inside the batch

Do not repeatedly reopen the same group, reread project architecture, reread AGENTS.md, or restate the task after every accepted case. Read the instructions once and keep the same Chrome session until the batch is complete.

### 5. Do not pre-collect future batches

Even if Facebook is open and more cases are visible, stop at 10 accepted cases. The development loop is intentionally:

`10 real cases -> analyze -> verify -> add action-algorithm deltas -> regression test -> next 10`

This avoids spending credits collecting cases before the current batch changes the system.

## Optional batch Navigator run

If there is already a working batch command/script in the repository that accepts the inbox JSON and sends all 10 questions to the current live Navigator, Codex may run that script **once** after saving the inbox file and save one `benchmarks/runs/...json` output.

Rules:

- one command for the whole batch, not 10 separate agent tasks;
- do not analyze the answers;
- do not repair Navigator from inside the collection run;
- report only HTTP success/error counts and the run filename;
- if no existing batch runner is available, do **not** spend Codex credits inventing one during collection; stop after the inbox file and let the main development workflow handle the run.

## Product-development handoff

After the batch is saved, the collection task is finished.

The next stage is performed separately: each real case is reviewed for the product principle in `AGENTS.md` — **every useful real story should add a reusable piece of an action algorithm, not merely another FAQ answer**. Legal rules are verified against official sources before being encoded as authoritative knowledge.
