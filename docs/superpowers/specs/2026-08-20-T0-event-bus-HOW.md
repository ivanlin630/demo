# HOW spec：T0 事件匯流排 + 事件驅動思考（效能 arc slice A／時間 spec §3 T0 同體）

date: 2026-08-20 ／ owner: systems ／ 上位 plan ＝ `2026-08-20-event-proportional-compute-HOW.md`（R² CLEAN）
狀態：待 R² → dispatch。

## §0 ★先拆一刀：A1（加反應性）與 A2（減輪詢）必須分開量
blueprint 的 T0 同時含**兩個方向相反的效果**：**瞬醒＝更常想（加計算、改行為）**、**取消輪詢＝更少想（減計算）**。
**混在一次做 → 量出來的淨值說明不了任何事**（正負相抵，無法歸因是哪半在起作用）。
∴ **A1 先落地並量、A2 再落地並量**：
- **A1｜事件匯流排 + 瞬醒**：只**加**（事件發生 → 相關隊立即可思考），輪詢**照舊不動**。預期：**行為更靈敏、計算略增**。
- **A2｜輪詢退場**：把「沒事發生也每 cadence 想一次」降頻/取消，靠 A1 的事件接住反應性。預期：**計算真正下降**。
★**A2 的前提是 A1 的盤點是全量的**——漏掉的事件型別會變成「該想的時候沒想」（比慢更糟）→ 故 §2 的盤點是 A2 的**硬前提**，非 A1 的附屬品。

## §1 T1：事件匯流排（單一 chokepoint、determinism 友善）
- `WorldEvents.emit(state, kind: String, subjects: Array)` → 對每個 subject team 標記 `pending_rethink`。
- **儲存**：`state.pending_rethink: Dictionary`（team_id → true）。**不放 TeamData**（它是 tick 內暫態、非持久世界態）→ ★**不入 fp**（同 `*_eval_next_tick` 那批 cadence 排程欄的既有慣例；但**要在註解寫明為何不入**，避免日後誤判成盲點）。
- **消費順序 ＝ team_id 升序**（穩定；禁 Dictionary 迭代序直接用）。
- **消費即清**：該隊本輪思考完 → 清旗標。
- ★**明文設計保證（R² ④ 要求、升格為設計條款而非事後量測）**：**消費迴圈必須在單一 tick 內把「當下快照」清空、不得分批**（禁「效能考量下只處理前 N 個、其餘留到下 tick」）。
  **理由**：`pending_rethink` 不入 fp 的正當性**完全建立在「它是 tick 內暫態」之上**；一旦分批，它就跨 tick 存活、`*_eval_next_tick` 的類比不成立 → 變成 determinism 盲點。
  ★**且不能只靠 gate 3 的三跑 byte-identical 事後抓**——byte-identical 抓得到「殘留造成分岔」，**抓不到「有殘留但三跑都一樣殘留」的偽陰性**（determinism 相同 ≠ 沒有殘留，只代表殘留是 deterministic 的）。

## §2 ★全量事件盤點（blueprint 明令「不搞白名單挑食」）
**現況：沒有中央事件登記**——`emit_message` 用 **17 個 ad-hoc 字串型別**；而「戰鬥起／領袖死／滅團」只是**函式呼叫**、不經訊息層。
**盤點來源三類（實作時逐條掛點，spec 附完整表）**：
1. **訊息型（17 種、`emit_message` 為 chokepoint）**：`combat_start`／`combat_end`／`famine_warning`／`faction_defect`／`faction_establish`／`diplomacy`／`extortion`／`subjugate`／`tribute`／`aid_given`／`aid_refused`／`trade_done`／`order_*`／`order_delivered`／`outpost_built`／`split`／`replace`。
2. **函式 chokepoint 型**：`NpcCombatSystem.start_combat`（被襲）／`EventSystem.on_leader_death`（領袖死）／`FactionAISystem._on_team_extinct`（滅團・目睹）／`WorldState.erase_teams`（同批死亡）／★**`DiplomaticAiSystem._execute_betrayal`（背叛）＝R² 抓到的第五個、我原本漏列**。
   ★**背叛這個漏洞的形狀值得記**：該函式全檔 **零 `emit_message`**，直接改 faction 歸屬 + 砍受害方聲望 −0.5 + 寫受害方 leader memory，只 `Probe.bump("g3.betrayal")`；**但它有 `state.player_alerts.append(...)` 通知玩家** → **玩家會立刻知道自己被背叛，NPC 受害者不會** ＝ 本日反覆出現的**玩家中心**家族又一實例。掛點：對 **`ally_team`（受害方）** 標 `pending_rethink`。
3. **狀態跨線型（需新增偵測點）**：**跨餓線**（`famine_days` 由 0 轉正、或 `food_days` 跌破人格安全線）／**勞力危機**／**關鍵情報抵達**（belief 更新且改變已知威脅/機會）。
★**守衛（新不變量）**：**新增突發事件型別必掛 T0**——`debug` 加一支檢查：`emit_message` 的 type 集合 與 T0 掛點表**對帳**，有新 type 未掛 → **FAIL**（同 constitution_gate 級別）。這條讓「白名單挑食」**結構上不可能**，而不是靠紀律。

## §3 T3：決策迴圈讀 pending
- 現行 cadence 判斷 **改為 `cadence 到期 OR pending_rethink`**（A1 階段：**只加不減**）。
- ★**在途不想**（blueprint 點名、intended-change）：移動中的隊**不因 cadence 重評**，但**仍受事件喚醒**（被襲/情報照樣瞬醒）→ 這條**同時**是反應性提升與計算下降，**歸在 A1 並單獨標注**（因為它會改變既有「移動中反覆重評」的行為）。

## §4 gate
**A1**：
1. **事件瞬醒真的發生**：合成床——非 cadence tick 發生 `combat_start` → 該隊**當 tick**可思考（對照組：舊行為要等 cadence）。
2. **全量盤點對帳守衛**：故意加一個假 message type 未掛 T0 → 守衛 **FAIL**（證明守衛有牙）。
3. **消費順序穩定**：同 seed 三跑 byte-identical。
4. **在途不想**：移動中隊不再每 cadence 重評（計數對照），**但被襲仍瞬醒**。
5. constitution ≤75／headless 0-new／**fp intended-change**（瞬醒與在途不想都真的改行為）。
6. ★**量化（blueprint 每刀量化紀律）**：每遊戲日 wall time、決策次數/日 — 預期**決策次數略增**、wall **略增**；**照實報**。
**A2**（另票、A1 綠後才發）：輪詢降頻/退場 → 量**決策次數/日下降**與 **wall 下降**，且 **A1 的反應性 gate 全部仍綠**（不得用降頻換掉靈敏度）。

## §5 風險
- ★**漏掉事件型別 ＝ 該想的時候沒想**（比慢更糟）→ §2 守衛是硬要求，且 **A2 不得在守衛缺席時落地**。
- ★**對帳守衛只保護第一類（`emit_message`）**（R² ③ 指出）：第二類（函式 chokepoint）與第三類（狀態跨線）**沒有結構性保護**——`_execute_betrayal` 正是從這個缺口漏掉的活案例。
  **弱防護建議（非本輪阻塞、記入 backlog）**：chokepoint 函式頂端統一加可 grep 的標記註解（如 `# T0-CHOKEPOINT: <event>`），另備一支輕量掃描：找「函式名含 `_execute_`/`_on_`/`_trigger_` 前綴、但無標記」的可疑函式 → **印出供人工複核、不自動 FAIL**（比 `emit_message` 那支弱，但比零防護強）。
- **pending 不入 fp** 的判斷若錯（它其實跨 tick 存活）→ determinism 盲點 → ★gate 3 的三跑 byte-identical 是這條的實證防線。
