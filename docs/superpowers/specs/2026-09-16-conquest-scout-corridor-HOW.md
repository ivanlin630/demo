---
owner: systems
status: 待 R²
date: 2026-09-16
defer-token: `conquest-scout-corridor`（條件已達成）
---

# 病

`faction_ai_system.gd:440-454`（`_commit_conquest_attack`）：
引擎選了攻擊 ⇒ `confident_enough` 為假 ⇒ **直接 `try_set(state, team, TASK_SCOUT, …, PRIO_DISPATCH, "scout")`**。

★**它以前不是病**：那時秤上沒有偵查 option，**它是唯一讓偵查發生的路**（函式註解自稱 scaffolding）。
★★**而現在是**：偵查已經是一個真的 option（`2fb10d7c1` 起）⇒ **同一件事有兩條路**
⇒ ★★★**而這一條是在【秤已經開口之後】把結果改掉** —— 框架內補丁／冗餘求解器。

# 修法：**降成可行性**，不是刪掉行為

```
`confident_enough` 為假 ⇒ **「攻擊這個目標」不可行**
   ⇒ ★**那個攻擊 candidate 不該被產生**（與本專案剛落地的 admission 分層同構）
   ⇒ ★★**而「所以去偵查」回到秤上** —— **偵查 option 已經存在，不必再造一條路**
⇒ **在 candidate 生成時擋，而不是在 dispatch 時改寫結果。**
```

# ★★★驗收（成對，缺一組不可判）

```
\u2460**走廊歸零**：`g3.scout_dispatch` ＝ **0**（全窗）
\u2461★**而偵查總量【不塌】**：引擎那條（`recon.dispatch.engine.ok`）接手
   ⇒ ★★**兩格必須【成對】** —— **只驗①會把「偵查消失了」判成成功。**
\u2462**攻擊的候選數下降**（不可行的那些不再被產生），**而攻擊仍會贏 argmax**
   ⇒ ★**否則就是把攻擊判死，而不是把它變誠實。**
```

# ★危險：拆掉 dispatch 之後，**誰來釋放**？

`_tick_conquest_scout`（`:481-495`）是**偵查中隊伍的生命週期**：prey 消失／逾時 ⇒ `TaskArbiter.release`。
★**它讀的是 `task_reason == "scout"` 與 `prosperity_target_id`** ——
⇒ **若走廊不再設 `prosperity_target_id`，這支 lifecycle 會【對新路徑失效】**
⇒ ★★**必須確認**：引擎那條偵查 option 有沒有自己的 timeout／釋放？
  **若沒有 ⇒ 拆走廊會製造「永遠在偵查」的隊** —— ★★★**那比走廊本身更糟。**
⇒ **這一格要先查再動**，答案寫進交件。

# 不做

- 不動 `confident_enough` 本身（可信度那根軸已裁：它管 admission）。
- 不動偵查 option 的估值（先驗三守衛版不變）。
