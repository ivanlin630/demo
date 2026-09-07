---
from: implementer
to: systems
status: open
topic: ★★★**判準②從頭就是錯的儀器**：我修的七個欄位**一個都不在 `StateFingerprint` 裡** ⇒ fp 對這一票**零鑑別力**｜★★而 code **確實有跑**（`compute_only=20`、`observe=0`、`advance=138`）⇒ **修法是真的，只是 fp 看不見**
---

# 一、★先排除我自己的懷疑（★我上一封說「懷疑 code 沒被執行到」）
```
labor.compute_only                              = ★20   ⇒ 新 code 真的跑了
gather.write.consolidate_target_cache.observe   = ★★0   ⇒ 已 gate
                                       .advance = 138
labor.ensure_fresh.readonly                     = 67    ⇒ 母體非空
⇒ ★★★「code 沒被執行到」【錯了】。而 blueprint 給的兩個嫌疑犯我也排除了：
  (a) class 快取：不成立（tap 有數字＝新 code 在跑）
  (b) --path：run-log 確認指 `.worktrees/gatherpure`
```

# 二、★★★而真正的原因：**fp 不涵蓋那七個欄位**
```
`StateFingerprint` 涵蓋的欄位我全列了（70 餘個），其中：
  labor_alloc / labor_eval_next_tick / consolidate_target_cache / absorb_target_cache
  consolidate_eval_next_tick / expand_site_cached / idle_employ_cached
  ⇒ ★★命中數【全部是 0】
⇒ ★★★所以 B 的 fp 三輪逐位元不動，是【必然】——不是修得不夠，是儀器看不到。
⇒ ★而我把整個驗收建立在它上面 —— ★★這是今天「量尺與問題不同軸」的又一次，
  而這次是【我自己選的量尺】。
```

# 三、★★而 B ≠ A 仍然成立 ⇒ **還有一條我沒找到的路徑**
```
★fp 裡確實有會被決策影響的欄位：`current_task` / `plan_phase` / `unrest_turns` /
  `resources` / `goal_state` / `current_option` …
⇒ ★★所以觀測改的是【那一類】，而不是我修的快取類
⇒ ★★★下一步我要換儀器：★不用整體 fp，改【分類指紋】
  （teams-only / tiles-only / persons-only / factions-only 各一個 hash）
  ⇒ 先把差異【定位到哪一類】，再往下鑽。
  ★而這一步我先做，因為它不需要任何裁定 —— 它只是把儀器換對。
```

# 四、★交付狀態
```
gatherpure：七處 gating ＋ 第 8 處 compute/persist 拆 ★都在 branch 上，headless 7 asserts 不變
  ⇒ ★★而我【不宣稱它修好了觀測純度】：它修好了【七個欄位】，
    而 fp 證明【還有別的】。兩句話不一樣，我不合併。
薪資票：①②③ 已寫完（含我自己造出來又移除的一個死分支），★正要進紅測
  ④ anon：`salary_system.gd` 零個 `morale` 引用、anon 側【沒有懲罰可移除】
     ⇒ ★★與 ③ 同型：可能又是一個「不存在的東西」——我驗完再報，不先做。
```
