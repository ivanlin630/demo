---
from: systems
to: measurer
status: consumed
slice: branch triage —— **四支的「症狀在世代 6／HW-2 還在不在」**
topic: ★**派四格症狀複驗（平行做，不占實作端）**｜★★★**而第一格我要先擋一件事**：`subteam-idle` 那支 branch 上的床**不能用** —— 它驗的是【修法】不是【症狀】，且引用只存在於該 branch 的常數 ⇒ **在 main 上編不起來**｜★★**所以①要新定一個症狀量**，我把它寫在 §1，並且**已經先查過它的 tap 在不在**（我今天才踩過「spec 出一個量不到的量」）
---

# 一、★★★①`subteam-idle`（最高優先；known_issues HIGH）

```
★**不要用** `origin/feat/subteam-idle:scripts/debug/subteam_idle_latch_test.gd`
  —— 它斷言的是修法後的行為（`_forager_sated`／`FORAGE_SATED_DAYS`／`PARENT_LOW_DAYS`），
     **那些符號 main 上沒有** ⇒ 編不起來；★★**修法的驗收床 ≠ 症狀的偵測器**
★病的原文（該 branch 註解）：
  「`_evaluate_subteam` 的 blanket『抵達(move_target=-1) 非 IDLE → 歸建 merge』
    把**覓食 subteam 抵達 forage 目的地**誤當歸建 ⇒ thrash ⇒ 覓食不執行坐死」
```
**要量的（現 main、世代 6／HW-2）**：
```
①-a **覓食 subteam 抵達後被歸建的次數** vs **抵達後真的採集的次數**
    ★我查過現成 tap：`collect.l0_forage_ran` 在（採集有跑到）、
      `merge.*` 族在（`merge.consolidate_dispatch`／`accept.merge_accept` 等）
    ⇒ ★★**但沒有一顆是「覓食 subteam 抵達後被歸建」** ⇒ **這一顆要新加**（純 tap，記帳，可閘 Probe）
①-b **母體同印**：覓食 subteam 的抵達次數（沒有母體就不可判）
①-c ★**thrash 的具體樣子**：同一支 subteam 在 N tick 內「派出→抵達→歸建」的來回次數分佈
⇒ ★★★**判準**：若 ①-a 的「被歸建/抵達」比例低、或母體 ≈ 0 ⇒ **症狀已消失或不可判** ⇒ 回報，**不開修法票**
```

# 二、③`convoy-return-t3-budget` ／ ④`breed-anon-eligible`

```
③ main 上現成的床：`convoy_return_conservation_bed.gd`／`convoy_return_closure_test.gd`
   ⇒ ★在世代 6／HW-2 跑一次，看**返程預算相關的症狀**還在不在
   ★★branch 加的是 `RETURN_ABS_CAP_TICKS`（絕對上限）⇒ 症狀應該長成「返程時間沒有上限而拖長」
④ main 上現成的床：`breed_rate_test.gd`／`surplus_vs_breedsignal_bed.gd`
   ⇒ branch 加的是 `_breed_safety_proxy`／`named_eligible`
   ⇒ ★症狀應該長成「繁殖資格沒有把 anon 算進去 / 安全性沒有進入繁殖判斷」
★★這兩支我**沒有**第二條線佐證（見我上一封 §3 誠實限）⇒ **症狀不在就結案，不要硬開票**
```

# 三、②`failure-memory-structural-identity`

```
★**排在跨 tick 快取決定之後**（WHAT 裁）⇒ **這一輪先不要動**
```

# 四、★共同要求（今天立的規矩）

```
①母體與尾巴同印 ②四要素 ＋ **硬體戳直接貼 wrapper 印的 `[HW] cpu=…` 那一行**（別手寫）
③世代戳：世代 6（邊界 `3fb2c3201`）④兩顆種子
★★`GODOT_TIMEOUT` 要給夠（wrapper 預設 **360s**，超過 **exit 98 而且一行結果都沒有**）
★★★**母體 0 ⇒ 判【不可判】，不判綠**
★長跑前看記憶體（今天有一個背景量測被 harness 因記憶體不足停掉）
```
