# Rights Navigator — project instructions

## Current Facebook collection workflow

The active Facebook collector is **Codex controlling the official Chrome extension and the user's existing Facebook session**.

The Workspace/Agent named **«Коллектор» is currently inactive**. Do not describe it as collecting Facebook data, do not assign current Facebook browsing to it, and do not confuse its role with Codex.

For Facebook benchmark collection, follow `docs/codex-facebook-collection.md`. The default credit-efficient loop is:

`one Codex task -> 10 new accepted real cases -> one inbox JSON -> stop -> separate analysis/fixes -> next 10`

Codex should spend credits primarily on the live Chrome/Facebook work that cannot be done by the rest of the workflow. During collection it should not perform legal research, verify Tatiana's answers, redesign the product, change Supabase/code, or produce long case analyses. If an existing batch runner can send all 10 questions to Navigator in one command, it may be used once; otherwise stop after collection rather than inventing automation inside the collection task.

## Core product principle

Rights Navigator is not a rewritten ChatGPT answer and not a catalog of rights. Its distinctive value is a practical action layer built from real cases.

**Every new real story must add not another answer, but a new piece of an action algorithm.**

When reviewing Facebook/Tatiana cases, designing knowledge cards, routing, retrieval, prompts, schemas, tests or UI, treat this as a mandatory design rule.

## What the user actually needs

The primary user need is not "what does the law say?" but:

- what exactly is happening in my situation;
- which fact changes the outcome;
- what should I do first;
- which document should I obtain;
- where should I send it;
- what wording/status/date matters;
- how do I verify that the process worked;
- what usually goes wrong;
- what should I do if it goes wrong;
- what related right or consequence might I be missing.

The answer should therefore lead with a clear practical sequence of actions. Legal/right information is necessary support, not the final product.

## Operational knowledge layer

For each useful real case, extract a reusable "playbook delta". Prefer storing or encoding the following elements whenever the source supports them:

1. **Trigger / situation pattern** — what real-world problem started the case.
2. **Decisive fact** — the single fact or small set of facts that can change the answer.
3. **First action** — what the person should do before anything else.
4. **Action sequence** — ordered next steps, not a loose list.
5. **Required evidence/documents** — what to collect or request.
6. **Destination / responsible body** — employer, BTL, Tax Authority, municipality, pension fund, housing company, etc.
7. **Correct wording/status/date dependency** — where phrasing, timing or classification matters.
8. **Typical failure mode** — what commonly breaks in practice.
9. **Verification step** — how the person can check that the action was processed correctly.
10. **Fallback / escalation** — what to do after refusal, silence, wrong calculation or missing record.
11. **Connected rights/consequences** — another benefit, tax, severance, waiting period, housing consequence, etc., that the user may not realize is linked.

Do not fabricate these elements. If a real case or official source does not support one, leave it unknown.

## Response design rule

For user-facing answers, prefer this order:

1. **Short conclusion** — what appears to apply.
2. **What to do now** — concrete ordered steps.
3. **What to prepare/check** — documents, dates, wording, status.
4. **What can go wrong / common mistake** — only when grounded in real cases or official procedure.
5. **How to verify the result**.
6. **What to do if it fails**.
7. **Official basis/source**.
8. **One decisive clarification**, only if it can materially change the plan.

Avoid showing users statistics about how many similar cases were seen unless they explicitly ask. Use case experience internally to improve the instruction, not as the main output.

## How to treat simple entitlement questions

Even when the user only asks "am I entitled to X?", do not stop at a reference-style yes/no answer if the real-case corpus supports a practical layer.

Add the most useful unique operational information, for example:

- whether the benefit is automatic or requires an application;
- what must match in agency records;
- where to check that the benefit was actually activated;
- what people commonly confuse with this right;
- what document or wording prevents a predictable problem;
- what immediate next step preserves the right;
- what related consequence is easy to overlook.

This operational addition is one of the main ways Navigator must differ from BTL, Kol Zchut and generic web-enabled AI.

## Knowledge-source hierarchy

- Official Israeli sources establish rules and current legal/administrative requirements.
- Tatiana/real Facebook cases are valuable for discovering operational patterns, failure modes, missing facts, real wording and practical sequences.
- Tatiana answers are benchmark/practice material, not automatic legal truth. Verify substantive rules before encoding them as authoritative knowledge.
- Kol Zchut is a secondary explanatory source, not the unique product layer.

## What not to build

Do not turn the corpus into:

- a pile of FAQ answers;
- a paraphrase of BTL/Kol Zchut;
- a generic "AI lawyer" prompt;
- a system that merely produces longer answers than ChatGPT;
- a dashboard of counts of similar cases for ordinary users.

The target is a **map of real implementation of rights**: situation -> decisive fact -> action sequence -> verification -> recovery path.

## Benchmark principle

When comparing Navigator with ordinary ChatGPT/Astra, allow the generic system normal web access. The benchmark is not meant to cripple the competitor. Navigator should demonstrate value from its proprietary real-case operational layer: better identification of decisive facts, more reliable action sequences, fewer practical dead ends, clearer verification/fallback steps, and disciplined use of verified sources.

## Development check for every new case

Before considering a case "processed", ask:

- Did we learn a new rule? If yes, encode and verify it.
- Did we learn a new **action step, decision point, failure mode, verification step or escalation path**? If yes, encode that operational delta.
- If the case adds neither, it may be useful as a regression test but should not create duplicate knowledge.

This principle should guide future routing, schemas, migrations, prompts, retrieval and UI changes.