---
from: systems
to: implementer
status: consumed
topic: "[dispatch settlement S2b(L0→L1工期=建點viability過濾)·base post-S2a main bd3e5988·spec=2026-08-18-settlement-S2b-L0-to-L1-corvee-HOW.md R²-CLEAN(reviewer親驗:in-place L0→L1 vs派子隊founding非冗餘=兩物理情境獨立決策、crude_camp:361已做L1-founding只服玩家NPC沒走過)·★核心HOW複用既有construction spine非新造:①T1 NPC建點決策=team站自己L0(camp_level=1腳下tile)+viable→設腳下construction_target{action:crude_camp複用or camp_to_l1,type:civ/mil by leader好戰野心,level:1,owner:team_id}+construction_ticks_left=L0_TO_L1_CORVEE_DAYS×TICKS_PER_DAY單旋鈕+current_task=建設(in-place自己施工非派子隊、決策落點延伸camp/settle族非新求解器)②T2工期複用_tick_construction:272推(ticks_left-=pop)、完工_complete_construction crude_camp分支:361既有set outpost_level=1+set_owner construct+food cap 40+tag→★S2b擴充完工清camp_level=0+camp_ticks_left=0(L0消融進L1非雙態)+升居民tag(勞力池從L1起=S2a界線落實)③T3工期中斷=既有busy-preemptible:415(壓境能傷你威脅打斷)、中斷工期暫停or作廢(TEST VALUE)·viability=付不付得起工期物理湧現(瀕餓工期中餓死→建不成、健康付得起、零硬門檻)·感知鐵律讀腳下自己L0(proximate站定合法)·守恆food cap抬非送即時糧(既有:362原則)·TDD:①站自己L0 viable→設target level:1+ticks②非站L0/瀕餓不啟③工期tick推ticks遞減④完工→level=1+owner+camp_level清0+居民tag(勞力池納)+fp反映⑤壓境威脅busy-preempt打斷L1未完⑥瀕餓工期中餓死建不成·gate:L0→L1端到端真通+viability過濾湧現(健康成/碎片不成、L1量恢復非spam)+複用spine不冗餘camp_level完工清淨無雙態+determinism+S1 reclaim/S2a L0/47 guard不破+constitution·fp intended-change·worktree feat/settlement-s2b·完→handback to:systems附measurer量測·地基KEEP"
---

# dispatch settlement S2b（L0→L1 工期 = 建點 viability 過濾）

spec=`docs/superpowers/specs/2026-08-18-settlement-S2b-L0-to-L1-corvee-HOW.md`（**R²-CLEAN**、reviewer 親驗冗餘查=非冗餘）。base=post-S2a main `bd3e5988`。

## ★核心 HOW：複用既有 construction spine 非新造
- **T1 NPC 建點決策**：team 站自己 L0（camp_level=1 腳下 tile）+ viable → 設腳下 `construction_target={action:"crude_camp"(複用) or "camp_to_l1", type:(civ/mil by leader 好戰/野心), level:1, owner:team_id}` + `construction_ticks_left = L0_TO_L1_CORVEE_DAYS × TICKS_PER_DAY`（單旋鈕 TEST VALUE）+ current_task=建設（**in-place 自己施工非派子隊**、決策落點**延伸 camp/settle 族**非新求解器）。
- **T2 工期 + 完工**：複用 `_tick_construction:272` 推（ticks_left-=pop）；完工 `_complete_construction` crude_camp 分支:361 既有 set outpost_level=1+set_owner+food cap 40+tag → **★S2b 擴充：完工清 `camp_level=0`+`camp_ticks_left=0`**（L0 消融進 L1 非雙態）+ 升居民 tag（勞力池從 L1 起=S2a 界線落實）。
- **T3 工期中斷**=既有 busy-preemptible:415（壓境「能傷你」威脅打斷）、中斷工期暫停 or 作廢（TEST VALUE）。
- **viability** = 付不付得起工期物理湧現（瀕餓工期中餓死→建不成、健康付得起、零硬門檻）。

## 守則
感知鐵律讀腳下自己 L0（proximate 站定合法）；守恆 food cap 抬非送即時糧（既有 :362 原則）。

## TDD
①站自己 L0 viable→設 target level:1+ticks ②非站 L0/瀕餓不啟 ③工期 tick 推 ticks 遞減 ④完工→level=1+owner+camp_level 清 0+居民 tag（勞力池納）+fp 反映 ⑤壓境威脅 busy-preempt 打斷 L1 未完 ⑥瀕餓工期中餓死建不成。

## gate（measurer bounded）
L0→L1 端到端真通 + viability 過濾湧現（健康成/碎片不成、L1 量恢復非 spam）+ 複用 spine 不冗餘（camp_level 完工清淨無雙態）+ determinism + S1 reclaim/S2a L0/47 guard 不破 + constitution。fp intended-change。

worktree `feat/settlement-s2b`。完 → handback to:systems 附 measurer 量測。地基 KEEP。
