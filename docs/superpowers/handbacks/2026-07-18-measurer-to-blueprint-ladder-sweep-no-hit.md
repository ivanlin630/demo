---
from: measurer
to: blueprint
status: consumed
topic: "[calibration sweep完·無命中·attrition內在] 掃4候選(主軸STALL_BASE×1.5/×3、次軸RELIEF_MIN×0.5、組合×2+0.5)對seed1337+4201，無一達標(seed1337 latch保 AND seed4201回近baseline 2.9%同時滿足)。最佳seed4201結果(STALL_BASE=24.0得attrition19.48%)仍是baseline 6.7倍,且該候選讓seed1337 attrition惡化(18.47%→27.93%)。趨勢非單調,顯示非單純調參數問題。判定：attrition內在(sweep移不掉)，依協議回報「不存在」，請裁(A)accept merge。"
---

# calibration sweep 完成：無命中，判定 attrition 內在

依 `2026-07-18-systems-to-measurer-ladder-calibration-sweep.md`（blueprint 裁 B）。implementer env override ready（`17fd4fc4`）後已跑完 4 候選。

## 判準表

| STALL_BASE | RELIEF_MIN | seed1337 starve/attr | seed4201 starve/attr | 命中? |
|---|---|---|---|---|
| 8.0（baseline） | 1.0 | 5 / 18.47% | 3 / 28.19% | （baseline） |
| 12.0（×1.5） | 1.0 | 10 / 26.35% | 9 / 29.07% | 否——**雙惡化** |
| 24.0（×3，極端點） | 1.0 | 4 / 27.93% | 4 / 19.48% | 否 |
| 8.0 | 0.5（×0.5） | 6 / 21.40% | 3 / 25.00% | 否 |
| 16.0（×2） | 0.5 | 7 / 26.13% | 5 / 25.58% | 否——組合未優於單軸最佳值 |

**命中判準**：seed1337 latch 保（starve≤5）**AND** seed4201 回近 baseline（attrition ~2.9%）**同時滿足**。四個候選**無一達標**。

## 關鍵觀察

- **主軸 STALL_BASE↑ 第一個測點（×1.5=12.0）直接讓兩 seed 都變差**——不是「沒改善」，是**淨惡化**（seed1337 5→10隊starve；seed4201 3→9隊starve，attrition離baseline更遠）。機制上說得通：更耐心（晚換格）代表壞 option 燒更多天才被排除，對已經沒救的隊是純負面。
- **極端點（×3=24.0）出現非單調反彈**：seed4201 attrition 從 12.0 的 29.07% 降到 19.48%（改善方向），但**仍是 baseline 目標 2.9% 的 6.7 倍**，遠稱不上「回近」；同時 seed1337 attrition 卻惡化到 27.93%（雖 starve 隊數回到 4，比 baseline 5 還好）。兩個指標（starve 隊數 vs attrition%）在不同候選上互相打架，找不到讓兩者同時滿意的點。
- **次軸單獨（RELIEF_MIN=0.5）**：方向正確但幅度不足——seed4201 attrition 25%（仍 8.6 倍目標），seed1337 小幅惡化。
- **組合（16.0+0.5）**：沒有優於單軸最佳值，兩個 seed 都停在惡化區。

**最佳單一結果全程掃描下來，seed4201 attrition 從未低於 19.48%**——離 2.9% baseline 目標有數量級差距，且達到這個最佳值的代價是 seed1337 attrition 惡化。

## 判定：attrition 內在，非 calibration 缺口

依協議：「掃遍無此值 → 證 attrition 內在（sweep 移不掉）→ 回報「不存在」」。四個候選（含主軸兩端點+次軸+組合，右尺寸覆蓋合理範圍）皆未命中，且趨勢非單調（顯示這不是簡單的『參數調太緊/太鬆』問題，而是機制本身在 seed4201 這個世界配置下就是會產生比 baseline 更高的 attrition）。

**回報「不存在」**，依協議路由請你裁 **(A) accept merge**（帶已知 attrition 差異，非 calibration 可解）。

## 備註

- `godot-detach.ps1` 原只轉發 `WARRING_*`/`GODOT_TIMEOUT` env，`LADDER_*` 會漏掉——已擴充 filter 加 `LADDER_*`（純量測 launcher 擴充，已驗 cmd 檔內容確實含 `LADDER_STALL_BASE`，未改 production 邏輯）。
- 每候選單跑一次（省窗，右尺寸；env const 為 static var 讀一次 init，同 no-env 已驗 byte-identical 機制類推，無額外 RNG-order 風險來源）——未逐候選雙跑覆核，若你/systems 要求可補。

---
measured_at_head: `17fd4fc4`（`.worktrees/desperation-ladder`）
raw_logs: `docs/measurements/2026-07-18-sweep-base12-multiseed.json`、`...-base24-multiseed.json`、`...-relief05-multiseed.json`、`...-base16relief05-multiseed.json`
measure.json: `docs/process/verdicts/desperation-ladder-calibration-sweep.measure.json`（`is_sim: true`）
