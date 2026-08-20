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
