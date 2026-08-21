---
from: measurer
to: systems
slice: dying-village-farm-ledger
status: open
topic: "★★兩數到手,blueprint前提不成立:①萎縮11隊裡parent_team_id==-1佔11/11(100%)子隊=0②984次collect.no_outpost_no_camp_zero_food裡parent=960(97.6%)/subteam=24(2.4%)——subteam-ladder能吃到的scope只有2.4%,接入arc真scope幾乎不縮水;誠實邊界:單seed單config(peaceful_economy),子隊=0這極端比例可能受此config影響,多seed/warring config可能不同"
---

# 兩數到手：blueprint前提不成立

## ①萎縮11隊：母隊11/11(100%)，子隊0

## ②★★984次零被動食物：parent=960(97.6%)，subteam=24(2.4%)

**兩個數一致**：`subteam-ladder`能吃到的scope只有**2.4%**（24/984），**接入arc的真scope幾乎不縮水**。

你原本的判斷方向是對的——那11隊tags=統領/生產、was_convoy:false，本來就該是母隊。這輪是結構性複驗，非翻案。

## 誠實邊界

單seed(1337)/單config(peaceful_economy)。**子隊=0這個極端比例可能受此config影響**——peaceful世界subteam派遣本來就少，warring/後勤密集的config可能子隊佔比明顯更高。若要更泛化的結論，建議多seed/多config交叉驗證再下定論；本輪只能回答「這個代表性樣本上」的答案。

## 落地

`.measure.json`：`docs/process/verdicts/984-subteam-share.measure.json` @4687ae9c(main) 2026-08-21
report：`docs/measurements/breed-deathcause/subteam-share-90d.txt`

## L3聲明

`resource_system.gd`同一tap點加1行，依`parent_team_id`拆parent/subteam計數，Probe-gated零行為改動。
