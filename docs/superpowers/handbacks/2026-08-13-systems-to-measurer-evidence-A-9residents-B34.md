---
from: systems
to: measurer
status: open
topic: "[證據包A(9居民為何不生產全線索)+B③④(紮營候選比分+對手 util genuine)·用戶裁證據優先、線索全收集才裁、禁 fix 提案禁 crank·★systems 已出 B①②⑤⑥ code-read(紮營 util=weight('camp')[野心0.4+統領0.3+求生欲0.3]×camp_drive[terms.gd:190 flat 1.0 不 need-scaled]、舊審計判 arguably-genuine survival-floor 被③挑戰、settle 死路 convert_to_resident 死在 dispatch or travel)·★證據包A(那9 resident team、官方 helper、id 逐一):①有無 manufacturing facility(tile facility_level)②TASK_PRODUCE 在不在其 decision candidate(生產 applicable=has_own_outpost AND has_manufacturing_facility→無 facility 則 produce.appl_kill_nofacility 濾掉、量 per-team 此 counter)③在不在 labor pool(TAG_PRODUCE tag 有無)④current_task 逐日序列(變 resident 後每天做啥=idle?覓食?建設?還是 TASK_PRODUCE 曾出現又被打斷)⑤produce.appl_kill_nofacility 等 gate counter per-team(生產被哪 gate 濾)⑥第三路 resident 化路徑=那9團怎麼變 resident(camp.fire=0/convert=0 都非、疑佔村 combat-adjacent→補 tap 佔村→resident 化計數 or trace 那9團 origin)·★證據包B③④(specimen dump 真實候選比分):③紮營 util vs winner util 逐時點(有 has_farmable_tile 的流浪團、紮營在候選時 util 多少 vs 贏家 util 多少、輸多少)④對手(貿易/覓食)util 本身 genuine 嗎(貿易 util 是真經濟期望還虛高?覓食 util 是真苟活值?=虛高則修對手非紮營)·★禁預設(9居民不生產=facility 缺 vs task-assignment vs 其他、讓數據說;紮營輸=死常數 vs 對手虛高 vs 真值低、比分攤開才分)·★禁 fix 提案(用戶裁證據優先)·output=A 九居民逐項+B③④比分→systems 補進證據包→blueprint 帶用戶看齊裁·★官方 helper 勿手設 specimen_team_ids·地基 KEEP"
---

# 證據包A(9居民不生產全線索) + B③④(紮營候選比分+對手 util genuine)

用戶裁：證據優先、線索全收集才裁、禁 fix 提案禁 crank。★systems 已出 B①②⑤⑥ code-read（紮營 util=weight("camp")[野心0.4+統領0.3+求生欲0.3]×camp_drive[terms.gd:190 flat 1.0 不 need-scaled]、舊審計判 arguably-genuine survival-floor 被③挑戰、settle 死路）。

## ★證據包A(那 9 resident team、官方 helper、id 逐一)
1. 有無 **manufacturing facility**（tile facility_level）。
2. **TASK_PRODUCE 在不在其 decision candidate**（生產 applicable=has_own_outpost AND has_manufacturing_facility→無 facility 則 `produce.appl_kill_nofacility` 濾、量 per-team 此 counter）。
3. 在不在 **labor pool**（TAG_PRODUCE tag 有無）。
4. **current_task 逐日序列**（變 resident 後每天做啥=idle?覓食?建設? 還是 TASK_PRODUCE 曾出現又被打斷）。
5. **produce.appl_kill_nofacility 等 gate counter per-team**（生產被哪 gate 濾）。
6. **第三路 resident 化路徑**=那 9 團怎麼變 resident（camp.fire=0/convert=0 都非、疑佔村 combat-adjacent → 補 tap 佔村→resident 化計數 or trace 那 9 團 origin）。

## ★證據包B③④(specimen dump 真實候選比分)
3. **紮營 util vs winner util 逐時點**（有 has_farmable_tile 的流浪團、紮營在候選時 util 多少 vs 贏家 util 多少、輸多少）。
4. **對手（貿易/覓食）util 本身 genuine 嗎**（貿易 util 是真經濟期望還虛高?覓食 util 是真苟活值?=虛高則修對手非紮營）。

★禁預設（9居民不生產=facility 缺 vs task-assignment vs 其他；紮營輸=死常數 vs 對手虛高 vs 真值低、比分攤開才分）。★**禁 fix 提案**（用戶裁證據優先）。output = A 九居民逐項 + B③④ 比分 → systems 補進證據包 → blueprint 帶用戶看齊裁。★官方 helper 勿手設 specimen_team_ids。地基 KEEP。
