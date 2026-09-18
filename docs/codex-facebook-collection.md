# Facebook collection — JavaScript-first workflow

## Primary collector

Bulk Facebook collection now uses `facebook-collector.js` in the user's existing logged-in Facebook session.

Codex is **not** the default collector anymore. Use it only when the JavaScript collector cannot reliably interpret a specific case.

## Why

The Facebook feed contains a large number of posts. Browser JavaScript can cheaply perform the mechanical work:
- scan loaded posts;
- detect post date / permalink / post ID;
- maintain progress/checkpoint;
- auto-scroll;
- expand visible "More" / replies controls;
- search visible comments for Tatiana Berlin;
- export candidate `question -> Tatiana answer` pairs.

AI reasoning is reserved for the later review stage.

## Collector responsibilities

The collector should:
1. Scan only top-level Facebook posts.
2. Track `post_date`, `post_url`, and `post_id`.
3. Maintain a checkpoint based on the oldest actually inspected post, not the last accepted case.
4. Expand collapsed post text where possible.
5. Expand a bounded number of relevant comment/reply controls.
6. Detect Tatiana Berlin comments.
7. Bind her answer to the question only when the relationship is sufficiently clear.
8. Mark uncertain/truncated pairs as `incomplete` or skip them.
9. Deduplicate within the run.
10. Export JSON.

## Current export shape

`facebook-collector.js` exports:
- `collector_version`
- `captured_at`
- `page_url`
- `checkpoint`
- `cases[]`: `question`, `tatiana_answer`, `post_date`, `post_url`, `post_id`, `source_url`, `status`, `reason`
- `skipped[]`
- `summary`: `scanned_posts`, `total`, `ok`, `incomplete`, `skipped`

## What collection must NOT do

The browser collector must not:
- decide whether Tatiana is legally correct;
- search BTL, gov.il or Kol Zchut;
- modify Navigator knowledge;
- touch Supabase;
- redesign prompts/routing;
- generate long legal/product analysis.

## Downstream workflow

`raw Facebook pairs -> review -> remove duplicates/noise -> classify -> verify legal rules against official sources -> extract action-playbook deltas -> add regression cases / knowledge as justified`

## Validation principle

Prefer false negatives over false positives.

It is better to miss a case than to connect Tatiana's answer to the wrong user's question.
