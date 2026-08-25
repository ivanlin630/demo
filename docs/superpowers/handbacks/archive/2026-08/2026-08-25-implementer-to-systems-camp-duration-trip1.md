---
from: implementer
to: systems
status: consumed
slice: camp-construction-duration
branch: feat/camp-construction-duration @ 1b6d2bd7 (pushed, base=feat/build-eta-single-source→已 merge 進 main)
topic: ★第一趟分佈(開發回饋非驗收)·★★本票原假設【工期端撐不完】被推翻:紮根 applicable 102 次只贏 1 次,44.6% 是同一隊反覆輸給同一個對手 ⇒【排不上隊】不是【蓋不完】;★發現 try_set 不是唯一收口(release 59 caller 旁路所有 guard);兩條修法方向都不在本票 scope
---

# camp 工期票：第一趟（★**開發回饋，非驗收**）

**branch**：`feat/camp-construction-duration` @ `1b6d2bd7`（已 push）
base ＝ `build-eta-single-source`（**已 merge 進 main `44dcbbfa`**）⇒ 照 §4 寫死的順序，24× 高估已修掉才量。
**床**：`scripts/debug/camp_duration_bed.gd`；`peaceful_economy` / `seed 1337` / 90 天。

---

## §1 ★★本票的原假設被推翻

spec §1 的病灶假設是**工期端**：「人走了工地就停」⇒ 開工後撐不完。
**實測不是這樣**：

| 量 | 值 |
|---|---|
| 紮根 applicable（可秤） | **102** 次 |
| **贏 argmax** | ★**1 次**（`root.won_by_team.8 = 1`）|
| 輸 | **101** 次，分佈 16 支隊 |
| ★ **team 11** | **45 次（44.6%），且【45 次全部輸給同一個對手】`build_workshop:resource`，一次都沒贏過** |
| 次集中 | team 13 / 18 / 21 **各 8 次，全部輸給 `備戰`** |

★**§E 的判準（我在跑之前就寫進床裡的）成立**：
> 少數隊 × 少數對手吃掉大半 ⇒ **那是「排不上隊」不是「蓋不完」，修法方向完全不同。**

⇒ ★**斷點在 argmax 層，不在工期層。**「開工後撐不完」在這一輪**根本輪不到發生**——
102 次裡只有 1 次走到開工。

### ★兩個案例不可合併敘述
你餵進來的 **team22「連續 7 次全輸給買糧」** 與 **team 11「45 次全輸給 `build_workshop`」** 是**不同的故事**：
- team22 的對手是**更急的求生需求**（買糧）
- team 11 的對手是**另一種蓋東西**（工坊）⇒ 這是**內部排序**問題，不是被生存壓力擠掉
- ★而且 **team22 在這一輪只輸 1 次** —— 那條故事是 `build-eta` 那個 branch 狀態下的世界。
⇒ **不同 branch、不同對手、不同機制**，合併會編出一個不存在的因果。

---

## §2 ★第一趟自己打自己臉的地方（→ 找到沒被列舉的出口）

第一次跑出來的兩個數字**互相矛盾**：

| 量 | 值 |
|---|---|
| ①施工中隊被 `try_set` 搶班 | **0** |
| ②持守 floor 遇到「還有未完工地但 task 已非 BUILD」 | **4379** |

**兩者不可能同時為真** —— 除非 `current_task` 有 `try_set` 以外的寫入路。

**窮盡列舉**（`grep -n "current_task = " --include=*.gd scripts/simulation/` ＝ **9 處**）：
| 路 | 過哪些 guard |
|---|---|
| `try_set` ×4 | combat 鎖／crisis 窗／**persist hold**／優先序 |
| ★**`release()` ×1** | ★**一道都不過**。`grep -c "TaskArbiter.release("` ＝ **59 個 caller** |
| `transition()` ×1 | combat／crisis／emergency 三道，**但不過 persist hold** |
| 其餘 3 處 | 新隊建立豁免 |

補上 tap 之後：**`build.released = 18`**、`build.transitioned_to.* = 0`、`preempted = 0`。
★**持守 floor 守的是 `try_set` 那道門，而離開的隊是從旁邊那扇沒鎖的門走的。**
（同 memory `feedback_spec_premise_verify_decision_layer`：**機械層旁路決策層**；
 也同 QA 在 convoy 抓到的「保護讀的狀態與事實是兩份真相」。）

---

## §3 ★對我自己數字的三條節制

1. ★**`build.floor_skipped = 4379` 不是「4379 次棄工」** ——
   它是 **per-cadence 計數**（每次算 persist 記一次），一支卡住的隊卡 30 天就貢獻幾百筆。
   而且 `bump_sample` 是 **first-N**，那 30 筆**全是 team 5 同一個工地**（`ticks_left 336`、tick 500→750 連續）
   ⇒ **證明不了分佈**。**事件級的真實數字是 `build.released = 18`。**
2. ★**那 18 筆的 `corvee` 全是 `[-1,-1]`** ⇒ **被 release 的建設隊【不是紮根隊】**
   （紮根隊才會設 `corvee_site`），是 `upgrade_facility` 的隊。
   ⇒ **不得**把這 18 筆當成「紮根被打斷」的證據。
3. `root.lost_seq` 樣本 **101 筆 < cap 200 ⇒ 這一輪沒被截斷、序列是完整母體**——
   ★**這是碰巧，不是保證**；床已寫明「滿 200 ＝ 被截斷，連續性判讀要小心」。

---

## §4 per-action stall（A1 留下的前置，已補）

| action | progress | stall | 停滯率 |
|---|---|---|---|
| `crude_camp`（紮根） | 185 | 825 | **81.7%** |
| `upgrade_facility` | 415 | 6230 | **93.7%** |
| 總計 | 600 | 7055 | 92.2% |

⇒ ★**當初拒絕把跨工程的總計套到紮根身上是對的**：差 12 個百分點，而且總計是被 facility 拉高的。

## §5 其餘對照
`camp.built 24 / abandoned 20`（83.3%）｜`start 3 / resume 0 / complete_crude_camp 1 / outpost.l0_to_l1 1`
｜**day90 outpost 存量 ＝ 12**（★存量 ≠ 事件計數，照你立的通則分開列）

## §6 閘
| 閘 | 結果 |
|---|---|
| headless | **8 ＝ main baseline，0-new** |
| det×3 | `c1e3f7c5db444fc06c6a826efa77b146` × 3 —— ★**與 base（未加 tap）逐位元相同** ⇒ tap 零擾動 |
| 憲法 | **PASS**（sites=74, removed=1）|
| tap 性質 | 全 **Probe-gated**、**零 RNG** |

★`seam-gate`（HARD）需 QA verdict，我沒跑、**不用 `SEAM_MODE=soft` 繞**。

---

## §7 ★兩條修法方向，**都不在本票 scope，我不自己動**

1. **紮根 vs 其他 build 的排序**（team 11：45 次全輸給 `build_workshop:resource`，0 勝）
   —— 這是 argmax 層的內部排序，**不在本票（工期端）也不在 A1（dispatch 端）**。
   ★**若要修，它才是「文明化二值閘」的真正上游**：102 次只有 1 次走到開工。
2. **`release()` 的 59 個 caller 沒有 source 歸屬**
   —— 我量得到「被 release 了」，**量不到「誰 release 的」**（`release(team)` 沒有 caller 資訊）。
   要穿一個 `source` 參數過 59 個 caller 是**另一張票的規模**。
   ★**而且更根本的問題是**：`release()` 旁路 persist hold **本身是不是設計意圖**？
   如果不是，那是「保護有一扇沒鎖的門」；如果是，那持守機制的適用範圍要重新定義。**這條我判不了。**

## §8 第二趟（spec §D）
第一趟已產出清單：**`SPECIMEN_TEAM_ID=4,3,5,1,7`**（開工未完工的 5 個工地及其 `construction_team_id`）。
★**但依 §1 的結果我建議調整第二趟的對象**：那 5 支是**工地層**的隊，
而真正的斷點在 argmax 層 ⇒ ★**第二趟應該盯 `team 11`**（45 次全敗、0 勝的那支），
**才讀得到「為什麼每次都排不上」**。
**要盯哪一組，你裁**；我兩份都可以跑。
