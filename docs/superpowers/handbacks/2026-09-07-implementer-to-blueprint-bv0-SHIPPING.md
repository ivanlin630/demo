---
from: implementer
to: blueprint
status: consumed
topic: ★**B-v0 出貨**（批 2 最後一票）——驗收八格、`.measure.json` 與十二份跑面 exact path 全在下面｜★★而我把**兩格「不是通過」的**也寫在卷面上，不藏
---

# 一、★交付
```
branch  feat/market-thickness-v0   HEAD f910d423（已 push）
base    origin/main（⑩ + board-declared-price + ⑨ 已入）
spec    docs/superpowers/specs/2026-09-06-market-thickness-v0-HOW.md
```

# 二、★★驗收（★每格都附它是【怎麼】被證明的）
| # | 判準 | 判決 | 證據 |
|---|---|---|---|
| ① | **紅線**：外地賣家成交後 `team.coin` 不變、待領款 +額 | **PASS** | 自報價 1.1200 → 待領款 11.20；賣家 coin `0.00 → 0.00` |
| ② | **到期**：貨不回家，落待領貨帳 | **PASS** | escrow 8.0 → 待領貨 8.0；賣家 material `32.0 → 32.0`；escrow 已搬空（非兩邊都有） |
| 3b | 款與貨**分開量** | **PASS** | 待領款 1 條／待領貨 1 條／合計 2，兩種 kind 窮盡 |
| ④ | **escrow 守恆** | **PASS** | 賣家 food `60.0 → 50.0` == escrow qty `10.0` |
| ⑤ | **鑑別力**：拿掉待領帳 ⇒ ①必紅 | **PASS** | `BV0_MODE=no_claim_account` ⇒ ①的**兩格都紅**（2 FAIL） |
| ⑤b | 拿掉領取 option ⇒ 野外率掉到 0 | ★**本床測不到** | 需要全世界長跑；★★**我不假裝測得到**——否則這格會在一支沒有 option 迴圈的床上永遠綠 |
| ⑥ | 五個 tap 全量 | **PASS** | 流量五 tap ＋ 待領餘額（**存量**）19.20 分開印 |
| ⑦ | determinism 三跑 | **PASS** | byte-identical `fp=39657d1e4acd83c15337553fded10563` |

# 三、★產物 exact path（★十二份，含四份「看起來像紅燈」的）
```
docs/measurements/2026-09-07-bv0-market-thickness.measure.json   ←★主卷
docs/measurements/2026-09-07-bv0-acceptance-run1-fixture-defect.txt
docs/measurements/2026-09-07-bv0-acceptance-run2.txt
docs/measurements/2026-09-07-bv0-acceptance-run3-funnel.txt
docs/measurements/2026-09-07-bv0-acceptance-run4.txt
docs/measurements/2026-09-07-bv0-acceptance-run5.txt
docs/measurements/2026-09-07-bv0-acceptance-run6.txt
docs/measurements/2026-09-07-bv0-acceptance-FINAL.txt
docs/measurements/2026-09-07-bv0-discriminator-no-claim-account.txt
docs/measurements/2026-09-07-bv0-discriminator-no-claim-option.txt
docs/measurements/2026-09-07-bv0-determinism-r{1,2,3}.txt
```

# 四、★★★而我要你看的是那四份「像紅燈」的
```
四次結果看起來都像 production 壞了，四次都是【fixture 的前提沒有被驗證】：
   run1 賣家【在場】⇒ 走 peer trade ⇒ 直接付款【是合法的】
   run3 買家【沒有需求】⇒ `want = 0` 是正確行為
   run4 賣家【深過剩】⇒ 自報價 0 ⇒ 沒有錢可追（⑩ 裁的「爛大街＝白送」）
   run5 母體被①【吃光】⇒ ②沒有東西可以到期
⇒ ★每一次我若只看結果不看分母，都會去改一個沒壞的 production ——
  ★★而改完那個紅燈會消失，看起來像修好了。
⇒ ★★★所以我把四份都留在 repo：它們是【這一票最有價值的東西】，
  而不是失敗紀錄。
```

# 五、★另記三個【床自己身上】的缺陷（★寫進 json，因為下一個寫床的人會踩）
```
①`BV0_MODE` 只被讀進變數、從來沒被使用（★而我是在批評完 money_genesis_bed
  的同型缺陷之後一小時內自己複製了它）
②對照讀舊值：`claims_coin` 在搬走 claim 之前算 ⇒ 只有一半的斷言會動
③母體判準用「claims 是否為空」⇒ ★鑑別力模式會把它搞空 ⇒
  ★★對照把自己偽裝成「沒有母體」，正好避開它要觸發的那條紅
```

# 六、不在範圍（spec §6 具名）
```
買單押錢半邊（你的砍法優先序）／v2 掛帳／自動改價／懸帳充公／跨地捎款
```
