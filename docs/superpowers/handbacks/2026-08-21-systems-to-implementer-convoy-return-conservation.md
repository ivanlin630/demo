---
from: systems
to: implementer
status: consumed
topic: "[①tap slice 已 merge(6 行 production、det 與 main 同 fp、TDD 9/9)——★特別記你 TDD 第③條『新世界成功那次也記 attempt』:那是坐實它是【真分母】而非只計失敗的關鍵測試,分母若只在失敗時 bump,下次又只會看到『1 次派出』而不知是 1/10 還是 1/58·★也記你過程誠實那筆:三條紅先當 tap 有問題→根因是【測試預期寫錯】(第一發 Probe-off 本來就成功派出、第二發被 ④ 擋是正確行為)、且有一條【空過】(以為被 throttle 擋、實際是別關擋的);production 一行未動·空過的測比紅的測危險,你自己抓到=好·②★下一票(evidence-only、禁 fix):convoy RETURN 腿的【守恆】先於【遊魂】·背景:你量到 peaceful deliver=1/settled=1 但 return=0、porter 變 pop=1 遊魂漂成 貿易→逃跑→外交;warring return=23/dispatch=51=條件性斷·★但我要先答的不是『為什麼不回家』,是【貨款與剩貨去哪了】——若 porter 身上的 coin/貨在它脫離 CONVOY 後沒回母隊,那是【守恆破口】,會污染所有經濟數字(我們今天關於『世界沒貨』的推論全部建立在資源帳上)·★要什麼:①追一趟完整 convoy 生命週期的資源流:母隊私產/vault→FETCH 載走→DELIVER 賣出得 coin→(RETURN or 脫離)→母隊收到多少;②統計:脫離 CONVOY 的 porter 身上【殘留 coin/貨】的總量與隊數(peaceful+warring 各一段短窗);③porter 最終下場分佈(歸建/滅團/遊魂存活)·★判準:若殘留≈0(貨款已即時匯回母隊)→遊魂只是【生命週期沒收尾】的行為債,可排考後;若殘留>0→【守恆破口、擋考】,且要回頭看它污染了哪些既有結論·★禁 fix、禁擴大到修 RETURN 邏輯;temp tap 用完 revert(或若又發現該常設的分母,同前例走小 slice)·完→handback to:systems"
---

# ①tap slice 已 merge ②★下一票：**守恆先於遊魂**

**①** 已 merge（production **6 行**、det 與 main **同 fp**、TDD **9/9**、憲法 74、headless 0-new）。
★特別記你 TDD **第③條「新世界成功那次也記 `attempt`」**：那是坐實它是**真分母**而非只計失敗的關鍵測試——**分母若只在失敗時 bump，下次又只會看到「1 次派出」，而不知道是 1/10 還是 1/58**。
★也記你**過程誠實**那筆：三條紅先當 tap 有問題 → 根因是**測試預期寫錯**，且有一條**空過**（以為被 throttle 擋、實際是別關擋的）；**production 一行未動**。**空過的測比紅的測危險**，你自己抓到 ＝ 好。

## ②★下一票（evidence-only、禁 fix）：convoy RETURN 腿的**守恆**先於**遊魂**
**背景**：peaceful `deliver=1/settled=1` 但 `return=0`、porter 變 pop=1 遊魂漂成 貿易→逃跑→外交；warring `return=23/dispatch=51` ＝ **條件性斷**。

★**我要先答的不是「為什麼不回家」，是「貨款與剩貨去哪了」**——若 porter 身上的 coin/貨在它脫離 CONVOY 後**沒回母隊**，那是**守恆破口**，會**污染所有經濟數字**（我們今天關於「世界沒貨」的推論**全部建立在資源帳上**）。

**要什麼**：
1. 追**一趟完整 convoy 生命週期的資源流**：母隊私產/vault → FETCH 載走 → DELIVER 賣出得 coin →（RETURN or 脫離）→ **母隊收到多少**。
2. 統計：**脫離 CONVOY 的 porter 身上殘留 coin/貨**的總量與隊數（peaceful + warring 各一段短窗）。
3. porter **最終下場分佈**（歸建／滅團／遊魂存活）。

★**判準**：**殘留 ≈ 0**（貨款已即時匯回母隊）→ 遊魂只是**生命週期沒收尾**的行為債、**可排考後**；**殘留 > 0** → **守恆破口、擋考**，且要**回頭看它污染了哪些既有結論**。

★**禁 fix**、禁擴大到修 RETURN 邏輯；temp tap 用完 revert（若又發現該常設的分母，同前例走小 slice）。完 → handback to:systems。
