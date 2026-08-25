---
from: systems
to: measurer
status: superseded
topic: "[9居民 precision 補完(用戶題:採集 vs 覓食)+★systems 重大 code-read 澄清(resident 採集入糧倉非 team.food、可能你 food_days 量錯 pool)·★兩 income 點+reason 坐實給你精確 tap(避 temp-diag 猜):①passive gather=resource_system:288 TileBank.deposit(dst_tile,res,gain,'harvest_intake_vault')=resident(outpost>0)採集入糧倉(granary/vault TileBank)★非 team.food;無 outpost fallback=resource_system:296 ResourceBank.add(team,res,gain,'harvest_intake')=進 team②forage/hunt=hunt_system:28 ResourceBank.add(team,'food',banked,'hunt')=TASK_FORAGE→hunt 進 team.food·★★澄清:你上輪『7/9 near-zero food_days』量 team.food/pop、但 resident 採集入糧倉(harvest_intake_vault→TileBank)非 team.food→resident 食物可能在糧倉累積、team.food 近零=量錯 pool!面2『resident 難積累』可能修正(食在糧倉)·★補完(官方 helper、禁 fix):①9 resident team id 逐一+current_task 逐日序列(證據包A 原 requirement 未回報項=白天真跑啥task、仍選覓食?還是駐守/生產?)②進帳歸因 tap 拆分 per-team:harvest_intake_vault(糧倉採集)vs harvest_intake(team 採集)vs hunt(覓食)各進帳量→分『自動採集 vs 覓食 task』各佔多少③★糧倉累積量:9 resident 站的 outpost 糧倉 food 逐日(TileBank granary food、非 team.food)→resident 是否真在糧倉累積(食在倉)vs 糧倉也空(真不採)④team47 vs 其他7對照:current_task 差異+糧倉 vs team.food 分佈(team47 積累是糧倉還 team.food?何條件對了)·★禁預設(食在倉 vs 真不採讓數據說)·output=①task序列②income 拆分③糧倉累積④team47對照→systems 收口(可能修正面2)→blueprint 帶用戶裁·官方 helper 勿手設 specimen·地基 KEEP"
---

# 9居民 precision 補完 + ★systems 重大澄清（resident 採集入糧倉非 team.food）

## ★兩 income 點 + reason 坐實（給你精確 tap、避 temp-diag 猜）
- ①**passive gather** = `resource_system:288 TileBank.deposit(dst_tile, res, gain, "harvest_intake_vault")` = resident（outpost>0）採集**入糧倉（granary/vault TileBank）★非 team.food**；無 outpost fallback = `:296 ResourceBank.add(team, res, gain, "harvest_intake")` = 進 team。
- ②**forage/hunt** = `hunt_system:28 ResourceBank.add(team, "food", banked, "hunt")` = TASK_FORAGE→hunt 進 team.food。

## ★★澄清（面2 可能修正）
你上輪「7/9 near-zero **food_days**」量 **team.food/pop**、但 resident 採集**入糧倉**（harvest_intake_vault→TileBank）非 team.food → **resident 食物可能在糧倉累積、team.food 近零=量錯 pool**！面2「resident 難積累」可能修正（食在糧倉）。

## ★補完（官方 helper、禁 fix）
1. 9 resident team id 逐一 + **current_task 逐日序列**（證據包A 原 requirement 未回報項=白天真跑啥 task、仍選覓食? 駐守? 生產?）。
2. **進帳歸因 tap 拆分** per-team：`harvest_intake_vault`(糧倉採集) vs `harvest_intake`(team 採集) vs `hunt`(覓食) 各進帳量 → 分「自動採集 vs 覓食 task」各佔多少。
3. ★**糧倉累積量**：9 resident 站的 outpost 糧倉 food 逐日（TileBank granary food、非 team.food）→ resident 是否真在糧倉累積（食在倉）vs 糧倉也空（真不採）。
4. **team47 vs 其他7對照**：current_task 差異 + 糧倉 vs team.food 分佈（team47 積累是糧倉還 team.food? 何條件對了）。

★禁預設。output → systems 收口（可能修正面2）→ blueprint 帶用戶裁。官方 helper 勿手設 specimen。地基 KEEP。
