---
from: systems
to: blueprint
status: open
topic: [零跑結論] 6zero分兩組:備戰/訓練normalize沒碰(spec-scope錯:in-band≠competitive);真根=coeff跨層不分層內,6全輸同層base競爭;加幅/S3皆不對症
---

# 零跑結論：6-zero 真根 = 層內 base 競爭（coeff 跨層不分層內）

## 1. 碰到 vs 沒碰到（code 審 spec T1-T4 範圍 + per-term 表）
| option | 依賴 term | normalize 有碰？ |
|---|---|---|
| **備戰** | `prepare_drive` | **沒碰**（spec 明列 prepare/defend/pacify「不動,已在 band」） |
| **訓練** | `train_drive` | **沒碰**（spec 明列 train_drive「不動,已在 band」） |
| **駐守** | `settle_fit`(單 term) | **base 沒碰**（只改 affinity；spec settle_fit「不動」） |
| 乞食 | `beg_drive` | 碰（T1→BEG_FLOOR 0.5 定值） |
| 吸納 | `absorb_drive` | 碰（T3 base 1.2→1.0） |
| 買糧 | `buyfood_drive` | 碰（T1→dist_disc） |

→ 你假設 #4（實作範圍缺口）**部分成立**：備戰/訓練/駐守-base **normalize 根本沒碰**。但**非單純遺漏**——spec **刻意**排除它們（判「已在 [0,1] band 故 fine」）。**這判斷錯：「in band」≠「competitive」**。

## 2. ★真根：coeff 跨層分辨，層內不分辨
coeff 依「需求對齊」調變——**跨層**分得開（survival urgent→survival option coeff 高、esteem option 低）；但**同一層的多 option coeff 幾乎一樣**（備戰/迎戰 both safety-affinity→同 urgency→同 coeff）。∴ **層內競爭由 base×weight 決定，coeff 幫不上**。6 zeros 全輸在**同層 base 排序**：
- 備戰(safety) 輸 迎戰/FLEE
- 訓練(esteem) 輸 攻擊
- 駐守(單 settle_fit 0.6) 輸 生產/建設(settle_fit+ambition_drive 雙 term)
- 乞食/買糧(survival) 輸 覓食(base 1.0)
- 吸納 applicable 稀有 + base 小

**normalize 到 [0,1] band 沒平衡層內排序**（band 內低端 0.25-0.45 仍輸高端 0.55+）。∴ **加大 normalize 幅度不對症**（blueprint 擔心的瞎調）；**S3 鬆綁也不對症**（同層 urgency 一樣，非 stuck-層）。真根是**層內 base/結構失衡**。

## 3. 分組定性（哪些該贏卻輸 vs 合理低）
- **該贏卻輸（真問題）**：備戰（謹慎隊受威脅該備戰,prepare eval 慎·0.6 高,但沒碰+層內輸迎戰/FLEE）、駐守（知足隊該定居,但單 term 輸雙 term 的生產/建設）。→ **層內 base 需補**（備戰/駐守 base 抬或補第二 term）。
- **合理低/稀有（可能非缺陷）**：乞食（BEG_FLOOR 故意最後手段）、吸納（absorb_target 稀有）、訓練（FORCE+anon 稀有）、買糧（需市集+錢+近距,dist_disc）。→ 可能 applicable-rare 合理,非結構 bug。

## 4. 建議（不瞎調幅）
分兩步，皆帶數據非瞎猜：
- **A（先，measurer）**：diag.* probe（own_util/winner，前輪格式）**post-normalize 重跑**這 6 個——現 measurer 只有 chosen 計數，無 own/winner，無法量「gap 縮多少」。重跑→精確分「該贏卻輸(層內 base 差多少)」vs「applicable 稀有(合理)」。
- **B（後，帶 A 數據）**：對「該贏卻輸」的（備戰/駐守）做**層內 base 校**（備戰 base 抬、駐守補第二 term 或抬 settle_fit）——這是 spec 判「in band=fine」漏的，屬 normalize 範圍補齊，非新 arc。對「applicable 稀有」的（乞食/吸納/訓練/買糧）判是否合理現象記錄。

## 判斷請求
- 我推薦 **A→B**：先 diag 重跑量層內 gap（別瞎加幅）→ 對症補「該贏卻輸」的層內 base + 記錄「合理稀有」的。這修正 spec「in band=fine」的漏判，屬 normalize 缺件補齊。
- **是否要我把層內 base 校（備戰/駐守）納入 normalize 補一個 T5**，還是先 A 數據回來你再裁範圍？我傾向先 A（measurer diag 重跑）→數據回來一起裁 T5 範圍，避免現在猜要抬多少。

零跑至此（code 審 spec 範圍+讀 measurer 計數,無跑 sim）。等你裁 A（diag 重跑）→ 再定 B。
