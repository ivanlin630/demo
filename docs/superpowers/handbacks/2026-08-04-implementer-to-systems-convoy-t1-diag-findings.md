---
from: implementer
to: systems
status: consumed
topic: "[convoy-lifecycle+T1 死因診斷真值·measure-first 別下修結論·feat/info-network-whole commit ff785b96]★#6 未在 peaceful_economy seed 70730 6mo 重現(harness==我 inline bed 逐行核實 faithful):distribute.dispatch=0(非6)·0 relief convoy·deliver(供給)convoy 健康 8 arrive/5 settled/3 economy-bail(owner_cant_afford1+no_surplus2)=無 travel 黑洞·T1(id1)全180天存活 pop6(非死day60)、T1=獨立隊(覓食/掠奪/投靠/乞食)無 lord 聞、food~0 靠覓食吊命=distribute 鏈根本沒 engage 它·→#6(distribute6/T1死)必另一 faction 結構 bed 非 peaceful70730=我問3次的 FACTION bed·★blocker:需你給 #6 exact bed/seed/config/months 我才重現真症。dump docs/measurements/2026-08-04-convoy-lifecycle-t1death-diagnostic.json。"
branch: feat/info-network-whole
commit: ff785b96
measurements: docs/measurements/2026-08-04-convoy-lifecycle-t1death-diagnostic.json
---

# convoy-lifecycle + T1 死因 診斷真值（measure-first、只交真值、別下修結論）

照 dispatch build `convoy_t1_diag_bed`（inline seeded run、每 tick 純 READ state、零 sim-code 改、零 randf；`seed()+advance_tick` 合法世界設置）on **peaceful_economy config seed 70730 6mo**（GODOT_TIMEOUT=1200）。

## ★★核心真值：#6 未在此 bed 重現
| #6 報 | 我 peaceful 70730 6mo 實測 |
|---|---|
| `distribute.dispatch=6` | **`distribute.dispatch=0`**（0 relief convoy、convoy_life 0 porter） |
| deliver 卡 1（5/6 沒送達=疑黑洞） | 見下（deliver 供給 convoy 全健康、非黑洞） |
| T1 死（day60、6 輪首次） | **T1(id1) 全 180 天存活、pop 6 不變**（沒死） |

**★harness faithful 核實**：`WarringHarness.run`（#6 measurer 用的 canonical 路徑）逐行核 = 我 inline bed（`seed(70730)`→`GameSetup.setup(config,seed)`→`advance_tick(no_player)` loop、**無 force_full_hd、無 config mutate、無額外 LOD**）＝完全相同世界。determinism 保證同 seed+config+ticks 同世界＝我測的 `distribute=0/T1 活` 就是 harness 在 peaceful 70730 的真值。

## (a) convoy-lifecycle 逐站（peaceful 70730）
- **distribute（relief）convoy：0 dispatched**——症1 賑濟鏈在此 bed 根本沒 fire（無 faction 領主聞到子民 distress→無 `_try_distribute_side` 候選）。
- **deliver（供給/貿易）convoy：8 arrive / 5 settled / 3 economy-bail**（`convoy.deliver=8` `convoy.deliver_settled=5`；bail：`sell_owner_cant_afford=1`、`sell_no_surplus=2`）。
  - ★**無 travel 黑洞**：8 個全抵達市場（arrive），3 個沒成交是**經濟原因**（買方付不起 coin / 賣方無真餘量）非 lifecycle 卡站/cull。convoy team 機制健康（travel→arrive→deliver/bail→return）。
- **[Convoy] log**：Team3→porter Team12（food×26 後 material×37 ×5）、Team4→Team17(food×15)/Team18(material×37)＝皆 **kind=deliver**（供給），非 distribute。

## (b) T1 死因（peaceful 70730）
- **T1 沒死**（alive_at_end、pop 6 全程、min_pop=6）。food day1=118 → day46=0，之後 day46-180 大多 food≈0 但 **pop 恆 6 靠覓食吊命**（0 buffer 生存、不死）。
- **T1 沒派 letter/herald**（`letter_dispatched=false`）＝沒 detach anon（排除「求救反抽勞力害死自己」假說——在此 bed T1 根本沒求救）。
- **T1 task 序**：idle→覓食→治理↔覓食↔return_home↔掠奪↔投靠↔乞食 循環＝**獨立隊絕境求生**（投靠/乞食/掠奪=非 faction resident 行為）。T1 無 lord→distribute 鏈**不 engage 它**。
- side-dispatch 沒改死時序（T1 沒死、也沒派 side-action）。

## ★歸因 + blocker（別下修結論）
- **兩 #6 症在 peaceful 70730 皆不現**（distribute 沒 fire、T1 沒死）→ **#6 的 `distribute=6`/`T1 死` 必來自另一 bed/seed/config**——極可能是 **faction 結構 bed**（lord+resident+固定 outpost、症1 真場景）＝我前 3 封 handback 一直問、systems 未答的「FACTION bed 選定」。peaceful 70730 的 T1 是獨立隊、無 lord-resident distribute 關係＝症1 鏈不成立。
- **★★硬 blocker（報 systems、非自造斷點）**：要診斷 #6 的 convoy-5/6 + T1-death **真症**，需你給 **#6 exact 重現參數：bed 檔名 + seed + config + months**（measurer 手上有）。給我即可立刻在該 bed 逐站重跑（bed 已備、換 config/seed 即可）。
- 在拿到前，我能確認的真值：**convoy team 機制本身無黑洞**（deliver convoy 8/8 travel+arrive 健康）＝(a)「又一黑洞家族」假說在 peaceful bed **不成立**；deliver 未成交=economy（付不起/無餘量）。

## 待你
1. 給 **#6 exact bed/seed/config/months** → 我在該 bed 逐站重跑 convoy-life + T1 timeline（同 probe）→ 真症卡站表 + T1 死因歸因。
2. 或你確認 #6 就是 peaceful 70730（則 #6 的 6/死 數字需 measurer 復核來源——我這裡 determinism-faithful 測到 0/活）。

★measure-first、只交真值（[[feedback_verify_execution_end]]、[[feedback_symptom_vs_root_retry]]）。dump 落地 `docs/measurements/2026-08-04-convoy-lifecycle-t1death-diagnostic.json`（per-convoy + T1 逐日 pop/food/task 全序）。HOLD 待你定 #6 repro 參數。
