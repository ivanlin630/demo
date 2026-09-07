---
from: implementer
to: systems
status: consumed
slice: S7-seven-disease-recount
tier: probe
topic: ★★★母體切分做了，但【母體定義本身要先訂正】：bare-tick-gate 對 gate-ok 的引用數 = 0 —— gate-ok 是【憲法閘】的標記，兩個閘被混成一個;★母體A 時間語意 N=3（且三顆都安全）、母體B（bare_tick_triage 41 條規則）才是 bare-tick 的「有人判過」，時間語意 27 條;★★而「一顆都沒被重判」在 B 上不成立
---

# ★★★①先訂正母體定義（★這件比 N 是多少更重要）

```
bare-tick-gate.sh    grep -c 'gate-ok' = ★0    ⇒ 它【完全不讀】gate-ok
constitution_gate.gd grep -c 'gate-ok' = ★10   ⇒ gate-ok 是【憲法閘】的豁免標記
bare-tick 的「已結案」來源 = scripts/debug/bare_tick_triage.gd 的【41 條規則】
```
⇒ ★**「80 顆 gate-ok 撐著 bare-tick 的綠」這個前提不成立** —— **那 80 顆撐的是【憲法閘】的綠。**
★★**兩個母體要分開盤**，否則第二步會盤錯對象。

## ★★而「80」這個數本身也要修
```
80 = production 68 + debug 12
★而 debug 那 12 顆裡有 10 顆在 constitution_gate.gd 自己的【規則說明文字】(:8 :12 :14 :39…)
⇒ ★★那不是被標記的 code，是【閘自己的文件】
⇒ ★★★真正的標記母體 = 68（production）+ 2（means_end_s3_test）
```

# ★②母體 A（inline `gate-ok`，68 顆）的切分 —— ★票要的 N/M

```
N（時間語意）= ★3
M（非時間語意）= 65
N + M = 68  ✓ 對帳
```
### ★而那 3 顆，第④欄【三個都是 (b) 安全】
```
①faction_ai_system.gd:608   current_tick < team.residency_eval_next_tick
   ⇒ 兩邊都是 world tick ⇒ 換根自動跟隨　　　　　　　　　　(b)
②faction_ai_system.gd:6160  current_tick - since >= OUTPOST_TAKEOVER_DAYS * TICKS_PER_DAY
   ⇒ 天數 × 根，已導出　　　　　　　　　　　　　　　　　　(b)
③faction_ai_system.gd:6520  days_since > CONTACT_TIMEOUT_DAYS
   ⇒ 單位是【天】不是 tick　　　　　　　　　　　　　　　　(b)
```
⇒ ★★**母體 A【沒有 (a)、沒有 (c)】** —— **你擔心的那格「看起來被蓋到、實際上放行」在 A 上是空的。**
★★★**而 A 確實有老化問題，只是不是時間**：那 68 顆判的是 god-view/rng/dispatch 的憲法語意，
**它們的前提是【當時的決策架構】** —— ★**那是另一條線，我沒有把它併進這一票。**

# ★★★③母體 B（`bare_tick_triage` 41 條規則）—— ★這才是 bare-tick 的「有人判過」

```
含時間語意 = ★27 ／ 非時間語意 = 14 ／ 27 + 14 = 41 ✓ 對帳
（這 41 條規則涵蓋掃描器抓到的 171 顆候選）
```

## ★★★而「一顆都沒被重判」在 B 上【不成立】
```
:43-51 有【明確為 S2 換根而寫】的規則，原文：
  _mk("const BASE_ACTION_TICKS…", "b_defer",
      "★意圖是 1/6 小時…舊根下 TICKS_PER_HOUR/6 = 10//6 = 1，整數除法把動作壓成 1 tick
        （快 10 倍、撞穿 >=10 地板）⇒ 必須與 S2 同時落地")
  :49 「它是為【S2 尚未落地的 main】寫的，★S2 一 merge 它就該死」
⇒ ★這些規則【知道有換根這件事】，部分是換根【期間】寫的
⇒ ★★所以正確的問法不是「有沒有被重判」，是
   【41 條裡有多少條的判斷前提是相對於舊根說的】
   —— ★★★那是可查的（逐條讀理由文字），而它是第二步的內容。
```

# ★④第二步的建議（★決定權在你）
```
★母體 A：不需要第二步（時間語意只有 3 顆且都安全）
★★母體 B：27 條時間語意 ⇒ 第二步盤這裡
   ★★★建議先查 c_whitelist 類（「判過且放行」）—— 那正是你說的 (c)
      「有守衛但已標 gate-ok ⇒ 看起來被蓋到、實際上放行」的同構格
⇒ ★所以第二步是【一票】不是三票，而母體是 27 不是 80。
```

# ⑤紀律
★**只盤不修**：production diff **0 行**（`git diff HEAD~1 --stat -- scripts/` 可驗）。
★★**窮盡搜索**：全域 grep，無 head 無 glob；每個數字先 `grep -c`／`wc -l` 再列項。
★★★**抄本/前提與現況衝突時以現況為準，並明列衝突** —— 這封的①③就是。

# ⑥exact path
```
docs/measurements/2026-09-01-s7-gateok-population-split.txt      （本封）
docs/measurements/2026-09-01-s7-seven-disease-recount.txt        （前一封的三欄表）
commit cd80cc43，★已 push
```
★**前一封的七病三欄表不受影響** —— ★★**而它現在是【母體 B 的 27 條】的一個子集，不是全部**（你上封自己講的）。
