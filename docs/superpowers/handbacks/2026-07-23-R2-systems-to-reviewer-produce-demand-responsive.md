---
from: systems
to: reviewer
status: open
topic: "[R²·produce_need demand-responsive·製造 bootstrap 子根②·死常數人格化] spec=2026-07-23-produce-need-demand-responsive.md。根:terms.gd:103-105 produce_need=死常數 `0.3 if has_goods else 0.6`,只看自家 goods 存量、不讀 market demand→workshop owner 聽到 795 tools 買單也不選生產(measurer 0 manufacture probe)。修:①decision_context 加 c.produce_pull=隊自家可造 outputs 的 worst shortfall ratio((need_keep(out)+demand(out)-holding)/target,0-1,mirror material_shortfall 範式)②produce_need term→ctx.produce_pull。★感知鐵律核審:demand()=_trade_demand 讀 team_known 親聞買單非 god-view 全域(TDD⑤god-view fixture 驗他隊有單但沒聽到→不含)。審點:①produce_pull normalization(worst ratio 對嗎/多 output 取 max 是否過激)②感知鐵律 belief-gate 真守③cold-start:無 demand+無 need→produce_pull=0→製造業會不會餓死(own-need baseline need_keep(tools)=pop×0.5 撐 tools/arrows;goods need_keep=0→goods 只市場驅,無人買 goods→不產 goods=對還是 bootstrap 死?這連子根①goods 不在 buy-proxy,另 thread)④舊 0.6 baseline 移除迴歸(本靠 baseline 產的隊變不產)⑤無 RNG(ambition=leader_values)。CLEAN→dispatch(feat/produce-demand-responsive,off tools-demand merge 後 main)。measure→QA。子根①/apothecary=後 thread。"
---

# R²：produce_need demand-responsive（製造 bootstrap 子根②·死常數人格化）

spec：`docs/superpowers/specs/2026-07-23-produce-need-demand-responsive.md`。arc 收斂 workshop 供給側，blueprint 認可 locus（terms.gd:103-105 非 3229）+ belief-aggregate 實作 + 攻序②先。

## 根
`terms.gd:103-105 produce_need` = 死常數 `0.3 if has_goods else 0.6`（只看自家 goods 存量、不讀 market demand）→ civ workshop owner 聽到 795 tools 買單也 produce_need 恆 0.3-0.6 → 競不過貿易 → 從沒選 TASK_MANUFACTURE（measurer「0 manufacture probe」）→ tools=0。

## 修
- ① `decision_context` 加 `c.produce_pull`（mirror `material_shortfall` 範式）= 隊自家可造 outputs 的 **worst shortfall ratio** `clampf((need_keep(out)+demand(out)-holding)/target,0,1)`，取 max（最缺/最好賣 output 驅）。僅 has_manufacturing_facility 算。
- ② `produce_need` term → `return ctx.produce_pull`。

## ★核審點
1. **produce_pull normalization**：worst/max shortfall ratio 對嗎？多 output 取 max 是否過激（一個 output 好賣就滿 util）？還是該 pooled/加權？
2. **★感知鐵律 belief-gate**：`demand()=_trade_demand` 讀 `team_known` 親聞買單、非 god-view 全域 order book——真守嗎？（TDD⑤god-view fixture：他隊有單但本隊沒聽到→produce_pull 不含）。
3. **★cold-start 餓死製造業？**：無 demand+無 need → produce_pull=0 → 不選生產。own-need baseline（need_keep(tools)=pop×0.5）撐 tools/arrows 自產；但 **goods need_keep=0 → goods 只市場驅**，若無人買 goods（goods 不在 buy-proxy=子根①/另 thread）→ 永不產 goods。**這是「不產無用 goods=對」還是「bootstrap 死鎖」？** 我判前者（不亂產浪費 material），但請審此語意 + 是否需 own-need floor 防製造業全滅。
4. **舊 0.6 baseline 移除迴歸**：本靠 `else 0.6` baseline 產的隊（無 goods 時）現變 produce_pull（可能低/0）→ 產量降？measure 驗，但結構上是否有隊本該產卻停。
5. **無 RNG**（ambition=leader_values 非 randf）。

## 回覆
`to:systems`：CLEAN / 修正（尤 cold-start floor、normalization、belief-gate）。CLEAN → dispatch（新 branch `feat/produce-demand-responsive`，off tools-demand merge 後 main）。measure 帶 §④b+specimen→QA（manufacture probe 0→?/produce 隊數/tools+goods 產量/weaponsmith 建成/回歸）。子根①/apothecary crowding = 後 thread（measure ② 後定）。
