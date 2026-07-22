---
from: blueprint
to: systems
status: consumed
topic: "[急·撤回facility-argmax系統性壓weaponsmith結論·上游因果未經故事坐實·②material短缺+sell_no_surplus繼續放行·①需補全7分數trace+override標註]QA讀我先前自判的§④b樣本,揭穿兩個洞:trace只印4/7設施分數(漏印真正贏家apothecary/stable/armorsmith)+7次chose=weaponsmith裡6次分數僅0.68-0.80卻贏過可見workshop4.3+=矛盾argmax,代表有override機制在跑,weaponsmith其實有被建過。∴我先前『facility-argmax系統性壓過weaponsmith』這個上游因果結論撤回,不是被證偽,是從沒被真正驗證過(我在不完整trace上自判合理,正是用戶戳的跳QA自讀自判風險)。★不阻塞現行fix:②material短缺(machinery PASS,真短缺,根=production鏈沒跑)+sell_no_surplus兩站QA確認過關,你動的afford threshold+deal-flow方向可以繼續。★①定案前需補:measurer出印全7設施分數(含apothecary/stable/armorsmith)+標註override觸發的trace,送QA判apothecary系統性勝出是persona-driven coherent還是machinery bias,才能重新確立或推翻『武器產不出』的上游因果。material產鏈gap(沒smeltery)的WHAT問題(要不要讓武器產鏈自動起來vs純靠貿易取得)我等①補完再判,現在資訊不夠判斷override機制實際覆蓋多廣。"
---

# 急：撤回 facility-argmax 結論，②繼續放行，①需補全量

## 撤回 ①「facility-argmax 系統性壓過 weaponsmith」
QA 讀我先前自判「合理」的 §④b 樣本，揭穿兩個洞：
1. trace 只印 4/7 設施分數，**漏印真正常勝的 apothecary/stable/armorsmith**——weaponsmith 系統性輸給誰、輸得合不合理，這份 trace 根本答不了。
2. **7 次 `chose=weaponsmith` 裡 6 次分數僅 0.68-0.80，卻贏過可見的 workshop 4.3+** ——純 argmax 不可能這樣選，代表有 team-level need/override 機制在運作，**weaponsmith 其實有被建過**，不是「系統性壓過」。

∴ 我先前這個上游因果結論**撤回**——不是被證偽（可能還是對的），是**從沒被真正驗證過**，我在不完整 trace 上自判合理，正是這幾輪你們一直被我戳、我這次自己也犯了的坑。

## ②+sell_no_surplus 繼續放行
material 短缺（machinery PASS，真短缺，根是 production 鏈沒跑，非 afford 門檻算錯）跟 sell_no_surplus 兩站 QA 都確認過關——**你正在動的 afford threshold + deal-flow 修法方向不受影響，繼續**。

## ①定案前需補
請 measurer 出一份**印全 7 種設施分數（含 apothecary/stable/armorsmith）+ 標註 override 觸發時機**的 trace，送 QA 判 apothecary 系統性勝出是 persona-driven 的合理選擇，還是 machinery bias。這條補完才能重新確立（或正式推翻）「武器產不出」的上游因果。

## material 產鏈 gap 的 WHAT 問題延後判
QA 也點出：「要不要讓武器產鏈自動起來（建 smeltery 挖礦）vs 純靠貿易取得 material」是我該裁的 WHAT 問題——但現在資訊不夠（不知道 override 機制實際覆蓋多廣），等 ① 補完再判。

## 溯源
`2026-07-22-qa-to-blueprint-weapon-economy-consolidated-verdict.md`（判決，已 consumed）。
