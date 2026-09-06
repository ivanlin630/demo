---
from: systems
to: blueprint
status: consumed
slice: ★B 前置件最後一格 —— warring pilot 回來了
topic: ★★★[PilotRun] completed=yes｜wall_clock_s=10159.7(169.3 分)｜9 段心跳全在｜0 個 TIMEOUT ⇒ 三個候選【全部排除】;★★而框架要換:那條 backlog 從「跑不完=量測能力的上限」變成【跑得完,但貴 23.6 倍】(warring 169.3 分 vs peaceful_regime 7.2 分)⇒ 判準⑨在 warring 上不是做不到,是【排程要先算小時】;★★★而這一封【不下 behavior 因果】——它全是運轉面讀數(completed/wall-clock/mem),所以不需要 specimen→QA 那條
---

# ①B 前置件：**最後一格清了**
```
①政權 ✅
②run-reliability ✅ —— ★而答案不是「找到兇手」,是【中斷不再昂貴】
   ⇒ 三候選全排除:計時器(對照探針兩支活滿 90 分+本跑 169 分)／固定天數(day 53 早越過)／
     記憶體(71.5 → 254.8 MB 單調上升【而沒有崩】)
③wall-clock ✅ —— warring 90 日 = ★169.3 分｜peaceful_regime 90 日 = 431 秒 ⇒ ★★約 23.6 倍
④基線質地 ✅ —— 政權注入無罪(config 層新舊都 25.0%),而 25% 是這個模擬的常態
★payoff 導出 ✅MERGED（★★而它產出了今天最有價值的一格:隊真的把糧食拿到手了）
```

# ②★★而排程要先算這個（★這是新的約束，取代舊的「做不到」）
```
★「多 seed × warring × 90 日」＝【小時級 × seed 數】
   ⇒ 3 seed ≈ 8.5 小時機器時間（★而它需要獨佔:時間類讀數並跑不可比）
⇒ ★★所以考卷若要 warring 長窗,【seed 數】是要先裁的東西,不是跑起來再說
⇒ ★★★而 peaceful 那邊 7.2 分 ⇒ 同樣 3 seed 只要 22 分鐘 —— 兩個世界的排程完全不同量級
```

# ③★一件我要主動聲明的（★hook 提醒的那條）
```
★這一封【不下任何 behavior 因果結論】—— 它全是運轉面讀數:completed / wall-clock / mem / 心跳段數
⇒ ★★所以它不需要 specimen → QA 故事稽核那條路(純聚合 metric、不下 behavior 因果者可免)
⇒ ★★★而【長考正考】不一樣:那一輪要下 behavior 結論 ⇒ 必附 specimen 送 QA
   —— 我把這句寫在這裡,是因為【那一輪最容易忘】(數字最多、最想直接讀)
```

# ④★★★而記憶體那條是【預先寫下的預測】
```
★day 40 時我外推「day 90 約 250 MB」⇒ ★★實測 254.8 MB
⇒ ★★★那是預測不是事後對帳 —— 而它把「記憶體會撞牆」這個候選【量化地】排除掉
```

# ⑤下一步（★等你裁的只有一件）
```
★機器空了 ⇒ implementer 已用 EXCLUSIVE=yes 開跑段級 PHASE_TIMING 的 before/after
   (那是 payoff merge 時我降級的具名回訪)
★★🅿️我這邊未派:cap 那層(單調壓縮保序,尺度參數不能手填,走 R²)
★★★而【正考 GO 是用戶扳機】—— 前置件四格已全綠,推不推 TG 是你的格
```
