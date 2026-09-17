---
slice: 兩支姊妹 site 改讀 `known_outposts`（`feat/sister-sites-outpost`）
owner: systems
status: draft — 待 R②（★R① 免：前提已由前一票的實作坐實，見 §0）
基於: `defers.tsv` → `settle-scan-reads-live-outpost-after-tile-gate`（條件已達成：據點票已 merge）
---

# §0 前提（★已坐實，不需要 R① factcheck）

```
main 現況（我剛核過）：
  BeliefSystem.known_outposts(state, observer_id) -> Array   ← belief_system.gd:364（★已在 main）
  faction_ai_system.gd        已改讀 ⇒ known_outposts 命中 2   ← 前一票做掉的那一支
  strategic_ai_system.gd      ★未改 ⇒ 命中 0
  decision/decision_context.gd ★未改 ⇒ 命中 0
```
★**所以這一票不是新設計，是【把已經證明可行的那一支的做法，套到剩下兩支】。**

# §1 病灶（逐字同形，reviewer 2026-09-17 揭第二支、systems 全庫掃補第三支）

```
閘：team_tile_known（只問「有沒有見過這塊地」，不分是誰的）
閘過了之後 ⇒ ★直接 live 讀 tile.outpost_owner ／ tile.outpost_level
⇒ belief 閘只授權「要不要評估」，★★不授權讀 live 值（憲法 §1a）
```
| # | 位置 | 函式 | 備註 |
|---|---|---|---|
| ② | `strategic_ai_system.gd:309-320` | `_find_trade_partner` | ★該函式 `:300-302` 的註解 **2026-09-02 就自承是 `CANDIDATE-LEAK…待 R²＋follow-up`** |
| ③ | `decision_context.gd:529-533` | `gather`（產出隊找 `work_outpost`） | ★**reviewer 與我都沒點到，是我照「先裸符號全庫掃再分類」補出來的** |

★★★**而有一支長得像卻【不是】病灶**：`goal_resolver.gd:1538-1546`（`find_nearest_known_tile`）
閘後 live 讀的是 **`t.terrain`** —— ★**地形不會變** ⇒ 「當時」與「現在」是同一個值 ⇒ **沒有製造出不該有的知識**。
⇒ ★★**判準是【那個欄位會不會變】，不是【有沒有在閘後讀 live】** —— **不要把它也「修」掉。**

# §2 修法

**兩支都改成列舉 `BeliefSystem.known_outposts(state, <觀察者 id>)`**，
子記錄帶 `owner_id`／`level`／`last_tick` ⇒ **原本 live 讀的兩個欄位改讀子記錄**。
★**`decision_context.gd` 那一支的觀察者是 `team`（自知，合法）**；`strategic_ai` 那一支是 `trader`。
★★**不要動 `gather()` 裡其他 8 處【合法的自家據點讀取】**（讀自己的家不是 god-view）——
★★★**這正是我上一輪 met_check 寫成「函式裡不再出現 outpost_owner」會【恆假】的原因。**

# §3 驗收（★每格能紅）

| 格 | 內容 | 反向 |
|---|---|---|
| 1-a | ★**知道得太多那一半消失**：見過 owner、沒走過那座城 ⇒ **不在**候選集（兩支各一格） | 退回 live ⇒ 它會在 ⇒ 紅 |
| 1-b | ★**知道得太少那一半消失**：走過城、沒見過 owner ⇒ **在**候選集 | 退回 live ⇒ 它不在 ⇒ 紅 |
| 1-c | ★**零 god-view**：兩支函式內**不再出現** `tile.outpost_owner`／`outpost_level` 的 live 讀 | 殘留任何一個 ⇒ 紅 |
| 1-d | ★★**`goal_resolver.find_nearest_known_tile` 逐字未改**（★守「別修錯東西」那一格） | 有人順手改了 ⇒ 紅 |
| 1-e | ★★**`gather()` 裡的自家據點讀取逐字未改**（8 處） | 被順手清掉 ⇒ 紅 |
| 1-f | ★世界級：兩支的候選集**都真的換了一批**（各印「只有新版有／只有舊版有／兩者都有」三個數） | 三個數有一個恆 0 ⇒ 要解釋 |
| 1-g | ★★★**到場點名**（要件③）＋ expect 釘 `N／N` | 少一格 ⇒ 紅 |

# §4 不在本票
`BELIEF_STALE_TICKS` 物理化（另一張 defer，條件也已達成，**另票**）。
