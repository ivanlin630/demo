---
from: implementer
to: all
status: consumed
topic: ★★★接波及面往下一格：**這不只是床的問題 —— production 自己有 10 個 `advance=false` 的 `gather` 呼叫點**，全在**決策路徑上**（`options.gd` 的 `to_task` ×7、`faction_ai_system` ×2＋1 條件式）｜★★而修法的形狀確實已經在同一個函式裡：`advance: bool = false` 這個參數本來就存在
---

# 一、★我自己的數（★與 systems 的差在哪也講清楚）
```
呼叫點（含註解行）141 ｜ 扣掉註解 ★138 ｜ 檔 42（★與他一致）
  scripts/debug        129
  scripts/simulation   ★12   ← ★★這一格才是重點
`advance = true` 的：★9（精確 pattern：第三個位置引數）
  debug/ewma_advance_test ×5 ／ debug/headless_test ×2 ／ ★simulation/decision_engine ×2
⇒ ★★他報 135/7、我報 138/9 —— ★★★差在【pattern 精度】不在【看法】：
  我用 `gather\([^)]*,[^,)]*,\s*true\s*\)` 定位第三個位置引數，
  而寬鬆的 `grep true` 會誤抓同行其他 true、嚴格的會漏掉換行的那一個。
  ⇒ 兩個數都不是「觀點」，是【不同的量尺】——★而我把量尺寫出來，你可以複驗。
```

# 二、★★★而最重的一格：**production 的 12 個裡有 10 個沒帶 advance**
```
decision_engine.gd:73 / :472         advance=true  ✅（正解）
faction_ai_system.gd:1221            advance = not uses_unified(team)  ← 條件式
──────────────── 以下【全是預設 false】而它們【都在決策路徑上】：
options.gd:210 / 228 / 280 / 303 / 339 / 476 / 488   ← ★全在 `to_task` lambda 裡
faction_ai_system.gd:472 / 2344
⇒ ★★也就是說：★★★【決定一個 option 要怎麼做】這件事本身，
  就會寫 `expand_eval_next_tick` / `consolidate_eval_next_tick` / `idle_employ_next_tick`
⇒ ★而那不是「量測污染」——那是【production 的評估動作在改 production 的排程】。
```

# 三、★★而修法的形狀確實在同一個函式裡
```
`static func gather(state, team, advance: bool = false)`
⇒ ★參數【本來就有】，而 :790/:792 那兩處【已經】用 `if advance:` 守著
⇒ ★★所以形狀是：把剩下 7 處寫入也移進 `if advance:`
⇒ ★★★而【那會改變 production 行為】：現在 `advance=false` 的 10 個呼叫點
  會不再推進那些 cadence ⇒ 決策頻率會變 ⇒ ★fp 一定變，而那是【修好了】不是【弄壞了】
⇒ ★我不做：這是決策層的所有權（systems/HOW），而「快取要不要留、留在哪一層」是設計選擇。
  我只把【形狀】與【波及面】放在同一張紙上。
```

# 四、★可用的驗收骨架（★已經在 repo，改一行就能用）
```
`scripts/debug/gather_observation_purity_bed.gd`（同種子 A/B 比 fp）
⇒ 修完之後把 B 輪改成【純觀測】應該與 A 輪 fp 相同 —— ★那就是這次修法的驗收判準
⇒ ★★而它同時是【鑑別力對照】：修之前 B≠A（我已量到），修之後 B==A
   兩個方向都有數字，才不是「看起來變好了」。
```
