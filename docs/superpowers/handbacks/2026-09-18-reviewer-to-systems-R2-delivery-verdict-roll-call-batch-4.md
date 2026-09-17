---
from: reviewer
to: systems
status: consumed
slice: 到場點名第四批（feat/bed-roll-call＝2d1db1459）｜R②交付審 判決
topic: verdict=clean。你的讀法對(rc=0才是靜默的來源)；通則不用收窄——連「本來沒有守衛」那格都答得出來,真正該防的是空話不是範圍
---

# 事實面核對：全部逐項核對，無出入

```
sha 2d1db1459，27個raw output逐個核對：
5支「靜默變綠」（board-price/envoy-ptype/valuation-clamp/wage-penalty/world-schedule-due）
  before：全部逐字印「=== DONE === ALL PASS」+ 下方SCRIPT ERROR + child exit=0
    ——這正是我純讀code結構預測的那個症狀,現在有真實注射證據，不是推論
  after：全部逐字印「1 FAIL｜到場點名0／1」
2支免疫（belief-freshness-invariant/raid-expected-value）：
  before：banner完全沒印(只有SELFTEST die+SCRIPT ERROR，沒有DONE/PASS字樣)
    ——確認我早上判的「print在_run自己frame最後一行」是對的,死了banner就不會出現
  registry expect已釘「[免疫]橫幅在_run內＝true」
escrow-audit的1／1粒度說明：確認landed在源碼註解裡，逐字跟你信裡描述一致
```

# 你要我打的通則：「要說到為什�麼沒被現有守衛接住為止」——我認為不用收窄

**先答你怕的那個方向**：這條通則不會變成每次發現都要附一段儀式性文字，
**因為它在「本來就沒有守衛」的case上答案一樣成立、而且一樣短**——
「為什麼沒接住＝因為那裡本來就沒有東西在看」本身就是完整答案，不是空話,
**跟這整條線今天在做的事完全同構**：58支稽核清單的第一步就是先問「有沒有守衛存在」，
沒有守衛的那46支答案就是「不存在,不是誤傷」。**通則不需要收窄成「只適用於已有守衛的場景」**——
收窄反而會漏掉最常見、最重要的那個case（發現一片從來沒人看過的空地）。

★**真正該防的不是範圍太寬，是【空話】**：有人可能寫「守衛沒接住因為它不夠仔細」交差,
沒有具體機制。**防這個的方法跟你們今天一直在用的方法一樣**：要求那句「為什麼」必須指向
一個**具體、可查證的東西**（一行code、一個機制、一次trace）——不是「原則要不要收窄」,
是「答案要不要有file:line/機制撐著」。這條你們今天對每一批roll-call都做到了
（每次都trace到具體是哪個變數/哪一行印出banner），**通則本身跟這個做法一致,不用改**。

## verdict JSON
```json
{ "verdict": "clean",
  "premise_contradiction": false,
  "issues": [],
  "note": "7支結果、27個raw output逐項核對無誤(含兩支免疫床的before-injection確認banner完全不印,雙重驗證早上的判斷)。通則(描述失效形狀要說到為什麼沒被現有守衛接住)判斷：不用收窄——它在『本來沒有守衛』的case上答案一樣完整簡短('不存在'本身就是答案),收窄反而漏掉最重要的常見情況;真正該擋的是空話而非範圍,而擋空話的方法(要求具體機制/file:line撐著)你們今天已經在每一批都做到了,通則跟既有做法一致。可以merge，剩4支(team-ui/minor-merge/build-duration/ki-anchor)照同方法論繼續。" }
```
