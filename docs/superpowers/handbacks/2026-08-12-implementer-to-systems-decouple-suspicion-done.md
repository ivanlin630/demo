---
from: implementer
to: systems
status: consumed
topic: "[promote_util 去慎重壓制項 DONE·feat/decouple-suspicion-promotion commit 7ee9ec29]多疑與提拔 decouple(用戶裁倒因果修、純去壓制無 boost)·真根:_promote_pmult 的『−慎重×0.7』項=倒因果多疑壓制擋提拔創造→缺 officer 領主永遠不提拔·fix=_promote_pmult(ambition)=clampf(0.3+野心×0.9,0,1.5)去慎重項、caution 參清乾淨(promote_util/promote_util_desperate/_try_promote_advisor call site 連動去 cau、無 dead param)、差異化改野心扛、多疑 genuine 位置移下游對待現有 officer PARK·genuine 非 crank:純去一項壓制、未加任何 boost;need-gated+candidate-gated+bounded 全不變·★驗:active_promotion_test ALL PASS(promote_util bounded machine-demonstrate demand=0→0 need-gated+★低野心 demand=1 util 0.48>0.3 照 fire[decouple 非被慎重卡]+野心 modulate rate[高1.11>中0.75>低0.48]+⑤前多疑-blocked 領主 now 提拔 relief 解卡)+named_scarcity_ab_test ALL PASS(⑤前多疑-blocked 絕境 now field-promote)+headless 0-new+constitution 75+determinism 3-run byte-identical(ledger 20天 28cd04d4)·★fp 前後對照 LIVE(ledger 45天 baseline[suspicion] vs branch[decoupled]:FP d63c53e5→c98e7029 DIVERGED、promote.fired 4→5[+1 前多疑-blocked lord]、field_desperate 4→5=relief 不再被多疑倒因果卡呼應用戶裁)·★下游 re-measure(野心差異化率+size 靠資源+relief 解卡+bounded 反證)=measurer·請 →R²(reviewer 審設計 CLEAN:核 genuine 非 crank[純去壓制無 boost]+差異化來源=野心+資源非多疑)→measurer realistic 前後對照→QA→merge"
branch: feat/decouple-suspicion-promotion
commit: 7ee9ec29
---

# promote_util 去慎重壓制項 DONE（多疑與提拔 decouple、用戶裁倒因果修、純去壓制無 boost）

feat/decouple-suspicion-promotion commit `7ee9ec29`（off main HEAD 69da7f0f；已 push）。

## 倒因果洞見（用戶裁）
懷疑是對「**已存在的人**」、沒提拔哪來對象可疑 → 懷疑擋**創造** = 倒因果。★我先前 FYI「多疑不濫拔=intended」被用戶正確 **override** = 那本身是倒因果 bug。

## 真根 + fix（純去一項壓制、無 crank/boost）
- 真根：`_promote_pmult` = `clampf(0.3+野心×0.9 − 慎重×0.7, 0, 1.5)` 的 **`−慎重×0.7`** = 倒因果多疑壓制擋提拔創造 → 缺 officer 領主因多疑永遠不提拔（pmult 夾 0 never fire）。
- fix：`_promote_pmult(ambition)` = `clampf(0.3+野心×0.9, 0, 1.5)`（去慎重項）；caution 參**清乾淨**——`promote_util(demand, ambition, quality)` + `promote_util_desperate(demand, ambition)` + `_try_promote_advisor` call site 去 `cau`（無 dead param）。
- 差異化改**野心**扛（野心大 pmult 高養大班底 / 務實野心中養夠用）+ 真實成本（`kill_random 1 anon`=size 靠經濟非性格）。
- 多疑 **genuine 位置** = 下游對待現有 officer（猜忌/防範/清算=內政忠誠）→ **PARK 未來 arc**、非 promotion gate。
- stale 註更新：「多疑吝嗇」「多疑絕境不濫拔」全改反映野心-modulate + need/candidate-gated。

## genuine 非 crank 守（命門）
**純去一項壓制、未加任何 boost**；need-gated（officer_need 0→不提 bounded 不變）+ candidate-gated（quality/desperate 不變）+ 野心 modulate。bounded 全不變（spare≥CONCURRENT→0 / 無村→0 / 非領主→0）。

## 驗（全綠）
| 閘 | 結果 |
|---|---|
| `active_promotion_test` | **ALL PASS**：①promote_util bounded machine-demonstrate（demand=0→0 need-gated；★低野心 demand=1+候選 → util **0.48>0.3 照 fire**[decouple、非被慎重永久卡]；野心 modulate rate 曲線 高1.11>中0.75>低0.48）②野心差異化 rate 非 gate（低野心 0.384 仍 fire）③候選資質 gate ④firing ⑤★前多疑-blocked 領主 now 提拔 relief 解卡 ⑥⑦⑧ |
| `named_scarcity_ab_test` | **ALL PASS**（⑤★前多疑-blocked 領主真絕境 now field-promote；B/A 全案保持） |
| headless | **0-new**（3 baseline FAIL） |
| constitution_gate | **PASS sites=75** |
| determinism | **3-run byte-identical**（ledger 20天 FP `28cd04d4`；純算術零 RNG） |

## ★fp 前後對照 LIVE（ledger_diversity 45天、baseline[suspicion] vs branch[decoupled]）
| metric | baseline(suspicion) | branch(decoupled) |
|---|---|---|
| **FP** | `d63c53e5` | `c98e7029` **DIVERGED(intended)** |
| **promote.fired** | 4 | **5**（+1 前多疑-blocked lord now field-promote） |
| field_desperate | 4 | **5** |

= named-scarcity relief **不再被多疑倒因果永久卡**（呼應用戶裁）。純去壓制→+1 lord 解卡、無新 crank。

## ★下游 re-measure（measurer realistic 前後對照、6gap 教訓）
野心差異化提拔率（高野心 rate/size > 務實中 > 野心低仍 fire=need-driven）+ **size 靠資源湧現**（小 anon 池 lord 提拔後真少 1 勞力→production 壓力=cost 自限、非 over-promote-collapse；若見小村崩=回報加 affordability 項，default 觀察 realized cost 自限）+ relief 解卡 + bounded 反證 = **measurer 職**（硬數字非預設）。

## 路
1. → **R²（reviewer 審設計 CLEAN）**：核 genuine 非 crank（**純去壓制無 boost**）+ 差異化來源=**野心+資源**非多疑（倒因果修正確）+ bounded 守。
2. → measurer realistic 前後對照（野心差異化率 + size 靠資源 + relief 解卡）。
3. → QA → merge。地基 KEEP。

（perf flag 續：promotion fire 多→persons 增→`_next_id` O(persons²)，systems/measurer 評 prune。F2 disk：~115 stale worktrees。）
