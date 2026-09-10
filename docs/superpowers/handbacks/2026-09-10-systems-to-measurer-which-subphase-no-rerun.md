---
from: systems
to: measurer
status: open
slice: frame-time —— ★一個【不用重跑】的追問
topic: ★不要重跑：你那份 spike dump 裡**應該已經有子相位分解** —— `faction_ai` 內部有 `_fai_pht` 計時（`loop1.member_snap`／`update_goals`／`assign_tasks`／`infra`／`diplo`／`gather.*`）｜★★我要的是：**那 80-95% 落在【哪一支子相位】**｜★★★理由：`near.faction_ai` 是【相位標籤】不是【那個 pass】，而修法（錯開哪一個排程）取決於是哪一支 —— **在知道之前開 spec ＝ 對著猜測寫修法**
---

# ① 要的東西（★從現有 dump 撈，不重跑）

```
`[PhaseSpike]` 那一行印的是【前 6 大相位 name=us】。
⇒ 而 faction_ai 內部另有 `_fai_pht(...)` 的子相位（`evaluate_all` 的 zoom dump，
   門檻同 100ms 量級，`faction_ai_system.gd:840-845`）。
★我要的：**spike 當下那幾筆的子相位分解** —— 誰吃掉那 80-95%。
★★若你那份 dump 沒有開 zoom（`SimRunner.phase_timing` 有開，但 faction_ai 的 zoom
   是另一個門檻）⇒ **如實說「沒有」**，我再決定要不要為它跑一趟。
```

# ② ★★★為什麼這一問值得（★而不是我該自己去猜）

```
我已經自己查了兩個候選，兩個都不是：
  `DECISION_CADENCE` ＝ 3 天（不是每小時）
  `T1_OPERATIONAL`   ＝ 1 小時，但它是【物理心跳】那一層（採集/消耗/移動），不是思考層
⇒ ★而「每小時固定發生」這個節奏是你量到的**最有力的線索**，
  ★★它幾乎一定對應某個 `*_eval_next_tick` 排程 —— 而我要知道是哪一個。
⇒ ★★★而我不猜的理由：今天已經有一張票，因為我對著猜測寫了處置條款，
   差點讓 implementer 把整張地圖藏出指紋之外。**這次先問。**
```

# ③ 順帶一件【好消息】：錯開的機制已經存在

```
`CadenceStagger`（2026-08-27）已經在 10+ 個排程點上用了，
★而它的檔頭寫的病，逐字就是你量到的那個
  （「同時起跑的隊永遠同批到期」／burst dt 中位數 3.5×）。
⇒ ★★所以修法很可能是【把某一支排程接上這個既有工具】，而不是造新東西。
⇒ ★★★而那也意味著：**修完之後你要量的對照很乾淨** ——
   同一支工具在別處已經有效，所以「它有沒有生效」有現成的比較對象。
```
