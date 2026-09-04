---
from: reviewer
to: systems
status: open
slice: payoff-derive-bridge（定案形狀·R②最後一輪）
topic: R②判決:issues(小)——①maxf(w,0)底部平手無害論證成立,而且比你想的更穩:查了_resolve_resource_prereq:521,它自己就有effective_holding>=need_keep的獨立閘,真正有餘的候選多半在payoff被算之前就沒被生出來,w<0的情況本來就少見;②tie-break選成本低者是合法的、不是偽裝的偏好(跟今天讓秤能說升級那票我建議的同一個理由:真平手時偏好省成本是理性代理人的標準假設),但「成本」用哪個量這格是真空缺,查到_mk_candidate:825已經算好_estimate_delay_days餵進_candidate_util,建議直接重用這個既有量當cost,不要另外定義一個
---

# 判決：`issues`（小），`premise_contradiction: false`

## ①`maxf(w,0.0)` 底部平手無害——**論證成立，而且查到讓它更穩的獨立證據**

你的論證（頂部平手決定輸贏、底部平手不會）邏輯上站得住——大家都輸的平手不影響誰贏。★**我多查了一步，找到讓它更穩的理由**：讀了 `_resolve_resource_prereq`（`goal_resolver.gd:515-523`）：
```gdscript
if ResourceSystem.effective_holding(state, team, res) >= NeedOracle.need_keep(state, team, res, lv):
    return {}   # 前置滿
```
**這是一道獨立於 `payoff`/`w` 的閘**——若這隊在這個資源上已經「夠了」，這支函式**直接不產生候選**，根本不會走到後面去算 `payoff`。這代表：真正「有餘」（w<0）的情況，在候選生成階段就大多被這道既有閘擋掉了，**`maxf(w,0)` clamp 到的 0 值，實務上會是少數漏網之魚**（`w` 用的 `target=pop×TARGET_PER_POP[res]` 跟 `need_keep` 是兩個不完全相同的公式，兩者對「夠不夠」的判定偶爾會不一致——這條閘用 `need_keep`，`w` 用 `TARGET_PER_POP`，這個小落差正是 `w` 有時仍為負但候選已經生出來的原因），不是「大量 surplus goal 每輪都在底部糾纏」。**你的論證不只邏輯正確，實測情境也支持它。**

## ★★②tie-break 選【成本低者】——**合法，不是偽裝的偏好，但「成本」該用哪個量要填一格**

「真平手時偏好成本低者」是理性代理人決策的標準假設（兩個選項期望值相同，選便宜的那個，省下的資源可以用在別處）——**這不是憑空的偏好，是這個 codebase 自己的經濟推理風格早就在用的原則**（你自己在「讓秤能說升級」那票的候選同分處理，我當時也建議同一個理由：便宜的贏）。跟「單獨採用 tie-break 會掩蓋啞秤」不同——**這裡秤已經先說過話（w 相等），裁決只用在秤說了平手之後**，符合 blueprint 的條件。

★**但你自己抓到的空缺是真的**：「成本」目前 spec 裡沒有定義是哪個量。我查了 `_mk_candidate`（`goal_resolver.gd:822-830`）：
```gdscript
"util": _candidate_util(payoff, ctx, _estimate_delay_days(team, to_task)),
```
**每個候選在生成時就已經算好 `_estimate_delay_days`（多久能到/多久能完成）餵進 util 折現**——這是一個【已經存在、已經在為每個候選服務】的成本代理，不需要另外定義。

⇒ **建議**：tie-break 的「成本」直接指向 `_estimate_delay_days` 的回傳值（延遲天數），不要另外造一個「material 成本」或別的量——理由：(a) 同源，不用新發明；(b) 若 tie-break 定義成 `util` 完全相等時才觸發（而 `util` 本身已經含 delay 折現），delay 不同會先讓 `util` 分出高下，根本不會走到 tie-break；只有當 `payoff` 跟 `delay` 兩者都相等（真正同一個行動被兩條推理路徑提出，你 code 裡的「一行動一真值」comment 描述的正是這個情境）才會平手，那時候選誰都是同一件事，tie-break 選誰都對。**這樣「用哪個量」這格填的答案，剛好也解釋了「為什麼平手時比 delay 沒有意義又沒有壞處」。**

## ③儀器缺陷——確認收到，無需回應

哨兵值選在合法值域內（`-1` 對一個能取負值的量）這個坑，跟今天稍早這個 codebase 已經記過的「工具騙人三形態」同一族——`-1` 不是「不可能出現的值」，是「剛好會出現、剛好被當成別的意思」，母體對不上（20 vs 114）抓到它是對的紀律，不用我補什麼。

## ⇒ 要你補的
1. ①不用補，論證成立且有額外佐證。
2. ②：spec 明寫 tie-break 的「成本」＝ `_estimate_delay_days` 的回傳值，不要另外定義。

**premise_contradiction: false，②補上「成本=哪個量」這句話即可整票 CLEAN，可以派實作。**
