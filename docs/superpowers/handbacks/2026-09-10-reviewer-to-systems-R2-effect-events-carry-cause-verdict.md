---
from: reviewer
to: systems
status: consumed
slice: 果事件帶因
topic: R² 判決 — 母體漏3個(同今天的病)；★★★兩個驗收樣本(求和/派工失敗)都不是這個機制能修的東西，查出真正的分歧點
---

# R² 判決：`2026-09-10-effect-events-carry-cause-HOW.md`

## 判決：非 CLEAN——你三題本身都對，但兩個盲區一查，發現整張票的兩個驗收樣本都要重新定位

## 先處理你三題

### item 1（防 spam：全印還是最大項）：建議【最大項 + 贏過第二名多少】，不是二選一

你自己點出的兩難是真的（全印變表格沒人看／只印一項丟掉「勢均力敵時什麼壓過什麼」）。
兩者都要的話：印【最大貢獻項的名字＋值】，加一句【贏第二名多少】——
「宣戰（野心 0.62，領先慎重 0.31）」，一行、有主詞、也保留了「差距大不大」這個信息，
不用列出全部五項。這個形狀比純 top-1 多一個數字，成本幾乎沒有增加。

### item 2（無因清單=做一半）：CLEAN，跟今天其他票同一個節奏——但要求它真的寄出去

「有因先接、無因列清單、下一張票再查」是今天處理「建設premise未到位」「四支床terrain」
這幾張票同一個節奏，判斷對，不算做一半。**唯一補的閘**（跟今天每一張票一樣）：
這份「無因清單」完稿後要真的寄一封 handback，不能只留在這張票的驗收段落裡。

### item 3（驗收⑤事件總數不變 → 逐 type 計數不變）：改，這是免費的加固

總數不變擋不住「刪一則、在別處加一則不相干的」這種淨零但成分變的情況；
逐 type 不變是嚴格更強的版本，而你已經在讀 `global_messages` 算總數了，
拆成 by-type 幾乎零額外成本。判：改。

## 現在說盲區——這才是這輪的重點

### 盲區①（TextBank 模板機制）：查完了，答案比你猜的更麻煩——不是「該塞模板還是串字串」二選一，是【每個 type 各自不同，要逐個對】

```
TextBank.TEMPLATES 裡有事件文本的 key：subjugate / battle / betrayal / faction_establish /
  diplomacy / tribute / outpost_built / order_delivered / famine_warning   ← 這 9 個有模板
combat_start（npc_combat_system.gd:124-126）：text 是【直接 % 格式化字面】，
  TextBank.TEMPLATES 裡【根本沒有 "combat_start" 這個 key】——只有 "battle"（另一個 type,結果訊息）
faction_defect / replace / split（events/*.gd）：同樣是直接字面,同樣沒進 TextBank
```

⇒ **加 `cause` 到 `params` 這件事,對走 TextBank 的 9 個型別要編輯模板字串(加 `{cause}` 佔位)，
對其餘型別（至少 combat_start/faction_defect/replace/split 我逐一查過是這樣，其他沒查的
建議同法比照）要直接改 call site 的那行 `%` 格式化字串——兩條路徑，不是一條。**
你 §4①的逐事件對帳表要多一欄：**這個 type 的文字走 TextBank 模板還是 call-site 字面**，
否則實作者會遇到「加了 cause 進 params，結果 TextBank 裡根本沒有這個 type 的 entry 可以改」
卡住不知道要編輯哪裡——這正是你自己怕的「加了但沒接電」，只是漏電點在【模板缺席】
而不是【模板存在但沒讀那個欄位】。

★★另外一個順手查到、TextBank 本身結構帶出的設計問題（供你判斷要不要處理）：
有模板的型別（如 diplomacy）分 `honest/unintentional/malicious/vague` 四個失真層——
這是給【傳播衰減】用的（遠方觀眾看到失真版）。**`cause` 這種結構化真因，
塞不塞進 `vague`／`malicious` 那幾層有語意衝突**：一則被扭曲成「附近有政治動作」的
模糊傳聞，不該同時附一句精確的「威脅 0.82」。**建議 `cause` 只進 `honest` 層**，
不要求你現在就決定，但這格必須在 spec 裡明講，不然實作者會照抄 honest 層的做法
塞進所有層，產生「假傳聞卻帶精確數字」的不一致。

### 盲區②（ticker/observer 渲染）：查完了——比你擔心的更嚴重，你的兩個驗收樣本查無此人

**「求和」**：全庫 grep「求和」——只在 decision_context/options/terms/failure_memory 出現
（它是決策層的 option 名稱），**沒有任何 `emit_message` 呼叫跟它關聯，一個都沒有**。
你 §4②把它定成「用戶親自抓到的那一則⇒拿它當這張票的驗收樣本」——但這個機制
（`emit_message` params 加 `cause`）**修不到它，因為它現在根本不走這條管道**。
用戶看到的「求和」文字，八成是 observer/text UI 直接顯示 `team.current_task` 之類的
狀態標籤，不是一則 ticker 訊息。**這格要先查用戶到底在哪個畫面看到「求和」三個字**，
不查清楚，這張票的頭號驗收樣本就是在修一個不存在的呼叫點。

**「派工失敗」**：`faction_ai_system.gd:4538 _log_dispatch_fail` 用的是**裸 `print()`**——
跟 `emit_message`/`TextBank`/`global_messages` 完全是不同管道（`grep -rln "global_messages|TextBank" scripts/ui/*.gd`
命中 5 個 UI 檔，`_log_dispatch_fail` 不在裡面任何一個的呼叫鏈上）。
你 §2②把它跟「求和」「宣戰」並列成同一個 `cause` 機制的三個例子——**但它不是**：
它的修法應該是**直接改 `_log_dispatch_fail:4624-4626` 那行 `%` 格式化字串**（加上
leader-在不在家那個事實），跟 `emit_message`/`cause`/`TextBank` 完全無關，
也不受你 §4④⑤（fingerprint／事件總數）兩格驗收約束，因為它根本不碰 `global_messages`。

**⇒ 這張票母體的三個代表案例（宣戰/求和/派工失敗）裡，只有「宣戰」真的走
`emit_message`。「求和」查無實據，「派工失敗」走的是完全不同的管道。**
不是說這兩個不能修——是**它們需要各自獨立的一句話 spec**（求和：先定位它到底在哪顯示；
派工失敗：直接改 `_log_dispatch_fail` 的字串，不套 `cause`/TextBank 機制），
不能被本票「加 cause 欄位」這個單一動作打包解決，套錯機制會查半天找不到掛勾點。

## 母體本身：漏了 3 個真實呼叫點，其中一個有現成的因

```
grep -rn "emit_message(" scripts/simulation/events/*.gd
  event_faction_defect.gd:51   "faction_defect"   params 只有 origin
  event_unrest_replace.gd:17   "replace"          params 只有 origin
  event_unrest_split.gd:26     "split"            params 只有 origin+x+y
```
你的「20 處」母體漏了整個 `scripts/simulation/events/` 目錄。跟今天稍早那次 radius 掃描
同一個病（母體排除了合法形狀，這次是排除了一整個目錄）。
**其中 `replace`（領袖替換）的因是現成的，而且比你已經寫的三個例子還便宜**：
```
event_unrest_replace.gd:7-14   team.unrest_turns（已跨門檻 UNREST_REPLACE_THRESHOLD=20）
                                dissenters（_get_dissenters 已算出、非空才會走到這行）
```
零額外讀取，直接可用——而「領袖突然被換」＋「隊伍突然分裂」這種戲劇性事件沒有因，
跟宣戰/求和一樣是「有戲卻看不懂為什麼」的候選,建議併入母體重新掃一次完整清單，
不只是把這 3 個加進去，是**重新確認 20→23（或更多）之後,原本『無因清單』的判斷還成不成立**。

## 其餘

誠實限（不改發生條件、不保證求和被認同）：沒有異議，這條在「求和」被重新定位之後依然成立。

CLEAN 差：①母體補齊 events/*.gd 三個且評估 replace 是否併入有因清單；
②「求和」先查它實際顯示位置再決定修法（可能不是 emit_message 問題）；
③「派工失敗」拆成獨立的 `_log_dispatch_fail` 直接編輯，不套 cause/TextBank 機制；
④對帳表加一欄「TextBank 模板 vs call-site 字面」；⑤cause 只進 honest 層記進 spec。
這些查完後預期本票範圍會縮小（少了求和、派工失敗兩個「不對版」的例子），
但「宣戰」＋新併入的「replace」應該足夠撐起這張票，不需要退回 blueprint 重新定義 WHAT——
這仍然是 HOW 層級的定位錯誤，你可以直接修正後再送一輪或視情況直接 dispatch 縮小後的範圍。
