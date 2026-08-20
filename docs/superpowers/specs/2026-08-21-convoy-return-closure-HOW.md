# HOW spec：convoy RETURN 收尾（讓車回站、不加車）

slice: convoy-return-conservation   <!-- P9 交接縫閘：slice id = branch 名去掉 feat/。★tier 不寫這裡——tier 的唯一來源是派工 handback，避免第二個真相 -->

date: 2026-08-21 ／ owner: systems ／ WHAT ＝ blueprint 裁定（採 systems 案：**修 RETURN 收尾、`一次一支` throttle 不動**）
狀態：待 R² → dispatch。

## §1 前提（實測）
- peaceful：`dispatch=1 / deliver=1 / settled=1 / return=1`，但**歸建延遲 27.9 日**（day10 出發 → day37.9 併回）。
- **脫離 CONVOY ≠ 斷**：`try_merge_back`（`subteam_system:183`）讀 `task_extra_data.convoy_phase`，對**被 release 成別 task** 的 porter 照樣認 → 遊魂是**很慢的路**、非死路；歸建條件 ＝ **何時剛好與母隊同格**。
- 期間 **④ throttle 鎖死該領主所有後續 deliver**（實測 9 次 blocked）→ **吞吐 ≈ 一趟／38 天**。
- porter 在 RETURN 期間**被改派成 `貿易`／`逃跑`／`外交`**，**自己在外面跑單**（coin 133→296）。

## §2 ★先擋掉一個誘人但錯誤的捷徑
**禁**「改派時把貨款/剩貨**瞬移**交割回母隊」。
理由：**違反後勤 arc 的物理性前提**（貨必須**真的走**到交易點／回到母隊）——那正是 GATE-B 這整條線在修的東西。**用瞬移補收尾 ＝ 一邊修物理、一邊開後門**。
∴ 收尾只能靠**真的走回去**（或**留在 porter 身上**直到歸建／獨立）。

## §3 設計：RETURN ＝ 承諾態
- **T1 RETURN 期間任務保護**：`convoy_phase == "RETURN"` 時，porter 的 task **對一般重評（ambient／trade／routine）免疫**；★**survival 仍可搶**（餓死/被襲優先於送錢回家——**不做成絕對鎖**，同今日反覆確認的「禁硬 gate、讓引擎秤」）。
  實作：RETURN 設任務時走**既有承諾機制**（`PRIO_DISPATCH` + engine-source 語意），**不新增優先級層**。
- **T2 抵達即結案**：與母隊同格 → `try_merge_back` → 資產併回 → `convoy.return` bump → **清 `convoy_phase`**（避免殘留旗標讓後續誤判）。
- **T3 回不去 ＝ 失敗事件（依失敗反饋鐵律）**：母隊已滅／長期不可達 → **porter 轉為獨立隊**（貨物**留在身上**＝守恆），並**發失敗事件**（`recent_failures` + T0 喚醒該 porter 重想）——**不得靜默漂流**。
  ★**判準需一個「長期」定義**：用**相對錨定**（`k × 預期回程 ETA`），**不新增絕對天數常數**（守時間包 §2 規約）。
- **T4 不動**：`一次一支 convoy` throttle（WHAT 已裁）。

## §4 gate
1. ★**歸建延遲大幅下降**：peaceful 同 seed/config，`dispatch → merge` 的中位延遲 **由 27.9 日顯著下降**（目標量級：≈ 回程 ETA，非隨機漫遊）。
2. ★**吞吐上升**：同窗 `convoy.dispatch` 次數上升、`convoy.drop.inflight_convoy`（④）**佔比下降**——★用**剛 merge 的常設分母** `dispatch_attempt` 算比例。
3. **守恆**：全窗 `coin/goods/material` 總量 byte-level 對帳無漏（porter 身上殘留 + 母隊 = 出發時總量）。
4. **survival 仍可搶**：合成床——RETURN 中的 porter 遇襲/瀕餓 → **仍會 flee/求生**（不得被承諾鎖死）。
5. **回不去→失敗事件**：母隊滅團 → porter **不再無限漂流**、發失敗事件並轉獨立。
6. det×3、constitution ≤74、headless 0-new、**fp intended-change**（porter 行為真的變了）。
7. ★**不得引入瞬移交割**（§2）——review 時逐行確認資產轉移**只發生在同格**。

## §5 R²delta（判決 CLEAN + 1 必查項、2026-08-21）
### ★必查項：T1 的「既有承諾機制」要點名具體是哪個 ＝ `PROGRESSIVE_HOLD_TASKS`
R² 親查指出：`TaskArbiter.PROGRESSIVE_HOLD_TASKS`（`task_arbiter:22`）**正是現成對的工具**，而 **`TASK_CONVOY` 目前不在裡面** → **補一行**比含糊寫「走既有承諾機制」更省事，且**自動滿足「survival 仍可搶」**（`try_set:60-70` 的 hold 條件明載：**危機 axis（任一側 ≥`PRIO_THREAT`）不介入／玩家命令不擋／同 task 不擋**）。
**採納**：`PROGRESSIVE_HOLD_TASKS` **加入 `TeamData.TASK_CONVOY`**。

> **★2026-08-21 事後訂正（實測推翻）**：下面這段預測**錯了**。單獨補 `PROGRESSIVE_HOLD_TASKS += TASK_CONVOY` **與 main 逐字節相同、零效果**；真根因是 `faction_ai:797-809` merge_queue 走 `TaskArbiter.release()` **繞過 `try_set`**，承諾在被問之前就沒了（`persist.hold = 0`、`convoy_preempt_try = 0`）。**hold 擋的是「CONVOY → 別的」，現場是「IDLE → 別的」。** 通則已升 `invariants`〈承諾態只能經仲裁移轉〉+〈先看 tap 是不是 0，再談門檻〉。

### ★systems 追加親驗（reviewer 未往下追的第二前提）
hold 還有**第二個條件**：`team.persist_strength > PERSIST_HOLD_THRESHOLD(0.1)`。
親查 `persist_strength`：`_value` **只對 `NON_PROGRESSIVE=[IDLE, FLEE]` 回 0** → CONVOY **有值**；`_progress` 對**非 BUILD** 走 **fallback ＝ `elapsed / COMMIT_HORIZON_DAYS`**，而 porter 的 `task_start_tick` **從 dispatch 起算**（phase 變化不重設）→ 到 RETURN 時 elapsed **已累積可觀** → **持守強度足夠、補一行即生效**。
★**但那是「時間 proxy」而非「真進度」** → **應變（寫進 gate、不預先實作）**：**若 gate 1（歸建延遲）顯示 hold 仍不足**，**首要嫌疑就是這個 time-proxy** → 屆時再給 CONVOY **真進度信號**（RETURN 腿的**已走距離／總距離**，同 BUILD 用 `construction_ticks` 的精神），**不是先加**（避免無證據的複雜化）。

### gate 追加
- **gate 8**：`persist.hold` 對 CONVOY **真的 fire**（porter 在 RETURN 途中被 routine 選項嘗試搶班 → 被擋、`Probe` 有值）；★**同時驗 survival 仍能搶**（gate 4 已有）。

---

## §6 診斷回填與帳目訂正（2026-08-21，實測後補；★這段是給未來讀者的，別讓錯誤結論留在檔面上）

### ★T1 是 **inert-by-construction**，不是「有效但沒遇到情境」
`diag.convoy_preempt_attempt` **75 天 ＝ 0**：**連一次 `try_set` 落在 `current_task == CONVOY` 的隊上都沒有**。
根因（`file:line` 坐實）：
- `faction_ai:761-762`：`parent_team_id != -1` → 子隊走 `_evaluate_subteam`，**完全不進 `_evaluate_solo`／`_decide_unified`**
- `faction_ai:2753-2756`：`_evaluate_subteam` 對 `TASK_CONVOY` **直接早退**

⇒ **世界上沒有任何一條路會對 CONVOY porter 呼 `try_set`**，`PROGRESSIVE_HOLD_TASKS` 自然無用武之地。
**修前它被 `release()` 繞過（先打成 IDLE），修後根本沒人搶** —— **T1 前後都不可能 fire**。

**帳目訂正（不得記為通過）**：
- **gate 8**（`persist.hold` 對 CONVOY 真 fire）＝ **合成床（TDD）證據；live 結構上不可達**
- **gate 4**（survival 仍可搶）＝ **同上** —— **沒人嘗試就沒得搶**。
  ★ porter 在 CONVOY 期間**只有 reaction 層在跑**（specimen：decision **0**、reaction 10、heartbeat 10）。
- ⇒ **27.9 → 9.2/1.3 日的改善 100% 來自 `merge_queue` 的 rehome 根因修**，T1 功勞為 **0**。

**T1 仍保留**（CONVOY 本來就是 progressive task，漏列是不一致；一旦子隊將來走一般決策它就生效），
★**但 `task_arbiter.gd` 那段註解必須訂正**——現行註解宣稱「漏列的實測代價＝被 routine 搶班」，
**那個因果在 live 不成立**，會誤導後人以為它正在起作用。

### ★T3 的兜底被它要限制的機制自己重置（**待修**）
`_stamp_return_eta` 在**每次 rehome 都重算**（`faction_ai:814`）
⇒ **T3 的「`elapsed > 3 × ETA` 放棄門檻」在追逐期間每次都被重置**
⇒ **只要母隊持續移動，T3 這條兜底永遠不會觸發**。

本例因母隊抵達目的地而自然收斂（尾隨追逐、**距離恆為 1、從不擴大**，母隊一停即 merge），
但**遇到長期流亡／持續移動的母隊，追逐的唯一終點只剩「母隊停」或「母隊滅團」**。

**裁定**：**放棄預算錨定在「進入 RETURN 的那一刻」，rehome 只更新路徑目標、不得重置預算**。
（＝ 兜底要錨在**承諾開始**，不是錨在**最近一次調整**——否則任何會重算的機制都能無限延後它。）
→ 另開 slice `convoy-return-t3-budget`（**不塞進本刀**，避免 QA 正在審的東西被移動）。

### §6b T3 預算：定案（R② 第三案 ＋ systems 裁邊角，2026-08-21）

**採納 R² 的第三案：預算隨 rehome【累加】，既不重置也不凍結。**
```
首次進 RETURN：  return_budget = MULT × eta
每次真 rehome：  return_budget += MULT × new_eta      # ★累加，不是換掉
放棄判準：       elapsed(from return_start_tick，不重設) > return_budget
```
- 與「**錨死不重置**」的差別：目標**真的變遠**時預算會跟著長 ⇒ **不會用「進 RETURN 那刻恰好很近」的小預算去審一整趟後來變長的追逐**（＝我原案的誤殺，**我自己的算術就已經證明會發生**）。
- 與「**重置**（現況 bug）」的差別：預算是**累加**不是**換成新值** ⇒ 純尾隨時預算增速與 elapsed 同量級，**不會「只要一直動就永遠不判」**。

**★systems 裁 R² 留的邊角：加一條防呆絕對上限——但理由不是「追逐品質」**。
教科書式等速平行移動時，累加預算會與 elapsed 同步成長、**永不觸發**。
★ **真正的傷害不是追逐本身，是「一隊一 convoy」throttle 被無限期扣為人質** ——
該領主**所有後續 deliver 全被鎖死**。所以要一條**很寬鬆的絕對上限**當**最後防線**。
- **定位寫死在 code 註解**：**系統健康維護（資源／throttle 回收），不是追逐品質判準**，
  **不得被當成 tuning 旋鈕**。
- 這**不違反**時間包 §2「找不到自然錨才准絕對」——**這裡就是真的找不到自然錨**（比值恆定是它的定義）。

### §6c gate（★2 格證偽稽核是硬 gate，不分方案）
9. ★**證偽誤殺（硬性）**：`stranded(timeout)` 事件中，**當時 porter 距母隊 ≤2 格的比例**。
   **這條不是「傾向做」，是必過**——理由（R² 提、我同意）：**這題紙上推導已證明比表面複雜，理論分析靠不住，唯一可信的收斂點是實測**。
   ★ 這是本輪 T1 教訓（**先看 tap 再談門檻**）的同精神延伸：**T3 也不該只靠公式推理過關**。
   **前置**：本 gate 需要 specimen 有 `tile_pos` ⇒ **`specimen-coverage-pos` 那刀必須先落地**。
10. **防呆上限不得在正常局綁到**：正常世界的 `stranded(timeout)` 中，**因絕對上限觸發的比例應為 0**。

### §6d 累加案的誠實邊界（2026-08-21 實測後補；★別讓它變成第二個 inert 機制）

**實測（`feat/convoy-return-t3-budget` @742ea66d，錨死版）**：那趟追逐進 RETURN 時 ETA ＝ 94 ⇒ 預算 282，
而實際追逐走了 **1000 tick** ⇒ tick≈3882 判 timeout ⇒ **原本 9.2 日成功歸建、帶回 296 coin 的那趟變成遊魂**，
`dispatch 3→2`、`deliver 3→1`。**證偽 gate 在 merge 前就咬到了。**

**改用累加後的算術**（`budget += MULT × new_eta`，實測 leg ETA 序列 94/171/74/76/82/124/95）：
三次 rehome 後預算已 ≈1245 > 當時 elapsed ≈900 ⇒ **該健康案例會存活**。

★★ **但要誠實寫下它的代價**：在尾隨情境下，**每段 elapsed 實際發生時間 ≈ 1× leg-ETA，而預算每段加 3×**
⇒ **累加預算幾乎永遠不會觸發**。也就是說：

> **真正的兜底是「防呆絕對上限」，累加預算是便宜的早退，不是主要防線。**

**必須寫成可觀測，不能靠相信**（今天已經栽過 T1 那一次「看起來在守、實際 inert」）：
- tap `convoy.stranded.timeout.by_budget` vs `convoy.stranded.timeout.by_abs_cap` **分開計**
- **gate 11**：若長跑中 `by_budget` **恆為 0**，就要在帳上明寫「**累加預算在本世界 inert**」，
  **不得含糊記成「T3 有在守」**。
