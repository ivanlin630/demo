---
from: systems
to: implementer
status: open
topic: "[小修:promote_util 去慎重壓制項(用戶裁多疑與提拔 decouple、倒因果:懷疑是對已存在的人、沒提拔哪來對象可疑→懷疑擋創造=倒因果)·新 branch feat/decouple-suspicion-promotion 自 main HEAD·★真根:_promote_pmult(faction_ai:1670)=clampf(0.3+野心×0.9−慎重×0.7,0,1.5)的『−慎重×0.7』項=用倒因果的多疑壓制擋提拔創造→缺 officer 領主因多疑永遠不提拔(我先前 FYI『多疑不濫拔=intended』被用戶正確 override=那本身是倒因果 bug)·★★§HOW-binding:①核心=_promote_pmult 去『−慎重×0.7』項→新=clampf(0.3+野心×0.9,0,1.5)(野心 modulate、base 0.3、無慎重壓制);caution 參數變 dead→建議清:_promote_pmult(ambition)+promote_util/promote_util_desperate 去 caution 參+_try_promote_advisor call site 去 cau(乾淨無 dead param、你定簽名)②差異化改野心扛(野心大 pmult 高養大班底/務實野心中養夠用)+真實成本(kill_random 1 anon=少1勞力已在=小村養不起自然湧現、size 靠經濟非性格怪癖)③多疑 genuine 位置=下游對待現有 officer(猜忌/防範/清算=內政忠誠、PARK 未來 arc、非 promotion gate)·★★genuine 非 crank 守(命門):need-gated(officer 夠→officer_need 0→不提 bounded 不變)+candidate-gated(quality/desperate 不變)+野心 modulate;★禁加任何 crank/boost、純去一項壓制·bounded 全不變(spare≥CONCURRENT→0/無村→0/非領主→0)·④★stale 註更新:去 caution 後『多疑吝嗇』『多疑絕境照樣不濫拔 genuine 分化保留』(desperate 路+return 註)全 stale→改反映野心-modulate+need/candidate-gated(非多疑)·★★驗收(硬數據、realistic 非只 unit、6gap 教訓):①★realistic 前後對照(main baseline vs branch):前多疑 lord(野心0.3/慎重0.6 pmult 舊0.15<0.3 never fire)now pmult 0.57→need=1.0+候選→promote fire(named-scarcity relief 不再被多疑永久卡=呼應用戶裁)②★野心差異化真現:高野心 promote 率/班底 size>務實中野心>(野心低但 need 高+候選好仍可 fire=need-driven、野心 modulate rate 非 gate)③★size 靠資源湧現:小 anon 池 lord 提拔後真少 1 勞力→production 壓力(cost 自限、非 over-promote-collapse;若 measurer 見小村 over-promote 崩=回報加 affordability 項、default 觀察 realized cost 自限)④bounded 反證(officer 夠→不提、非 always-promote)⑤determinism+active_promotion regression+named_scarcity_ab_test 更新(去 caution 案)+constitution·★行為變 slice=fp 分化 intended·完成 handback to:systems→R²(reviewer 審設計 CLEAN:核 genuine 非 crank[純去壓制無 boost]+差異化來源=野心+資源非多疑)→measurer realistic 前後對照(野心差異化率+size 靠資源+relief 解卡)→QA→merge·地基 KEEP"
---

# 小修：promote_util 去慎重壓制項（多疑與提拔 decouple）

用戶裁。倒因果洞見：**懷疑是對已存在的人、沒提拔哪來對象可疑 → 懷疑擋創造 = 倒因果**。新 branch `feat/decouple-suspicion-promotion` 自 main HEAD。

## ★真根
`_promote_pmult`（faction_ai:1670）= `clampf(0.3 + 野心×0.9 − 慎重×0.7, 0, 1.5)` 的 **`−慎重×0.7` 項** = 用倒因果的多疑壓制擋提拔**創造** → 缺 officer 領主因多疑**永遠不提拔**（我先前 FYI「多疑不濫拔=intended」被用戶正確 override = 那本身是倒因果 bug）。

## ★★§HOW-binding
1. **核心**：`_promote_pmult` 去 `−慎重×0.7` 項 → 新 = `clampf(0.3 + 野心×0.9, 0, 1.5)`（野心 modulate、base 0.3、無慎重壓制）。caution 參數變 dead → 建議清：`_promote_pmult(ambition)` + `promote_util`/`promote_util_desperate` 去 caution 參 + `_try_promote_advisor` call site 去 cau（乾淨無 dead param、你定簽名）。
2. **差異化改野心扛**（野心大 pmult 高養大班底 / 務實野心中養夠用）+ **真實成本**（`kill_random 1 anon`=少1勞力**已在**=小村養不起自然湧現、size 靠經濟非性格怪癖）。
3. **多疑 genuine 位置** = 下游對待現有 officer（猜忌/防範/清算=內政忠誠、**PARK 未來 arc**、非 promotion gate）。

## ★★genuine 非 crank 守（命門）
need-gated（officer 夠→officer_need 0→不提 bounded 不變）+ candidate-gated（quality/desperate 不變）+ 野心 modulate。★**禁加任何 crank/boost、純去一項壓制**。bounded 全不變（spare≥CONCURRENT→0 / 無村→0 / 非領主→0）。

## ④★stale 註更新
去 caution 後「多疑吝嗇」「多疑絕境照樣不濫拔 genuine 分化保留」（desperate 路 + return 註）全 stale → 改反映野心-modulate + need/candidate-gated（非多疑）。

## ★★驗收（硬數據、realistic 非只 unit、6gap 教訓）
1. ★**realistic 前後對照**（main baseline vs branch）：前多疑 lord（野心0.3/慎重0.6 舊 pmult 0.15<0.3 never fire）now pmult 0.57 → need=1.0+候選 → promote fire（**named-scarcity relief 不再被多疑永久卡** = 呼應用戶裁）。
2. ★**野心差異化真現**：高野心 promote 率/班底 size > 務實中野心 >（野心低但 need 高+候選好仍可 fire = need-driven、野心 modulate rate 非 gate）。
3. ★**size 靠資源湧現**：小 anon 池 lord 提拔後真少 1 勞力→production 壓力（cost 自限、非 over-promote-collapse；若 measurer 見小村 over-promote 崩=回報加 affordability 項、**default 觀察 realized cost 自限**）。
4. **bounded 反證**（officer 夠→不提、非 always-promote）。
5. determinism + active_promotion regression + named_scarcity_ab_test 更新（去 caution 案）+ constitution。
★行為變 slice = fp 分化 intended。

## 序
完成 handback `to:systems` → R²（reviewer 審設計 CLEAN：核 genuine 非 crank[純去壓制無 boost] + 差異化來源=野心+資源非多疑）→ measurer realistic 前後對照（野心差異化率 + size 靠資源 + relief 解卡）→ QA → merge。地基 KEEP。
