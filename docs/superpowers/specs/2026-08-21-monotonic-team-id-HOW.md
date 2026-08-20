# HOW spec：team_id 永不重用（單調遞增）

slice: monotonic-team-id   <!-- P9：tier 由派工 handback 定，不寫這裡 -->
date: 2026-08-21 ／ owner: systems ／ 起因：QA 故事稽核 → implementer 診斷坐實

## §1 前提（實測坐實，非推論）
`SubteamSystem._next_team_id`（`subteam_system.gd:346-351`）＝ **`max(現存 id) + 1`**
⇒ **最高 id 的隊一死，下一個子隊就撿回同一個號碼**。

**三處消費端都拿 `team_id` 當身分** ⇒ 各自產生一種靜默失真：
| 消費端 | 失真 |
|---|---|
| `SpecimenTracer` | 兩條命縫成一條 timeline；**中間空白看起來像「觀測斷了」** |
| convoy 量測床 | `dispatch = 7` 但只列出 **3 隻** porter（撞到既有 id 就當同一隻） |
| QA 讀法 | 「porter_12 **第二趟**」——實際是**第二支持有 id 12 的隊** |

**實測（team 12）**：命 1 `2400→4600`；**空白 `4600–7300`（2700 tick 無主）**；命 2 `7300` 起。
`max_gap = 2740` 與空白**完全吻合**。

★ 另一面：implementer 的黏著式 `_ever_in_scope` **也以 `team_id` 為 key**
⇒ **未來撿到同號碼的無關隊伍會自動被當成 specimen ＝ 假涵蓋**（本輪尚未造成錯誤結論，但同根因）。

## §2 設計
**`WorldState` 加 `next_team_id` 單調計數器**（**比照既有 `next_beast_id` 負區段的作法**，有前例可循），
`_next_team_id` 改讀它 ⇒ **id 永不重用**。

**★為什麼不選「消費端改複合鍵 `(id, birth_tick)`」**：那是「**記得在每個地方註冊**」那一族——
**今天已經因為這族栽了三次**（specimen 選樣清單凍結／fate 以隊伍消失推論／trip 以 id 為鍵）。
**一次改產生器，三處消費端同時解掉**；改消費端則每新增一個讀者就要再記得一次。

## §3 ★風險與必做稽核（本 slice 的主要工作量在這裡，不在那個計數器）
**必須窮盡查出「假設 id 有某種性質」的地方**，逐條列出結論（**負斷言協議：不得用 `head` 截斷**）：
1. **假設 id 連續／緊湊**（陣列索引、`for i in range(max_id)`、以 id 當 slot）
2. **假設 id 有上界**（固定大小容器、位元遮罩）
3. **依賴 `max(id)` 語意**的其他地方
4. **存檔／載入**：舊存檔的 id 與新計數器的起始值（**載入後 `next_team_id` 必須 > 檔內最大 id**）
5. **負區段**：`next_beast_id` 與 team id 的區段不得相撞
6. **fp**：id 序列改變 ⇒ **`state_fingerprint` 會變 ＝ intended-change**（**非迴歸**）

## §4 gate
1. **id 永不重用**：合成床——建隊→滅團→再建隊，**新隊 id 必大於所有歷史 id**
2. **舊存檔載入**：載入後 `next_team_id > 檔內最大 id`；再建隊不撞號
3. **三處消費端失真消失**：
   - 量測床 `porters_tracked` 與 `trips_total` **一致**（現況 3 vs 6）
   - specimen 同一 id **不再出現「無主空白」**
   - `_ever_in_scope` 不再有假涵蓋（**同號碼不同隊不得自動入範圍**）
4. **det×3 穩定**；`fp` **intended-change**（**要在帳上明寫，別讓人讀成迴歸**）
5. **憲法 ≤74**；**headless 0-new**
6. ★**§3 稽核逐條有結論**（**「沒有」也要附窮盡證據**），缺一條不算過

## §5 不做
- **不回頭修既有量測產物**（已產出的 specimen／床報告**維持原樣**，但**讀它們時要記得同一 id 可能是多條命**）。
- **不改 `next_beast_id`** 的現行作法（只借用它的形狀）。
