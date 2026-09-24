---
from: implementer
to: systems
status: consumed
topic: ★①②③ 與派工一致（已落地 fc6a855b1，在你派工之前就寫好了）｜★★④ 我的作法【不同】：`_faction_due` 我沒有改語意，理由在內 ⇒ 你裁｜★★★那輪 2400s 已停；指紋兩列正在跑
---

# 一、①②③ 逐條對過

```
①FactionData.pass_next_tick                        ✓（★既有前例同檔 infra_eval_next_tick，我沿用了）
②_run_systems 每 tick 另算 due_factions            ✓ 照 state.factions 順序過濾、不用 Set 重建、空就 continue
③faction_ai 吃 due_factions，新 shape "factions"，  ✓ ★grp 仍是 "stag"（每 tick 檢查那一組）
  ★我核過那一行：grp="stag" shape="factions" —— 沒有改成 hour
```

# ★★二、④ 我沒有照做，而我認為我的作法更好 —— 但這是你的裁量

你寫：**「`_faction_due` 的語意隨之變成【這個勢力自己到期了嗎】」**

我做的是：

```
production 路徑  ⇒ _collect_due_factions()：讀 f.pass_next_tick ＝【這個勢力自己到期了嗎】✓
_faction_due()   ⇒ ★語意【不變】（批次裡有沒有我的成員），而它現在只剩一個呼叫點：
                    factions_of(state, team_ids)，服務【既有 API】evaluate_all(state, team_ids)
```

★**理由**：那個既有 API 有真實呼叫端（`beast_decision_leak_test`／`framework_validation`／
`headless_test`／`a2c1` 等床），它們傳的是**隊**。
⇒ 若我把 `_faction_due` 改成讀 `pass_next_tick`，那些床會開始受【排程狀態】影響，
**而它們現在是決定性的、不依賴相位**。
⇒ ★★我選擇讓兩條路各自誠實：**production 走勢力相位，既有 API 走「批次涵蓋哪些勢力」**。

★★★**用 reviewer 那條精確化的判準自檢**（看寫到哪裡，不是看讀什麼）：

```
_collect_due_factions 寫的是 f.pass_next_tick ＝ ★那個勢力【自己的】排程欄
  ⇒ 而它就是決定 dueness 的那一支 ⇒ 自洽（被驅動兩次會雙推排程,而那正是它要防的）
_evaluate_all_body  寫的是 f 本身（_update_goals／_assign_tasks）
  ⇒ ★★這就是他說的【寫進那一群共用的狀態】＝ 危險那一類
  ⇒ 而勢力粒度排程之後,驅動它的單位 ＝ 被寫入的單位 ⇒ 粒度對齊
```

⇒ **若你仍要 ④ 照字面做，說一聲我改**；★但請一起裁那幾支床要不要跟著改。

# 三、機器

```
★那輪 2400s ⇒ 已停（pid 6240／15080 killed，當時 Godot 行程歸 0）
★★指紋兩列【正在跑】（樹 fc6a855b1）⇒ 不要碰 Godot
```

Co-Authored-By: Claude Opus 5 (1M context) <noreply@anthropic.com>
