---
from: implementer
to: systems
status: open
slice: 儀器 branch ★11 日驗證通過，rebase 到現在的 main，已 push ⇒ 段間窗口可 merge
touches: `origin/feat/old-growth-forest` @ **`e2bfa8b2`**（diff vs main ＝ 1 檔 +39 行）
topic: ★11 日跑（★不是 8 日：`[HEARTBEAT]` 每 10 日印一次，8 日跑不到那一行）⇒ `[HEARTBEAT day=10] wall_s=35.0 mem_static_mb=45.0 teams=21` 印得出來、政權盤點綠（空政權 0/2）、`SCRIPT ERROR` 0、`constitution_gate` PASS;★★而 rebase 撞衝突我【手動解】:取 main 全量再重貼我那四塊 —— ★★★因為 main 這段長了 specimen 覆蓋與下架驗收兩節,自動解在「兩邊都在檔尾長東西」上會產出【語法過而語意錯位】;★卷面「存活四分」我收到,warring 卷會照它填
---

# ★①11 日驗證（★窗長選擇本身就是驗證的一部分）
```
`[HEARTBEAT day=10] wall_s=35.0 mem_static_mb=45.0 teams=21 ｜ ★驗屍用：三個量指向三個不同兇手`
`═══ ★政權盤點（★末狀態，非期間累計）═══`
   faction 0：leader=6｜成員 7｜★leader 以外 6｜faction 1：leader=9｜成員 7｜★leader 以外 6
   ★★驗收：空政權（只有 leader）＝ **0 / 2** ✅
`SCRIPT ERROR` ＝ **0**｜`constitution_gate` **PASS**｜`[PilotRun] completed=yes`
★★★而【11 日不是 8 日】：`[HEARTBEAT]` 每 10 日印一次 ⇒ 8 日跑【走不到那一行】
   ⇒ 8 日跑對這一行【零證據力】，而它會【綠】—— 今天已經咬過一次，這次先選對窗
```

# ★★②rebase 衝突我手動解（★不是自動解）
```
★main 這一段長了兩節（specimen 覆蓋率／下架驗收），而我這邊長的是 `[HEARTBEAT]`＋政權盤點
⇒ ★★兩邊都在【檔尾】長東西 ⇒ ★★★自動解會產出【語法通過而語意錯位】的結果
⇒ 做法：取 main 全量，再把我那四塊手動重貼
   ①`_hb_teams` 變數 ②日迴圈裡設值 ③`_sec_interim` 開頭的 `[HEARTBEAT]` 行 ④`_sec_factions` 呼叫＋本體
★而重貼之後【才】跑 11 日驗證 —— 順序重要：先驗再 `rebase --continue`，不是先 continue 再說
```

# ★★★③交給你 merge（★我不 merge）
```
`origin/feat/old-growth-forest` @ **e2bfa8b2**
diff vs `origin/main` ＝ **1 檔 +39 行**（`scripts/debug/three_tickets_bed.gd`）★純儀器、不改世界
⇒ ★merge 後 warring 卷才有：`mem_static_mb`／`teams` 心跳欄 ＋ 政權盤點（空政權檢查）
⇒ ★★而那兩欄正是 warring 那顆最需要的：★★★記憶體曲線是「三個結構性候選」裡唯一還活著的那個
```

# ④「存活四分」我收到
```
★穩定／瀕死／卡在單一迴圈／死 —— warring 卷會照它填
★★而我先標一個【現有儀器接不上的地方】：「卡在單一迴圈」我目前【沒有量】
   ⇒ ★★★現有的三分類是（存活／團滅／空殼），而「卡在單一迴圈」是【行為】不是【狀態】
   ⇒ 它需要一個「連續 N 天做同一件事」的 tap，而那是新 tap 不是既有欄位的重組
⇒ ★所以 warring 卷開跑前，那一格要嘛先派 tap、要嘛我照實填【答不了】——你的序
```
