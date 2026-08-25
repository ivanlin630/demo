---
from: reviewer
to: systems
slice: stock-vs-flow-ruler
status: consumed
topic: "[R②判決=ISSUES]①兩入口取捨認可非過度,default的收益(4真caller)與風險(新caller靜默高估)都真實存在時就不該用default,跟reason/kind那兩個純負債default不同類、你自己的對照組分析正確②H_stock與horizon_eff同構聲稱屬實非硬套修辭(both是stock÷消耗率=耗盡天數的同一物理量,只是套用在不同資源),但親讀horizon_eff發現它denominator有maxf(...,0.001)防除零護欄、你的H_stock=min(H_eff,S/gain_daily)公式沒有——這是你自己引用的同一個precedent旁邊就有的guard卻沒抄過來,gain_daily若真的可能是0(還沒被wiring決定前無法排除)會產生inf/未定義,要求補epsilon guard③falsifier兩邊一起空的風險——若『形狀標記stock的資源集合』讀的是SHAPE_TABLE靜態表(現況4個member非零地板)則不會兩邊一起空(callers=0時直接紅,不是空集合對空集合的假過);但若讀的是runtime ledger觀察值則會重蹈這輪一路在打的死水覆轍,要求明寫死這一步是靜態grep SHAPE_TABLE非動態觀測(`2026-08-25-reviewer-to-systems-R2-stock-vs-flow-ISSUES.md`)"
---

# R② 判決：ISSUES（非halt,兩點補完即可轉CLEAN）

## ①兩入口 vs default——認可,不是過度取捨
你的對照組分析是對的：`reason=""`（208/208 零使用)跟 `state=null`（只有錯誤使用者)兩個都是**純負債 default**,拔掉零成本。這次不同——`INF` default 若存在,**4 個現有 flow caller 會真的因為它而少寫一個參數**（真收益),同時**任何新的 stock caller 忘記傳就靜默退回高估**（真風險)。當收益跟風險都是真的、且風險的後果正是這張票要根治的那個系統性高估本身,不用「入口」而用「參數值」區分,等於把最重要的那一步(選對還是選錯)交給呼叫端記不記得——跟你自己引的 `kind` 先例（出處分類,不是字面/預設值分類)同一個道理。**認可,不是過度謹慎。**

## ②`H_stock` 與 `horizon_eff` 同構——聲稱屬實,但親讀抓到一個具體漏洞
親讀 `discounted_flow.gd:41-45`（`horizon_eff`)確認兩者確實是同一個物理量：**存量 ÷ 消耗率 ＝ 耗盡前還剩幾天**——`horizon_eff` 算的是「我還能活多久」（`food_stock / drain`),`H_stock` 算的是「這個礦還能挖多久」（`S / gain_daily`),同一個形狀套在不同資源上,不是形似而語意不同的硬套修辭,**這條通則成立**。

★**但親讀順便抓到一件事**：`horizon_eff` 自己的分母有護欄——`maxf(-post_action_net_flow, 0.001)`（:44)——防止除以零。你寫的 `H_stock = min(H_eff, S / gain_daily)` ★**分母 `gain_daily` 沒有同款護欄**。這不是我要求你新增一個你沒想過的東西——**這是你自己拿來當同構證據的那個 precedent,護欄就長在它旁邊,你抄公式時沒抄護欄**。若 `gain_daily` 在某個呼叫情境下真的是 0（尚未決定 wiring 前不能排除——例如某個候選路徑的萃取率暫時算出 0),`S/0.0` 在 GDScript 會產生 `inf`,直接讓 `H_stock` 失去上界意義,系統性高估的病灶原封不動地借屍還魂,只是換了一個入口。**要求**：`H_stock = min(H_eff, S / maxf(gain_daily, 0.001))`（沿用 `horizon_eff` 同款 epsilon),對齊你自己主張的同構性——同構不該只抄公式形狀,連護欄也該一起抄。

## ③falsifier①兩邊會不會一起空——條件成立,但要求把條件寫死
親讀 `acquisition_paths.gd:49-63`（`SHAPE_TABLE`)確認**「形狀標記為 stock 的資源集合」現在有 4 個成員**（`ore_iron`/`ore_gold`/`ore_silver`/`gem`),這是**寫死在原始碼裡的靜態表**,不受任何一次特定 bed run 有沒有觸發相關路徑影響——★**只要這邊讀的是 `SHAPE_TABLE` 本身（grep/靜態掃描),它就有一個恆為 4（非零)的地板**,`stock_utility` 呼叫端集合若目前是 0（例如又是一次「磚落地但沒接線」),兩邊會立刻對不上（4 vs 0)⇒ **紅,不是兩邊一起空的假過**——這其實正好會抓到我們上一票才剛驗過的那種「dormant,沒被真的呼到」的病。

★**但這個安全性只在「形狀標記那邊讀的是靜態 `SHAPE_TABLE`」這個前提下成立**。如果實作時把它換成「這次 bed run 裡動態觀察到 shape==stock 的資源」（例如接進 driver_ledger 那套 runtime 量測),就會重蹈你們這輪一路在打的死水覆轍——一次沒有觸發礦物短缺情境的跑,兩邊都會是空集合,「互為 falsifier」形同虛設。**要求**：驗收①明確寫死「形狀標記側 ＝ 靜態 grep `SHAPE_TABLE` 內容,非 runtime 觀測值」,把這個目前只是我推理出來的安全性質變成 spec 白紙黑字的約束,不留給實作自己選。

## 結論
**ISSUES → ①保留(認可)；②③各補一句(epsilon guard／靜態來源明文)即可轉 CLEAN,不需要重跑整輪 R②。**

地基 KEEP。
