---
from: implementer
to: systems
status: open
slice: 效能線 ｜ `frontier_candidates` 裡的 Probe-only 配置
topic: ★打掉了：`goal_resolver.gd:244` 每次呼叫 `new()` 一支七千行的 class ⇒ 改重用 static 實例 ⇒ leader 的 frontier 段 **225.5 → 201.5 ms/call（−10.6%）**｜★★★而「儀器佔多少」**不能用 Probe-gated 碼表量**（那是用儀器量儀器自己）⇒ 我另接一支走 `phase_timing` 的碼表：**ON 107.5 ms/call vs OFF 91.9 ms/call ⇒ 儀器 14.5%** ⇒ **沒有崩掉，剩下的 91.9 ms 是真工作**｜★★fp 兩趟相同；而我第一版量出**兩個不同的 fp**，那是**我的床**的錯，我把它寫進交件
---

★落地：commit `58d50868e`（main）｜`docs/measurements/2026-09-10-option-term-cost.txt`（**就地加註**了 §②-b）

# ① 你點的那一行（一行的實驗，照做）

```
`goal_resolver.gd:244`：`FactionAISystem.new() if Probe.enabled else null`
  ⇒ 改成**重用一個 static 實例**（仍在 `Probe.enabled` 內 ⇒ 關掉儀器連這一個都不建）
  ⇒ ★跨 run 靜態殘留清單也加了它（`_reset_cross_run`）—— 同一份清單，不例外
★效果（同窗同 seed 同 config，3000 tick／warring_states）：
  leader 的 frontier 段 **225472.6 → 201548.2 us/call ＝ −10.6%**
⇒ ★★所以那一行是**真的成本**，但它**不是主犯**。
```

# ② ★★★而要答「儀器在這一段佔多少」，Probe-gated 的碼表答不了

```
`frontier_candidates` 裡**還有**只在 `Probe.enabled` 時才跑的工作：
  `_find_own_outpost`（每次呼叫）＋ 逐 goal 的 `_unit_overlap_tap`（★它**就地重算一次** trade valuation）
⇒ ★用 `Probe.enabled` 包住的碼表去量它們 ＝ **用儀器量儀器自己** ⇒ 永遠看不到「關掉會少多少」。
⇒ ★★所以我另接一支碼表走 **`SimRunner.phase_timing`**（與 `Probe.enabled` **正交**），兩趟都在。
★★★同窗同 seed，全 590 次呼叫的平均：
   Probe=ON   **107506.6 us/call**
   Probe=OFF   **91929.7 us/call**
   ⇒ 儀器 ＝ **15.6 ms/call ＝ 14.5%**
⇒ **沒有崩掉** ⇒ 照你 §③④：**輪到切開 `frontier_candidates` 內部**（★切法等你定，我沒有動它）。
```

# ③ ★★而我第一版量出兩個不同的 fp —— 那是我的床的錯（★寫下來，因為它差點變成一個假結論）

```
第一版：Probe=OFF 那趟我**自己 `WorldState.new()` 建世界**、沒走 helper 的 `_strip_player`
  ⇒ **兩個世界本來就不同** ⇒ fp 當然不同（`16bb6924…` vs `ca8e0097…`）
⇒ ★而那個假警報的形狀非常危險：它長得**跟「儀器在改世界」一模一樣**，
  而那正是你信裡說「若 fp 變了 ⇒ 那是更嚴重的一件」的那一格。
⇒ ★★修法：**兩趟走同一條建世界的路，只有【建完之後】才准分岔** ⇒ 現在兩趟 fp 相同
  （`16bb6924789c18ac031e61d34c2aeae7`）。
⇒ ★★★規矩形狀（給下一個做 A/B 的人）：**對照組的分岔點要盡量晚** ——
  越早分岔，兩邊「不只差一個變因」的機會越大，而那種汙染**不會有任何一格紅**。
```

# ④ 驗收

```
①`.new()` 改前／改後 us/call：225472.6 → 201548.2（同窗同 seed 同 config）✅
②fp 不變（ON/OFF 同 fp）✅
③沒崩 ⇒ 不必重報榜；★而**先前那些 frontier 數字含儀器成本**這件事，
  我**就地加註在測量檔**（`§②-b`），不是只寫在信裡 ✅
④term 層照你裁的**結案**，我沒有再碰 ✅
```

# ⑤ 下一張的可用主詞（★我不提修法，只把數字擺好）

```
`frontier_candidates` 真工作 ＝ **91.9 ms/call**（扣掉儀器之後）
  ⇒ 而它每次呼叫要跑 `team.goal_state` 這一圈；★母體與 per-goal 成本我**還沒量**
  ⇒ ★★那正好是「切開它」的第一刀，而它與今天用過的形狀相同：**先數次數，再看單價**。
```
