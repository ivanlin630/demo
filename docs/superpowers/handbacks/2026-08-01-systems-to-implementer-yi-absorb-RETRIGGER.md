---
from: systems
to: implementer
status: consumed
topic: "[re-trigger·吸納量測沒撿到·甲SLICE B已merged收尾、你idle後沒loop回撿吸納measure(那張handback 2026-08-01-systems-to-implementer-yi-absorb-trajectory-measure.md還open、branch feat/scale-absorb-measure還沒建)·現撿它跑:instrument吸納(pull-side整併)lifecycle trajectory=強隊主動吸弱鄰TASK_MERGE(options.gd:154-166無food gate)·量①吸納候選fire數(absorb_target_id!=-1)②dispatch TASK_MERGE數③arrive prey數④merge成功數·分蒸發點(finder無target/belief-stale凍/prey移動/churn)·對比JOIN 33→1驗『強隊有糧撐旅程』假說·cheap dev-verify同3seed×1mo·純觀測tap零行為變零RNG·落地docs/measurements·隔離branch feat/scale-absorb-measure·別下de-patch結論只交真值→我+blueprint方向定乙HOW·blueprint watchdog在等這環,卡/不清楚回to:systems別空等"
branch: feat/scale-absorb-measure
---

# re-trigger：吸納量測沒撿到 — 現撿它跑

**狀態**：甲 SLICE B 已 merged 收尾（4cc5da15）。你 idle 後**沒 loop 回撿吸納 measure**——那張 handback `2026-08-01-systems-to-implementer-yi-absorb-trajectory-measure.md` **還 open**、branch `feat/scale-absorb-measure` **還沒建**。**現撿它跑**（全細節在原張、此為 re-trigger 喚醒）。

## 做（吸納 pull-side 整併 trajectory、cheap dev-verify、3seed×1mo）
強隊主動吸弱鄰 = TASK_MERGE（options.gd:154-166「吸納」、`absorb_target_id!=-1`、**無 food gate**）。instrument lifecycle：
1. 吸納候選 fire 數（`absorb_target_id != -1` 可選次）。
2. dispatch TASK_MERGE 數。
3. arrive prey 數（強隊行軍抵弱鄰）。
4. merge 成功數（`_try_merge` 真併、team 數真減）。
- 分蒸發點（別假設）：finder 無 target? / belief-stale 凍? / prey 移動? / churn?
- **對比 JOIN 33→1**：pull-side 成功率是否顯著更高（驗「強隊有糧撐旅程」假說）。
- 純觀測 tap（零行為變、零 RNG、determinism 保）。

## 交付
- 落地 `docs/measurements/`（標 path）帶吸納 trajectory 分帳。
- handback `to:systems`（★別下 de-patch 結論、只交真值）→ 我 + blueprint 方向 → 定乙 HOW。
- 隔離 branch `feat/scale-absorb-measure`。**blueprint watchdog 在等這環**——卡/不清楚 → 回 `to:systems`（別空等、別問用戶）。
