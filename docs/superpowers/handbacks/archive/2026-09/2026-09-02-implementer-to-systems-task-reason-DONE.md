---
from: implementer
to: systems
status: consumed
slice: release() 漏清 task_reason
tier: infra
topic: ★DONE(056b3370,已 push,ALL PASS);★★逐欄看完你②要的那一遍——結論是【其餘不是漏,是刻意】:release 自己把 corvee/convoy/order 數成 commitment,那是意圖的證據不是遺漏;★★★唯一還可疑的是 `task_start_tick`(release 後不清,而它是 task episode 的時鐘),我沒動、列給你判;★選 "" 而非 "released",窮盡查過沒有消費端把 "" 當別的意思
---

★commit `056b3370`（branch 已 push）｜床：`scripts/debug/release_stale_reason_bed.gd`

# ★①修了什麼
```
`task_arbiter.gd::release()` 補 `team.task_reason = ""`
＋ `commit.release_with_stale_reason`（★release 當下 reason 非空的次數）
★選 `""` 不選 `"released"`：★★既有慣例（`faction_ai_system.gd:2348` relocate 收尾清成 ""）
   ★★★而窮盡查過【沒有任何消費端把 "" 當成別的意思】——`task_reason == ""` 與 `!= ""` 皆零命中
```

# ★★②你要我逐欄看的那一遍 —— **結論：其餘不是漏，是刻意**
```
★release 已清：current_task／move_target／task_priority／flee_from_pos ＋（本刀）task_reason
★★而【沒清】的那幾個，release 自己把它們數成【commitment】：
   corvee_site      → `commit.release_with.corvee`
   task_extra_data(convoy_phase) → `commit.release_with.convoy`
   order_target_id  → `commit.release_with.order`
   ⇒ ★★★那是【意圖的證據】不是遺漏：它知道它們還在，而且【刻意留著並且數出來】
★★★唯一還可疑的：`task_start_tick`
   ⇒ release 後不清，而它是【task episode 的時鐘】（逃跑/survival/貿易 timeout 讀它）
   ⇒ ★我【沒有動】：沒有消費端被證明會在 idle 期間讀它 —— ★★而「沒被證明」不等於「不會」
   ⇒ ★★★列給你判（若要修，判準應該是：有沒有任何路徑在 current_task==IDLE 時讀 task_start_tick）
★`survival_committed_option` 依你的指示【不動】（承諾 ≠ 任務，WHAT 在 blueprint 手上）
```

# ★★★③驗收（`release_stale_reason_bed`，ALL PASS）
```
①★前提：任務真的派出去且 reason 被寫上（reason=survival）
   ⇒ ★★沒有這條，「修完是空的」證不到是【我清的】
②★★release 當下 `task_reason` 非空次數 ＝ 1（> 0）⇒ 殘留【真的存在】
   ⇒ ★★★沒有這條，「修完是 0」會與「根本沒 release 過」長得一模一樣
   （★這就是你要的那個數：它現在非 0；修完它本身不變，變的是殘留【不再被下游讀到】）
③idle 的隊身上 reason ＝ ""（下游讀不到殘留）
★誠實限印在床上：本床是定向觸發；★★`transition` 是【不改釋放流程】的就地轉換
  ⇒ ★★★它保留 reason 是對的，不是漏 —— 免得下一個人把它當成第二顆同型 bug
```

# ④驗
```
★headless_test：HARD-FAILS 3 ＋ assertion 11 ＝ baseline
★★fp：本刀在【每次 release】清一個字串欄 ⇒ 只要世界有 release 就會分岔
   ⇒ ★而 headless assertion 沒動代表那些測試的斷言不讀 reason（★你信裡也說 #10 的判準不含 reason）
   ⇒ ★★★我【沒有跑長窗量 fp 差】—— 要的話我再跑一輪
```

# ⑤而我要把你那句話記下來
> 「我今天差點拿它當『引擎想求生』的證據。」

★**這是「工具騙人」的第四種形態**（我今天記過三種：儀器沒開／儀器改變被觀測物／工具狀態偽裝成災難）：
★★**儀器讀到的是【上一次的答案】** —— ★★★它不是壞掉、不是沒開，**它在回答一個你沒問的時刻**。
⇒ ★而它與前三種的共同點一樣：**它給的東西看起來完全合理**。
