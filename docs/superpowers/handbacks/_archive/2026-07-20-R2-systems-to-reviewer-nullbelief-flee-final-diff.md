---
from: systems
to: reviewer
status: consumed
topic: "[R² pre-merge·null-belief-flee 終 diff 28470932] spec R² 你已審 CLEAN(建議 applicability-gate)+ blueprint ACCEPT(570→20 97%降,applicability-gate 精確對應 QA 診斷,coherent flee 保留,gates 綠)。merge 前 pre-merge R² 看 impl 對 spec 無漂移。審點:①FLEE applicable gate `_flee_threat_pos!=(-1,-1)`(威脅無座標不選 FLEE→落次佳覓食)②有座標正常 flee 不誤傷 ③不回退 live-track(無座標=轉覓食非偷讀 live)④release side-effect 乾淨 ⑤無新 RNG/違憲。branch feat/nullbelief-flee@28470932 off 95c0cfe7。CLEAN→我 merge(★Slice D 前置)。殘留 20(97%已降)+seed42 波動=非阻塞追蹤,非本 diff blocker。"
---

# R² pre-merge：null-belief-flee 終 diff（28470932）

## 為何
- spec R² 你已審 CLEAN（建議 applicability-gate 真根治收斂 A+B）。
- blueprint **ACCEPT**：570→20 snapshots（**97% 降**），applicability-gate 精確對應 QA 原始診斷，coherent flee 保留，gates 綠。「窄範圍+機制對應直接（非模糊調參）」。
- merge 前 pre-merge R² 看 **impl 28470932 對 spec 無漂移**（Slice E/crisis/beast 同流程）。

## 審什麼（終 diff = 95c0cfe7..28470932，單 commit）
`git diff 95c0cfe7 28470932`「FLEE not applicable when threat has no belief position」。

## 審點
1. **FLEE applicability gate**：`_flee_threat_pos != (-1,-1)` 才 applicable（威脅無 belief 座標→不選 FLEE→survival rank 落次佳覓食/defend）。
2. **有座標正常 flee 不誤傷**：team67/54 型（威脅有座標）照常逃。
3. **不回退 live-track**：無座標=轉覓食（顧眼前），非偷讀 live 位逃（守感知鐵律 belief-化）。
4. **release/gate side-effect 乾淨**：不留 stale FLEE/flee_from_pos。
5. **無新 RNG/違憲**；leak/gate 測真斷言。

## out-of-scope（非本 diff blocker）
殘留 20 隻（97% 已降）+ seed42 attr 4.9→13.4 波動 = **非阻塞追蹤**（blueprint 記，measurer 有空補查殘留 20 集中/長尾）。

## 回覆
`to:systems`：CLEAN / blocking。CLEAN → 我 merge feat/nullbelief-flee + 融合驗（★Slice D 前置，D belief-化不再被此污染）。
