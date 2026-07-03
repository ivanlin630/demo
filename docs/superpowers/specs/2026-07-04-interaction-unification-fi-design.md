# 互動統一（F-I2/I4/I5/I7 + I6 順手）— Design

> 統一矩陣剩餘・互動格（audit `2026-07-01-unification-matrix-audit.md`）。與 observer GUI slice 平行軌。
> F-I1（diplomacy resolver 統一）已 merged；本軌收互動格剩餘。
> **C 類 judge 紀律：統一=退役不並存**——舊公式/舊引擎收斂後必須死，不留平行路。

## 項目與現況（audit 錨點）

### F-I2 — tribute/extort accept 三公式統一
- `_should_pay_tribute`（interaction，god-view strength）/ `handle demand_tribute`（diplomatic，belief pop）/ `resolve_extortion_direct`（raw pop+fear）——同一「要不要屈服」判斷三套 epistemics。
- 統一向：**單一 accept 公式，belief-gated**（沿 F-I1/G3-E diplomacy 轉換 pattern：用 believed strength/pop，非 god-view）。三 caller 全走同源；fear/威嚇差異=輸入權重非分叉公式。
- **順手 F-I6**：`tribute_refused`（diplomatic:111）memory entry 缺 `type` 欄 → 補齊，type-scan counter 可見。

### F-I4 — deception/distortion 三引擎統一
- interaction `_write_tier2_intel` / message `_distort_content` / message `_distort_intel_entry` + 第 4 dormant。
- 統一向：**單 distortion 引擎**（單一函數 own「失真怎麼算」），三 call site 傳 context 參數。dormant 第 4 個=退役刪除（C 類）。
- ★失真含 RNG roll：統一後 RNG 消耗序必變——允許（行為統一本來就變），見驗收 baseline 節。

### F-I5 — RelationGraph typed-edge：接線 or 退役（judge）
- feud/killed/protect/gratitude edges **orphaned**：互動/外交/salary 全用 known_reputations+person.memory，不 consult。
- **measure-first**：先盤 producer 側——誰在寫 edges、資料活的還是空的（grep 寫入點+headless 跑量 edge 數）。
- Judge 二選一（C 類，不並存）：
  - edges 有真資料+有消費價值 → **接線**：互動/外交 accept 公式（F-I2 統一後的單公式）consult feud/gratitude 邊當權重項。
  - 空轉/與 known_reputations 全重複 → **退役**：刪 graph 或降級為 known_reputations 的 view。
- 裁決寫進 handback，別兩邊都留。

### F-I7 — combat-decision verb god-view → belief
- `_should_attack`/`_should_pay_tribute` 仍讀 god-view `team_strength`；diplomacy 已 belief（G3-E）。
- 轉換：讀 believed strength（team_intel/belief 源，沿 G3-E pattern）。無情報時 fallback=不確定性懲罰（保守），**不是偷看真值**。
- 與 F-I2 同函數帶（`_should_pay_tribute` 兩案都碰）→ **同軌做避免二次翻**：先 F-I2 統一公式、公式內全 belief 輸入=F-I7 同步完成。

### 順盤（報告即可，不強制重構）
- **finder 濾鏈 C 類 watch**：per-option finder 濾鏈重複盤點（audit watch 項）——列清單進 handback，重複顯著者標 C 類候選，本軌不動手（除非 trivial）。

## 硬約束

- **凡身分=權重非路徑切換**：統一公式內 faction/獨立差異走輸入權重。
- **凡 belief→provenance**：新 belief 讀取標 source；不引入新 god-view 讀。
- **RNG 流神聖（改動內部）**：濾鏈/公式含 randf 者勿重排勿 memoize（cadence 教訓）；行為改變 OK，順序假設不 OK。
- 單寫者格局不動：本軌只改判斷/讀側+distortion 寫 intel 走既有寫點。

## 驗收

1. 回歸：headless（1 pre-existing FAIL+0 SCRIPT ERROR+DONE）+ framework PASS=7 DORMANT=0 + coin_eq。
2. **seeded warring hash 允許變**（統一改行為）——變了要附前後 final 摘要（teams/factions/established/pop 量級不崩）。**merge 序：observer GUI 軌先 merge**（它靠同 hash 證明不擾），本軌後 merge 並以當下 main 重驗。
3. C 類證明:三 tribute 公式→1（舊二者刪）；三 distortion→1（舊+dormant 刪）；F-I5 二選一落地無並存。
4. F-I7:headless 加 belief-gate 測試（無情報→保守;誤報 believed strength→決策跟 belief 走,同 F-I1 deceive 測試 pattern）。
5. 順盤報告（finder 濾鏈清單）進 handback。

## 檔案 scope（平行紀律）

改：`interaction_system.gd`、`diplomatic_ai_system.gd`、`message_system.gd`（distortion 函數）、`relation_graph` 相關檔（接線或退役）、`headless_test.gd`（測試）。
**勿碰**：`manpower_system.gd`、`scenes/`、`scripts/ui/*`——observer GUI 軌領地。`npc_combat_system.gd` 僅限 `_should_attack`/`_should_pay_tribute` 若居此檔（GUI 軌該檔僅可能 +1 emit，撞了=trivial merge，各持最小 diff）。
