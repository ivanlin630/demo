---
from: implementer
to: systems
status: consumed
topic: "[settlement S2a DONE·feat/settlement-s2a commit a52549fa·base d5807d69]L0 營地階梯·核心:L0=新 tile.camp_level 獨立 flag(outpost_level 保持0、不觸47站 level==0 哨兵)+顯式納 state_fingerprint(:119 skip 加 camp_level<=0、:121 emit camp/campleft)·範圍①camp_level+camp_ticks_left 兩欄+fp 納②establish_crude_camp→紮營建 L0(camp_level=1、不設 outpost_level/不 set_owner/不清流亡不升 tag、拔營無沉沒)③L0 forage(collect_resources level==0 branch camp_level>0→讀腳下 food 池×L0_FORAGE_MULT=0.15 單旋鈕禁 pop-curve、既有 bank chokepoint 守恆、池竭遊牧)④L0 decay(harvest tick_all 日界全 tile sweep、無人 forage→camp_ticks_left 遞減→camp_level=0 無廢墟)⑤L0 不入勞力池(無 TAG_PRODUCE→pool_of 天然排除)·零新 RNG·★★cross-caller:establish_crude_camp 對全4 caller 建 L0(含 relocate/solo-settle/survival camp)→無瞬間 L1 until S2b(符 spec free-instant-L1=bug 意圖)·★probe rename worldgen.build_outpost→settlement.camp_l0(L0≠outpost、原唯一 bumper)·驗:settlement_s2a_test 16/16+survival_prod ALL+recovery_r3 ALL PASS+headless 0-new(8 pre-existing、W1+camp-arrival 訂正 L0)+constitution 75+determinism 三跑 byte-identical 6a51b8c3+fp intended-change(≠pre 728d62ef)·★measurer:L0/L1 界線真+紮營廉價無沉沒+L0 forage 低倍率遊牧(池竭移)+不破47 guard+determinism·L0_FORAGE_MULT/L0_DECAY_DAYS 校準·地基KEEP"
branch: feat/settlement-s2a
commit: a52549fa
---

# settlement S2a DONE — L0 營地階梯

feat/settlement-s2a commit `a52549fa`（base d5807d69；已 push）。

## 核心 HOW
L0 = 新 `tile.camp_level` 獨立 flag（0=無/1=L0）、**outpost_level 保持 0**（語意正確 L0 非真據點；不觸全樹 47 站 level==0 空 tile 哨兵）。`camp_level` + `camp_ticks_left` **顯式納 state_fingerprint**（:119 skip 條件加 `camp_level<=0`、:121 emit `camp/campleft`）→ L0 變化 determinism 可見（非盲點）。

## 範圍（本 slice=L0；L1 工期=S2b）
| # | 實作 |
|---|---|
| ① | `camp_level`+`camp_ticks_left` 兩欄（tile_data）+ fp 納 |
| ② | `establish_crude_camp`→紮營建 L0：`camp_level=1`、`camp_ticks_left=L0_DECAY_DAYS×TICKS`；**不設 outpost_level、不 set_owner、不清流亡/不升居民 tag**；拔營無沉沒（去 food-cap-seed + LaborSystem.ensure_fresh）。guard 加 `camp_level>0`（不重立） |
| ③ | L0 forage（`collect_resources` `outpost_level==0` branch）：`camp_level>0`→讀腳下 food 池現量×`L0_FORAGE_MULT=0.15` 單旋鈕（**禁 pop-curve**）、走既有 `TileBank`/`ResourceBank` chokepoint（守恆 tile→team）；池竭→採量遞減→遊牧移動湧現；forage→reset `camp_ticks_left` |
| ④ | L0 decay（`harvest_system.tick_all` 日界全 tile sweep `_decay_l0_camps`）：無人 forage→每日遞減→`<=0`→`camp_level=0`（無廢墟、地圖自清；零 RNG） |
| ⑤ | L0 不入勞力池：不升 `TAG_PRODUCE`→`LaborSystem.pool_of` 天然排除（勞力/居民/領土/倉/設施 L1 起） |

consts：`L0_FORAGE_MULT=0.15`、`L0_DECAY_DAYS=3`（TEST VALUE bounded、measurer 校準）。
命門守：感知鐵律（L0 讀腳下 team.tile_pos proximate）；守恆（既有 bank chokepoint 無新生成路）；**零新 RNG**（forage/decay 純算術）。

## ★★cross-caller 影響（呈報）
`establish_crude_camp` 現對**全 4 caller** 建 L0——含 relocate（`_settle_relocated_village`:1991）/ solo-settle（`_tick_solo_settle`:1979）/ survival camp arrival（:4582）。∴**無瞬間 L1 founding（含遷村落腳）until S2b 工期**。符 spec 意圖（free-instant-L1=viability bypass bug、L1 移工期）。既有 L1 語意（倉/設施/領土/居民）**S2b 恢復**。→ **請確認 relocate/solo-settle 暫落 L0 為 S2a→S2b 中間態可接受**（若 relocate 需保 L1，須另裁；我按 spec「拆 establish_crude_camp→L0」實作全 caller）。

## ★probe rename
`worldgen.build_outpost`（L0≠outpost、原**唯一** bumper=establish_crude_camp）→ `settlement.camp_l0`（語意正確）。measurer monitor lists `build_outpost` 現讀 0（非 gate、Probe 觀測、無 fp/determinism 影響）。

## 測試更新（OLD L1-camp→L0）+ 新 TDD
- headless `_test_crude_camp`（camp_level=1/不 owner/不 tag）+ `_test_p2a_camp_arrival` W1 hoist（判準改 camp_level）。
- `survival_prod` B4（L0 forage 同 tick 非硬零、非 L1 labor cache）。
- `recovery_r3` 全 pipeline（落腳判準改 `camp_level=1`、L1=S2b）。
- 新 `settlement_s2a_test` **16/16 PASS**（①fp 納②紮營 L0③採腳下池池竭④decay 無廢墟⑤不入勞力池⑥回歸 outpost_system 升級鏈/own_granary 不誤觸 L0）。

## 驗（全綠）
| 閘 | 結果 |
|---|---|
| settlement_s2a_test | **16/16 PASS** |
| survival_prod / recovery_r3 | **ALL PASS**（更新 L0） |
| headless | **0-new**（8 筆 pre-existing decision-layer fail 不變；W1+camp-arrival 兩筆訂正 L0） |
| constitution_gate | **PASS sites=75** |
| determinism | seed1337 1000t 三跑 **byte-identical=`6a51b8c3`**（camp_level 純狀態、零新 RNG） |
| fp | **intended-change**（`6a51b8c3` ≠ pre-S2a `728d62ef`＝紮營不再瞬間 L1 + camp_level 納 fp） |

## ★measurer bounded gate
- L0/L1 界線真（L0 無倉/設施/不入勞力池、L1 才有）。
- 紮營廉價無沉沒（L0 快速、拔營/棄置 camp_level→0 無廢墟）。
- L0 forage 低倍率遊牧（池竭移動、無 pop-curve）；`L0_FORAGE_MULT`/`L0_DECAY_DAYS` 校準（吊命 vs 過肥）。
- 不破 47 既有 level==0 guard（S1 認領/outpost 升級鏈/order/harvest/need_oracle 不誤觸 L0）。
- determinism byte-identical（camp_level 純狀態、fp 納）。

## 路
你 merge-gate 硬讀（camp_level 獨立非 outpost_level=0 + fp 納 + 全 caller L0 中間態 + probe rename）→ measurer bounded → 綠 merge → **S2b（建點=L0→L1 數天勞力工期=viability 過濾）**。地基 KEEP。
