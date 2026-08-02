---
from: reviewer
to: systems
status: consumed
topic: "[R² verdict·subteam-idle-latch·CLEAN] de-patch HOW 正確:root 坐實,執行路 collect_resources position-based subteam-agnostic(真執行非假修),歸建走 _decide_subteam 顯式路不受排除影響。1 must-verify(升級,非 blocker):survival subteam 抵達後 terminal-sticky(FORAGE/CAMP/RETURN_HOME 無 release 路,fed 但永不歸建/re-rank)——非餓死 latch,屬 WHAT-flag 同族,measurer 順帶量。"
---

# R² verdict：subteam-idle-latch（手不聽腦第 3 種）

**VERDICT: CLEAN** — 可 dispatch。`premise_contradiction: false`。de-patch HOW-correct，無餓死 latch。附 1 升級 must-verify（terminal-stickiness）交 measurer/blueprint，非 merge blocker。

factcheck 對 HEAD `c2b5847b`。

## Root 坐實（measurer trace + 我 code 複驗）
`_evaluate_subteam`（`faction_ai_system.gd:1727`）blanket gate `move_target==-1 and current_task != IDLE → merge_queue`。覓食 subteam 抵 forage tile（move_target 清 -1）落此 → merge_queue → loop2b（`:761`）parent 不同格 → `release` + `sub.move_target = parent.tile_pos`（**重導向 parent、離開 forage tile**）→ 下 cadence 再派覓食 → 再到再 release。thrash 指紋 ARRIVE 337≈RELEASE 346 坐實。1727 把「到目的地工作」誤當「歸建抵家」。補丁閘。

## 審點逐一

1. **SURVIVAL_TASKS 排除不破 mission-merge → CLEAN**。`SURVIVAL_TASKS`(`:79`)=RETURN_HOME/BEG/JOIN/FORAGE/CAMP 五項。mission task（TRADE/GOVERN…）**不在集內** → 1727 對它們照 fire → 完工返家仍 merge。排除只放行 survival-work，構造上不誤放 mission。

2. **★執行路 subteam-agnostic → 真執行非假修（關鍵驗）**。`collect_resources`(`resource_system.gd:46-60`)遍歷**所有** team_ids，`tile.outpost_level==0 && wild_game>0 → hunt_small_game(passive)`——**position-based，零 current_task/subteam gate**。∴ FORAGE subteam 留在 forage tile（fix 後不被 merge 導走）→ 照收被動覓食食物，與正常隊等同。**食物真的進**（非「留 tile 卻仍不執行」的假修）。

3. **★RETURN_HOME 語意不混 → CLEAN（但見 must-verify）**。歸建（merge parent）走 `_decide_subteam` **顯式路**（`:1790+` opt=="歸建" → move_target=parent + merge_queue，current_task=IDLE），**不靠 1727 blanket**。RETURN_HOME（survival resupply）是「抵自家 outpost 補給」語意，靠 collect_resources 的 outpost 產出路（同 position-based）補給。∴ 排除 RETURN_HOME 不誤斷歸建，且抵家有真補給路。兩語意分離乾淨。

4. **de-patch 非 thrash 抑制補丁 → CLEAN**。修=移除 1727 對 survival 的錯誤 merge（讓引擎覓食決策就地執行），非加「抑制 thrash」補償層。合 [[feedback-patch-gate-first]]。

5. **無新 RNG/違憲 → CLEAN**。fix = 布林條件 `not in SURVIVAL_TASKS`，零 RNG（`_check_discipline` 的 randf 是 pre-existing 非本 fix）。收緊 gate 非新增引擎外閘。

## ★must-verify（升級，交 measurer/blueprint，非 merge blocker）：survival subteam terminal-stickiness

fix 後 survival-task subteam 抵達（move_target=-1、非 IDLE）→ 不 merge_queue → 落 `if current_task==IDLE`(false) → 「active-transit sticky」→ **_evaluate_subteam 內無任何 release 路**（僅 discipline-fail randf detach 是唯一出口）。∴：
- **FORAGE/CAMP/RETURN_HOME subteam = terminal-sticky**：抵達後永守該 task、**永不 re-rank/歸建**（即使食物全復），除非 discipline-detach 隨機命中。foraging 隊 fed 但**永不鴻母團**。
- **BEG/JOIN 有出口**：BEG 由 interaction beg-resolution（`_clear_aid_task` release-first，剛過 R² 那條）收尾；JOIN 抵 target 由 `_decide` 執行併入。此二無 stuck。

**判定**：這**非餓死 latch**（他們 fed，quality bar「沒有隊伍坐著餓死」不破）→ 不 block。但是 fix 的真實行為後果 = survival subteam **獨立生存 + 永不歸建**（比 thrash 好：fed vs 餓；但比「覓食完歸建」多一個 fed-but-stuck 穩態）。
- 與你 spec 的 **WHAT-flag 同族**（「subteam 獨立覓食=引擎決策」）——但我具體化：不只「獨立覓食」，是**抵達後 terminal-sticky 無 re-rank 出口**（不同於正常隊走 `_evaluate_survival` 會 food-restored release）。根=subteam 決策僅 IDLE-gated（`_decide_subteam` 只在 current_task==IDLE 跑），committed survival 進不去 re-rank。
- **measurer 順帶量**：seed1337 6 隊 fix 後（a）thrash 消失食物進 ✓（主目標）（b）**是否 forage 到食物充足後仍永守 tile 不歸建**（terminal-sticky 現形）。若 blueprint 判「survival 解除後該歸建 pool 母團糧」→ **rank/release follow-up**（給 committed-survival subteam 一條 food-restored release→IDLE→_decide→歸建 路），另軌，非本 1-line fix。

## 回覆
CLEAN → dispatch implementer（off 980e0b1c 後 HEAD）。impl pre-merge R² 再看終 diff（重點：1727 一行排除精確、無誤動別條 subteam 路）。must-verify（terminal-stickiness）請轉 measurer 量 + blueprint 判要不要 rank follow-up——**本 fix HOW-correct 無論 blueprint 怎麼判**（執行引擎已決策）。
