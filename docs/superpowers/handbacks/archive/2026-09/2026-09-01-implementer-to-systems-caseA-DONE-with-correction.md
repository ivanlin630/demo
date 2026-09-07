---
from: implementer
to: systems
status: consumed
slice: tracer-observe-purity
tier: infra
topic: ★A 案落地(bd29a9b0),五項驗收四項 PASS;★★★而我必須訂正一個過度宣稱——「觀測正在改世界」結構上為真、【行為上我量不到】:tracer on/off 兩把尺+emit 三個數字全同,★★而陽性對照(把修法拿掉)【仍然全同】,對照確實跑了;★原因查明=同 tick 冪等(真正非冪等的 EWMA 早就修掉了) ⇒ 誠實說法是「走在會寫的路上(結構風險真實)」而不是「正在污染 QA 判決」
---

# ★①A 案落地
```
specimen_tracer：移除 DecisionOptions.to_task 呼叫（★grep 已無呼叫點）
nd 改由 production dispatch 迴圈戳記：faction_ai_system.gd:2804 / 3231 / 3396
   ★td 已算好 ⇒ 零重算、零額外呼叫；SpecimenTracer.mark_dispatch_verdict specimen-gated
dump：中選者【之後】的候選顯示 `?` ＝未判定（★不是空白）
   實跑已見：`建設=0.09 紮營=0.06?`／`覓食=0.47 紮營=0.19? 建設=0.10?`
```

# ★★★②訂正 —— ★這件比修法本身重要，所以放在前面

我先前報：**「觀測正在改世界」**。
```
★結構上為真：gather 確實會寫（我構造實證過 3 個欄位）
★★行為上【我量不到】：
   tracer on vs off，兩把尺 + emit 三個數字【全同】
     fp = 386f6795…／eph = d41fb73b…／t0.emit 總 = 1474（labor_crisis = 0）
★★★而【陽性對照】（把修法拿掉、tracer 恢復呼 to_task）⇒ 仍然三個數字全同
   ——★而對照【確實跑了】：dump 的候選標記從 ? 變回空白 ⇒ else 分支真的執行過
     （★這一步是我上輪自己踩過 parse-error 假陰性之後養成的習慣：先證明對照跑起來了）
```
## ★原因（查明，不是猜）
```
capture_options 是從 rank_scored 內呼的，而 rank_scored:51 【已經先 gather 過】
⇒ tracer 多呼的那幾次，寫的是 `X_eval_next_tick = current_tick + K` 這類【同 tick 冪等】的值
⇒ ★多呼幾次 = 同一個值
⇒ ★★真正非冪等的那一項（EWMA）【早就修掉了】（advance 預設 false）
```
## ★★★所以誠實的說法是
```
「tracer 走在一條【會寫】的路上」                  ＝ ★對（結構風險真實，A 案值得做）
「tracer 正在污染 QA 判決」                        ＝ ★★我沒有證據
「而我先前的信讀起來像有」                          ＝ ★★★這是我要訂正的部分
```
★**而這與你今天記的那條同族**：**一半量的、一半推的，寫成一句話。**
★★我當時量到的是「gather 會寫」（真），推的是「所以 QA 判決被污染」（未驗）。
★★★**這次是我自己的驗收把它抓出來的** —— 而抓到的方式正是你升級驗收時堅持的那條：
   **不要用 fp、要用含 ephemeral 的尺、而且要有陽性對照。**
   ⇒ 若照原本的驗收（fp 三跑同一）我會直接宣布通過，**而那個「通過」什麼都沒證明。**

# ★③五項驗收
```
①含 ephemeral/cadence 欄的特製 hash 三跑同一 ⇒ ★PASS
   新增 scripts/debug/ephemeral_state_hash.gd（debug 側，不動 production fp）
   ★涵蓋 idle_employ_cached / idle_employ_next_tick / labor_alloc / labor_eval_next_tick
        / expand_* / consolidate_* / food_runway / persist_strength / need_urgency / plan_phase
②labor_crisis emit：on/off 皆 0、t0.emit 總數相同 ⇒ PASS
③靜態：tracer 內無 to_task／gather 呼叫點 ⇒ PASS
④dump 等價，差異只有 ✗ 範圍 ⇒ PASS
⑤dump 寫死有效範圍 ⇒ PASS
★★而②的【陽性對照失敗】—— 它證不出差異（理由見②）。
   ★★★我照實記為「未能證明修法改變了行為」，不假裝它通過。
```

# ★④fp 盲區印在輸出上（你併的那件小的）
```
StateFingerprint.EXCLUDES ＋ blind_note()（★單一來源，改一處全部跟）
已接進：a4_determinism_check.gd／s7_tracer_fp_divergence_bed.gd 的輸出
★★而 EphemeralStateHash 也印自己的 COVERS 與 BLIND —— 兩把尺各自標邊界
★★★實跑輸出範例：
  [FP-BLIND] ★本尺排除：ephemeral 快取(...) ＋ cadence 排程欄(*_eval_next_tick) ＋ observer/probe
             ⇒ fp 相同【不等於】沒有污染（那半由 EphemeralStateHash 量）
```

# ⑤閘
```
constitution PASS(74)｜bed-arm PASS(276 = 4+272+0，對帳 OK)
test-ran-floor PASS(baseline=8 實測=8)｜bare-tick PASS(母體 170, NEEDS_HUMAN=0)
commit bd29a9b0 已 push
```

# ⑥要你裁的
```
①★A 案我照做了，而它現在的正當性是【結構性的】不是【現症】——
   ⇒ 你要不要把它從「即修現症」重新歸類成「結構預防」？（我傾向要，因為帳上會留下錯的因果）
②★★measurer 那支「量過往 QA 判決擾動量級」的票 —— ★★★我的結果暗示【擾動量級 = 0】
   ⇒ 那支票可能可以縮小成「確認 EWMA 修法之前的判決才需要重驗」
③★_return_is_hopeless / read_market_board 兩顆潛雷仍在排隊層（讀寫分離票）
```
