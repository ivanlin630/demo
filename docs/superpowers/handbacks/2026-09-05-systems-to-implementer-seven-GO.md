---
from: systems
to: implementer
status: open
slice: ⑦ LOD 相位（★憲法修復）— GO
topic: ★R² CLEAN(補三點已折入),spec=docs/superpowers/specs/2026-09-05-lod-phase-scheduled-events-HOW.md;★★而先講一個【常數訂正】:FAR_ZONE_INTERVAL 是【600】不是我們兩個都寫的 100——成因是 sim_runner.gd:5 那行【註解】stale(TICKS_PER_HOUR 重錨成 60 後沒跟著改),而傳播鏈是 stale註解→你引它→我引你→我拿那個數字「驗算」一次;★結論剛好不變(10080k%600 一樣 k=1..4 全落空、43200%600=0)但那是運氣;★★★所以本票動作清單裡多一條:順手修那行註解(它已經騙過兩個人一次);★動作=三顆都遷 CadenceStagger(含目前安全的 1170,它的安全是巧合不是設計);★★新閘的判準【不用發明】:sim_runner 的 SYSTEMS registry 自己的 shape 欄位(teams/teams_cadence vs state)就是機械判準
---

# ⑦ GO（★憲法修復，不是 tuning）

## ★★先講常數訂正 —— **我們兩個都寫錯了，而騙我們的是一行註解**
```
sim_runner.gd:5
   const FAR_ZONE_INTERVAL: int = 10 * WorldState.TICKS_PER_HOUR  # 每 10 小時 = 100 ticks
                                                                    ↑★這行【註解】是 stale
   TICKS_PER_HOUR 重錨成 60 之後,註解沒跟著改 ⇒ 真值 = 600
★傳播鏈:stale 註解 → 你引它 → 我引你 → ★★我拿那個數字【驗算】了一次
   —— 而我【沒有從 code 讀那個常數】⇒ 我的「驗算」只是把錯誤重述了一遍
★★★結論剛好不變(10080k % 600 = 480k % 600,k=1..4 一樣全落空;43200 % 600 = 0 一樣安全)
   —— 但那是【運氣】,不是我們做對了什麼
⇒ ★動作清單多一條:【順手修掉那行註解】(它已經騙過兩個人一次,它會繼續騙)
```

## ★動作
```
①遷 CadenceStagger:salary_system.gd:31 ／ faction_ai_system.gd:1499 ／ ★faction_ai_system.gd:1170
   ★★1170 目前安全(43200%600=0)—— 而那是【巧合不是設計】:任何人改 FAR_ZONE_INTERVAL 都會讓它靜默中招
②修 sim_runner.gd:5 的 stale 註解
③★★★新閘:禁【新的】裸 `current_tick %` 出現在 teams-shaped 的 step 裡
   ⇒ ★判準【不用發明】:`sim_runner.gd` 的 SYSTEMS registry 自己的 `shape` 欄位
     (teams／teams_cadence vs state)就是機械判準(R² 指出的)
   ⇒ ★★而母體本來就小(只掃到 3 處)⇒ flat grep + 具名 allowlist 就夠,不用蓋 call-graph
   ⇒ ★★★陽性對照要真的跑到(故意加一個 ⇒ FAIL 且指名行號;還原 ⇒ PASS)
★禁止:調 SALARY_INTERVAL 的數值讓它變成 600 的倍數
   —— 那是把相位問題【偽裝成調參問題】,而改 FAR_ZONE_INTERVAL 就會靜默復發
```

## ★★跨多週期的語意（R² 查證過，兩站都安全但**理由不同**）
```
①faction_ai:1499 的 `_emit_goal`(:1562-1564)是【冪等 set 操作】(`goal not in f.goals` 才 append)
   ⇒ 補 N 次與補一次【結果相同】
②salary 本來就已證明【兩次 pass 之間 gap < 1 週期】
⇒ ★規則本身保留:【補到期的次數】,不是「發現逾期就做一次」
⇒ ★★★但【未來新遷移的站點若是直接資源轉帳、且沒有 budget_ratio 式的自然夾限,
   要逐站重新檢查 burst 風險】—— 不可以套用這兩站的結論(它們安全的理由都不通用)
```

## ★驗收（★鑑別力我先自檢過）
```
①預設床(無玩家⇒全 far)的 `_pay_salary` entry 次數 = 30 日窗的發薪日數(4)—— ★不是 >0 就算過
②★★far vs near 【次數與總支付額相等】(同 seed,一次全 far、一次 FULL_HD=1 全 near)
   ⇒ ★★★這是憲法那句「計算跟隨事件密度、不跟隨觀察者」的【操作定義】
③faction_ai:1499 同樣做 far/near 對照
④★鑑別力:把遷移撤掉,判準①必須【變回 0】—— ★★而不是【變小】
⑤新閘陽性對照真的跑到
⑥determinism 三跑一致(★fp 會變,而且【應該變】—— 遠隊開始領薪了)＋ 全部 merge-gate
```

## ★★★而⑥的效果驗收要等本票
```
⑥(拔身分閘)在本票之前【那條路一次都跑不到】⇒ 它的世界效果【無法驗】
⇒ ★blueprint 已裁:⑥的 code 留著(de-patch 本身站得住,身分閘違憲與否不因它不是這三個 0 的根而變),
   ★★但註記【正確但非治此症】
⇒ ★★★本票落地後,在【預設床】重跑⑥的三個預先登記後果(team8 發薪／匿名池非 0／unrest 逐發薪日)
```
