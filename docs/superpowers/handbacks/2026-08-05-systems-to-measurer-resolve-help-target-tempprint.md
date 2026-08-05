---
from: systems
to: measurer
status: open
topic: "[_resolve_help_target 89% 失敗 temp-print 診斷(QA flag:此 bug 卡 cohesion ①分化 relief 鏈比 race-timing 更早、不修 ①verdict 下不了)·systems 讀 code 理解迴圈+QA 排除 3 顯性 skip 後 sharp 假說、需 runtime 值分辨·★迴圈邏輯(faction_ai:1746-1758):resident 掃全 tile 找『outpost_level>0 且非 hidden 且 outpost_owner!=自己 且 owner!=null 且 owner.faction_id==team.faction_id』最近者當求援目標、無→id=-1·QA 排除 outpost_level(T0T2 config level1)/hidden(stub false)/faction_id remap(match)·★剩 3 假說 temp-print 分辨(在 1746 迴圈內對 T1/T3 severity_positive 36 次呼叫印):H1=owner==null(state.teams.get(outpost_owner) 回 null=outpost_owner 指向不存在隊、印 outpost_owner + owner==null?)H2=唯一同 faction outpost 是 resident 自己(被 :1751 outpost_owner==team.team_id skip、印跳過原因分布:幾個因 self/幾個因 owner-null/幾個因 faction-mismatch/幾個因 level)H3=runtime faction 態(team.faction_id vs owner.faction_id 當下值、印兩者)·temp-print 建議:迴圈頂印 team.team_id/team.faction_id/f.leader_team_id 一次+每 tile 印 tile_id/outpost_level/outpost_owner/(owner==null?)/owner.faction_id+迴圈尾印 best_pos 找到否·跑 moderate 床(config/infonet_established_fragility.json or 你的 moderate 床)T1/T3 那 36 次·純觀測抓真相→回 systems 定 bug root+修·temp 完 revert·★這 code-correctness bug 卡 cohesion ①(relief 鏈斷在求援 target 解析)·地基 KEEP"
---

# `_resolve_help_target` 89% 失敗 temp-print 診斷（卡 cohesion ①）

QA flag：`_resolve_help_target`（`faction_ai:1738-1758`）moderate 床 89%（32/36）失敗、**卡 cohesion ①分化 relief 鏈（比 race-timing 更早）、不修 ①verdict 下不了**。systems 讀 code + QA 排除 3 顯性 skip 後 sharp 假說、需 runtime 值分辨。

## 迴圈邏輯（`:1746-1758`）
resident 掃全 tile 找「`outpost_level>0` 且非 `hidden` 且 `outpost_owner!=自己` 且 `owner!=null` 且 `owner.faction_id==team.faction_id`」最近者當求援目標、無→`id=-1`。QA 排除 outpost_level(T0T2 config level1)/hidden(stub false)/faction_id remap(match)。

## ★剩 3 假說（temp-print 分辨）
- **H1＝owner==null**：`state.teams.get(outpost_owner)` 回 null（outpost_owner 指向不存在隊）。
- **H2＝唯一同 faction outpost 是 resident 自己**（被 `:1751 outpost_owner==team.team_id` skip）。
- **H3＝runtime faction 態**（team.faction_id vs owner.faction_id 當下值）。

## temp-print 建議（`:1746` 迴圈內、對 T1/T3 severity_positive 36 次呼叫）
- 迴圈頂：`team.team_id / team.faction_id / f.leader_team_id`（一次）。
- 每 tile：`tile_id / outpost_level / outpost_owner / (owner==null?) / owner.faction_id`。
- 迴圈尾：`best_pos 找到否` + **跳過原因分布**（幾個因 self / 幾個因 owner-null / 幾個因 faction-mismatch / 幾個因 level）。

## 序
跑 moderate 床（`config/infonet_established_fragility.json` or 你的 moderate 床）T1/T3 那 36 次。純觀測抓真相 → 回 systems 定 bug root + 修。temp 完 revert。★此 code-correctness bug 卡 cohesion ①（relief 鏈斷在求援 target 解析）。落地 `docs/measurements/`。地基 KEEP。
