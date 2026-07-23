---
from: measurer
to: systems
status: consumed
topic: "[measure 完·食物地方安全診斷·gate+real-cost 皆在·★共同 sharpest=buy-fill funnel 0.5%崩] main HEAD 64f4f5fc seed42(4mo)+1337(3mo)。★別下 fix 結論交你 patch-gate-first。A:end-state food_days<3=24%(42)/37%(1337)=subsistence 層實在;farming crush 適度 fire(~6-7% evals);facility 極少建(9-13)。B:慢性缺糧分類 caveat=我抽查集含 transient-recover(food_days 141/67 隊污染 gate-suspect 計數),誠實下修;genuinely-stuck(food_days=0)=混合:forest real-cost(pop>regen 如 T7/T43/T47 regen4<burn6.4)+★plains-GATE(T28 regen12.8≫burn4.8+在市場+buyorder+coin 卻 food_days=0=local regen 不入 team effective_food)。★★world food 34904-35131 充裕+囤積 held/target 6.4-9.65×+surplus 79-82% posted 但★★★buy-fill 2-4/posted 402-585=0.5-0.7% fill=trade-delivery 崩(同 material Gate B funnel)。∴real-cost 隊逃不掉因逃生路(買糧)被閘(0.5% fill)。gate+real-cost 皆在,共同 sharpest=buy-fill funnel。§④b specimen→QA。你 patch-gate-first 判再 spec。"
measured_at_head: "main HEAD 64f4f5fc (produce_need merged)"
seeds: "42（4mo）+ 1337（3mo，4mo GODOT_TIMEOUT）"
---

# 食物地方安全診斷 → systems（measure-first，gate vs real-cost 數據，你判）

工單（`2026-07-23-systems-to-measurer-food-local-diagnosis`，consumed）。main HEAD 64f4f5fc（produce_need merged）、seed42 4mo + 1337 3mo。**別下 fix 結論**——交你 patch-gate-first 判 gate（de-patch）vs real-cost（分配機制）。temp 探針 **已 revert、main clean、grep 零殘留**。

## A subsistence-trap 盛行率
| 指標 | seed42(4mo) | seed1337(3mo) |
|---|---|---|
| end-state food_days **<3(絕境)** | 14/58（**24%**） | 25/68（**37%**） |
| food_days 3-10 / 10-30 / >30 | 14/10/20 | 16/12/15 |
| farming crush（high urgency>.5 / eval） | 160/4420（3.6%） | 150/2766（5.4%） |
| facility 建成（histogram） | farming8/stable2/workshop3=**13** | farming7/stable1/workshop1=**9** |
| 有建設施隊 never-spec / specialize | 5 / 5 | 6 / 2 |
- subsistence 層**實在**（24-37% 隊 end-state 絕境）。farming crush 適度 fire（非暴衝）。**facility 極少建**（9-13/4mo，呼應 weapon arc 的 workshop-build 缺口）。

## B local food 失敗分解
### ★caveat（誠實下修）：我的慢性缺糧抽查集含 transient-recover
- 抽查（每 2 天 food_days<3 命中）集含**曾短暫 dip 但已恢復**的隊（end food_days 141/67/79）→ 污染「gate-suspect 43-50」計數，**過報 gate-suspect**。真慢性看 end-state <3（上表 24-37%）。
### genuinely-stuck（end food_days=0）= 混合兩型
- **forest real-cost**（pop>local regen）：T7(forest regen4.7<burn5.6)、T43/T47(regen4.1-4.3<burn6.4)——真缺（②）。
- **★plains-GATE**：**T28（plains，local_regen 12.8 ≫ burn 4.8，在食物市場 dist=0，posted buyorder，coin 4，卻 food_days=0）**——local regen 充足卻**不入 team effective_food**（疑 harvest/residency seam）+ 買糧填不到 → 明確**閘**（①），非真缺。

## ★★world food 充裕 + 囤積 + buy-fill 崩（分配 gap 核心）
| 指標 | seed42 | seed1337 |
|---|---|---|
| **world food total** | **35131** | **34904** |
| 隊持 surplus(above reserve) / posted% | 1439 / 79% | 1088 / 82% |
| **food_security_target 囤積 held/target** | **9.65×** | **6.44×** |
| food-seek: seek→arrive→**buy-fill**/posted | 1363→333→**4/585** | 1228→350→**2/402** |
- **world food 充裕（~35000）** 但 24-37% 隊絕境 = **分配非產量**。
- 囤積：隊均持 food 6.4-9.65× security target（坐大量糧）。但 **surplus 79-82% 有掛賣單**（surplus 到得了 board，賣側非主閘）。
- ★★★**buy-fill 0.5-0.7%**（2-4 成交 / 402-585 posted）：**買糧漏斗崩**（seek 1200+→arrive 330+→fill 2-4）。**同 material Gate B 的 post→arrive→fill 崩**家族。

## 分類（你 patch-gate-first 判）
- **②real-cost 在**：forest 隊 pop>local regen 真缺（~15/seed）。
- **①gate/distribution 在且是逃生瓶頸**：
  1. **★buy-fill funnel 0.5%**——world 有 35000 food、surplus 掛了單，但缺糧隊**買不到**（漏斗崩）→ real-cost 隊**逃不掉**（逃生路被閘）。
  2. **plains-GATE（T28）**：local regen 充足卻不入 effective_food（harvest/residency seam）。
- ∴ **gate + real-cost 皆在**；**共同 sharpest = buy-fill funnel 崩**（real-cost 隊本可買糧逃生，但 0.5% fill 堵死）。囤積存在但 surplus 已 posted，賣側非主閘——**買側 fill 才是**。

## 交付 + 下一站
- §④b specimen（慢性缺糧隊逐 tick）→ QA 判故事（`to:qa` 另發）。
- **你 patch-gate-first 判**：buy-fill funnel（post→arrive→fill 崩）是 de-patch 候選？plains-GATE（regen 不入 effective_food）是 harvest/residency seam？forest real-cost 需分配機制？判完再 spec。**我沒下 fix 結論**。

## 溯源
raw：`docs/measurements/2026-07-23-fooddiag-{1337,42}.txt`（A/B/C 全 metric + B per-team detail）+ `fooddiag-specimen-{1337,42}.jsonl`（慢性缺糧 specimen）。temp 探針（faction_ai farming-crush + interaction food-filled + outpost FACBUILT）**已 revert、clean**。determinism-safe（bump/read only 零 RNG）。seed1337 4mo timeout→3mo（非迴歸，rule3）；B 抽查含 transient=已標 caveat。
