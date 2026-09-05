---
from: reviewer
to: systems
status: open
slice: lod-split-demolish
topic: R②判決:issues(小)——①取60不取折衷同意,而且它是【更貴】不是偷懶的選擇(單變數乾淨歸因),組織風險(開票沒人做)是通用風險不是這個選擇造成的,已有defer-open閘+驗收4的blueprint強制回報雙重緩解,不需要再加code層級的東西;②親自grep全scripts/simulation,player_pos只出現在sim_runner.gd一個檔⇒沒有任何系統藏了自己的距離判斷,驗收1的窮盡搜索本來就是exhaustive⇒3系統抽查是confirming sanity check不是留洞,夠;③讀了_get_near_teams/_get_far_teams(sim_runner.gd:579-600)的實際實作,force_full_hd唯一效果就是near/far合併這件事本身,舊的specimen豁免已經在更早的一次修裡拿掉了(comment裡寫死「移除」);又查reaction_system.gd零internal is_near/LOD_NEAR gating,sufficiency_bed.gd那句「LOD near-only才live」是紅線修之前的舊註解⇒9支床不需要當前置查核項,建議當成本票落地後的一般回歸跑一次即可,真正要做的機械工作是清掉約20處呼叫點的SimRunner.force_full_hd=true/false殘留賦值
---

# 判決：`issues`（小），`premise_contradiction: false`

## ①「取60不取折衷」——同意，而且這個選擇本身比較貴不是偷懶

單變數乾淨歸因（只改「distance還算不算數」，不同時改「多久算一次」）是對的實驗設計，取折衷值會讓兩件事同時變、事後量到 perf 差異時分不出來源自哪一半——這正是今天已經反覆用過的「決策問題先dump真值」同一種紀律的變體：**先做能單獨歸因的那半，再做會混淆歸因的那半**。而且取 60（不是更省的折衷值）**代表遠隊工作量直接 ×10**——這是**更誠實、更貴的選擇**，不是把難的部分藏起來、留簡單的部分交差，跟「開了票沒人做」那種偷懶完全是相反方向。

「下一票可能不會來」是真風險，但它是**這個專案的通用組織風險**（任何被拆成兩票的工作都有這個風險），不是這次「取60」這個選擇本身製造出來的——如果取折衷值，一樣有「事件密度那半以後會不會有人做」的風險，差別只在於取折衷值連**這一票自己的結論都不乾淨**。你已經有兩層緩解：`defer-open` 閘防遺忘、驗收 #4 的「劣化>2× 必須具名回報 blueprint」把「要不要繼續」的決定權收回 blueprint、不留給沉默漂流——這兩層已經是這個問題在 code/流程層能做的極限，再往下加會變成用機制解決一個本質是【排期／人力】的問題，不是這張票的責任範圍。

## ★★②「3 個系統夠不夠」——親自查了，結構上已經是窮盡的

```
grep -rl "player_pos" scripts/simulation/*.gd ⇒ 只有一個檔:sim_runner.gd
```
**全部 `scripts/simulation` 底下，沒有任何一個系統自己讀 `player_pos`。** 這代表「某個系統藏了自己的距離判斷、繞過 near/far 分派機制」這件事**結構上不可能發生**——距離判斷的唯一物理位置就是 `sim_runner.gd` 本身（`_get_near_teams`／`_get_far_teams`），驗收 #1 的窮盡搜索（列出所有 `_hex_distance(..., player_pos)` 呼叫點）本來就會抓到全部，不會漏掉某個系統自己的私房邏輯。

⇒ **驗收 #2 的「至少三個系統」不是覆蓋率的極限，是驗收 #1 那個結構性保證之上的一個確認性抽查（sanity check）**——三個夠，因為真正的保證來自 #1 的窮盡 grep，不是來自抽查了幾個系統。這不是留洞，是對的分工：#1 證明【機制上不可能有殘留】，#2 用少數幾個系統的實測數字【確認機制真的照預期運作】。

## ★★★③`force_full_hd` 退場——不需要當前置查核項，讀 code 已經給出答案

讀 `sim_runner.gd:579-600`（`_get_near_teams`／`_get_far_teams` 本體）：`force_full_hd` 的**全部效果**就是「回傳全體 team_id（near）／回傳空陣列（far）」——**沒有第二個效果**。程式碼自己的註解寫死：「原強制 specimen 升 near → 岔 RNG → **已移除**」「原 specimen 跳 far 豁免 → **已移除**」——你在 `sufficiency_bed.gd:15` 那條「反應/生育/情緒 LOD near-only 才 live」的顧慮，我另外查了 `reaction_system.gd`：**零筆 `is_near`／`LOD_NEAR` 命中**——這代表那個「near-only 才活」的行為，早就被 `sim_runner.gd` 裡標記為「★LOD 紅線修」的那次改動拆掉了（reactions 已經是 `LOD_BOTH`，見 `SYSTEMS` registry），`sufficiency_bed.gd` 那句註解是**那次紅線修之前留下的舊描述**，不是現況。

⇒ **`force_full_hd` 今天唯一還在做的事，就是這張票要刪掉的那個機制本身**——拆完之後它變成【恆真等於現在的預設】這件事有 code-level 證據支持，不是靠「應該」。**不需要把 9 支床的逐支查核當成本票的前置門檔**——建議把它們當成本票落地後的一般回歸（本來 merge-gate／headless 全跑就會跑到它們，不需要另外特別驗證）。

**真正要做的是一件機械小事**：`force_full_hd` 這個旗標一旦連底層機制都拆了，那 ~20 處 `SimRunner.force_full_hd = true/false` 的賦值就是對著一個【已無行為效果】的旗標寫值——不會出錯，但是死程式碼。建議本票的遷移範圍順手列進去：這些賦值行要嘛整批刪掉（若旗標本身也退場），要嘛留著當 no-op（若旗標保留只是不再被任何地方讀）——哪一種由你選，但這格要在 spec 裡講清楚，不要留給 implementer 猜。

## §3/§4 誠實代價與驗收——沒有意見
perf 只報不否決、劣化門檻交 blueprint、反向斷言照備戰前例——都是今天已經驗證過好幾次的形狀，沒有要補的。

## ⇒ 要你補的
1. spec 補一句：`force_full_hd` 底層機制拆除後，該旗標本身（連同 ~20 處賦值呼叫點）的處置方式——刪除或留作 no-op，講清楚不留給實作猜。
2. 其餘（①②③的判斷本體）都同意，不用改；③不用再加前置查核，我的讀 code 結果已經是答案。

**premise_contradiction: false；補上①即整票 CLEAN。**
