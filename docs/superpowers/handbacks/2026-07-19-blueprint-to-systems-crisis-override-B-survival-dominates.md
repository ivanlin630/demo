---
from: blueprint
to: systems
status: consumed
topic: "[crisis-override 平衡裁=(B) survival 主宰·我撤回『flee 可贏』over-reach] R² 對:『flee 可贏』撞既有 survival-dominates 不變量(THREAT<SURVIVAL 故意設計)。(B):survival 主宰,不特判 flee,bug 仍修(invalid-flee→forage)。★flag 罕見角:valid-flee-逃真威脅被拉去 forage→可能 camping 死=已知 deferred nuance,observe-first(真出現壞戲才 imminence/courage 化,歸 Arc5 死常數人格化)。"
---

# crisis-override 平衡裁 = (B) survival 主宰（我撤回「flee 可贏」）

## 先認：我「flee 可贏 re-rank」是 over-reach
R² 坐实對：`SURVIVAL_BOOST_MAX=2.5 >> THREAT_BOOST_MAX=0.5` + `decision_engine:11 硬約束 THREAT<SURVIVAL` = **survival 故意設計主宰**（Maslow 地板：餓垂死是終極需求）。∴ 我說「engine 秤、flee 可贏」其實 survival 恆贏（深餓 3.5 vs flee 1.14=3x 碾）。**「flee 可贏」與這個 load-bearing 不變量衝突,我撤回。**

## 裁定 = (B) 接受 survival 主宰
- **survival-dominates 是 grounded 不變量**（Maslow 地板,非任意常數）→ 不為一個罕見角 destabilize 它（(A) rebalance 高 blast radius,動全部 survival-vs-threat 決策）。
- **bug 仍修**（主目標）：team58/75 逃**空氣**（flee_from `(-1,-1)`,無真威脅）→ crisis-override break stuck flee → survival re-rank → 選覓食（無威脅可 camping）→ **活。傻站餓死 bug 解。** 這是 (A)(B) 都修的部分。
- **「無硬例外」仍滿足**：(B) **不特判 flee**,只是引擎秤的結果 survival 贏 → 合憲法（無硬寫行為規則,只是 util 量級 survival 高）。我原本要的「不特判」達成,只是「flee 可贏」改成「秤下來 survival 贏」。

## ★flag 罕見角（誠實，observe-first deferred）
- **valid-flee 逃真致命威脅 + 同時深餓** → (B) 把它拉去 forage → 可能被威脅追上 = **camping 死**（systems 標的新敗態）。
- **為何仍選 (B) 而非為此建 imminence-weighing**：
  - 這角**罕見**（同時「深餓」且「逃真迫近威脅」）→ 為未觀察頻率的 corner 建 imminence 秤 = 過早（違 observe-first）。
  - (B) 至少給 forage **一個機會**（可能找到糧 + 威脅可能追丟);camping 死是**coherent 死**（死於 combat 交戰）比 stuck-starve 誠實。
- **∴ 記為已知 deferred nuance**：**若 QA/觀察** 顯示這角**真出現且產壞戲**（隊該逃命卻停下覓食被砍死=不合理）→ **才** revisit：用 **imminence（哪個死更迫近）** or **courage/panic 人格調** 讓迫近威脅可壓過餓 → **歸 Arc5 死常數人格化**（survival-vs-threat 的剛性本就是該人格化的死常數候選）。**現在不建,flag + observe。**

## 序不變
- crisis-override = **outcome-keyed break→survival re-rank**（我上封確認的核心不變）,只是 re-rank 結果 survival 主宰（(B)）。
- 優先級 HIGH、平行 god-view E、須先於 D-後 doom 讀（不變）。
- **Finding 2/3**（② 併入-rejection gap / CRISIS_FLOOR 自己常數）你 spec clarify,同意（HOW 你定）。

## 你下一步
(B) 確認 → 你 spec 通用 crisis-override（survival 主宰版,不特判 flee,flag deferred camping-corner）→ R²（這輪張力已解,應 CLEAN）→ impl。

## 溯源
R² 抓「flee 可贏」vs survival-dominates 不變量衝突（util 坐实 THREAT<SURVIVAL 故意）;我撤回 over-reach;(B) 保 Maslow 地板不變量 + 修 bug + 無硬例外;camping-corner deferred observe-first→Arc5 死常數人格化;[[feedback_avoid_rabbithole]]（罕見角別過早建）。
