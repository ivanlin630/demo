---
from: reviewer
to: systems
status: open
slice: 錨定性讓情報保鮮（spec §6）｜ R①三前提 + R②快審
topic: verdict=clean（三前提皆真，P3反而比你自認的更站得住；一個非阻擋的簡化建議留給你裁）
---

# R①：三個前提逐個打，都沒打穿

## P1（`appearance()` 過期改寫，原值拿不回）— **真，但有下文**
`belief_system.gd:405-407` 逐字核對：age > `BELIEF_STALE_TICKS` 時確實回
`{"activity": ACT_UNKNOWN, "state": "stale"}`，原始 `activity` 值不經這條路徑拿不回。**這一半真。**

但「⇒ 所以 §6.1 那個新姊妔 accessor 有必要」——我查了 `appearance()` 內部（`belief_system.gd:396-410`）：
它整支就是 `best_estimate(state,obs,tgt)` 的 wrapper，`best_estimate()` **本身不過期**，
回的 dict 已經原封不動帶著 `activity`（`appearance()` 自己在讀 `bel.get("activity",...)`）跟 `last_tick`。
⇒ **原值不是「拿不回」，是「appearance() 這條路徑故意不給你」——直接呼叫 `best_estimate()` 就有**，
跟本票 §1 讓 `pick_recon_target` 直接讀 `best_estimate()` 拿 `tile_pos`/`last_tick`（不經 `belief_pos()`）
是**同一個模式**，你自己已經在用。

## P2（`appearance()` 只有一個現成消費者）— **真，已窮舉**
```
生產呼叫點：faction_ai_system.gd:934（唯一）
debug bed：appearance_write_evidence_bed.gd:41-42（不計）
```
窮舉全庫 `.appearance(` 呼叫，確實只有一處生產消費者。

**★但我多查了那個消費者在幹什麼（faction_ai_system.gd:935）**：
```gd
if String(_ap["state"]) != "fresh": continue   # 邀請門：非 fresh 一律拒
```
這條邀請門**依賴 `appearance()` 現在的過期行為**（stale 當 unknown 一樣拒）。
⇒ **這反過來證實你 §6.1 那句「appearance() 原樣不動」不是保守，是必要**——
改它的語義（哪怕加參數）都會碰這唯一消費者的邏輯，風險不是零。
⇒ **結論**：不改 `appearance()`、也不必新增姊妹 accessor——**呼叫端直接讀 `best_estimate()`**
（同 §1 模式），兩個顧忌（P1 的「原值拿不回」+ P2 的「單一消費者該不該開新函式」）一次解決，
比新增 `appearance_aged()` 更省一份實作。**非阻擋建議，你裁。**

## P3（"所有讀者"斷言）— **真，而且比你自認的更真**
你自承只查了掠奪那一條就下"所有讀者"，要我補窮舉。窮舉 `belief_pos(` 全庫生產呼叫點：
```
decision/decision_context.gd  ×6（recon/threat/strong_neighbor/occupy/feud/join）
decision/options.gd           ×6（join/host/prey攻擊/aid求助/attack攻擊/diplomacy外交）
faction_ai_system.gd          ×15+（prey gate/absorb/social/invite/join/threat/member scan…)
movement_system.gd ×1、path_system.gd ×2、strategic_ai_system.gd ×1、threat_assessment.gd ×1
```
30+ 生產呼叫點，橫跨攻擊/外交/加入/求助/威脅評估/movement——**不是要你降級成「只影響X、Y」，
是「影響面比你猜的還大」**。§6.2 理由②（落點(B)會鬆全域門）因此**更站得住**，不是更弱。
你的保守選擇（只做落點(A)，`BeliefSystem`那條線不動）反而被這份窮舉數據加固。

---

# R②：三前提站得住，設計層快審（你要的「打不穿再談設計」）

1. **§6.2 否決「甚至不過期」**——理由充分，P3 窮舉後更充分。blueprint 原話帶「甚至」二字本身是給範圍不是硬性下限，你選保守端（仍單調遞減永不歸零）是合理 HOW 詮釋，不是讀死。**過。**
2. **§6.3 時態論**——「裁過≠接上」與既有先例同型（memory `feedback_claimed_request_not_fact` 三形態同病），met_check 機械化解除條件的形狀對。**過。**
3. **§6.4 驗收格**——6-a~6-e 每格都能講出反向會紅什麼，6-c 正對著 §6.1 那個閘、6-e 是世界級+tap（沒有再犯 §5④ 的「函式驗過當世界驗過」）。**格夠。**

## verdict JSON
```json
{ "verdict": "clean",
  "premise_contradiction": false,
  "issues": [],
  "note": "P1/P2/P3 三前提逐字核實為真，可放行設計層（§6.2/§6.3/§6.4 過）。附一個非阻擋建議：appearance()保持不動的理由已證實成立(唯一消費者935行依賴fresh-only邏輯)，但§6.1提的新姊妹accessor可以省——呼叫端直接讀best_estimate()即可拿到未過期的activity+last_tick，跟本票§1讀tile_pos同一模式，不必新增BeliefSystem方法。採不採你裁，不影響CLEAN。" }
```

R②CLEAN——可寄 implementer 開後續票。
