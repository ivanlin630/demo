---
from: systems
to: implementer
status: open
topic: "[dispatch T0-A1 事件匯流排+瞬醒(效能 arc 第一刀、與時間 spec §3 同體)·spec=2026-08-20-T0-event-bus-HOW.md(含 R²delta:第五個 chokepoint、單 tick 清空明文保證、守衛覆蓋範圍)·R²=CLEAN+1 必查項(已納入 spec)·★這一刀【只加不減】:事件發生→相關隊立即可思考,輪詢照舊不動;A2(輪詢退場)是【另一票】、A1 綠了才發——理由:兩者方向相反,混做的淨值正負相抵無法歸因·★T1 匯流排:WorldEvents.emit(state, kind, subjects)→state.pending_rethink[team_id]=true;★消費順序=team_id 升序(禁 Dictionary 迭代序);★★消費迴圈【必須單 tick 內清空當下快照、不得分批】(這是 pending 不入 fp 的正當性基礎;分批=跨 tick 存活=determinism 盲點,且 byte-identical 抓不到『三跑都一樣殘留』的偽陰性)·★T2 全量盤點掛點(三類、spec §2 有完整表):①17 個 emit_message 型別②函式 chokepoint 五個【含 R² 抓到我漏的第五個 _execute_betrayal(diplomatic_ai_system:330)——它全檔零 emit_message、直接改 faction 歸屬+砍受害方聲望+寫 memory、卻【有通知玩家】(player_alerts)而 NPC 受害者不會被喚醒=玩家中心家族又一實例;掛點對 ally_team 標 pending】③狀態跨線型【目前連偵測點都不存在、要新增】:跨餓線(famine_days 由 0 轉正 或 food_days 跌破人格安全線)/勞力危機/關鍵情報抵達(belief 更新且改變已知威脅或機會)·★T3 決策迴圈:cadence 到期 OR pending_rethink(A1 只加不減);★『在途不想』(移動中隊不因 cadence 重評、但仍受事件喚醒)也在本刀、單獨標注·★T4 對帳守衛:emit_message type 集合 vs T0 掛點表,有新 type 未掛=FAIL(constitution_gate 級);★gate 要求【故意加一個假 type 證明守衛有牙】·★誠實邊界(spec §5 已記):此守衛【只保護第一類】,函式 chokepoint 與狀態跨線【沒有結構性保護】(betrayal 正是從這缺口漏的)——弱防護(可 grep 標記+啟發式掃描)記 backlog、非本輪·gate①事件瞬醒真發生(非 cadence tick 發生 combat_start→該隊當 tick 可思考、對照舊行為要等 cadence)②守衛有牙(假 type→FAIL)③消費順序穩定+三跑 byte-identical④在途不想(移動中隊 cadence 重評次數降、但被襲仍瞬醒)⑤constitution<=75+headless 0-new+fp intended-change⑥★量化照實報:每遊戲日 wall + 決策次數/日(【預期兩者都略增】——這一刀本來就是加反應性、不是省算力;報出增幅供 A2 對照)·worktree feat/t0-event-bus·完→handback to:systems·地基KEEP"
---

# dispatch：T0-A1 事件匯流排 + 瞬醒（效能 arc 第一刀／時間 spec §3 同體）

spec＝`docs/superpowers/specs/2026-08-20-T0-event-bus-HOW.md`（含 R²delta）。**R²＝CLEAN + 1 必查項（已納入）**。

★**這一刀只加不減**：事件發生 → 相關隊立即可思考，**輪詢照舊不動**。**A2（輪詢退場）是另一票**、A1 綠了才發——**兩者方向相反，混做的淨值正負相抵、無法歸因**。

- **T1 匯流排**：`WorldEvents.emit(state, kind, subjects)` → `state.pending_rethink[team_id]=true`；**消費順序 ＝ team_id 升序**（禁 Dictionary 迭代序）。
  ★★**消費迴圈必須單 tick 內清空當下快照、不得分批**——這是「`pending_rethink` 不入 fp」的**正當性基礎**；分批 ＝ 跨 tick 存活 ＝ determinism 盲點，而 **byte-identical 抓不到「三跑都一樣殘留」的偽陰性**。
- **T2 全量盤點掛點**（三類、spec §2 有完整表）：①17 個 `emit_message` 型別 ②**函式 chokepoint 五個**——★含 **R² 抓到我漏的第五個 `_execute_betrayal`**（`diplomatic_ai_system:330`）：它全檔**零 `emit_message`**、直接改 faction 歸屬 + 砍受害方聲望 −0.5 + 寫 memory，**卻有通知玩家**（`player_alerts`）而 **NPC 受害者不會被喚醒** ＝ 玩家中心家族又一實例；**掛點對 `ally_team` 標 pending** ③**狀態跨線型**（**目前連偵測點都不存在、要新增**）：跨餓線／勞力危機／關鍵情報抵達。
- **T3 決策迴圈**：`cadence 到期 OR pending_rethink`；★**「在途不想」**（移動中隊不因 cadence 重評、**但仍受事件喚醒**）也在本刀、**單獨標注**。
- **T4 對帳守衛**：`emit_message` type 集合 vs T0 掛點表，**有新 type 未掛 ＝ FAIL**（constitution_gate 級）。
  ★**誠實邊界**（spec §5 已記）：此守衛**只保護第一類**；函式 chokepoint 與狀態跨線**沒有結構性保護**（betrayal 正是從這缺口漏的）→ 弱防護（可 grep 標記 + 啟發式掃描）記 backlog、非本輪。

**gate**：①事件瞬醒真發生（非 cadence tick 發生 `combat_start` → 該隊**當 tick** 可思考） ②**守衛有牙**（故意加假 type → FAIL） ③消費順序穩定 + 三跑 byte-identical ④在途不想（cadence 重評次數降、**但被襲仍瞬醒**） ⑤constitution ≤75 + headless 0-new + fp intended-change ⑥★**量化照實報**：每遊戲日 wall + 決策次數/日——**預期兩者都略增**（這一刀本來就是加反應性、不是省算力），**報出增幅供 A2 對照**。

worktree `feat/t0-event-bus`。完 → handback to:systems。地基 KEEP。
