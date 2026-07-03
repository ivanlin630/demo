# 征服收益鏈（佔村點火）— Plan

> Spec：`docs/superpowers/specs/2026-07-03-conquest-yield-chain-design.md`（先整份讀）。
> 序:Task1 A 治權（核心）→ Task2 B margin → Task3 C 收取驗 → Task4 長窗。

## Task 1 — A. 翻旗接治權
**檔**:`npc_combat_system.gd`（決勝尾）、`outpost_system.gd`
1. `_end_combat` capture 翻旗處:敗方=resident 村隊存活 → 治權隨旗（複用 `_try_subjugate` 語意:併入勝方 faction;勝方獨立→found_subjugate 既有路 create_faction）。**注意與既有 `_try_subjugate` 呼叫（決勝尾已有）的去重/順序**——理想=同一事件一次處理,勿雙 subjugate。
2. 鬼村路:敗方滅/走 → 翻旗即可（residency 既有接手）,探針 `yield.flip_ghost`。
3. 探針:`yield.flip_with_rule`/`yield.works_tile_pass`（翻旗後該 tile 生產 tick 真跑,Probe guard 在 manufacturing/harvest works 判定點——或 harness 側驗,實作選侵入最小者）。
4. headless 測:決勝於村→同 faction→works_tile true→產出跑;獨立勝方→立國;鬼村→翻旗+owner 可派駐。

## Task 2 — B. 圍城 margin gate
**檔**:`faction_ai_system.gd`（僅 `_find_occupy_target`）
1. gate 補:己方 armed（真值）≥ `believed pop_est × ARMED_RATIO_FLOOR × OCCUPY_WIN_MARGIN`（TEST VALUE 1.3）——村防下限估用 belief pop 非 armed_est 表象。
2. headless 測:pop8 狼對 pop20 村不 applicable;壯狼（armed 夠）applicable。

## Task 3 — C. 收取閉環驗
1. 追一遍:村產出→tile 公庫→owner tax/granary→owner `effective_food`（異地 roam 含）。有洞修最小洞（既有 bank/tax 內）,無洞寫測固定。
2. headless 測:佔村 owner 異地,村產出 N 日後 owner effective_food 增。

## Task 4 — 長窗驗收
`LW_SEED=1337 LW_MONTHS=6 LW_DIAG=1`（輸出落檔）:
- **雙引擎弧一段**:狼 raid→captive→同化→pop↑→佔村→flow 轉正（per-wolf 曲線+yield 探針鏈）。
- found faction 含征服路（found_subjugate fire）。
- 不 over-war（隊數/attrition sanity）;asm 分流順記（(c) 殘留佔比,修後自然變化）。
- 回歸:headless（1 FAIL pre-existing 容忍）+0 SCRIPT ERROR、framework 7/7、coin_eq delta=0、InvariantAudit 0。

## Handback
`2026-07-03-conquest-yield-chain.md`:治權去重處理、弧證據（哪隻狼走完哪段）、margin 值、收取鏈洞（若有）、TEST VALUE 清單。

## 注意
- Godot wrapper;長窗 5400 背景;輸出先落檔。1 FAIL pre-existing。
- 硬約束:零新判斷器/系統;守恆走 AnonTier/bank;無新 latch;禁碰 asm 值/envoy/馬/diplomatic。
- 弧不必一跑全走完（6 月窗）——每段 fire 過+至少一狼串兩段以上即收,全弧=軌3 二考看。
