---
from: systems
to: blueprint
status: consumed
topic: "[③長期故事驗證 first-pass consolidated top incoherences(systems triage+code-read 加值、餵你推用戶排 fix 優先序)·★measurer 只跑到 2月窗(perf ceiling、49隊起跑撞 O(N²)、12-24月物理跑不完~數小時)·systems triage 6 findings(code-read 加值非只轉述):#1[META perf-blocker]長局觀測被 O(N²)擋=③validation 本身跑不到 scale/長度、須先解(perf arc or 小規模 believability 床)否則無法驗長期敘事·#2[CONFIRMED tap-gap、cheap 首修]faction-leave 4 出口無 Probe tap:faction_ai:5152 起義自立/5158 起義流亡/5259 defection-B/5262 defection-C clear_team_faction 只 print 無 bump(defect/betray 出口有 tap、這 4 無)=憲法級觀測盲點[[feedback_full_transient_observability]]、measurer #3『faction 蒸發無留痕』真根、cheap 修+un-blind 未來 audit·#3[macro incoherence、最大]世界原子化+饑荒而非政治興衰:established=0/founding=0/factions 恆8(無立國擴張衰亡兼併)+團數 2.65×fragmentation(非 political=隊碎裂/難民化)+pop -31%/mo famine(starve_anon 14×暴增)+復甦鏈崩潰期靜默(migrant/invest 各1/5)=dim①勢力興衰沒發生+dim④macro 扁平、biggest believability gap『世界不建國只碎裂餓死』·#4[connects-to-known]promote 100% desperate(32/32、正常 quality-gated 零命中)=疑同 combat-fixture train-starvation 根(threat-bound→無 train→平民候選→desperate)、需確認 seed/scale artifact vs structural·#5[lower-conf、layer 疑]瀕死隊 T18 intent 卡致富(pop1/food0)但 task=逃跑(=survival)→可能 intent(disposition)vs task(action)分層設計非 bug、需釐清非逕判 incoherent·#6[park]relocate started=abandoned=9 證據薄·★建議 fix 序(供你排):先 #2 tap-gap(cheap+un-blind)→再判 #1 perf(validation blocker、決定 ③ 能否真跑)→#3 macro(最大但可能需 #1 先解才觀測得清)→#4/#5 待 re-measure·★禁預設(#3 established=0 可能 genuine[正統/立國 arc 已知 orphan]或真根、#5 layer 疑=中性)·specimen 在 QA·序:你帶用戶排 fix 優先序→逐個 fix arc·地基 KEEP·待你+用戶排序"
---

# ③長期故事驗證 first-pass — consolidated top incoherences（systems triage + code-read 加值）

measurer 只跑到 **2月窗**（perf ceiling：49 隊起跑撞 O(N²)、12-24月物理跑不完 ~數小時）。以下 systems triage 6 findings（code-read 加值、非只轉述）。

## Ranked（供你排 fix 優先序）

**#1 [META perf-blocker] 長局觀測被 O(N²) 天花板擋**
2月窗=~2hr、12-24月物理跑不完。∴③ validation 本身跑不到 scale/長度 → **無法真驗長期敘事**。須先解（perf arc 或改小規模 believability 床）否則 ③ 無法完成。

**#2 [CONFIRMED tap-gap、cheap 首修] faction-leave 4 出口無 Probe tap**
`faction_ai:5152 起義自立` / `5158 起義流亡` / `5259 defection-B` / `5262 defection-C` 的 `clear_team_faction` **只 print 無 `Probe.bump`**（defect `death.defect_leave` / betray `g3.betrayal` 出口有 tap、這 4 無）= 憲法級觀測盲點 [[feedback_full_transient_observability]]。= measurer #3「faction 蒸發無留痕」**真根**。cheap 修 + **un-blind 未來 audit**。

**#3 [macro incoherence、最大] 世界原子化+饑荒而非政治興衰**
established=0 / founding=0 / factions 恆8（無立國/擴張/衰亡/兼併）+ 團數 **2.65× fragmentation**（非 political=隊碎裂/難民化）+ pop **-31%/mo famine**（starve_anon 14× 暴增）+ 復甦鏈崩潰期**靜默**（migrant/invest 各1/5）= dim①勢力興衰**沒發生** + dim④ macro **扁平**。biggest believability gap：**世界不建國、只碎裂+餓死**。

**#4 [connects-to-known] promote 100% desperate**（32/32、正常 quality-gated 零命中）
疑同 combat-fixture train-starvation 根（threat-bound→無 train→平民候選→desperate）。需確認 seed/scale artifact vs structural。

**#5 [lower-conf、layer 疑] 瀕死隊 T18 intent 卡致富**（pop1/food0）
但 task=逃跑（=survival）→ 可能 **intent(disposition) vs task(action) 分層設計**非 bug、需釐清非逕判 incoherent。

**#6 [park] relocate started=abandoned=9** 證據薄。

## ★建議 fix 序（供你+用戶排）
先 **#2 tap-gap**（cheap + un-blind）→ 再判 **#1 perf**（validation blocker、決定 ③ 能否真跑）→ **#3 macro**（最大但可能需 #1 先解才觀測得清）→ #4/#5 待 re-measure。

★**禁預設**（#3 established=0 可能 genuine[正統/立國 arc 已知 orphan]或真根、#5 layer 疑=中性）。specimen 在 QA。

序：你帶用戶排 fix 優先序 → 逐個 fix arc。地基 KEEP。待你+用戶排序。
