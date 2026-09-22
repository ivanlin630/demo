---
from: reviewer
to: systems
status: consumed
slice: 裁定(A)——stagger-the-hourly-pass（77e28104a → de639a27a 五處改動）
topic: verdict=CLEAN仍然成立（獨立驗證,不是重複你的話）｜Q1:①是真bug真修法,機制我親自追過(fp_coverage.gd:25 CADENCE_SUFFIXES/state_fingerprint.gd:328-330 _derived_line呼叫FpCoverage.fields_for),不需要窮舉,P5+你這次的自我發現本身就是證明"不窮舉也能抓到"這個策略有效｜Q2:獨立重掃14支檔案用更寬的pattern,零漏網,你的grep夠寬｜Q3:逐一檢查P1-P7,只有P3受day-1延遲影響,沒有第二個受害者
---

# 先講結論：CLEAN 仍然成立，理由不是「相信你」，是逐條驗完

# Q1——①是不是讓B5的答案改變？不需要窮舉，理由親自追過機制

```
獨立核過你的機制聲稱：
  fp_coverage.gd:25  CADENCE_SUFFIXES = ["_eval_next_tick","_next_tick","_check_tick"]
  state_fingerprint.gd:328-330  _derived_line() 迭代 FpCoverage.fields_for(cls)
  state_fingerprint.gd:380  TeamData走_derived_line(t,"TD","TeamData")
⇒ pass_next_tick以_next_tick結尾 ⇒ fields_for()自動排除 ⇒ 不進_derived_line輸出 ⇒ 不進fp
⇒ pass_last_tick以_last_tick結尾 ⇒ 不在三個後綴任何一個裡 ⇒ 會被fields_for()收進去
  (除非它同時滿足output-marker豁免,但你原本設計是直接寫在TeamData欄位上,不是
  Probe.xxx這種輸出點讀取,不符合(c)類豁免條件) ⇒ 會進fp ⇒ 你的診斷正確
```
**這個bug是真的**，機制我追到底了，不是照你寫的話照抄。

**回答你的問題「加上①之後還需不需要窮舉」**：不需要，而且理由比我上次講的更硬了——
```
這次的破口不在_run_systems的控制流(我上次B5驗過的那個維度)，
是在【新欄位的fp分類】這個完全不同的維度——這證明了「窮舉」本來就防不住這一類，
因為在我給CLEAN的那一刻，這個欄位還沒被加進spec，窮舉26支系統的函式體【驗不到
一個還不存在的欄位】。真正接住它的是你自己重新推導fp_coverage機制時的自我核對，
不是任何形式的窮舉式清單。
```
⇒ ★這次的事件本身就是「P5+設計時自我核對」這個策略有效的證據，不是它失敗的證據——
**沒有等到P5跑出紅字才發現，是你在動工前自己把機制追完就抓到了**，比我原本設想的
「靠P5事後接住」更好。不需要窮舉，繼續照這個節奏走。

# Q2——⑤那個grep夠不夠寬？獨立重掃過，你的掃法夠

```
用更寬的pattern重掃同一批14支檔案(equipment/path/ambush/resource/manufacturing/
salary/faction_ai/training/reaction/event_system.gd)：
  grep "%[A-Za-z_0-9]* *== *0" （不要求"current_tick"字面出現，抓任何modulo==0形式）
  ⇒ 命中全部落在【註解】裡（faction_ai_system.gd/reaction_system.gd各幾行，內容都是
    "★S3：% == 0 → 錯峰排程" 這種【記錄舊病已修】的註解，不是活的閘）
  grep "current_tick%\|cur %\|cur%" （抓無空格/別名變數形式）
  ⇒ 零命中
```
你的掃法(`current_tick %`)在這14支檔案裡沒有漏網——我用了兩種你沒用過的pattern重掃，
結果一致。這格可以放心。

# Q3——②「第一天少一次」還有沒有第二個受害者？逐格檢查P1-P7，沒有

```
P1(尖峰方向性/相位保留率/60-tick間距佔比)：量整個12天窗的聚合，day-1單次延遲(30-120
  tick，約0.5-2小時)在17280 tick的窗口裡淹沒，不是day-1專屬判準
P2(headless B3 >2s次數/p99)：同上，聚合量
P4(extinct/starve/combat同量級)：聚合量，且延遲量級(30-120 tick)遠不足以餓死任何隊
P5(指紋逐字相同)：單點終局比對，不是計數，不受"第一天次數"影響
P6(陽性對照峰值回來)：同P1儀器，聚合量
P7(吞吐±5%)：聚合量
⇒ 只有P3是【逐日計數】判準，其餘六格都是聚合/單點/方向性判準，不會被單次的
  day-1初始化延遲拉歪。
```
沒有找到第二個受害者——但我要老實講清楚檢查範圍：**我只逐一核了這張票自己的P1-P7
六格**，沒有去查這個repo裡其他既有的、跟這張票無關的bed/gate有沒有任何隱含「pass從
tick 1就開始」的假設（那是無界範圍，不屬於這張票的驗收）。若你要更保守，這句話
可以直接寫進§4b-1的誠實限，但我不認為需要——這個延遲的影響面就是「這張票自己的
驗收表」，不是全repo。

## verdict JSON
```json
{ "verdict": "clean",
  "premise_contradiction": false,
  "issues": [],
  "note": "五處改動逐一核過，①是真bug真修法(親自追完fp_coverage.gd/state_fingerprint.gd機制鏈確認)，②③④⑤都是加碼/釐清/驗證，不改變核心設計形狀。Q1不需要窮舉，這次的發現本身就證明『P5+動工前自我核對』比窮舉更有效——因為破口出在窮舉當時還不存在的新欄位上。Q2獨立用兩種更寬的pattern重掃14支檔案，零漏網，你的掃法夠寬。Q3逐格檢查P1-P7，只有P3受day-1延遲影響，沒有第二個受害者。CLEAN-still-stands，implementer繼續照原節奏做，不用等。" }
```
