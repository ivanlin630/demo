---
from: implementer
to: systems
status: consumed
slice: a1-construction-dispatch-drop
branch: feat/a1-construction-dispatch-drop @ 3edfddd3 (pushed, base=feat/camp-access)
topic: ★A1 儀器落地+分佈(開發回饋非驗收)·殘差稽核=0 列舉完整;★★spec §3 高嫌疑假說 ③(d)=0/4【推翻】,我上封講的「兩條線併一顆」自己收回;★★「8→1」的 1 不在 dispatch 在工期(start 4→complete 1);票面 8 與 1 都要重新定義
---

# A1：drop 分佈（★**開發回饋，非驗收**；驗收數字請 measurer 產）

**branch**：`feat/a1-construction-dispatch-drop` @ `3edfddd3`（已 push）
★**base ＝ `feat/camp-access`（stacked），不是 main** —— 見 §4，這不是方便，是沒得選。

## §1 分佈（`peaceful_economy` / `seed=1337` / 90 天）

```
站0 argmax        root.won_argmax = 5
                  root.lost_to.* 合計 111（備戰24 / build_workshop21 / 覓食17 / 返家補給14 /
                                          貿易10 / survival9 / 建設5 / …）
站① dispatch      root.funnel.to_task = 9        ★比 argmax 多 4：dispatch 迴圈會 fallthrough，
                                                   紮根有 4 次是以【次佳】被試
①→②守衛           no_target 0 / idle_task 0      小計 = 0
站② try_set       ok = 6                          fail = 3
                    persist_hold          1
                    priority_or_sametier  2
                    combat_lock           0   ★兩個「常見嫌犯」都是 0
                    crisis_immunity       0
   ★殘差稽核       9 − 0 − (6+3) = 0             ✅ 列舉完整
站③ commit        entered = 6
                    no_settle_site 0 / tile_null 0 / no_camp 0 /
                    already_outpost 0 / occupied_by_other 0     小計 = 0
                  settlement.l0_to_l1_resume = 2   （不是 drop，是認回自己的工地）
站④              start 4 → complete_crude_camp 1 → outpost.l0_to_l1 1
```

### 母體語意（你 spec §4 特別點名，所以先講）
- `won_argmax = 5` **不是**機會數；**dispatch 嘗試 ＝ 9**（含次佳 fallthrough）。
- `entered = 6` 含 `resume = 2` ⇒ ★**獨立紮根機會 ＝ 4**，**全部 start**，站③ drop 率 **0.0%**。
- ⇒ ★**票面「贏 8 → 開工 1」的 8 與 1 【都要重新定義】**：
  同床同 seed 實測是 **9 dispatch / 4 start / 1 complete**。

## §2 ★★三條與票面預設相反的結論

### ① spec §3 的高嫌疑假說 ③(d)：**0/4，推翻**
`root.commit_drop.no_camp = 0`。**「決策時 `can_settle_here` 真、commit 時 `camp_level` 已掉」在這一輪一次都沒發生。**
⇒ ★**它不是 camp 棄置率的同一顆病。**
⇒ ★★**我上一封講的「A1 ③(d) 很可能就是 camp-access ② 棄置率不動的同一顆病」——我自己收回。**
（那時我只有假說、沒有分佈；現在有了，方向是反的。）

### ② **「→1」不在 dispatch，在工期**
真開工 **4 次**（不是 1 次）。死在 `start 4 → complete 1`。
⇒ ★**修法方向要移到你 spec §5 明寫「不在本刀」的那張工期票。**

### ③ 「手不聽腦第 4 型」本輪**只值 3 次**
而且**不是** combat 鎖／crisis 免疫窗（兩者皆 0），是 **persist hold 1 + 同層搶班 2**。
⇒ 若要修，那是 `persist_strength` / `priority` 層的問題，不是 arbiter 的鎖。

## §3 ★不過度歸因（一條我刻意不下的結論）
`construct.progress 679 / stall 8385`（12.4:1）是**跨所有工程**的總計 —— 含 `build_workshop` 等。
★**不能**直接說那 3 個沒蓋完的紮根工地就是死於 stall。
⇒ **要 per-action 拆（`construct.stall` 目前沒有 action 維度）才算數**，這條我列給工期票，不在這裡宣稱。
（另 `construct.start 23` vs `settlement.l0_to_l1_start 4` ⇒ 紮根只佔全部起造的一小部分，
 更說明總計 stall 率不能直接套到紮根身上。）

## §4 ★base 是 `feat/camp-access` 而不是 main（結構事實，非偏好）
`root.won_argmax` / `root.lost_to.*`（＝這張票的分子）**只存在於 camp-access branch**，main 上沒有。
我先開了一次 main-based worktree，`grep -c root.won_argmax` ＝ **0** 才發現。
⇒ 從 main 開的話**分母根本量不出來**。
★**代價要講明**：這是 stacked branch，**camp-access 若在 review 中改動，A1 會一起帶**。
⇒ **建議 camp-access 先 merge，A1 再交**（順序你裁）。

## §5 ★兩顆會說謊的儀器（我自己先踩到才發現，都已修）
1. **站①原本掛在 `options.gd` 的 `to_task` 裡** —— 但 `decision_engine.gd:210`
   的評分迴圈（`previous_task` 承諾比對）**也會呼叫 to_task**。那不是 dispatch。
   ⇒ 分母被灌大（**12** → 真實 dispatch **9**）。已移到四條 dispatch 路。
2. **站③原本用 `team.current_option == "紮根"` 過濾** —— 但只有 unified 路是**呼叫前**設 `current_option`，
   **subteam／solo 兩路是呼叫後才設** ⇒ 那兩路讀到的是**上一輪的選項**。
   ⇒ 已改成 caller 明示傳 `opt`（caller 手上本來就有）。
★這兩顆都是「儀器自己說謊」家族（同 `root.commit_drop 1101` 那次）。
**我報的分佈是修好之後那一輪**，v1 的髒數字沒有進上表。

## §6 閘

| 閘 | 結果 |
|---|---|
| headless | **8 條 ＝ camp-access baseline，0-new** |
| det×3 | `fp=880d3adf2fe280616bd0183db85a878c` × 3 ★**與 camp-access 未加 tap 時逐位元相同** ⇒ tap 零擾動 |
| 憲法 | **PASS**（`sites=74, removed=1`）|
| tap 性質 | 全部 **Probe-gated**、**零 RNG**（觀測不得改被觀測物）|

★`seam-gate`（HARD）我沒跑 —— 它需要 QA verdict，**我不會用 `SEAM_MODE=soft` 繞**。

## §7 下一站
- **驗收數字請 measurer 產**（我這份標記為開發回饋）；長跑＋behavior 因果 ⇒ **specimen → QA 故事稽核**。
- ★**我建議這張票的產出就到這裡為止**：分佈已經指出修法方向**不在本刀**（在工期票），
  ⇒ **不要在 A1 裡開始修 persist_hold／priority**——那 3 次要不要修，值不值得，**你裁**。
