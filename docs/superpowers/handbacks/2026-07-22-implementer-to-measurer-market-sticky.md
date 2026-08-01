---
from: implementer
to: measurer
status: consumed
topic: "[★WITHDRAWN·HALT 別量] systems 撤回 market-seek stickiness dispatch(方向錯:64% divert metric 本身 bug=arrive% position==move_target 邏輯洞,23/40 已到算沒到;真相 re-seek 空市場 loop=Gate B under-production 非 divert)。★branch feat/market-sticky@d26ae644 丟棄不 merge,別量。等 Gate B production 側修。原文留史↓。 // [measure·behavior-sensitive·deal-flow Gate A] market-seek stickiness → feat/market-sticky@d26ae644。★arrive%(seek→arrive 36%→?)+deal 數+reeval.marketseek_sticky fire+★無 starve 回歸(crisis escape 驗,別餓死買路隊)+doom-delta seed1337/42+8config,帶 §④b 樣本 Probe.bump_sample。TDD 4/4(①RED 驗)、headless 0new、gate 75 removed=0、determinism seed1337 2mo byte-identical(md5 999f58b3,無 RNG)。"
---
# Hand Back: market-seek stickiness（deal-flow Gate A，手不聽腦家族·尋路 task）

承 dispatch `2026-07-22-...-market-seek-stickiness-dispatch.md`（R² CLEAN）。★behavior-sensitive deal-flow。

## 實作摘要
branch `feat/market-sticky@d26ae644`（off local main abbc5159；★禁 origin）已 push（★過 installed pre-push 兩閘）。
- **`_should_reeval`（faction_ai:1877）**：_directive_fresh 後、cadence 前加 sticky guard：`if current_task==TASK_TRADE and move_target!=(-1,-1) and not in_crisis: Probe.bump("reeval.marketseek_sticky"); return false`。in_crisis 用上方已算 var。
- **根**:market-seek(TASK_TRADE 在途)cadence re-eval 被機會性選項搶走 → 64% 到不了市場(sell/buy routing 斷)。TASK_TRADE 非 SURVIVAL/STATION sticky、unified 無子隊 transit-exempt 保護 → 補此層。

## ★survival/escape 保（設計硬約束全守）
- **crisis escape**:`and not in_crisis` → 餓/暴跌 market-seeker 落下方 cadence(/4 快)可 divert 求生。**不餓死買路**。
- **IDLE/stuck/crisis-edge/directive** 上方已 return true → 卡住/新命令/進 crisis 全能打斷。
- **trade-timeout**(:817)抓追不到 zombie → release。**resident 擺攤**(move_target=-1)非在途不受影響。

## 我的驗證
- **TDD** `market_sticky_test` **4/4 PASS**（RED→GREEN；★還原→①在途非 crisis + cadence DUE 返 true=divert，證 sticky load-bearing）。①在途非 crisis→false ②在途+crisis→落 cadence(escape) ③已抵達→正常 ④非 TASK_TRADE→不受影響。
- **headless** `=== DONE ===`，3 fail = **baseline 0 new**。
- **constitution_gate** PASS **sites=75 removed=0**（_should_reeval 非 decision func，guard 不掃）。
- **determinism** seed1337 2mo 2 跑 **byte-identical，md5 `999f58b3`**（無 RNG，純 guard）。

## ★請你量（spec §measure，behavior-sensitive，帶 §④b 樣本）
- **★arrive%（seek→arrive 36%→?）**：主驗——in-transit sticky 後 market-seeker 真到得了市場。
- **deal 數**：sell/buy 成交（routing 斷修好→成交回來）。
- **reeval.marketseek_sticky fire**：Probe 計數 sticky 真擋 divert（可帶 §④b `Probe.bump_sample` 具體 case:哪隊/往哪市場/被啥搶）。
- **★★確認無 starve 回歸**：sticky 別餓死買路隊——**crisis escape 驗**（餓的 market-seeker 落 cadence 求生，doom-delta 不惡化）。
- **doom-delta（seed1337/42）+ 8 config sanity**。
- 你用 `godot --path .worktrees/market-sticky` 跑（★禁原地 checkout）。

## 連動風險
- **market-seeker 在途不 divert**（除 crisis）=預期修（到得了市場）。判準=arrive%↑ + deal↑ + **無 starve 回歸**（crisis escape 保） + doom-delta 不崩。
- ★sticky 過黏風險:若 measurer 量到 market-seeker 卡死追消失的市場 → trade-timeout(:817)該兜;若沒兜到 → flag(timeout 值/機制)。

## out-of-scope
Gate B（under-production=facility 從不完工，weaponsmith HELD 同根）靠 production 軌另修（build-completion 調查在飛）。本刀只 Gate A(routing)。

## 完成判定
task 完成 = systems + reviewer 判。你量完(arrive%/deal/無 starve)→ 餵 blueprint / pre-merge to:systems。我 hold warm 等裁決。
