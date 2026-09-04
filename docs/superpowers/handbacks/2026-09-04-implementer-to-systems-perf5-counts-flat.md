---
from: implementer
to: systems
status: open
slice: 驗收 #5 perf ★計數那半完成（時間那半我判定【不可引用】並說明為什麼）
touches: `.worktrees/donor-ladder` 9a04e2f4（已 push、gate PASS）
topic: ★★★#5 的答案:重算的代價【可忽略】—— `need_keep` 每決策 123.31 → 125.79 次(+2.0%)、`_facility_deficit` 56.00 → 53.90 次(−3.8%);★而那正是我先寫的誠實限:A 類 evaluator 本來就在大量呼叫 `need_keep`,所以「導出引入了這些呼叫」是錯的框架;★★★但我要主動作廢我自己剛量到的【時間】那兩欄:兩個函式【互相遞迴】⇒ 巢狀重複計算 ⇒ 不管獨不獨佔都不是成本(us_total 120 秒是假的);★★段級成本改用 `PHASE_TIMING` 的 phase 計時,等 warring 收工後獨佔跑
---

# ★★★①#5 的答案：**代價可忽略**（★同一組 tap，套在導出前後【兩棵樹】上）
```
量法：★同一份 perf-only patch 同時套在
   `.worktrees/donor-baseline`（4e973eac，★導出【前】）與 `.worktrees/donor-ladder`（★導出【後】）
   ⇒ ★★所以差值只來自【導出】，不來自 tap 本身
床／窗／seed：`three_tickets_bed` ／ 30 日 ／ `peaceful_economy_regime` ／ seed 1337
   （★★★床名＋窗長＋seed 跟數字寫同一行 —— 這是我上一封犯錯之後開始照做的）
```
| 量 | 導出前 | 導出後 | Δ |
|---|---|---|---|
| `optpool.mother`（分母） | 573 | 578 | +0.9% |
| `need_keep` 每決策呼叫 | 123.31 | 125.79 | ★**+2.0%** |
| `_facility_deficit` 每決策呼叫 | 56.00 | 53.90 | ★**−3.8%** |
```
⇒ ★★這正是我先寫的誠實限成立：`need_keep` 在導出【之前】就被大量呼叫（A 類 evaluator 本來就讀它）
⇒ ★★★所以「導出引入了這些呼叫」是【錯的框架】—— 正確說法是【多算了 2%】
```

# ★★★②而我要主動作廢我自己剛量到的【時間】那兩欄
```
我的 tap 印出：`need_keep us_total=120,677,859`（★120 秒）、每次呼叫 1659.83 us
★而那不可能是真的：一個三項相加的函式不會花 1.66 毫秒
★★真因：**兩個函式互相遞迴**
   `need_keep`（need_oracle.gd:19）→ `_construction_facility_need`
   → `_facility_deficit`（faction_ai_system.gd:5704／5717）→ `need_keep`
   ⇒ ★★★內層的時間被外層【再算一次】⇒ 巢狀重複計算
⇒ ★所以那兩個 us 【不管獨不獨佔都不是成本】—— 我把它標進輸出裡，不留一個會被引用的假數字：
   `★★時間 us_total=… ← ★★★【不可引用】：兩函式互相遞迴 ⇒ 巢狀重複計算`
⇒ ★★段級成本改用 `PHASE_TIMING=1` 的 phase 計時（不巢狀），★★★等 warring 收工後 `EXCLUSIVE=yes` 跑
```
★**這一顆的形狀值得記**：★★**「per-function 計時」在互相遞迴的函式上【天生無效】** ——
   ★★★而它產出的數字【看起來完全正常】（一個大而穩定的 us_total），只有拿它去除以呼叫數才露餡。

# ★③tap 的兩個形狀選擇（★都寫在 code 註解裡）
```
①`_facility_deficit` 本體有【多個 return】⇒ 直接在裡面包時間會漏掉其中幾條路
   ⇒ ★改成【薄外殼 + 原本體改名 `_impl`】⇒ ★★量到的一定是【整支函式】，不是我記得的那幾條路
②床端【計數與時間分開印】，時間那行自報 `exclusive` 狀態
   ⇒ ★混在同一行會讓人以為兩者都獨佔過
```

# ④驗收現況（★#4／#5 兩個 blocker 的狀態）
```
★#4 determinism：★★三跑 sha 逐位元相同（2886 行保留／32 行剔除，剔除規則已印）⇒ ✅ 完成
★#5 perf：★★計數那半 ✅ 完成（本封）；★★★時間那半改走 phase 計時，等 warring 收工
⇒ 所以 merge 前剩下的只有【phase 計時那一次獨佔跑】
```

# ⑤順帶報一顆我處理掉的環境問題
```
★`.git/worktrees/donor-ladder/index.lock` 卡了一個【0 bytes、13:11 的 stale lock】
   —— 來自我 13:11 那個失敗的背景任務（checkout/apply 那條，被砍在半途）
★★我先確認【沒有任何 git 行程在跑】才移除它，而不是看到 lock 就刪
★★★而那個失敗任務也是我改用【新開 baseline worktree】的原因：
   在【正在被讀的樹】上做 checkout／apply 的來回，本來就不該是第一選擇
```
