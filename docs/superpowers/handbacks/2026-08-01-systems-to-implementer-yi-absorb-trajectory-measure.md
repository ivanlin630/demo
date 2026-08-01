---
from: systems
to: implementer
status: open
topic: "[乙補全貌·量吸納(pull-side整併)trajectory補完整併全貌·JOIN(併入push)已量97%半路死,但另條路吸納(options.gd:154-166強隊主動吸弱鄰TASK_MERGE無food gate)未量·measure-first定de-patch落點需知pull-side是否已work·instrument吸納lifecycle(cheap dev-verify,seeded warring短窗同前3seed×1mo):①absorb候選fire數(absorb_target_id!=-1可選次)②dispatch TASK_MERGE數③arrive prey數(強隊行軍到弱鄰)④merge成功數(_try_merge分流真併)·分蒸發點同JOIN框架(finder無target?/belief-stale凍?/prey移動/re-eval churn)·純觀測tap零行為變零RNG·落地docs/measurements·對比JOIN 33→1看pull-side是否更高成功率(強隊有糧撐旅程假說驗真)·非de-patch只交真值→我+blueprint方向定HOW·延用feat/scale-join-measure branch或新isolated"
branch: feat/scale-absorb-measure
---

# 乙 補全貌：量「吸納」(pull-side 整併) trajectory

**背景**：JOIN（併入 push）已量＝97% 半路死（絕境隊 <3 天糧到不了 host）。但**另條整併路「吸納」**（options.gd:154-166、**強隊主動行軍吸弱鄰** TASK_MERGE、`absorb_target_id!=-1`、**無 food gate**）**未量**。measure-first 定 de-patch 落點前必知：**pull-side 是否已 work**（強隊有糧撐旅程的假說）。

## 做（instrument 吸納 lifecycle、cheap dev-verify、同前 3seed×1mo 短窗）
1. **吸納候選 fire 數**（`absorb_target_id != -1` 可選次數＝強隊有無弱鄰可吸）。
2. **dispatch TASK_MERGE 數**（真派吸納）。
3. **arrive prey 數**（強隊行軍抵達弱鄰）。
4. **merge 成功數**（`_try_merge` 分流真併、team 數真減）。
- **分蒸發點**（同 JOIN 框架、別假設）：finder 無 target(absorb=-1)? / belief-stale 凍? / prey 移動追不上? / re-eval churn?
- 純觀測 tap（零行為變、零 RNG、determinism 保）。

## 交付
- 純觀測 instrument（gates 綠、headless 0-new、3 跑 byte-identical）。
- **落地 `docs/measurements/`**（標 path）帶吸納 trajectory 分帳（fire/dispatch/arrive/merge + 蒸發分因）。
- **對比 JOIN 33→1**：pull-side 成功率是否顯著更高（驗「強隊有糧撐旅程」假說）。
- handback `to:systems`（★別下 de-patch 結論、只交真值）→ 我 + blueprint 方向 → 定乙 HOW。
- ★隔離 branch `feat/scale-absorb-measure`（約束2）。卡住報 `to:systems`。**甲 SLICE B build 優先、吸納量可排 甲 後**（別搶 甲 進度）。
