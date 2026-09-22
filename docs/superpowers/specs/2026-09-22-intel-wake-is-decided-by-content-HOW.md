---
slice: 情報瞬醒改由**內容**決定（威脅才瞬醒，其餘折進下一次排定思考）
owner: systems
status: ★**草稿，待 R²**（2026-09-22）——★世界改變窗 #3 ＝ 這張（世代 7），WHAT 已裁
基於: DIAG 票 `2026-09-22-the-hourly-whole-world-pass-DIAG.md` §11；WHAT 裁定 2026-09-22（喚醒語意）
---

# §1 ★前提（file:line 坐實，systems 開檔核過）

```gdscript
# scripts/simulation/world_events.gd:64
static func emit(state: WorldState, kind: String, subjects: Array) -> void:
    for tid in subjects:
        state.pending_rethink[id] = true      # ★★★只存「有事」，**不存 kind、不存內容**
# scripts/simulation/world_events.gd:100
static func pending_source(...) -> String:
    if state.pending_rethink.has(team_id): return "cur"    # ★恆回 "cur" ⇒ 消費端問不出來源
# scripts/simulation/belief_system.gd:293
WorldEvents.emit(state, "intel_arrived", [obs_id])          # ★情報的唯一 emit 點
```
★量到的（DIAG §11）：`woke_only` **441 次全部在 pass tick**、非 pass **0**；
emit 端 12 種事件 **100% 落在 pass tick**，`intel_arrived` **佔 94%**。

# §2 ★★★這條裁定**不能在消費端實作** —— 而那指出一個更好的形狀

```
WHAT 裁：「**緊迫由內容決定，不由管道決定**」
★但消費端（`faction_ai_system.gd:8081` 的 `_woke`）**手上只有一個布林** ——
  `kind` 沒存、`pending_source` 恆回 `"cur"` ⇒ **它不可能依內容分流**
⇒ 兩條路：
  (a) 讓 `pending_rethink` 帶內容 ⇒ **新增狀態 ＋ 每次喚醒多一次查詢**
  (b) ★★★**把判斷搬到 emit 端**：**非威脅的情報【根本不 emit 瞬醒】**
⇒ **選 (b)**。理由三條：
   ①**資訊在那裡**：`belief_system.gd:293` 當下手上就有 `tgt_id`／`fields`／觀察者的 `team_intel`
   ②★★**零新狀態、零新查詢** ⇒ 不會把省下來的時間又花掉
   ③★★★**它讓 B1 的「非威脅 intel 引發的瞬醒 ＝ 0」變成【構造保證】**，
     而不是一張要有人維護的清單 —— **清單保證會因為漏列一個點而變綠。**
```

# §3 ★★★感知鐵律（**我 owner 的憲法，這裡先套回自己**）

```
威脅判定**只能讀【觀察者自己的 belief】**，★**不得讀世界真值**。
⇒ 可用：`state.team_intel[obs_id]` 底下那一筆 claim 的內容（**這隊知道的東西**）
⇒ ★**不得**：直接去 `state.teams[tgt_id]` 讀對方此刻的兵力／位置／意圖
⇒ ★★**判準句**：**「如果這隊其實被騙了，這個判斷會不會跟著錯？」** ——
   **答案必須是「會」**。若答案是「不會」，代表我讀了它不該知道的東西。
★★★而這一條**不是提醒，是驗收格**：spec 送審時 R² 要能在 diff 裡指出讀的是哪個容器。
```

# §4 ★第 0 步（**在實作之前，而且它可能直接殺掉這張票**）

```
★**先量：那 5386 次 `intel_arrived` 裡，有多少會被判為【威脅相關】？**
   ・純 tap，不改行為：在 `belief_system.gd:293` 前計數兩類（威脅／非威脅）
   ・兩顆種子、與 DIAG 同窗（★窗長要與 B1 的母體一致）
⇒ ★★**它把 B1 從【方向性】變成【一個推導出來的數字】**：
   威脅佔比 ＝ f ⇒ **預期 `woke_only` ≈ 441 × f ＋ 非情報喚醒（~6%）**
⇒ ★★★**若 f 很高（例如 > 0.6）⇒ 這張票買不到 35%** ⇒ **回報，不要硬做**
   （★而那不是失敗：它會把答案推向 (乙) 幀分片，而那正是 WHAT 留的 defer 門票。）
★**「假設為假時這格長什麼樣」**：若情報其實不是喚醒波主因 ⇒ f 無論多少，`woke_only` 都不會降。
```

# §5 驗收（★WHAT 預註冊版原文照收 ＋ §4 推導出的門檻）

| 格 | 判準 |
|---|---|
| **B1** 機制 | pass tick 上 `woke_only` 次數相對修前**下降**；★**門檻由 §4 的 f 推導**（≈ 441×f＋非情報）；**非威脅 intel 引發的 T0 瞬醒 ＝ 0（構造保證）**；威脅 intel 引發的瞬醒次數與修前**同量級（±20%）** |
| **B2** 行為 | 威脅反應延遲（威脅情報 → 第一個反應動作的 tick 數）median 修前後**同（±10%）**；非威脅情報 → 動作延遲 median **≤ 60 tick** |
| **B3** 玩家尺 | `>2s` 幀數／p99／median（同尺）；可交玩門檻不變（**≤1/日 且 p99<1s**） |
| **B4** 副作用 | 每隊每日決策次數 median **±5%**；**A6 守 `extinct`／`starve`／`combat`**（★帶主詞，不用 `teams.size()`） |
| **B5** fp | 指紋床改變 ＝ **預期紅** ⇒ 世代 7；★**樁開／關 fp 相同**（不變量 #7） |
| **B6** 陽性對照 | 把「**威脅也折進排定**」跑一次 ⇒ **B2 的威脅延遲必須惡化** ⇒ 證明 B2 會紅 |

★**WHAT 的「假設為假」句原文保留**：若情報不是喚醒波主因 ⇒ B1 的 `woke_only` 不會降、B3 不動
⇒ ★★**兩格一起綠才算**。

# §6 閘（★形狀窄 ＋ 陽性對照）

```
禁：在 `belief_system.gd` 的威脅判定路徑上出現 `state.teams[` 直讀對方欄位
  ⇒ ★**陽性對照**：把判定改成讀世界真值 ⇒ 該閘**必須紅**（否則它沒有鑑別力）
★★而閘只掃**威脅判定那一段的函式範圍**，不掃整個檔（★錨在函式不在行號 —— 行號會被推走）
```

# §7 ★不做的事

```
✘ 不讓 `pending_rethink` 帶 payload（那是 (a)，會把省下的時間花回去）
✘ 不列「哪些事件型別可以等」的白名單 —— ★**WHAT 明令用內容切，不用管道切**
✘ 不碰十處純加法那條分支（HELD，不搭這班）
✘ ★**在 §4 的 f 回來之前不寫實作** —— f 高就不做，那不是失敗，是省下一次世代邊界
```
