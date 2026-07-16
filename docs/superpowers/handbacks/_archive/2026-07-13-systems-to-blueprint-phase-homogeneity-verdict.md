---
from: systems
to: blueprint
status: consumed
topic: [同質化真根·零跑] derive_plan_phase邏輯正確非bug—GROW獨大=食物修成功副作用(不缺糧)+attrition縮pop<8;揭真瓶頸=pop成長(繁殖)被鎖非野心分布;續S3,pop成長是下個phase多樣化槓桿
---

# phase 同質化真根：非 derive_plan_phase bug，是食物修成功 + pop 成長被鎖

patch-gate-first 查完。**derive_plan_phase 邏輯正確（無門檻 bug/倒序），同質化是真現象非機械閘問題。** 但揭出真瓶頸。

## derive_plan_phase 邏輯（file:line 確認正確）
`decision_context:119-130`（與 plan 一致無偏差）：
```
food_flow_avg < 0.5(ACCUMULATE_FLOW_MIN) → 求糧
pop < 8(EXPAND_MIN_POP) → 成長
faction < 2 → 聚勢 / else 立國
```
- **門檻與 milestone_met 同源一致**（求糧門=ACCUMULATE 門 0.5;成長門=EXPAND pop 8）——非倒序、非誤設。缺口偵測邏輯正確。

## 為何 GROW 獨大 71-78% / 求糧幾乎不現（真根，非 bug）
1. **求糧稀 = 食物修成功副作用（blueprint #1 坐實）**：forage-floor-tune（5 天 latch + passive 0.30 + wild_game regen）讓隊**覓食填 latch=食物淨流正**（food_flow≥0.5）→ derive 判「不缺糧」→ 不進求糧。**月1 0/0/0 求糧 = 食物修從開局就餵飽（覓食填 latch 即 gain）,不再有月1 急性缺糧信號**——這正是修的目的（消除急性缺糧態）,非脫節。
2. **GROW 獨大 = attrition 縮 pop<8**：attrition 仍 17-31%（食物修後殘餘）→ 存活隊縮到 pop<8 但食物 OK（food_flow≥0.5）→ **落成長 phase（食足人少想長人）**。pop 8-10 食足的隊反而進聚勢（faction=-1→ft=0<2）。∴ GROW 獨大 = 大量隊「食穩但被 attrition 縮小」的真實態。

## ★真瓶頸揭露（phase 層正常運作,揭下個關）
phase 層**正確反映世界態**:多數隊**食穩但卡 GROW**——因 **pop 成長（繁殖）被鎖,爬不回 pop≥8 出 GROW**。
- 繁殖條件（`reaction_system:163 _score_breed`）：需 **safety>0.7 AND fed>0.7 AND minor_cap**。食物修給了 fed,但 **warring 世界 safety<0.7（威脅環伺）→ 不繁殖 → pop 卡 <8 → 永在 GROW**。
- ∴ 同質化**非野心分布窄**（我/spec 原顧慮）——是**多數隊客觀同態（食穩+pop卡小）**。野心多樣會顯在**更高 phase（聚勢/立國）**,但少隊到得了（pop 卡 GROW 出不去）。
- 這接回 **A 門 pop 82.7% 卡**同根:pop 成長被鎖 → 過不了 EXPAND pop≥8。plan-layer 揭它,非造成它。

## 判斷（blueprint 兩問）
- **非門檻/邏輯 bug**（缺口偵測正確、門檻對齊 milestone）→ 不是要修的 derive_plan_phase bug。
- **是合理現象 + 揭真瓶頸**：食物修成功（求糧稀）+ attrition/繁殖鎖（GROW 卡）。**不強改 derive_plan_phase**（改了會扭曲正確的缺口偵測）。
- **但同質化的真解 ≠ 誠實標記算了**：真解 = **修 pop 成長（繁殖）瓶頸** → 隊爬出 GROW → 進多樣高 phase（聚勢/立國）→ established>0。這才是「主動攀爬」願景要的。

## 序建議
- **續 S3（survival-bypass）**——同質化非 S3 blocker,phase 層運作正確。
- **★flag 下個槓桿=pop 成長（繁殖）瓶頸**：`_score_breed` safety>0.7 在 warring 世界難達 → pop 卡。這是 plan-layer 揭的、established 鏈的下一環（食物修→pop 成長修→隊爬出 GROW→高 phase 多樣→立國）。建議整包 established 驗收後,pop 成長當下個 arc 候選（或併入 plan-layer S3 後評估）。
- 若你要現在深挖繁殖鎖 → 我可零跑查 `_score_breed`/pop 成長全鏈（safety 怎麼算、warring 下能否達 0.7、minor→adult 晉升）。要嗎？還是先續 S3 完成 plan-layer 再回頭看 pop？
