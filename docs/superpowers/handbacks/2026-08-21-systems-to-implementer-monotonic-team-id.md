---
from: systems
to: implementer
slice: monotonic-team-id
tier: full
status: consumed
topic: "[派工·team_id 永不重用(R² v2 CLEAN)·spec=docs/superpowers/specs/2026-08-21-monotonic-team-id-HOW.md·★這刀的重點【不是那個計數器,是七處收斂 + 六項稽核】:全站 7 份獨立 _next_team_id 全部同款 max(現存id)+1(R² 親 grep 抓到、我獨立確認正好 7 份每檔 1 份),收斂成 WorldState.consume_next_team_id() 並【刪掉七份】——不要改成七處各自讀同一計數器(那只是把 bug 從『重用 id』換成『七個物理上分開的計數概念』)·★§3.0 是前置:grep -c func _next_team_id 必須=0,否則下面六項稽核做完也驗不出核心宣稱·★六項稽核【『沒有』也要附窮盡證據】(禁 head 截斷):id 連續/上界假設、max(id) 語意依賴、★存檔載入(載入後 next_team_id 必須 > 檔內最大 id)、負區段(next_beast_id)相撞、fp intended-change·★fp 會變=intended-change,要在帳上明寫別讓人讀成迴歸·★落地後把 expect-min-gate 的 TEAM_ID_GEN_MAX 從 7 收緊到 0(我先凍結在 7 防第 8 份,你落地後改)·★這刀落地前,所有 specimen/床/QA 讀法裡的『同一 id』都只能讀成『同一個號碼』"
---

# 派工：team_id 永不重用（R² v2 **CLEAN**）

**spec**：`docs/superpowers/specs/2026-08-21-monotonic-team-id-HOW.md`
**branch**：`feat/monotonic-team-id`（新建，基於現行 main）

## ★這刀的重點不是那個計數器，是**七處收斂 ＋ 六項稽核**
全站 **7 份**獨立 `_next_team_id`、**全部同款 `max(現存 id)+1`**
（R² 親 grep 抓到、**我獨立確認正好 7 份、每檔 1 份**）：
```
subteam_system.gd:345-350 / game_setup.gd:434-438 / event_unrest_split.gd:118-123 /
manpower_system.gd:228-233 / population_system.gd:78-83 (★_create_overflow_team=production 常態路徑) /
reaction_system.gd:412-416 / recruit_tutorial.gd:29-32
```

**收斂成 `WorldState.consume_next_team_id()`，並【刪掉七份】。**
⛔ **不要改成「七處各自讀同一計數器」** —— 那只是把 bug 從「**重用 id**」
換成「**七個理論上該同步、物理上分開的計數概念**」，**同族的病換個樣子**。

## ★§3.0 是**前置**，不是最後檢查
`grep -c "func _next_team_id" scripts/` **＝ 0**。
**否則下面六項稽核做完也驗不出核心宣稱**（另外 6 個出生口還在製造重用 id）。

## ★六項稽核：**「沒有」也要附窮盡證據**（**禁 `head` 截斷**）
1. 假設 id **連續／緊湊**（陣列索引、`range(max_id)`、以 id 當 slot）
2. 假設 id 有**上界**（固定大小容器、位元遮罩）
3. 依賴 **`max(id)` 語意**的其他地方
4. ★**存檔／載入**：**載入後 `next_team_id` 必須 > 檔內最大 id**（否則新隊會撞舊號）
5. **負區段**：`next_beast_id` 與 team id **不得相撞**
6. **`fp` intended-change**

## ★兩件帳目要求
- **`fp` 會變 ＝ intended-change**（id 序列改變）。**在帳上明寫**，別讓人讀成迴歸。
- **落地後把 `expect-min-gate.sh` 的 `TEAM_ID_GEN_MAX` 從 7 收緊到 0**
  （我先**凍結在 7** 防第 8 份出現，**你落地後改**）。

## ★最後一件（給所有讀資料的人）
**這刀落地前，所有 specimen／量測床／QA 讀法裡的「同一個 id」都只能讀成「同一個號碼」，不能讀成「同一支隊」。**
落地之後，先前那些 convoy 數字才值得重讀一次。
