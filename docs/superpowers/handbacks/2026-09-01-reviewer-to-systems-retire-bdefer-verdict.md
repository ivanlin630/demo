---
from: reviewer
to: systems
status: open
slice: retire-dead-bdefer-rules
topic: R②判決:issues(小)——你的論證核對過regex,方向對(第二軸name-pattern會接住兩個名字都含TICKS),但推理≠量測,建議退場前先跑一次真陽性對照(暫時寫回裸值試跑,不是只信我推的regex)
---

# 判決：`issues`（小），`premise_contradiction: false`

## 你的論證——**核對過 `bare_tick_scanner.gd` 全文，方向對，理由比你講的更具體**
你說「裸值若再出現會落入 NEEDS_HUMAN」——我追了兩層機制確認：

1. **第一軸**（`_sym_re`，同行有 tick 符號）：`BASE_ACTION_TICKS = 10`／`TICKS_PER_TURN = 10` 這種**裸值回歸**（沒有 `TICKS_PER_HOUR` 之類的引用），第一軸抓不到——沒有 `current_tick`／`*_next_tick`／`TICKS_PER_[A-Z_]+`／`elapsed_ticks` 這些符號出現在同一行（`\btick\b` 是小寫、大小寫敏感，`TICKS` 這個全大寫子字串不會命中它）。
2. ★★**第二軸**（`_name_re`，:39-47，「名字像時長+值是裸整數」）——**這才是真正接住這次退場的東西**：`BASE_ACTION_TICKS` 跟 `TICKS_PER_TURN` **兩個名字裡都含有 "TICKS"**，落在 `_name_re` 的 `(TTL|TIMEOUT|...|TICKS)` 分支裡——★**若裸值回歸的寫法是簡單的 `const NAME: int = <整數>$`，這條會命中，候選會被產生出來，不會被漏看。**

★**你的論證站得住，而且比你自己講的更具體**——你只講了「裸值若再出現會落入NEEDS_HUMAN」的結論，我補上了「是靠哪一條軸接住」的機制細節，這樣下次要驗算它有沒有失效時，知道要看哪個 regex，不用重新推一次。

## ★但推理不等於量測——建議退場前跑一次真的陽性對照
我做的是**讀 regex、手動追蹤匹配**——這比純粹「感覺應該可以」硬，但仍然是推理，不是你今天一整天在教我們的「跑出來看」。★**建議（便宜，五分鐘內做完）**：
```
1. 暫時把 encounter_system.gd:20 或 sim_bridge.gd:10 其中一顆改回裸值（本地、不 commit）
2. 重跑 scanner + triage
3. 確認它落在 NEEDS_HUMAN（不是被某個你沒注意到的既有規則意外接住,例如那些「太寬」你自己標過的規則,像 `[0-9]+\s*\*\s*TICKS_PER_` 那條 22 命中的）
4. 還原,不留痕跡（同「操作後 git status 確認乾淨」那條紀律）
```
**這樣「退場不會拆掉守衛」就從一個推理結論變成一個真的看過的事實，跟你自己在別票上堅持的標準一致——不用等我再審一輪，這步做完直接退場即可。**

## ③排程理由——認同
扣住到期閘不 merge、等退場票一起落地、兩張同時 merge 讓閘一開始就是綠的——這個排序判斷對，「merge 一個恆紅的 merge-gate等於沒有閘」的顧慮站得住。

## ④硬條款——都對，不用改

**premise_contradiction: false。核心論證我驗過是對的，只差『用工具真的看一次』這最後一步，補了就能退場。**
