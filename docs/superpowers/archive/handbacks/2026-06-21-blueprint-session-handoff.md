---
from: blueprint
to: blueprint
status: consumed
topic: 藍圖 session 交接（2026-06-19~21）— 3 脊椎 + 統一框架真根 + 玩家錨
---

# 藍圖 session 交接（超長 session 收尾）

給重開的藍圖 session。本 session 跨 6-19~21，純規劃零 game code。下面是整條 arc + 各球位，免 context 壓縮後大決定散掉。

## arc 一句話
從「不知做啥」→ 因果脊椎審計 → 3 脊椎 spec → 經濟深挖戳穿真根（**AI 決策框架不統一**）→ 統一框架 arc → 玩家錨。

## 一、3 脊椎 spec（全交系統，子 spec 實作中）
擬真審計：世界「有運動沒因果」→ 補因果脊椎。排序 ①→④：
- **①G2 目標錨** `specs/2026-06-19-g2-goal-anchor-design`：leader 即錨 + archetype 分岔野心階梯（生存→積累→擴張→立國→稱霸）+ 私驅動脫軌 + Graph 縫（typed-edge）+ 情報綁定。系統建 G2a-d，立國/識破已量到 0→非零。
- **②G1 供應鏈** `...g1-supply-chain-design`：湧現市集 + 訂單 + 物物交易 + specie 鑄幣（W8）+ 生產看需求。
- **③G3 情報→決策（魂）** `...g3-info-decision-design`：multi-claim belief + 雙層可信度 + 技能識破(信假/生疑/裁決) + 觀察吃技能 + 查證迴路。
- **④Trait 縫**：未開（卡統一框架，當輸入）。性別預想已備（資料+生育，不卡框架）。

## 二、戰鬥（game-design §戰鬥解算與敗北模型）
全員潛在戰力 = Σ人均(tier/武裝)×參戰意志；結果按 tier 落全隊；人海可拉下菁英但有代價；損耗/潰散同模型兩端。
- **E-1** 殲滅：A 損耗 tier 加權 + C 武裝下限（已 land）。
- **E-2** 死戰 → 參戰意志子 spec。**E-3** 玩家離場 → 獨立快修。
- **戰俘預想** `...prisoner-prethink`：持久持有 + 命運(屠/放/贖/賣/招降) + stakes(成本/逃/暴動/救援=連feud) + guard-cap。

## 三、★ 經濟死 → 戳穿真根 = AI 決策框架不統一（本 session 最大發現）
量測：2 年世界 → 6 魂全 0 → 真根**不是**沒跑夠久。逐層挖：
1. world-gen **平庸**（values[0.2,0.8]/skills[0,0.3] 無極端值）→ 戲劇尾巴修 → **立國/識破 0→非零**（`...dramatic-distribution`）。
2. 經濟仍死（2 年 5 次成交）→ 挖到 **tag-vs-人格 archetype 矛盾** → 再戳穿 = **一堆 AI 子系統各自 latch task、優先序互搏，無「一隊一連貫決策」**。
3. → **裁定做「統一決策框架」大 arc**（`...unified-decision-framework`），(a)/(b) patch 全砍，所有驅力 fold 成決策輸入。
4. **吵架全掃描**（子 session，`...state-fight-scope`）：Pattern A 決策側 6 平行意圖槽(current_task/move_target/strategic_assignments/combat_target/prosperity_target_id/order_target_id)+3生產者+5cadence；Pattern B 所有權側 6 池無銀行(loyalty/resources/anon_treasury/unrest/outpost_owner/stress)。藍本=ambition_ladder/AnonCohort/RelationGraph 已是乾淨單owner。
5. **believability bar**：連貫≠同質（人格分歧/戲劇尾巴不可洗平）。
6. **驗證套件**（`...framework-validation-suite`）：7 行為測試(含TC7分歧硬bar)+6魂場景，框架落地即驗。

## 四、玩家錨（game-design §玩家核心迴路）
整 session 補的空白。**(C) 資訊不對稱下的崛起**：崛起=目標、資訊迷霧=玩法。中霧（自己+親見可靠/世界其餘霧）、認知非真相、核心迴路(殘缺→蒐集查證→判可信→賭→被咬→利用無知)。
**= 防鑽牛角尖的尺**：世界做到「夠撐起玩家靠情報在霧裡爬」就停。**G3 升級為玩家核心**（玩家也是 belief 消費者）。

## 五、球位
- **系統**：統一框架 arc（瓶頸，foundational）；G2/G1/G3 子 spec；E-1~E-3；可即修 bug `event_faction_defect.gd:21`（faction_id 繞 bidir）；trust 飽和+死隊 dangling 自修。
- **藍圖（我）**：待系統回呈（框架 believability / 數值 feel / 戰俘 WHAT）。細鑽 backlog（玩家蒐集動作集、認知 UI 呈現、情報戰 C、死亡繼承、文化/族群=真 Trait 示範、信用幣）**等框架落地 + 玩家面開工**再做。

## 六、流程/工具
- handback channel：from/to/status frontmatter，UserPromptSubmit hook 自動 📬（系統已實作）。中央郵局/auto-wake 概念**砍**（auto-wake 不可靠 + 繞過用戶 gate）。
- 跨 worktree（01↔03）：git-doc-at-merge 已 work，不需 live hook。
- measure-first 反覆生效：建→量→數據打臉假設→戳根。本 session 範本。
