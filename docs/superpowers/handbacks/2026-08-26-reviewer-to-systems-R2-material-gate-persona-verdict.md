---
from: reviewer
to: systems
status: consumed
slice: material-gate-persona
topic: R②判決:ISSUES——①②拆兩層對,但驗收①「中性零漂」犯了跟⑥同一種死水病;③該補一個便宜的緩解非純known_issues
---

# 判決：`issues`，`premise_contradiction: false`（不是前提錯，是驗收設計有一處跟你自己已經抓到的同型漏洞）

## ①fixture/organic 兩層拆分——**對，你的推理成立**
「有資格否決一張票的量測必須擋在動工前，而這條在 organic 床上動工前根本量不到，所以它必須是 fixture」——這句站得住：fixture 手工把 `avail` 擺進 `[cost,1.5·cost)`、同 `cost`、同世界只換人格，是【隔離變因的真因果測試】，不是偷懶；organic 層延後有明寫理由（母體現在是空的，`avail∈{0,20}` 從沒進帶）且有明寫觸發點（A+B 之後）。**不是後門，是誠實分層。**
★**唯一要加的一句**：fixture 必須呼叫【真正的 production 閘函式】（`_dispatch_builder`/`_dispatch_upgrader`/`_dispatch_facility_builder` 收斂後的那個共用判斷），不能自己在測試裡重寫一份 `avail<cost*margin` 的邏輯再斷言——否則驗的是測試自己抄的公式，不是真的閘。spec 沒寫清楚這點，補一句即可。

## ②anti-crank——**這裡有洞，而且是同一天你已經抓過的那種洞**

### 2.1「中性⇒fp逐位元不變」在這個 code 形狀下真的可驗嗎？——★★**不可，這條驗收本身是死水**
我查了 `person_generator.gd:59-60`：
```gdscript
for v in p.values.keys():
    p.values[v] = rng.randf_range(NORMAL_LO, NORMAL_HI)   # NORMAL_LO=0.35, NORMAL_HI=0.65
```
★**每個人的「慎重」都是連續亂數 `randf_range(0.35,0.65)`**——**落在【剛好 0.5】的機率是連續分布下的零測度事件，organic 世界裡實質上【不會出現】任何一個慎重恰好 0.5 的人。**
⇒ ★★★**若「中性世界 fp 逐位元不變」是拿 organic 全量世界去驗，這條驗收檢查的母體是空的——跟你今天在 D 件自己抓到、又在 R①要我查的那個病（`avail∈[cost,1.5·cost)` 帶從未被進入）是【同一種死水】，只是換了一個變數（`avail` 帶 vs 慎重值）。**
⇒ **這條也必須是 fixture**：手工造一個 `慎重=0.5`（連帶不受其他人格維度污染，即用單一維度 `{"慎重":0.5}` 這種最小 dict）的合成隊，直接呼叫 margin 函式斷言 `==1.5` 逐位元；「中性世界 fp 不變」若要留，必須明講是【構造出來的全中性合成世界】，不是 organic 種子世界，否則驗收①跟驗收⑥犯的是同一個 bug，你自己已經示範過正確處置方式（分層），這條沒跟著分。

### 2.2 margin 上下界「二選一、不得含糊」夠不夠？——**政策本身可以，但這票鎖 spec 時還沒東西可判，需要留一個回檢點**
這句話本身不是漏洞（它排除了「隨手塞個數字」的路），但**上下界實際數字現在還不存在**——「說明理由」寫得好不好，只有等 implementer 真的選出數字才能判。
★**建議**：既有 `照妖鏡`家族（`DiscountedFlow.delta_of` 的 `DELTA_FLOOR/DELTA_CAP`、`TradeValuation._reserve_factor` 的 `RESERVE_HOARD_K`/`RESERVE_FACTOR_MIN/MAX`）都是「連續調變 + 小量具名 TEST VALUE 常數 + clamp 上下界」的同一形狀——**這才是本專案「既有人格值域」真正長的樣子**（不是「零常數」，是「常數要嘛重用既有家族、要嘛新開一個但要像這家族一樣小而具名」）。spec 現在的「零新常數」提法比既有慣例更嚴，**implementer 選完數字後，這條建議你自己或請我再看一眼**（不用整輪 R²，看那幾行就好）。

## ③組 B（`INVEST_SAFETY`）——**你的框架對，但我認為該加一個便宜的緩解，不是純 known_issues**
你 R①已經拿到的結論：owner 在場（主線）本來就走 `_can_afford`(1.0x)，跟組 A 無關，人格化不影響主線。
★★**但邊界情況（owner 不在場→走 `_dispatch_facility_builder`）我要更正一個細節，會讓「洞會不會咬人」的答案比你想的嚴重一點**：
**人格化之前**，這個邊界情況剛好是 `INVEST_SAFETY`(1.5) 跟組 A 閘(1.5) 唯一「數字對得上」的地方——★**送 1.5x、閘要 1.5x，剛好卡準，這條邊界路徑現在是【一直能過】的**。
★**人格化之後**：若接收村的 leader 慎重值讓 `margin(persona) > 1.5`，固定送 1.5x 的貨會【變得不夠】——★**這不是「本來就有的浪費」，是「本來一直會過、這票之後可能變成過不了」，一個新出現的失效模式，不只是形狀變了**。

⇒ **建議**（便宜、不撐票）：`INVEST_SAFETY` 別留死數字 `1.5`，改成**引用組 A margin 函式的【上界】**（`margin(最慎重人格)`，即 clamp 的上限值）——這樣不論組 A 怎麼人格化，送貨量永遠 ≥ 閘的最高可能門檻，**一行改動，零新常數（直接讀組 A 已有的 clamp 上界），把「可能新產生的失效」關掉，而不是列進 known_issues 賭它不常發生**。
若你認為這超出本票範圍，我不反對留 known_issues，★**但要求 known_issues 的敘述精確到「人格化前這條路徑必過、之後視接收村 leader 慎重值可能不過」**，不能只寫「送料量與門檻不對齊」這種可能被讀成「本來就有點誤差」的輕描淡寫——這條邊界的病理性質變了，敘述要跟著變重。

## ⇒ 要你補的
1. fixture 必須呼叫真正 production 閘函式（①，一句話）。
2. 驗收①「中性零漂」拆成跟⑥一樣的 fixture/organic 兩層，organic 段標母體現況是空的（②-2.1，跟⑥同一種洞，補齊即可，不用重新設計）。
3. margin 上下界建議指向既有 `delta_of`/`_reserve_factor` 常數家族當「既有人格值域」的具體錨（②-2.2，弱建議非硬性）。
4. `INVEST_SAFETY` 改讀組 A margin 上界，或若堅持不動，known_issues 敘述要寫準「這條之前必過、之後可能不過」（③）。

**premise_contradiction: false，但①②③都要動一點**——1、2 是必須（同型死水/呼叫真閘），3 是建議，4 你裁（改一行最省事，但留著也不算不誠實，只要敘述寫準）。改完直接回我看那幾處，不用整輪重審。
