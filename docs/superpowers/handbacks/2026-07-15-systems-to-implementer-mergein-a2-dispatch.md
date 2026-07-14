---
from: systems
to: implementer
status: open
topic: "[DISPATCH] Fix A-2 併入 look-before-leap——同分支feat/desperation-food-seeking;R②CLEAN;host對應鎖定;TDD"
---

# Dispatch：Fix A-2 併入 look-before-leap（完成 A 覆蓋）

spec：`docs/superpowers/specs/2026-07-15-desperation-food-seeking.md` **§Fix A-2**（讀該段）。
R②v CLEAN：`2026-07-15-reviewer-to-systems-mergein-r2-clean.md`（4 點全 CLEAN，host 對應已鎖）。
承：QA 抓併入幻覺→systems code 定音確診（`_absorber_accepts` feed_ok 餓世界恆拒）→補 look-before-leap 完成 A。

## 在哪：同分支（A/B 已在此）
worktree `.worktrees/desperation-food-seeking`（`feat/desperation-food-seeking`，含 A/B）。先 `git fetch && git merge origin/main`（拿最新，若有）。

## 做什麼（Fix A gate 家族）
`decision_context.gd` 加 `has_acceptable_join_host: bool`（gather 填）：
- **★host 對應鎖定（R② 抓的關鍵）**：評的 host **鏡射 `options.gd:181 to_task` 同一優先序**——`host = strong_neighbor_id if strong_neighbor_id != -1 else consolidate_target_id`，belief 估**這一個** host（**非兩者 OR**）。
- **honest（感知鐵律）**：對選定 host，`BeliefSystem.best_estimate(state, joiner, host)` 估其糧/pop（**非 god-view 讀 host 真值**）；可達（PathSystem）+ 粗估 `combined_days_est ≥ ABSORBER_MIN_SURVIVE_DAYS × 保守係數` 才 acceptable。無 belief→保守不入。
- `options.gd:103` 併入 applicable 加 `and ctx.has_acceptable_join_host`。
- **不誤殺**：belief 估收得起（含 stale/失真）就入；到場真被拒走既有 release 撲空 emergent。

## 守則（同 A 家族）
純讀 belief/PathSystem，零 state mutation/RNG；憲法零新 try_set（併入既有 dispatch 路不變，只加 applicable gate）。

## TDD
1. 構「餓世界 host 依 belief 估收不起」→ 斷言併入**不入候選**（gate 擋幻覺）。
2. 構「host 依 belief 估收得起」→ 併入入候選（不誤殺）。
3. 構「strong_neighbor 存在但 belief 估收不起 + consolidate_target 收得起」→ 斷言**不入候選**（鏡射 to_task 優先序取 strong_neighbor，非 OR）。
4. 標準：determinism 兩跑同；憲法 sites=29（零新 try_set）；headless 零新增。

## 完成後
→ measurer 全-HD 重跑（Team20+Team18+新死隊，A+B+A-2 全）→ QA 複判連貫窮死（併入不再幻覺）→ blueprint 批 merge。
完成判定 = systems + reviewer/QA。scope 疑義走 `to:systems`（不自標 REDO）。
（乞食強制測 measurer 另跑中，非本 A-2 blocker。）
