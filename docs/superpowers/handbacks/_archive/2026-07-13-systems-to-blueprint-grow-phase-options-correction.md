---
from: systems
to: blueprint
status: consumed
topic: [訂正·零跑] 成長≠繁殖用戶對,我over-simplified兩次—GROW偏置=返家/紮營(非breed);pop成長多管道(breed safety-gated+征服吸收flee-throttled+俘虜/流民);繁殖鎖非唯一瓶頸,交繁殖arc measure勿假設
---

# 訂正：成長≠繁殖（用戶質疑成立，我上輪 over-simplified 兩次）

零跑查完。**用戶對,我上輪「成長=繁殖鎖」是雙重過度簡化,訂正。**

## 錯 1：GROW phase 偏置根本不是 breed
`decision_context:138 _phase_option_bias(PHASE_GROW)` = **`{"返家補給": MAG, "紮營": MAG}`**——**不含 breed**。GROW 偏置導向**紮營(定居建基)+返家補給(回家補給)**,非直接繁殖。理論鏈:紮營→建基→safety 升→**間接**使繁殖可行,非直接催生。∴ 我說「GROW=繁殖」把 phase(想長人)跟 mechanism(怎麼長)混為一談。

## 錯 2：pop 成長非只繁殖一途（多管道，file:line）
1. **繁殖** `reaction_system:163 _score_breed`：safety>0.7 AND fed>0.7 gated（我上輪唯一提的）。
2. **征服吸收** `anon_tier_system:13 CAPTURE_RATE=0.5`：**打贏→吸收敗方殘餘 anon→captive→同化→自己 anon pop**。=warring 世界的**武力 pop 成長路**（贏仗長人）。
3. **俘虜** `encounter_system:1289 prisoner_population`：capture→俘虜池（cap=winner pop）。
4. **流民 recruit**：`manpower_system` 脫離/逃亡 captive→流民隊→可被招募/join。

∴ pop 成長 = 繁殖(safety鎖) **or** 征服吸收(打贏) **or** 俘虜/流民。**非單一繁殖鎖。**

## 訂正後判讀（成長 phase 卡死的真義）
「pop 卡 <8」**非單一繁殖鎖**,是**多條 pop 成長路各自受限的合成**：
- **繁殖路**：safety>0.7 warring 難達——**但 GROW 偏置的紮營(定居建基)理應升 safety→解鎖繁殖**。這條 phase 層有接（紮營→base→safety→breed），**是否真跑通=待 measure**（紮營有無真升 safety 到 0.7？）。
- **征服吸收路**：warring 該長人,但 [[project_desperation_economy]] 揭 combat **flee-heavy 83%**（敗方逃非被俘/吸收）→ 吸收路被 flee 節流（贏了敵人跑了，吸不到）。
- **俘虜/流民路**：同 flee 節流（逃了不成俘）。

## ∴ 給下輪繁殖/pop arc（訂正 backlog 假設）
- **不是「繁殖被鎖=唯一瓶頸」**（我上輪錯）——是**多路 pop 成長合成受限**：繁殖(safety)+吸收(flee-throttle)+俘虜(flee)。
- **繁殖 arc 該 measure 而非假設**：①GROW 紮營有無真升 safety→解鎖繁殖（phase 層設計是否跑通）②征服吸收在 flee-heavy 下實際吸多少 pop③哪條路是主 pop 來源 vs 主 blocker。**patch-gate-first + measure-first,別再拿單一「繁殖鎖」當定論。**
- 這也接 [[project_desperation_economy]]（flee-heavy 節流吸收路）——pop arc 與 combat/consolidation 腿可能共根。

## 序
- 訂正記入 [[project_established_chain]] memory（繁殖鎖→多路 pop 成長合成）。
- **S3 續（不受此影響，survival-bypass 與 GROW 選項無關，你已裁）。**
- 繁殖/pop arc 仍 defer 到 plan-layer 全做完；回頭時**以多路 measure 開場,非繁殖單點**。
- 教訓：我上輪沒細查就轉「繁殖鎖」= over-claim,謝用戶戳（[[feedback_structural_audit_complement]] measure-first）。
