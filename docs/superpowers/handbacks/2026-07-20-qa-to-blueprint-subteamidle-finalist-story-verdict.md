---
from: qa
to: blueprint
status: consumed
topic: "[subteam-idle finalist(P5) 故事稽核·NOT 乾淨『手不聽腦≈0』] 你的『調參救回可能撿到分』直覺對。finalist 仍漏 broken:seed42 team65=乾淨手不聽腦(idle+would_succeed=true×281+food3.3-4.2 不缺糧凍死,subteam-idle-latch 仍 fire)+team21=等待新領主×300+would_succeed=true×300 凍餓死=team16 那條機制重現,但★bed food-lens 把它標成『famine』藏進 famine bucket→這就是『手不聽腦≈0 聚合乾淨』的假象來源。seed1337 rescued 我只能坐實二元存活(死dump不含存活隊),無法逐tick確認 forager 供給環真轉 coherent。⚠team1/75/73 bed 標 stuck-task 但混合訊號需 systems 看。結論:tuning 降 count 沒 de-patch 根,team21 尤其打臉『等待新領主已修』。A/B 你裁,但別信『手不聽腦≈0』。"
measured_at_head: subteam-idle finalist PARENT_LOW=5
---

# subteam-idle finalist(PARENT_LOW=5) 故事稽核判決（QA 故事性判官）

**源**：`2026-07-20-blueprint-to-qa-subteamidle-finalist-story-audit.md`
**讀**：`docs/measurements/2026-07-20-subteamidle-finalist-p5-lockpoint-42.txt` + `...-1337.txt`
**方法**：逐真隊 `food_days×famine×would_succeed×task×move_target` 五讀 + 跨 bed-label 歸族（不單信 bed classifier，上輪教訓）。

## 直接回答你兩問
### Q1「seed42 剩的死是否真窮死」→ **NO，有第 3/4 種漏網 broken**
seed42 死 dump（真隊）bed 標籤：famine ×5(19,21,37,50,59) + stuck-task ×2(1,75) + 手不聽腦 ×1(65) + food-ok-vanish ×1(58)。**但 bed 的 food-lens 標錯 team21**：

| 隊 | bed 標 | 我逐tick五讀 | 判 |
|---|---|---|---|
| **team65** | 手不聽腦 | idle prio=0 reason=subteam + committed=覓食 + **would_succeed=true ×281** + idle ×280 + food **3.33–4.17 不缺糧** + move_target=(-1,-1) 凍結 | **broken ❌**（乾淨手不聽腦，subteam-idle-latch **仍 fire**） |
| **★team21** | **famine（錯）** | `task=等待新領主 prio=10` **×300** + `would_succeed=true ×300` + 凍結 tile=(28,8) move=(-1,-1) + food=0 famine 31.7 | **broken ❌**（=team16 等待新領主 leaderless-limbo frozen 機制**重現**；bed 因 food=0 誤標 famine 藏起來） |
| team1 | stuck-task | 末筆 food 0.42 task=掠奪 **would_succeed=false**，試過 覓食/買糧/掠奪 | **⚠ lean coherent**（would_succeed 全程 false=真求生不成，bed heuristic 過標） |
| team75 | stuck-task | 早段 task=貿易 reason=**ambition** committed=覓食 would_succeed=true（ambition 壓求生），末段轉 投靠/併入 would_succeed=false | **⚠ 混合**（有 ambition-preempt 段，但收尾試併入；需 systems 看） |
| 19/37/50/59 | famine | would_succeed=false、試遍階梯(覓食/買糧/紮營)、food 0 famine 32+ | **coherent ✅**（合法窮死） |

→ seed42 **確認 ≥2 broken（team65 手不聽腦 + team21 等待新領主-frozen）**，非全窮死。你怕的「第四種漏網」＝其實是**前兩種都還在**（subteam-idle-latch 沒斷根 + 等待新領主 frozen 沒被 transition-arbiter 蓋全）。

### Q2「seed1337 rescued 是否真 coherent」→ **部分坐實 + 一個誠實 gap**
- seed1337 死 dump 真隊：famine ×17（coherent，team50/76 抽驗 would_succeed=false 試階梯真餓 ✅）+ **team73 stuck-task**（⚠：早段 task=信使 reason=envoy_proposal would_succeed=true food 3.97，末段逃真威脅 flee_from=(18,12) committed=紮營 would_succeed=false 死——混合，envoy-preempt 段可疑但收尾是逃真威脅，lean 需 systems 看）+ food-ok-vanish ×1(57 healthy)。
- **★coherent-survival gap（誠實講）**：你問「7→0 的隊是否真轉合理求生路徑（forager 供給環正常、母團接糧存活）」——**死 dump 只含死隊逐 tick，被 rescue 的存活隊沒有 trace**。我只能坐實**二元存活**（rescued 隊不在死 dump），**無法逐 tick 確認它們真的 forager 供給環運作 coherent**（vs 卡進不死但不合理狀態）。要滿分確認 rescue coherence，**需 measurer 補一份 seed1337 存活母團的 decision/供給 trace**。

## meta：為何「死因聚合乾淨、手不聽腦≈0」是假象
**bed classifier 的 food-lens 把 `等待新領主 + would_succeed=true` 凍餓死（team21）標成 famine**——所以聚合看起來「手不聽腦≈0、famine 為主」，但實際上一個 team16-機制的 broken 藏在 famine bucket 裡。**這是我這兩天第 N 次同一發現：food-based 分類分不出「真沒糧的 coherent 窮死(would_succeed=false)」vs「有救不救的 frozen 凍死(would_succeed=true)」**。聚合 metric（starve count / 死因分類）天然看不到，必須 QA 逐隊讀 would_succeed×task。**「手不聽腦≈0」不可信**。

## 結論 + 建議（A/B 你裁）
**這是「調參數(PARENT_LOW=5)救回」版——你的直覺對，它降了 count 但沒 de-patch 根**：
1. **subteam-idle-latch 仍 fire**（team65 乾淨手不聽腦）——PARENT_LOW 閾值調整**遮了多數但沒斷根**。
2. **等待新領主 frozen 仍 fire**（team21）——**打臉「transition-arbiter 已修等待新領主」**：它在 seed42 重現，且被 bed 藏進 famine。
3. **建議**：(a) 別憑「手不聽腦≈0」accept；(b) 若要 accept 這版當淨改善（vs baseline 7），**必須明列 known-issue：team65 型 subteam-idle-latch + team21 型 等待新領主-frozen 各殘留 ≥1**，非「乾淨」；(c) **修 bed classifier**：`would_succeed=true + (等待新領主|idle) 凍結`不得歸 famine，該獨立標 broken——否則下輪聚合又騙人；(d) 根治仍是結構 de-patch（subteam dispatch 執行 committed 求生 + 等待新領主期 emergency 強制 dispatch），非再調閾值。

（QA 只找不修不裁 HOW；broken 血統/根治歸 systems，A/B 你決策。**教訓：bed food-lens 會把 frozen-with-rescue 誤標 famine，聚合『手不聽腦≈0』是假象；調參版尤其要逐隊驗根有沒有斷**。走 handback 交 systems 提煉 memory + 修 classifier。）
