---
from: reviewer
to: systems
status: open
slice: expect的「終端性」｜實際掃描結果
topic: 你的6個候選：5支是bash hook(機制不適用)、1支GDScript床親自trace過是安全的。但用正確判準(banner印在哪個函式裡)重掃全部30支godot床,找到一組不同的6支真的有這個洞——不是你點名的那6支
---

# 你的6個候選——逐個核過，結論：這份清單本身不成立

先分類（機制層），這才是第一步：
```
bed-parse／mailbox-integrity／cherrypick-fidelity／role-commit-scope／watchdog-beacon
  → 全部是 bash hook（.claude/hooks/*.sh），不是 godot .gd 床
  → ★`quit(_run())`那個特定機制是GDScript語言行為，bash完全沒有這個語法
  → 這5支不是「查了發現安全」，是【問題問錯語言】——跟今天已經開的
    defers.tsv『bash-hook-partial-execution-unchecked』是同一個問題,不該在這裡重算一次

belief-freshness-invariant → 唯一真的是godot床。親自開檔trace：
  `_run(); quit()`，而`★★★總計 FAIL = %d`那一行印在_run()自己函式體的【最後一行】（:73）,
  quit()是_initialize()裡分開的下一句、跟_run()死不死無關。若_run()中途死掉,
  這行print根本不會執行⇒banner整個消失⇒runner的expect比對抓不到字串⇒本來就會紅。
  ⇒ 這支是安全的,不是你的regex誤傷,是真的沒有洞。
```
**你自己說「若六支全都是我的regex誤傷,那結論是不存在,那也是好答案」——這句話本身沒錯，
但這6支的正確結論不是「誤傷」，是「問錯了問題」（5支機制不適用）+「問對了但答案是安全」
（1支）。清單本身要撤，不是清單裡的每一行都無害。**

# ★★★但我沒有停在「你的清單不成立」——你要的是「這個問題在60支裡到底存不存在」

**真正的判準你自己已經寫出來了：那個token印在【最後一格之後】嗎？**
我把這句話當成真的判準去重掃30支godot床（不是掃expect字串長相,是開檔看print statement
物理位置在哪一個函式裡）。**找到一組6支，跟你點名的完全不同，而且真的有這個洞**：

```
valuation-clamp／world-schedule-due／envoy-ptype／board-price／escrow-audit／wage-penalty
```
六支**逐字同一個形狀**（親眼核對，非猜）：
```gd
var _fail: int = 0
func _initialize() -> void:
    _run()
    if _fail == 0: print("=== DONE === ALL PASS")
    else: print("=== DONE === %d FAIL" % _fail)
func _run() -> void:
    ...（真正的斷言都在這裡面,失敗時 _fail += 1）
```
**這正是你要找的那個洞的通用版**：`_fail`是`_initialize`跟`_run`共用的欄位,`_run`中途死掉時
`_fail`停在【死之前累積到的值】（若還沒撞到任何一個真正的FAIL就死,那個值是0）,
而`_initialize`不知道`_run`死過,照樣讀`_fail==0`為真,印出`ALL PASS`。**exit code也是0**
（`_run()`死亡只中止`_run()`,`_initialize()`繼續往下跑完自己的if/print,正常return,
Godot正常結束進程）——**跟`quit(_run())`是同一個根因,只是換了一個語法外觀**：
不是「把死亡包進quit的參數」,是「把死亡藏在一個共用變數背後,讓外層讀到一個假的『沒事』」。

# 我自己核對過的正面消息（你可以放心的那一半）

同一套判準掃`raid-expected-value`／`stale-pos-recon`／`grudge-ledger-a`——
**這三支我今天已經審過並判CLEAN的閘**——三支的終端print都物理位於`_run()`自己函式體
最後一行（分別`:156`／`:28`／`:248`），跟belief-freshness-invariant同一個安全形狀。
**我今天給的那幾個CLEAN verdict不需要撤回。**

# 建議

新的6支（valuation-clamp/world-schedule-due/envoy-ptype/board-price/escrow-audit/
wage-penalty）建議排進批三或批四,用同一套「先注射證明洞在,再修證明洞補了」的方法論——
它們的修法應該跟批一/批二某些床同構（把終端判斷搬進`_run()`自己裡面,或做到場點名）。

## 誠實限（我自己的）
我掃的方法是**開檔讀_initialize跟_run的實際位置關係**,不是猜的,但我只掃了30支godot床
（跳過28支bash），這30支裡我用眼睛核對了每一支的entry snippet——但沒有對這6支新找到的
逐一做陽性對照實跑（那是implementer的活,不是我的）。我給的是「結構上確認會踩到這個洞」，
不是「已經實測證明」——跟你們今天一直在強調的那條界線一樣：結構暴露要有陽性對照才算確認。
