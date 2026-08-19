---
from: systems
to: implementer
status: open
topic: "[dispatch §4a 建點入引擎+de-scaffold(★硬 gate:constitution 77→75 本 slice 完成)·base main 6bd10f36·spec=2026-08-20-settlement-S4-strategic-siting-HOW.md(含 §5 R²delta 訂正、R²=CLEAN+1 必查項)·★①新 engine option『紮根』進 options.gd REGISTRY:applicable=只物理可行性(站自己 L0 camp_level==1 腳下+outpost_level==0+construction_team_id==-1+非玩家;★不加 current_task==IDLE、理由見 spec §5)·terms=可行性帳(工期 ETA[L0_TO_L1_CORVEE_DAYS+殘距] vs team.food_runway、ETA≫runway→util→0=瀕餓自然不開工、取代原 hard threshold)+選址品質(腳下 tile 地力/farm 潛力、belief 分層親見>傳聞)+人格 modulate 既有權重(好戰/野心→type 與權重、非另加線)·★★②必查項(R² 抓的 zombie race、systems 裁 (b) 根治非 (a)):to_task【只回 {task,target}、零世界寫入】;construction_target/construction_ticks_left/construction_team_id/corvee_site 寫入【移到 _set_ok==true 之後的 commit-hook】——比照既有 pattern(td.has('combat_target')/td.has('social_target') 在 try_set 成功後才處理、_decide_unified:2586-2589 先例)·理由:to_task 在 :2520、try_set 在 :2575 且真會 false(combat 鎖/crisis 免疫窗/progressive-hold persist/搶班失敗)→副作用先落地=tile 標記但隊沒進 BUILD→_tick_construction 只在隊死才清 orphan→永久 zombie 工地·★③刪 _evaluate_l0_settle(faction_ai:4777)+唯一 caller(:838)、功能全落 option→constitution_baseline_v2.txt 移除 :77-78 兩行→★gate 硬:constitution PASS 75·TDD:①applicable 只吃物理條件②瀕餓團 util→0 不開工(無 hard gate 仍過濾)③健康團開工並完工(端到端 L1)④★非 idle 隊+站自己 L0+紮根進 ranked→try_set 失敗→tile construction_target 仍空/team_id 仍 -1(零 zombie 殘留)⑤constitution 75(兩站消失+baseline 同步)⑥既有 S2b 行為不破(工期/busy-preempt 中斷/corvee_site recovery/完工清 camp_level)+S1 撿現成不破·gate:上述+determinism 三跑 byte-identical(記新 fp、engine 化=fp intended-change 預期會變)+headless 0-new+agriculture/settlement 既有 test 全綠·★不做 §4b(三動機/overflow 決策化)、§4c(反饋)——後續 slice·worktree feat/settlement-s4a·完→handback to:systems 附新 fp·地基KEEP"
---

# dispatch §4a：建點入引擎 + de-scaffold（★硬 gate 77→75 本 slice 完成）

spec=`docs/superpowers/specs/2026-08-20-settlement-S4-strategic-siting-HOW.md`（**含 §5 R²delta 訂正**；R²=**CLEAN + 1 必查項**）。base=main `6bd10f36`。

## ★①新 engine option「紮根」（options.gd REGISTRY）
- **applicable=只物理可行性**：站自己 L0（`camp_level==1` 腳下）+ `outpost_level==0` + `construction_team_id==-1` + 非玩家。**★不加 `current_task==IDLE`**（理由見 spec §5：那是治症非治根、且限制引擎公平競爭）。
- **terms**：**可行性帳**（工期 ETA[`L0_TO_L1_CORVEE_DAYS`+殘距] vs `team.food_runway`；ETA≫runway→util→0=**瀕餓自然不開工**、取代原 hard threshold）+ **選址品質**（腳下 tile 地力/farm 潛力、**belief 分層**親見>傳聞）+ **人格 modulate 既有權重**（好戰/野心→type 與權重、非另加線）。

## ★★②必查項（R² 抓的 zombie race、systems 裁 **(b) 根治**非 (a)）
- **`to_task` 只回 `{task, target}`、零世界寫入**；`construction_target`/`construction_ticks_left`/`construction_team_id`/`corvee_site` 寫入**移到 `_set_ok==true` 之後的 commit-hook**——**比照既有 pattern**（`td.has("combat_target")`/`td.has("social_target")` 在 try_set 成功後才處理、`_decide_unified:2586-2589` 先例）。
- **理由**：`to_task` 在 :2520、`try_set` 在 :2575 且**真會 false**（combat 鎖 / crisis 免疫窗 / progressive-hold persist / 搶班失敗）→ 副作用先落地=**tile 標記但隊沒進 BUILD** → `_tick_construction` 只在隊死才清 orphan → **永久 zombie 工地**。

## ★③de-scaffold（硬 gate）
刪 `_evaluate_l0_settle`（faction_ai:4777）+ 唯一 caller（:838）、功能全落 option → `constitution_baseline_v2.txt` **移除 :77-78 兩行** → **★gate 硬：constitution PASS 75**。

## TDD
①applicable 只吃物理條件 ②瀕餓團 util→0 不開工（無 hard gate 仍過濾）③健康團開工並完工（端到端 L1）**④★非 idle 隊 + 站自己 L0 + 紮根進 ranked → try_set 失敗 → tile `construction_target` 仍空 / `construction_team_id` 仍 -1（零 zombie 殘留）** ⑤constitution 75（兩站消失+baseline 同步）⑥既有 S2b 行為不破（工期/busy-preempt 中斷/corvee_site recovery/完工清 camp_level）+ S1 撿現成不破。

## gate
上述 + determinism 三跑 byte-identical（**記新 fp**、engine 化=**fp intended-change 預期會變**）+ headless 0-new + agriculture/settlement 既有 test 全綠。
**★不做 §4b（三動機/overflow 決策化）、§4c（反饋）**=後續 slice。

worktree `feat/settlement-s4a`。完 → handback to:systems 附新 fp。地基 KEEP。
