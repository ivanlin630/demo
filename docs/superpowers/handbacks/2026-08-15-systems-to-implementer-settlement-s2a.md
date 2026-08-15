---
from: systems
to: implementer
status: consumed
topic: "[dispatch settlement S2a(L0營地階梯)·base post-crash main d5807d69·spec=2026-08-15-settlement-S2-L0-camp-ladder-HOW.md R²-CLEAN(訂正已納)·★核心HOW:L0=新tile.camp_level獨立flag(0=無/1=L0)、outpost_level保持0(語意正確L0非真據點)——禁用outpost_level=0當L0(全樹47站14檔把level==0當空tile哨兵、會全誤判)·★★state_fingerprint:119現於outpost_level<=0 and construction_team_id==-1跳過tile→L0(level0無construction)不入fp→必顯式納camp_level入state_fingerprint(:119條件或:122欄)否則L0變化determinism盲點·S2a範圍:①camp_level欄+fp納②establish_crude_camp(faction_ai:4707)拆出紮營=設camp_level=1不設outpost_level不set_owner(非領土宣稱)、拔營無沉沒(離開/棄置camp_level→0無廢墟)③L0採集讀腳下tile池現量低倍率單旋鈕L0_FORAGE_MULT(禁pop-curve、池竭移動遊牧湧現)④L0衰敗L0_DECAY_DAYS棄置camp_level→0(cadence掃)⑤L0不清流亡不升居民tag(勞力池從L1起、L0無倉無設施無領土無居民身分)·★感知鐵律:L0選址採集讀腳下live(proximate合法同:4708)·TDD:①camp_level+顯式fp納②紮營設camp_level不設level(既有guard不誤判)③L0採腳下池池竭移④棄置decay→0無廢墟⑤L0不入勞力池⑥★回歸驗outpost_system升級鏈7站(446/469/511/638/658/681/745)+state_fingerprint:119+抽驗order_system(5)/harvest(2)/need_oracle(2)不被L0誤觸(非只faction_ai清單)·L1工期=S2b後續slice本slice不做·gate:L0/L1界線真+紮營廉價無沉沒+不破47既有guard+determinism byte-identical(camp_level純狀態、fp納)+constitution·worktree feat/settlement-s2a·完→handback to:systems附measurer量測·地基KEEP"
---

# dispatch settlement S2a（L0 營地階梯）

spec=`docs/superpowers/specs/2026-08-15-settlement-S2-L0-camp-ladder-HOW.md`（**R²-CLEAN**、訂正已納）。base=post-crash main `d5807d69`。

## ★核心 HOW
- **L0 = 新 `tile.camp_level` 獨立 flag**（0=無/1=L0）、**outpost_level 保持 0**（語意正確 L0 非真據點）。**禁用 outpost_level=0 當 L0**——全樹 **47 站 14 檔**把 level==0 當空 tile 哨兵、會全誤判。
- **★★state_fingerprint:119** 現於 `outpost_level<=0 and construction_team_id==-1` **跳過 tile** → L0 不入 fp → **必顯式納 camp_level 入 state_fingerprint**（:119 條件或 :122 欄）、否則 L0 變化 determinism 盲點。

## S2a 範圍（L1 工期=S2b 後續、本 slice 不做）
①camp_level 欄 + fp 納 ②`establish_crude_camp`(faction_ai:4707) 拆出**紮營**=設 camp_level=1、**不**設 outpost_level、**不** set_owner（非領土宣稱）、拔營無沉沒（離開/棄置 camp_level→0 無廢墟）③L0 採集讀腳下 tile 池現量、低倍率單旋鈕 `L0_FORAGE_MULT`（禁 pop-curve、池竭移動遊牧湧現）④L0 衰敗 `L0_DECAY_DAYS` 棄置 camp_level→0（cadence 掃）⑤L0 不清流亡不升居民 tag（勞力池從 L1 起、L0 無倉/設施/領土/居民身分）。

## ★感知鐵律
L0 選址/採集讀腳下 live（proximate 合法、同 :4708 讀 team.tile_pos）。

## TDD
①camp_level + 顯式 fp 納 ②紮營設 camp_level 不設 level（既有 guard 不誤判）③L0 採腳下池、池竭移 ④棄置 decay→0 無廢墟 ⑤L0 不入勞力池 ⑥**★回歸驗** outpost_system 升級鏈 7 站(446/469/511/638/658/681/745)+state_fingerprint:119+抽驗 order_system(5)/harvest(2)/need_oracle(2) 不被 L0 誤觸（非只 faction_ai 清單）。

## gate（measurer bounded）
L0/L1 界線真 + 紮營廉價無沉沒 + 不破 47 既有 guard + determinism byte-identical（camp_level 純狀態、fp 納）+ constitution。

worktree `feat/settlement-s2a`。完 → handback to:systems 附 measurer 量測。地基 KEEP。
