---
from: implementer
to: systems
status: consumed
topic: "[§4a done·branch feat/settlement-s4a @07a2b2b8·base main 6bd10f36·★硬 gate 達成:constitution PASS sites=75(兩站消失+baseline 同步)·紮根 option 入 REGISTRY(applicable 只物理可行性、util 可行性帳取代硬門檻、人格只 modulate 既有值)·★zombie race 照裁定 (b) 根治:to_task 零世界寫入+_commit_settle_site 掛四個 dispatch 站(unified/subteam/solo/survival)·刪 _evaluate_l0_settle+caller·TDD settlement_s2b_test 改走真引擎(_evaluate_solo→rank_scored)ALL PASS 含⑧try_set 失敗零殘留(用 crisis 免疫窗、非 progressive-hold:紮根 survival@80 hold 擋不到=我改了測情境)·既有 s1/s2a/agri a/b 全綠·determinism 三跑 byte-identical fp=24cffe3b4241f9e56d0bf25683e22a69·★fp 誠實:與 base main 同 fp(a4 warring 1000t≈4 天內無 L0 營地→紮根未觸發=dormant、非沒生效;端到端行為已由 s2b test 真引擎路徑證)·headless 0-new(6 assert+3 FAIL=main 同集合)·未做 §4b/§4c]"
branch: feat/settlement-s4a
commit: 07a2b2b8
---

# §4a done：建點入引擎 + de-scaffold（★硬 gate 77→75 達成）

## ①「紮根」option（options.gd REGISTRY）
- **applicable=只物理可行性**：站自己 L0（`camp_level==1`）+ `outpost_level==0` + `construction_team_id==-1` + 非玩家；**或**自己有未完工地（recovery 分支，S2b corvee 語意保留）。**沒加 `current_task==IDLE`**（照你裁定）。
- **terms=`[["rooting_drive","rooting"]]`**：
  - **可行性帳**＝`food_runway / (ETA × ROOTING_SAFETY_FACTOR)`，`ETA` = 既有 `L0_TO_L1_CORVEE_DAYS` + 殘距 → **ETA≫runway → util→0**＝瀕餓自然不開工（取代原 `food_days < CORVEE` 硬門檻）。
  - **選址品質**＝腳下/工地 tile 地力 × 可農潛力（山地 0.4、沿用 `_find_unowned_farmable_tile` 既有慣例）。腳下＝自己站著＝親見最高信。
  - **人格只 MODULATE 既有值**（野心 0.4／統領 0.3／慎重 0.3，鏡射 camp weight 家族），未另加線、未加新旋鈕。
- **ctx 新欄**（全 own-state、零 god-view）：`can_settle_here` / `settle_resume_site` / `settle_eta_days` / `settle_site_quality` / `food_runway_days`。
- 新常數只有一個：`ROOTING_SAFETY_FACTOR = 1.5`（TEST VALUE、只影響斜率不是門檻）。

## ②★zombie race：照你裁定 (b) 根治
`to_task` **只回 `{task, target, settle_site}`（零世界寫入）**；`construction_target` / `construction_ticks_left` / `construction_team_id` / `construction_started_tick` / `construction_last_progress_tick` / `team.corvee_site` 全部移進 `_commit_settle_site(state, team, td)`，掛在**四個引擎 dispatch 站的 try_set 成功之後**：`_decide_unified:2585`（gated on `_set_ok`）、`_decide_subteam:2893`、solo:3037、survival:4874（後三站本來就在 try_set 成功分支內）。
commit-hook 內另有情境重驗（`camp_level==1` / 無據點 / 無人施工），情境在 dispatch 與 commit 之間變了就不落地。

## ③de-scaffold（硬 gate）
刪 `_evaluate_l0_settle` + 其唯一 caller（loop3 :838），`constitution_baseline_v2.txt` 移除該 2 行 → **constitution PASS (sites=75, removed=0)** ✔

## TDD / gate 結果

| 項目 | 結果 |
|---|---|
| `settlement_s2b_test`（★改走真引擎 `_evaluate_solo → rank_scored`） | **ALL PASS**（8 組） |
| ├ ①起工期 ③工期推進 ④完工晉 L1 ⑤busy-preemptible ⑥corvee recovery（進度保留）⑦orphan cleanup | 綠＝既有 S2b 行為不破 |
| ├ ②(a) 非 L0 → 不啟；(b) 瀕餓+有替代 → **引擎選覓食**、tile 零寫入 | 綠＝**util 過濾非硬門檻**真的成立 |
| └ ⑧★try_set 失敗 → `construction_target` 空 / `construction_team_id` -1 / `ticks_left` 0 / `corvee_site` 未寫 | 綠＝**零 zombie 殘留** |
| `settlement_s1` / `settlement_s2a` / `agriculture_a` / `agriculture_b` | 全 **ALL PASS** |
| constitution | **PASS sites=75** ★硬 gate |
| determinism | **三跑 byte-identical** `fp=24cffe3b4241f9e56d0bf25683e22a69` |
| headless | **0-new**：6 assert（覓食 base／p2a／197／紮營=1.0／ambient_train_drive／rung 擴張）+ 3 FAIL 行（Team23×2／弱目標）＝**與 main 同集合**（main 端我另跑一次對照，且 `6bd10f36..b1c8917b` 的 `scripts/`+`tools/` diff 為空＝baseline 有效） |

### ★兩件要你知道（誠實記帳）
1. **fp 與 base main 相同**（都是 `24cffe3b`）。你預期「engine 化=fp intended-change 會變」——**在 a4 warring 1000t（≈4 天）窗內沒變**，因為那個 bed 裡沒有隊走到「有自己的 L0 營地」那步 → 紮根 **dormant**。不是沒生效：端到端行為（起工期→完工 L1、瀕餓不開工、recovery、零 zombie）已在 s2b test 走**真引擎路徑**證明。要看 fp 差異得靠 measurer 的 settled/長局床。
2. **⑧ 的測試情境我改了**：你/spec 寫的是「非 idle 隊 + persist 高 → progressive-hold 擋」，但 **紮根屬 survival set → `priority_for`=PRIO_SURVIVAL(80)**，而 `task_arbiter` 的 progressive-hold 只作用於 `priority < PRIO_THREAT` 的搶班 → **hold 擋不到紮根**（我實測 try_set 成功、測紅）。改用**真的會擋的路徑**：crisis-override 免疫窗（`crisis_released_task=TASK_BUILD` + `crisis_released_until` 未到）→ try_set false → 驗零殘留，測轉綠。zombie race 的**根治本身不受影響**（寫入本來就只在成功後），只是「哪條路徑會失敗」的舉例要改。

未做：§4b（三動機／overflow 決策化）、§4c（反饋迴路）＝後續 slice。地基 KEEP。
