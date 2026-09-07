---
from: implementer
to: systems
status: consumed
slice: ★★★seg1 重跑【三張交付】—— 四格全綠、SCRIPT ERROR 0、specimen 涵蓋 runtime-born
touches: `docs/measurements/2026-09-04-exam-seg1-23708982-paper.md` ／ `exam-seg1-23708982-seed{1337,42,7}.specimen.jsonl`
topic: ★三張 `completed=yes`、四格對帳全綠、section 23/23/23 互比一致、`SCRIPT ERROR` **0**、specimen 三份逐檔驗過(8.16／6.97／7.45 MB,★config 8 ＋ runtime 8);★★而你的預先登記預測我【只列數字不下判定】:求和 116／178／★299,三張都進前四、seed 7 第一名 —— ★★★而我【沒有】「同一批 tick 上備戰原本會贏幾次」這個量,那需要下架前後對【同一個世界】比,而下架本身改了世界軌跡 ⇒ 判定是你的;★兩件標而不解讀:承諾紮根【首次有勝場】(上輪三張全 0)、cap 的大(≥9)【三張都 n=0】(上輪 42 曾有 13)⇒ 那格又回到未觀測
---

# ★①交付（★exact path）
```
卷面：`A:\GDS\demo\docs\measurements\2026-09-04-exam-seg1-23708982-paper.md`
specimen（★逐檔驗過存在＋大小）：
   `docs\measurements\exam-seg1-23708982-seed1337.specimen.jsonl`  8,159,395 B
   `docs\measurements\exam-seg1-23708982-seed42.specimen.jsonl`    6,965,113 B
   `docs\measurements\exam-seg1-23708982-seed7.specimen.jsonl`     7,452,354 B
```

# ★★②四格對帳（★逐張、跑完立刻做）
```
①`[INTERIM]` 9／9／9　②`[CP]`+`[TickPerf]` 90／90 三張皆是　③section **23／23／23**（互比一致）
④黏連 0／0／0　｜★`SCRIPT ERROR` **0／0／0**（★★上輪加 runtime 覆蓋時撞的兩顆崩潰已修掉）
`[PilotRun]`：438.3／419.6／403.2 s、`EXCLUSIVE=yes`
★★★③從 21 變 23 ＝ 本輪新增的【下架驗收】與【specimen 覆蓋率】兩節 —— 不是有東西不見
```

# ★★★③specimen 涵蓋 runtime-born（★你要的那格）
```
三張都是：config-born 8 ｜ ★runtime-born 8
runtime 8 隊的【結局分布】（★卷面逐隊印，讓 QA 自己判代表性）：
   1337：12 不在名冊｜13/14/15/17/18 存活(pop=1)｜16 不在名冊｜19 存活(pop=3)
   42  ：★13 團滅｜12/16/1000001 不在名冊｜14/15/17/18 存活(pop=1)
   7   ：13/14/15/16/17/18 存活(pop=1)｜12/1000000 不在名冊
⇒ ★★所以【最激烈的那一層現在讀得到了】：有團滅、有不在名冊、有 pop=1 的邊緣
★★★留讀數不解讀：出現 `1000000`／`1000001` 這種 team id —— 遠離一般 runtime 號段，我沒查
```

# ★④ANNOTATION §3 的格（★同窗同 seed，只差 code）
| 格 | 上輪 `e863873c` | 本輪 `23708982` |
|---|---|---|
| payoff 相異值 | 321／436／237 | **192／248／191** |
| tie_exact workshop | 19／4／28 | **26／25／18** |
| tie_exact apothecary | 4／4／4 | **4／4／4** |
| 其餘 5 個 | 全 0 | **全 0** |
| `u>=CAP`／`x<0` | 0／0 | **0／0** |
| 對照組非存活 | 27.6／36.8／19.4% | **28.1／35.3／38.9%** |
| config-born 非存活 | 25.0／16.7／16.7% | **25.0／25.0／41.7%** |
| runtime-born 非存活 | 29.4／46.2／20.0% | **28.6／40.9／37.5%** |
| 施主 hit/entry | 0/574｜0/347｜3/605 | **8/490｜0/612｜0/596** |
| 承諾紮根 贏／母體 | 0/3｜0/1｜0/11 | ★**1/4｜1/1｜0/4** |
| cap 大(≥9) | n=0／**13**／0 | ★★**n=0／0／0** |

# ★★★⑤你的預先登記預測 —— ★我只列數字，不下判定
```
★你的預測：下架後【求和】的勝場應接近增加原本備戰的量（而不是散開）
本輪：求和 **116／178／★299**，三張都進前四；★seed 7 是第一名
★★而我【不寫「符合預測」】，理由是量的問題不是禮貌問題：
   ★★★我沒有「同一批 tick 上備戰原本會贏幾次」這個量 ——
   那需要在下架前後對【同一個世界】比，而★下架本身改了世界軌跡（`fp` 變了）
⇒ 判定是你的；而若你要那個量，它需要一個【下架 flag 可切換】的版本，那是另一票
```

# ⑥誠實限
```
①`_sec_goalutil` 用 `──` 不是 `═══` ⇒ 不在 section=23 裡
②specimen ＝ 創世 8 ＋ runtime 前 8（id 昇序）⇒ ★不是隨機樣本，代表性由 QA 判
③三張同一次連續跑、同 commit、同 env ⇒ 產地同源
④★★`大(≥9)` 三張皆 n=0 ⇒ cap 的 pop 殘留這一格【本輪答不了】
⑤缺席欄位：`mem_static_mb`／`teams`、政權盤點（★仍在 `feat/old-growth-forest`，未 merge）
```
