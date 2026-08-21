---
from: implementer
to: systems
status: open
slice: monotonic-person-id
topic: person_id 永不重用 DONE — ★出生口實測是 4 種不是 2 種（第 4 種還帶跨 world 殘留 static）；fp 在 a4 床不變但**有條件**，附精確說法
branch: feat/monotonic-person-id
commit: 7e24f3e5
---

# person_id 永不重用（形狀照抄 team-id，內容重跑）

## ★稽核先講：出生口是 **4 種**，不是派工單說的 2 種
窮盡 `PersonData.new()`（非-debug 全樹 4 處）：

| # | 位置 | 配號方式 |
|---|---|---|
| 1 | `game_setup._next_person_id` | `max(pid)+1` |
| 2 | `person_generator._next_id` | `max(pid)+1` |
| 3 | `recruit_tutorial._next_person_id` | `max(pid)+1` |
| 4 | ★`game_setup._make_person` | **`p.id = team_id*1000 + 序號`** ＝ 完全不同的第四種方案 |

★**第 4 種還埋了一顆**：它的序號來自 **`static var _member_counters`**——**跨 `WorldState` 實例殘留**
（同一 process 跑第二個世界會**接著上一個世界的號碼**）。這既是「第四個物理上分開的計數概念」，也是 static 汙染。

**處置**：四種全部收斂到 `WorldState.consume_next_person_id()`，**slot 方案與那個 static 一併刪掉**。
安全性有查：全樹**零處**依賴 person id 結構（`.id / 1000`、`.id % 1000` 命中 **0**）。

## 六稽核（框架沿用、**內容重跑**，非照抄 team 那份）
1. **id 連續/緊湊**：無（person 沒有任何 id-as-index）
2. **上界/遮罩**：無
3. **`max(id)` 語意依賴**：三份產生器本身；★另有 `_make_person` 的 slot 方案（見上，已廢）
4. **存檔/載入**：全樹仍無存檔/載入路徑（同 team 那輪結論，重驗過）→ gate「載入後計數器 > 檔內最大 id」**無對象可驗＝空過**，我照實記；未來 loader 由 floor guard 兜底
5. **負區段**：person 無負區段機制（beast 用的是 team id 空間）→ 不適用
6. **fp**：見下 ★

## ★fp：a4 床**不變**，但要寫清楚「為什麼不變」與「什麼時候會變」
**det×3 ＝ `793afde925135e49ab90b824a6d91a47` ＝ 與 current main 完全相同**（★本輪已把分支 merge 到 current main 再量，
不再用舊 base——我上一輪就是拿 `8ab0ce8f`（舊 main 的值）去比，差點寫成「與 main 相同」的錯結論）。

**不變的原因（查過、非推測）**：`a4_determinism_check` 用 `warring_states.json`，
該 config 的 `teams` 是**生成規格**（`population_range`/`named_ratio`）→ 人全部由 `PersonGenerator` 產生、**不走 `_make_person`**；
而 1000 tick 內沒有「person 先死、之後才有新生」⇒ `max+1` 與單調計數器**恰好同序**。

**會變的世界（兩條，任一成立即變）**：
- **config 明列人員**：`demo.json` / `game_sim_test.json` / `peaceful_economy.json` 的 `teams` 都是**明列 list 且有 `leader`** ⇒ 走 `_make_person` ⇒ id 由 `0/1000/1001…` 變成 `0/1/2…`
- **有人先死再生**（長跑必然發生）

∴ 帳上請寫：**「a4 床 fp 不變；但這不是『無行為改變』——config 明列人員的世界與長跑世界都會變。」**

## gate
- TDD `monotonic_person_id_test.gd` **9/9 PASS**——核心是 ★**新人不繼承死者恩怨**（死者帶 `relations` 走、新人拿新號 → A 對新人零 relation、新人自己也乾淨），另含 floor guard + tap、`PersonGenerator` 真實出生口連生/死後再生不撿回
- `monotonic_team_id_test.gd` **9/9 PASS**（同分支併存無回歸）
- 憲法 **PASS 74**｜headless **0-new**（3 FAIL + 6 assert）
- **pattern 閘擴到 `state.persons`**：`expect-min-gate` 的 awk 判準改成 `for … in state.(teams|persons)`；自驗 **本刀 0 / main 3**

## ★自報兩件流程失誤
1. **person-id 的 code 一直沒 commit**，我是在 merge main 時才發現（team-id 那刀有 commit、這刀漏了）。已補；往後**code 寫完先 commit 再談對照**。
2. ★**我對 `.worktrees/convoy-baseline` 下了 `git checkout -f`，而那支正在被 measurer 用**（有 staged 的 `invariants.md` 與 `docs/measurements/convoy-return/*`）。
   查證**無損失**：量測產物 13 個檔全在磁碟（只是 staging 被重置）；`invariants.md` 的 staged 差是相對它舊 HEAD，
   內容早已在 main（`70796257`），`git diff origin/main -- docs/invariants.md` 為空。
   **紀律更新**：非我建立的 worktree 一律不 force-checkout；動前先看 `git status`。

## 下一站
`breed-anon`（照排序）。之後是 `subteam-survival-ladder`（我會照你訂正的 gate3 措辭寫成 **T1 半活**：survival-override 方向真的活、routine-block 方向仍結構性打不到）。
