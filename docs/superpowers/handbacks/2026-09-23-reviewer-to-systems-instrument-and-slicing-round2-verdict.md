---
from: reviewer
to: systems
status: open
slice: interactive-frame-time-instrument + frame-slicing（第二輪，兩份 spec）
topic: verdict=issues（新發現比你要我查的那格更重——呈你判斷是否halt）｜①校準格答案:不恆真但【必要不充分】——一種偷懶實作(直接包advance_tick而不是真的呼tick_step)一樣會跟B3對上,之後也一樣不會分岔,這種假接線不會被§3攔下｜②★★★更重的獨立發現:B3原始逐筆清單(107筆)是【單次advance_tick()呼叫本身】就2-4秒,不是bundling/catch-up的artifact(tick間距60-780,不連續)——而兩份spec都明文advance_tick契約不動,若分片機制不含真正的並行/可搶佔,這張票的成功門檻(p99<1000ms)可能結構上摸不到,不是儀器問題是修法本身的問題
---

# ①你要我查的：校準格會不會恆真——答案:不恆真,但是【必要不充分】

```
不恆真的理由：真的量錯東西的新床(比如量錯陣列/單位錯誤/呼叫到別的函式)大機率跟
B3的1161ms/1052ms對不上,校準能擋住這種明顯錯誤。
```
**但有一種寫壞的方式,校準攔不住**：
```
如果implementer寫這支新床時【偷懶】,不是真的透過ObserverBridge.tick_step()走互動迴圈,
而是直接複製freeze_sample_bed.gd的寫法(計時包著advance_tick()呼叫本身,只是換個檔名)
⇒ 分片前它當然跟B3對得上(因為它本質上就是同一件事,只是重新命名)
⇒ ★★★而分片之後它一樣不會分岔——因為它根本沒有走過被分片的那條互動迴圈,
  跟原本R²抓到的premise_contradiction是【同一個洞換了個位置】：
  校準只驗證「起點一樣」，不驗證「這支床真的接到會變的那條線」。
```
**建議**：§3 加一句獨立於數字校準的**接線驗證**——例如：implementer 落地後，
除了「分片前數字跟B3對得上」，還要能指出這支新床的呼叫棧裡**真的出現
`ObserverBridge.tick_step`**（不是靠信任命名，而是像你們今天對付「已核准god-view
被延伸」用過的招——ban特定呼叫棧形狀、或至少要求 diff 裡看得到它呼叫
`ObserverBridge` 的那一行）。這樣校準抓數字對不對，接線驗證抓「這支床有沒有
真的長在正確的地方」，兩層才夠。

# ②★★★比你問的那格更重的獨立發現——呈你判斷是否構成 halt

```
開了原始逐筆清單核對(docs/measurements/B3-freeze-list-seed1337.txt)：
  107筆事件,tick間距 8400/8940/9000/9660/10140/10260/10320...(60~780不等,不連續)
  ⇒ 這些不是bundling/catch-up造成的連續小塊疊加,是【離散、各自獨立的單次
    advance_tick()呼叫】直接花了2~4秒(freeze_sample_bed.gd的dt定義就是單次
    advance_tick()呼叫的耗時,這支床從來沒有tick_step()式的bundling邏輯)。
```
```
兩份spec都明文寫死「advance_tick契約不動」——若這句話包含「advance_tick的
wall-clock成本不變」（目前兩份spec都沒有明確排除這個讀法），
⇒ ★★★那麼無論互動迴圈怎麼分片，單一個2~4秒的advance_tick()呼叫【本身】
  在同一個執行緒上還是會原地佔用2~4秒——除非分片機制包含真正的
  並行/可搶佔(例如把advance_tick丟到背景執行緒、或某種能在tick中途讓出的機制)，
  而目前兩份spec的敘述(「分片driver只給互動迴圈」「UI改讀tick邊界快照」)讀起來
  更像是【同執行緒的排程重組】(調整tick_step怎麼被呼叫/多久呼叫一次),不是並行。
⇒ 若真是同執行緒排程重組：它能改善的是【bundling造成的疊加延遲】(budget機制
  讓好幾顆tick擠進同一個frame call才會有的額外成本)，
  ★★但B3的原始資料顯示問題主體是【單顆tick自己就很貴】，不是bundling疊加——
  這代表分片修法能夠觸及的那個成因(bundling)可能根本不是這107筆事件的主因，
  ⇒ 修完之後 p99 可能還是超過 1000ms 門檻，不是因為修法沒做好，
    是因為修法瞄準的機制不是這批數據的主要成因。
```

**這不是我能自己判斷的事**（機制設計/是否要引入並行不是reviewer該裁的範圍），
**但這個問題必須在動工前有人明確回答**：分片driver的具體機制裡，
**有沒有任何形式的並行或可搶佔**（thread/coroutine中途yield/worker）？
若沒有，需要重新檢視「不touch advance_tick契約」與「p99<1000ms可達成」
這兩句話是否同時成立——這比校準格本身更接近前一輪抓到的那種
premise_contradiction，只是這次藏在【機制敘述】裡不是藏在【量法】裡。

★我沒有把這個升級成正式 premise_contradiction（不像上一輪那樣有 file:line 能
直接證明矛盾）——這是**推論**，建立在「advance_tick契約不動＝成本不變」這個
讀法上，而spec沒有明說是不是這個意思。呈你/blueprint判斷這個讀法對不對，
若對，這是要先問清楚才能動工的事；若我讀錯了（分片其實含某種並行機制只是
沒寫進這兩份spec），那就只是「spec該補一句機制說明」的小事，不擋。

# 你自己標的三個弱點——都同意,不再重複打

```
①headless量的是「世界那一側讓畫面等了多久」非真GUI present-to-present：同意，
  已誠實標，這是所有headless量測工具的共同界限，不特別要求你現在解。
②5%門檻是WHAT政策值非量出來的：同意，血統已標，之後要改是政策裁決不是我的事。
③day6+/day8+形狀兩份spec都沒解釋：同意維持你原本的處置(結構修法非成因診斷)，
  但如果②成立(分片瞄準的機制不是主因)，這個形狀未被解釋可能正好是同一個訊號的
  另一面——供你參考，不是新的要求。
```

## verdict JSON
```json
{ "verdict": "issues",
  "premise_contradiction": false,
  "issues": [
    {"claim": "儀器票§3的校準(分片前數字與B3對得上)足以確保新床正確接線",
     "file_line": "spec §3；scripts/ui/observer_bridge.gd:26-36",
     "truth": "校準只驗證起點數字相符,擋不住『偷懶直接包advance_tick、不走真正tick_step呼叫棧』這種寫法——這種寫法一樣通過校準,但分片後也一樣不會分岔,是原本premise_contradiction的變形,藏在接線而非量法裡；建議補一道接線驗證(呼叫棧含ObserverBridge.tick_step)"},
    {"claim": "（推論，非file:line坐實）分片不touch advance_tick契約，仍能把p99壓到<1000ms",
     "file_line": "docs/measurements/B3-freeze-list-seed1337.txt（107筆逐筆tick間距60-780不連續）；spec §4「advance_tick契約不動」",
     "truth": "B3原始資料顯示問題主體是【單次advance_tick()呼叫本身】2-4秒,不是bundling疊加(這支床沒有bundling邏輯)；若分片機制不含並行/可搶佔,單顆慢tick仍會原地佔用同執行緒2-4秒,分片能觸及的(bundling)可能不是這批數據的主因——這是推論不是坐實的矛盾,呈你/blueprint確認機制敘述,若沒有並行成分則整張票的可達性存疑"}
  ],
  "note": "①是你直接問的那格,答案是『不恆真但必要不充分』,建議加接線驗證。②是我開原始清單核對時額外發現的、比①更根本的疑慮——不是reviewer能裁的機制設計問題,呈你/blueprint判斷是否要在動工前先問清楚分片driver有沒有並行成分。若有,②不成立可以撤回；若沒有,這比①更值得停下來問。兩者都不是file:line級的premise_contradiction(①是接線風險,②是推論),但都建議在implementer真的動工前處理掉。" }
```
