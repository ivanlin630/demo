---
from: blueprint
to: systems
status: consumed
topic: [★補完3 incomplete供用戶裁·非阻塞] slice A大幅進步(attrition 3.7x→1.7x)但未全綠;用戶睡,release門檻歸用戶,先自動補完determinism/P25工具/層4三態讓裁決資訊完整
---

# Slice A 大幅進步 → 補完 incomplete，release 門檻留用戶

## 驗收結果（measurer `2026-07-14-measurer-to-blueprint-sliceA-acceptance.md`，consumed）
- **attrition：1.9-3.7x → 1.3-1.7x**（大降，但仍高 main 30-70%，非嚴格 ≈baseline）。
- **established 反向利多**：seed1337 branch 多達成 1 個（`[1,0,2]` vs main `[0,0,2]`）。
- **性格顯性化 PASS**：3 樣本 food_sec_target 隨慎重遞增（3.8→4.7→5.0）、option 分布明顯分化（中庸買糧54%為主 / 好戰9-option多樣含迎戰34 / 謹慎建設79%）——**行為分化方向對，願景A的品質線初步達成**。
- **Fix3c 武備隊 PASS**：has_specie=true、barter food 5→142/weapon 30→11，滿手武器不再餓死。
- **boost 頻率 10.52%**：tuning 訊號非壞（但偏高，見下）。
- **Team10（活教材）改善**：v2 Extinct 滅團 → sliceA 僅 1 筆 famine 即存活。**但同 run Team1/7/9/14 仍全滅**（thrash 同型現象，v1/v2 皆有，sliceA 沒消滅）。

## release 門檻＝用戶親裁（park，不代決）
「attrition 1.3-1.7x main 算不算可接受餘裕」是 WHAT/願景門檻，屬用戶。用戶睡，此項 park 到醒——我會備妥具體裁決問題（見末）。**但補完以下 incomplete 不需用戶、且讓裁決資訊完整，先自動推**：

## 請做（HOW/工具，你 owner，dispatch implementer/measurer）
1. **加「指定 team_id specimen」工具**（measurer 兩輪都缺）：`single_team_trace_bed` 候選由 pop-swing 自動挑，鎖不到指定隊。加一個 `SPECIMEN_TEAM_ID` 參數強制指定。**用途：直接鎖 Team10=P25（野心0.89霸主）驗活教材**——這正是願景A品質線的關鍵樣本，兩輪都因工具缺口 incomplete。順手把 leader values 進 SpecimenTracer dump（caution-trait log tap，前輪也標過缺）。
2. **補 determinism/憲法閘複核**：本輪改動集中決策層非 site 結構，前兩輪皆綠，但如實未複核。release-gate 衛生，補一次。
3. **層4 鋸齒三態細驗**：本輪跳過層4（判被層0/3/5溶掉），量測未確認殘餘鋸齒是否真消。用新的指定-specimen 工具挑 1-2 隻窮隊看還有沒有 3天線鋸齒——**這直接回答「層4 到底要不要補」**。
4. **Team1/7/9/14 仍全滅**：跟 Team10 同型 thrash，sliceA 改善 Team10 卻沒清這幾隊。用指定-specimen 各鎖一隻看死因——是同一個「求生封頂殘餘」還是別的根。**這可能是 attrition 沒完全回落 main 的殘餘來源**，查清供用戶門檻裁決參考。

## 完成後回 blueprint（供用戶醒來一次看全）
把上述補完結果彙整回 blueprint，我連同 release 門檻問題一次呈用戶。**別直接推 merge**——release 是用戶親裁的 gate（attrition 仍 1.3-1.7x + 4 隊全滅，非無條件綠）。

## 備妥的用戶裁決問題（我醒來問用戶）
- attrition 1.3-1.7x main（established 反有利多、性格分化達標、武備隊救活）算可接受 release，還是要再壓（查 Team1/7/9/14 全滅殘根 + 補層4）？
- boost 頻率 10.52% 偏高要不要 tune 安全網（常觸發=上游備糧沒做好）？

## 邊界
補完屬 HOW/工具/驗證，你 owner，自動流。**唯 release 門檻 + boost tuning 方向 = park 用戶**。三鐵律（全好才量/不加行為/性格不許結構餓死）+ 願景A 不變。
