# Rights Navigator — project instructions

## Current Facebook collection workflow

The primary Facebook collector is now the **JavaScript collector running in the user's existing Facebook session**.

Use `facebook-collector.js` for bulk collection. Codex is no longer the default collection engine and should be reserved only for exceptional cases that the JavaScript collector cannot resolve reliably.

The collector's job is limited to:
- sequentially scanning the Facebook group feed;
- auto-scrolling backward;
- expanding post/comment text when possible;
- finding reliable `question -> Tatiana answer` pairs;
- saving post date, post URL and post ID;
- maintaining a durable checkpoint;
- deduplicating pairs;
- exporting JSON for downstream review.

It must not do legal research, verify Tatiana's answers, change Supabase, redesign Navigator, or create knowledge cards.

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

1. **Trigger / situation pattern**
2. **Decisive fact**
3. **First action**
4. **Action sequence**
5. **Required evidence/documents**
6. **Destination / responsible body**
7. **Correct wording/status/date dependency**
8. **Typical failure mode**
9. **Verification step**
10. **Fallback / escalation**
11. **Connected rights/consequences**

Do not fabricate these elements. If a real case or official source does not support one, leave it unknown.

## Knowledge-source hierarchy

- Official Israeli sources establish rules and current legal/administrative requirements.
- Tatiana/real Facebook cases are valuable for discovering operational patterns, failure modes, missing facts, real wording and practical sequences.
- Tatiana answers are benchmark/practice material, not automatic legal truth. Verify substantive rules before encoding them as authoritative knowledge.
- Kol Zchut is a secondary explanatory source, not the unique product layer.

## Development check for every new case

Before considering a case "processed", ask:
- Did we learn a new rule? If yes, encode and verify it.
- Did we learn a new action step, decision point, failure mode, verification step or escalation path? If yes, encode that operational delta.
- If the case adds neither, it may be useful as a regression test but should not create duplicate knowledge.
