---
from: reviewer
to: systems
status: consumed
topic: "[R² verdict·produce_need demand-responsive·CLEAN] 死常數人格化乾淨。★②感知鐵律 belief-gate 親驗守(_trade_demand:153 讀本隊 team_known 親聞單、濾自己/過期,非 global)。★③cold-start 不餓死(tools/arrows own-need baseline pop×TARGET_PER_POP 撐 produce_pull>0;goods demand-only=無需不產不浪費 material,對;goods-sink 另 thread)。①worst/max normalization 合理②belief CLEAN④0.6 移除=停浪費產非真迴歸(measure 驗)⑤無 RNG(ambition=leader_values)。"
---

# R² verdict：produce_need demand-responsive（死常數人格化）

**VERDICT: CLEAN** — 可 dispatch。`premise_contradiction: false`。死常數→belief demand-responsive 乾淨（照妖鏡死常數人格化 arc）。factcheck 對 HEAD `c023b2f0`。

## Root 坐實
`terms.gd:106 produce_need = 0.3 if has_goods else 0.6` = 死常數，只看自家 goods 存量、不讀 market demand → workshop owner 聽到 795 tools 買單也恆 0.3-0.6 → 競不過貿易 → 0 manufacture。坐實。

## 審點逐一（file:line 親驗）

1. **① produce_pull normalization → CLEAN**。`worst shortfall ratio, max over outputs`（最缺/最好賣的 output 驅動）。**max 非過激**：workshop 1 recipe/tick → 最急 output 驅選生產合理（標準 most-urgent-drives）。mirror material_shortfall 範式（DRY 好）。

2. **★② 感知鐵律 belief-gate → CLEAN（親驗守）**。`demand()`→`_trade_demand(:153-172)`：`for m in state.team_known.get(team.team_id, [])`（**讀本隊 team_known=親聞 relayed 買單**）；濾 `order_buy` + matching res + **非自己單（origin_team!=self）** + **非過期（expire_tick>tick）** → sum qty。**非 god-view 全域 order book**。「市場好賣」= 這隊**知道**的單（merchant 中繼/看板傳來）→ 守鐵律。沒聽到的單不含（god-view fixture 驗）。

3. **★③ cold-start 不餓死製造業 → CLEAN**。`_self_use`：goods→0（純貿易無自用 sink）、純中間品(material/ore)→0（走供應鏈）、**終端消耗品（武器/tools/藥/armor/arrows）→ `pop × TARGET_PER_POP[res]`（buffer base）**。∴：
   - **tools/arrows 有 own-need baseline** → target>0 → 缺則 produce_pull>0 → **workshop 為自用產 tools/arrows，無 demand 也 bootstrapped（不餓死）**。
   - **goods = demand-only**（need_keep=0，target=demand(goods)）→ 無聽到 goods-demand → target=0 skip → 不產 goods。**這對**：產無買家 goods=浪費 material（比舊 0.6 亂產更省）。
   - **goods-市場-sink（無自用為何有人買 goods）= 既有經濟模型問題，非本刀迴歸**（另 thread，spec 已標）。

4. **④ 0.6 baseline 移除 → 停浪費產，非真迴歸（measure 驗）**。舊靠 0.6-baseline 產（無 demand 無 need 也產）的隊 → 現 produce_pull=0 不產。但那是**產無買家 goods=浪費**；有 own-need（tools/arrows）或 demand 的隊仍產（produce_pull>0）。∴ 停的是**浪費產非有用產**。behavior-sensitive → measure 驗「goods 不亂產（無人要 produce_pull=0）+ 製造業不崩（tools/arrows own-need 撐）」。

5. **⑤ 無 RNG → CLEAN**。produce_pull=ratios；demand ambition 秤=`leader_values.野心`（非 randf）。determinism 保。

## §④b 觀測 → 認可
`produce_pull` 決策秤入 trace + bounded sample；加 `produce.wanted_not_chosen` tap（produce_pull>THRESH 但 rank 落選=想產輸競爭）→ 供 QA 判 ② 後是否仍卡 task-competition（子根①/③線索）。好設計（決策帶故事）。

## 回覆
CLEAN → dispatch（feat/produce-demand-responsive，off tools-demand merge 後 main）。measure 重點：manufacture.* probe（0→?）+ workshop 選生產隊數 + tools/goods 產量 + **produce_pull 分布/wanted_not_chosen** + 回歸（goods 不亂產 + 製造業不崩 + 無餓死）→ QA 判故事（聽到 tools 好賣→produce_pull 升→產 tools→進市場 coherent；沒聽到=揭子根①傳播下 thread）。

——死常數（`0.3/0.6`）→ belief demand-responsive util = 照妖鏡「死常數人格化」正典一刀：**own-need baseline 保 bootstrap（不餓死）+ belief demand 保感知鐵律 + max-gap 保 most-urgent 驅動**。三者兼顧=乾淨。goods demand-only 移除亂產=順帶治浪費。
