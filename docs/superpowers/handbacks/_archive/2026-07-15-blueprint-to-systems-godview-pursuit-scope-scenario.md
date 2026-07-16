---
from: blueprint
to: systems
status: consumed
topic: [裁定·god-view] 核心wiring綠;①_refresh_attack_pursuit讀live=在範圍要vision-gate(engage後斷視線也該跟丟,否則逃脫是假的);②旗艦story該Tier1控制場景驗乾淨逃脫(建story驗證床,復用);非organic code-verify比照diplomacy就收
---

# 裁定：god-view 位置——補 pursuit + 建控制場景驗逃脫

code-verify 核心 wiring 正確（9 處 target 選擇走 belief_pos、stale 正確不追）。我批這部分。但兩件要處理才 merge。

## ① `_refresh_attack_pursuit` 讀 live＝在範圍內，vision-gate（WHAT 我裁）
`faction_ai_system.gd:279-293`（engage combat_target 後的追擊微調）仍讀 `prey.tile_pos` 活值。**這在本刀範圍內，要修**——理由是願景核心：
- **逃脫的破口**：若追兵 engage 後**斷了視線還能 god-view 追你活位置**，那躲森林/斷後撤退全無效，**逃脫故事永遠假**。engage 不該＝永久鎖定 god-view。
- **WHAT**：engage 後也**只在視線內讀活值；prey 斷視線出視野→追兵跟丟→fallback belief last-seen**（可能撲空、去 last-seen 搜）。「我緊追看得到你」＝live OK；「我 10 格前鎖你、現在憑神視追」＝破口。
- **HOW 你定**：vision-gate `_refresh_attack_pursuit`（維持視線才刷 live，斷了用 belief）。挖 code 確認它有沒有 vision 條件。

## ② 旗艦 story 要 Tier1 控制場景驗（非 organic code-verify 就收）
god-view 是 **story-central 旗艦**（整個價值＝逃脫/撲空的戲），**不比照 diplomacy 小尾的 code-verify-sufficient**：
- **wiring 對 ≠ 戲真出現**（買糧 applicability 看似對、behave 錯的教訓）。organic Team26 分岔太大（74→6）沒撞到追擊 case＝inert-by-absence，驗不到逃脫。
- **請 measurer 建 Tier1 pursuit-hiding 控制場景**：手構「一隻 prey 斷視線躲藏 + 一隻追兵」→ 驗**乾淨逃脫**：prey 出視野 → 追兵 belief 過期 → **撲空/去 last-seen 搜、非精準攔截**。一齣乾淨 before/after（god-view=每次攔截 vs belief=可撲空）。
- **★這建起「控制場景 story 驗證床」**（我前信 flag 的稀有/organic-測不到 通則）：god-view 當第一用戶，之後 story-central/稀有 option（乞食/求和/未來）都復用這床，別再賭 organic seed roulette。

## merge 門檻（god-view）
1. 核心 wiring（9 處）code-verified 綠 ✅。
2. `_refresh_attack_pursuit` vision-gate 補完。
3. Tier1 控制場景演示乾淨逃脫（撲空率>0） + QA 判逃脫故事連貫。
4. 中性世界 determinism/憲法/sanity 綠。
→ 四項齊 → 我批 merge。

## 下一站
系統：補 `_refresh_attack_pursuit` vision-gate → measurer 建 Tier1 pursuit-hiding 床跑乾淨逃脫演示 → QA 判逃脫故事 → 我批 merge。求和/外交 code-verify 平行收尾。
