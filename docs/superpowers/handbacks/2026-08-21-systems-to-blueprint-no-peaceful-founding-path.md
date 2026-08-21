---
from: systems
to: blueprint
status: open
topic: ★★★T3 挖到今天最大一顆:和平床上 faction 永遠不可能出現 —— 「建國」只掛在打贏/臣服,沒有經濟成長→立國的路;26/29 床 faction 層全程 dormant;附一個 WHAT 問題+我的冷啟動結論訂正
---

# T3：問的是「停在哪一段」，答案是「**那個迴圈是空的**」

## measurer 查到
`state.factions.size()` **恆 0**（逐 tick 取樣）。`faction_ai:717` 外層 `for fid in state.factions:`
⇒ **零疊代** ⇒ **`_update_goals` / `_assign_tasks` / `_evaluate_infrastructure` 三者從未被呼叫過一次。**
⇒ 回溯訂正 T1：28 次 dispatch_fail 全部來自 `_dispatch_goal_delegate`（per-team），**不是** infra 路徑。

★**他沒有把「四格全 0」當答案交出來，而是往上追一層。** 這判斷是對的，我已把它立成 03b §④d。

## ★我自驗並擴大了（窮盡 grep `create_faction` 全部呼叫點）
| 建國路徑 | 出處 | 和平床上會發生嗎 |
|---|---|---|
| config 預塞 | `game_setup.gd:298 / :572` | 只有 **3/29** config 有（`default`／`perf_scale`／`warring_states`） |
| **戰勝後建國** | `npc_combat_system.gd:784` | ❌ 和平床無戰鬥 |
| **外交臣服** | `diplomatic_ai_system.gd:251` | ❌ |
| 玩家命令 | `player_command_system.gd` ×4 | ❌ headless 無玩家 |

★★**「建國」這個動詞只掛在【打贏】和【臣服】上。沒有「經濟／聚落成長 → 立國」的和平路徑。**
⇒ **和平床上 faction 永遠不可能出現**（推論，但四個呼叫點是窮盡的）。
⇒ **26/29 個 config 沒有 `factions`**（含 `world_sim`／`econ_bed`／全部 `infonet_*`／`unified_dispatch_diverse_bed`）
⇒ **這些床上勢力層全程 dormant。過去在和平床做的量測，量的都是一個「沒有勢力層」的世界。**

## 我先訂正自己的話
我前天報你的「**冷啟動雞生蛋死結**（沒人有料 → 沒人蓋 → 永遠沒料）」——**描述錯了**。
真相是**蓋 manufacturing 的那條迴圈根本沒跑**。
★**第三類判別（「從未被填過」≠「被榨乾」）本身仍然成立**，只是**那顆展品的成因要改述**。已改。

## ★WHAT 問題（我不預設，交你，必要時帶用戶）
**「和平地建國」該不該存在？** 三個方向，代價差很多：

| 方向 | 意思 | 代價 |
|---|---|---|
| **A. 補和平建國動詞** | 聚落成長到某條件 → 立國（新機制） | 大；但**這是世界模型的真缺口**，不是量測問題 |
| **B. 經濟床預塞 faction** | 給 `peaceful_economy` 等床加 `factions` | 小；**但會動到所有既有 baseline**，且**掩蓋 A 的缺口** |
| **C. 承認分工** | 和平床本來就只測 per-team 層，勢力層去 warring 床測 | 零成本；**但要明寫，且今天起所有和平床結論都得標明「不含勢力層」** |

★**我的傾向是 A＋C**：C 立刻做（誠實標註），A 立成 arc 排序由你定。
**B 我不建議** —— 它會讓「和平世界長不出國家」這個缺口**永久隱形**。

## 已落地（不等你回覆的部分）
- `known_issues.md`：冷啟動條目訂正 ＋ 四路徑表
- `03b_measurer.md §④d`：**床的有效性** ——「回答 X 為什麼沒發生前，先報 X 所在迴圈跑了幾次」；
  ★**全 0 的分佈不是答案，是母體塌陷，要當紅燈**；**換床前先問**（換 config ＝ 換世界）
