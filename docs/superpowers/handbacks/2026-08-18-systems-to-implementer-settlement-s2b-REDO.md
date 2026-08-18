---
from: systems
to: implementer
status: open
topic: "[REDO settlement S2b·gate①紅:L0→L1 corvee啟動後卡死(team12 pop=1唯一案例做10/720 ticks就走、6mo+12mo ticks_left=710零推進、complete=0一年沒完工)·非工期不夠是TASK_BUILD不夠sticky被搶班(construct.stall:progress=21546:273、peaceful零威脅非壓境)·★systems diagnostic-first grounded(讀persist_strength.gd):有CONSTRUCTION_ACTIVE_FLOOR=0.15 hard-floor(:71-75)本該擋routine搶班、適用TASK_BUILD+construction_ticks_left>0 on team.tile_pos——但團走10 ticks就永不回·根候選:①persist.hold沒擋第一次離開(查為何tick16010走)②★團離開tile覓食後persist_strength查team.tile_pos(現他處)=查錯tile→無floor→無回收(一次離開=致命、abandoned corvee construction_team_id=team12但團在他處=stall forever無re-select)·★用measurer construct.stall tap(outpost_system:284記ct_reason=施工隊現task/pos/reason)pin團去哪被啥改(.measure.json有)·fix=補丁閘/手不聽腦root:讓in-place solo L0→L1 corvee受persist保護如remote founding(hard-floor本為此class加、solo可能漏)、非加新sticky補丁·★可能需:corvee啟動記tile_pos+persist查corvee-tile非team.tile_pos(離開仍認得未完工程)or abandoned-corvee recovery(團回頭完成自己起的工程)·★★感知鐵律守:別引god-view·驗同前gate+特驗corvee progress真推進到完工(construct.complete_crude_camp>0)·worktree feat/settlement-s2b續(base同)·完→handback附measurer·地基KEEP"
---

# REDO settlement S2b — L0→L1 corvee 啟動後卡死（gate① 紅）

## 症狀（measurer）
L0→L1 corvee **啟動後立刻卡死**：team12(pop=1) 唯一案例做 10/720 ticks 就走、6mo+12mo `construction_ticks_left=710` 零推進、`construct.complete_crude_camp=0` 一年沒完工。非工期不夠、是 **TASK_BUILD 不夠 sticky 被搶班**（`construct.stall:progress=21546:273`、peaceful 零威脅=非壓境 preempt）。

## ★systems diagnostic-first（grounded、讀 persist_strength.gd）
有 `CONSTRUCTION_ACTIVE_FLOOR=0.15` hard-floor（persist_strength:71-75）本該擋 routine 搶班（>PERSIST_HOLD_THRESHOLD 0.1）、適用 `TASK_BUILD + construction_ticks_left>0` on **team.tile_pos** tile。但 team12 做 10 ticks 就**永不回**。
- **根候選①**：persist.hold 沒擋第一次離開（查為何 tick~16010 走：persist 那時值？被啥 PRIO 蓋過？）。
- **★根候選②（強）**：**團離開 tile 覓食後 `persist_strength` 查 `team.tile_pos`(現已他處)=查錯 tile → construction_ticks_left 檢查 miss → 無 floor → 無回收**。一次離開=致命（abandoned corvee `construction_team_id=team12` 但團在他處=stall forever、無 re-select 機制）。=persist_strength.gd:25-28 註明的「cold-start 搶班→progress 永不累積=惡性循環」、hard-floor 本為 **remote founding 子隊**加、**in-place solo corvee 可能漏保護**。

## ★pin 根
用 measurer `construct.stall` tap（outpost_system:284 記 `ct_reason`=施工隊現 task/pos/reason）→ 定 team12 走哪、被啥決策路徑改（.measure.json 有數據）。**先 pin 再修**（別猜）。

## fix 方向（補丁閘/手不聽腦 root、非新 sticky 補丁）
讓 **in-place solo L0→L1 corvee 受 persist 保護如 remote founding**（hard-floor 本為此 class 加、solo 漏）。可能需：
- corvee 啟動記 tile_pos + persist 查 **corvee-tile 非 team.tile_pos**（團離開仍認得自己未完工程）；OR
- **abandoned-corvee recovery**（團回頭完成自己起的工程、非永久 abandon）。
- ★感知鐵律守（別引 god-view）。

## 驗
同前 gate + **特驗 corvee progress 真推進到完工**（`construct.complete_crude_camp>0`）。worktree `feat/settlement-s2b` 續。完 → handback 附 measurer。地基 KEEP。
