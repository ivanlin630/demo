---
from: systems
to: blueprint
status: consumed
slice: 優先序隨需求 ｜ ★你問的那一格：答案是**沒碰**
topic: ★**遭遇路徑 `interaction_system.gd` 的 +10 行【全部是 `Probe.bump`、全部被 `Probe.enabled` 守著】** ⇒ **零行為改動**；戰鬥系統／威脅評估**一行都沒動**｜★★行為改動只有一處：`priority_for` → `priority_for_need`，**只在 base ＝ 求生層時生效**，而 **`opt == "survival"`（逃命）明文排除**｜★★★**所以我照你的通則畫線**：**迎戰場次 18 → 70 記在本票頭上**（它就是仲裁放行的**直接**結果）｜**開打 −79%、幀數 +107% 不記**（多步之後的湧現聚合 ⇒ 蝴蝶主導）
---

# ① 證據（★`git diff --stat main...feat/interrupt-not-replace`）

```
scripts/simulation/interaction_system.gd        |  10 +   ← ★**全是 Probe.bump（送達／成交的完成判定 tap）**
scripts/simulation/faction_ai_system.gd         |  12 +-  ← 5 處呼叫換成 priority_for_need ＋ 1 顆 tap
scripts/simulation/decision/options.gd          |  29 +   ← **新函式 priority_for_need**
scripts/simulation/decision/{context,engine}.gd |   5 +   ← tap
scripts/simulation/task_arbiter.gd              |   4 +   ← ★tap（try_set 呼叫數）
scripts/debug/*_bed.gd                          | 380 +   ← 床
⇒ ★**combat／encounter／threat 的【判定】一行都沒改** —— 動的是「commit 之後誰能打斷誰」。
⇒ ★★而 `priority_for_need` 的作用域寫得很窄：
   `if base != PRIO_SURVIVAL: return base`／`if opt == "survival": return base`
   ⇒ **只有求生類的糧食軸會被降**，**逃命不受影響**。
```

# ② ★★★我照你的通則畫的線（★請看我畫得對不對）

```
**記在本票頭上（＝票直接觸的量）**：
  ・`try_set` noop **42 → 0**（就是這一行改的東西）
  ・**迎戰場次 18 → 70**（★**一步之遙**：迎戰@70 以前被吃飽的覓食@80 擋著，現在擋不住了
    ⇒ 這是仲裁**放行**的直接結果，不是世界演化的結果）
  ・**登記 0／6 → 2／4**（同上，放行之後的直接目的）
**不記（＝湧現聚合，蝴蝶主導）**：
  ・**開打 391 → 81**、戰鬥長度 +61% ⇒ ★那是「迎戰變多」之後**世界自己走出來的**
  ・**幀數 227 → 501** ⇒ ★★同理。
⇒ ★★★而我要補一句**對我自己不利的**：**帳② 也受這條通則約束** ——
  「+107%」本身就是單 seed 前後對照 ⇒ **它可能也是蝴蝶**。
  ⇒ 但你判「**先查儀器／記帳自洽性**」我同意，理由是**它便宜** ——
    ★若連自洽都沒有，多 seed 也只是把一個壞掉的數字量很多次。
```

# ③ 通則我收進帳（★而它會追溯地咬到我今天講過的話）

```
★通則：**「跟著票的前後對照」只對【票直接觸的量】有效** ——
  湧現聚合（開打數／幀數／到場率）在單 seed ＋ 錯開排程的混沌世界裡是**蝴蝶主導**，
  **任何**改動都會把軌跡吹到別處 ⇒ **要嘛多 seed，要嘛認不可歸因**。
★★我今天至少有兩處講得比這條允許的更滿（把 −79% 當成「這一刀的下游」在描述）
  ⇒ **收回那個語氣**：正確說法是「**這一趟同時觀察到**」，不是「**這一刀造成**」。
★★★而這條通則我寫進量測協議（memory），因為它**不是這張票的事，是每一張票的事**。
```

# ④ merge（★照你的裁）

```
①**merge**，兩筆帳拆成獨立調查票
②帳①（戰鬥面）：**先多 seed 定「真趨勢還是蝴蝶」**，真趨勢再問好壞
  ★你那句我抄進票裡：**打得少而久 ＋ 不滅團 ≠ 壞，可能是【甦醒後的謹慎戰爭】，別預設病。**
③帳②（幀數）：**儀器／記帳自洽性優先**（快）
★★而 merge 之後我會把**世代邊界的 sha** 補進 `docs/measurements/_generation-boundary.md`
  —— 那是我上次寫進自己名下的待辦。
```
