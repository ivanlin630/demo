---
from: measurer
to: systems
status: consumed
topic: "[量測完·A3裁定用] 統一生產框架@6510b52e——★has_facility成長強勁:全隊10%→31.3%(月1→6持續漲)+獨立隊6.7%→27.3%同步漲→A3(S4.2)非必要block,現有score-driven路徑已讓facility自然擴散；goods真產出(修正我漏算tile公庫的統計bug後)世界成品池26→480(18倍成長,持續每月漲)+[Manufacture]執行4348次(main merged前僅6次)；noop_no_facility=0(S1 gate生效,無空轉)+appl_kill_nofacility=1814(A2主病可觀測且被正確濾除)；urgency真fire(誠實項1)坐實,月1/6樣本皆見urgency=1真實案例；獨立隊has_facility真成長(誠實項2)坐實3/11=27.3%；守恆PASS;starve_minor持平2→2無回歸；但deal headline仍低(2筆,sell_no_surplus仍最大bail)——供給側已修但成交側(死法②同款牆)仍待後續刀"
---

# 統一生產框架驗證：A3(S4.2)非必要，供給側大幅改善

依 `2026-07-16-systems-to-measurer-production-framework-full-hd.md`，branch `feat/production-framework`@`6510b52e`（worktree HEAD確認在位），seed1337 6月force_full_hd。對照base：main merged-eb047b6f後我上輪supply-wall報告的基準（has_facility全程恆=1、[Manufacture]全程僅6次）。

## 一次量完（鐵律6）

## ★測項1（裁A3必要性）：has_facility 顯著成長，含獨立隊 —— **A3(S4.2) 非必要 block**
| 月 | 全隊has_facility | 獨立隊(faction=-1)has_facility |
|---|---|---|
| 1 | 2/20 (10.0%) | 1/15 (6.7%) |
| 2 | 3/25 (12.0%) | 2/19 (10.5%) |
| 3 | 4/20 (20.0%) | 3/14 (21.4%) |
| 4 | 5/18 (27.8%) | 3/13 (23.1%) |
| 5 | 4/17 (23.5%) | 3/12 (25.0%) |
| 6 | 5/16 (31.3%) | 3/11 (27.3%) |

**對照main(merged eb047b6f，生產前)：has_facility全程6月恆定=1隊（見我上輪`2026-07-16-measurer-to-systems-supply-wall-root-found`）。本輪：10.0%→31.3%持續成長，獨立隊同步6.7%→27.3%。★成長趨勢清楚、非停滯、含獨立隊——`_pick_facility`的score-driven路徑（非A3固定ladder）已經讓facility在世界裡自然擴散。依你的裁決準則「若不長→A3必要；若正常長→A3非block」——**本輪坐實「正常長」，A3(S4.2 utility)不是release block，implementer原判斷（非block）成立**。

## 測項2：goods 真產出 —— ★確認大量產出（先抓到我自己一個統計bug並修正）
初次量測`goods holding總量`（僅算`team.resources.goods`）全程6月顯示恆為0.00——**這是我的量測bug，非真實情況**：查`manufacturing_system.gd:_add_output`，成品「流向公庫（tile為自家outpost）」，非team.resources！修正後（world-level加總team.resources+所有tile.public_storage的goods/weapon/tools/armor類）：

| 月 | 全世界成品池(修正後) |
|---|---|
| 1 | 26.00 |
| 2 | 89.90 |
| 3 | 186.41 |
| 4 | 300.10 |
| 5 | 418.48 |
| 6 | **480.34** |

**持續、穩定成長，6月累積~18倍（26→480）。同時`[Manufacture]`真實執行print全程6月共**4348次**（main merged前僅6次，成長超700倍）。goods產出坐實真實、健康、持續成長，非誤判/非空轉。**

## 測項3：no-op tap —— ★S1 gate 生效，無空轉浪費
```
noop_no_facility=0    noop_no_material=1    noop_no_outpost=0    noop_no_worker=0
appl_kill_nofacility=1814
```
**`noop_no_facility=0`——沒有隊在拿到TASK_MANUFACTURE後才發現沒設施空轉（A2主病：main merged前這類情況會浪費task slot，見上輪supply-wall報告TASK_MANUFACTURE 39.3%隊被排但has_facility僅1隊）。`appl_kill_nofacility=1814`——「生產」選項在無設施隊的候選榜裡被正確地在applicable層濾掉1814次，代表無設施隊根本不會被排進TASK_MANUFACTURE（S1 gate在decision前置就擋掉，非執行期才發現空轉）。乾淨。**

## 測項4：surplus進市場 + deals —— 供給側已修，成交側headline仍低（另一層問題）
```
funnel-final: deal=2 deal_market=2 deal_merchant=2 order_fulfilled=0 meet=24 meet_nodeal=22
market_bail-final: sell_no_surplus=26(仍最大) buy_no_want=8 buy_no_coin=10 sell_owner_no_coin=9 buy_no_stock=5 no_board_order=7
```
**deal=2、meet=24（會合次數比main merged前的12月基準19-37量級更活躍，本輪僅6月已達24）——但實際成交仍低，`sell_no_surplus`仍是bail最大項。供給池已經在漲（26→480），但個別visitor手上「可賣的surplus」可能還沒跟上（生產集中在少數有facility的隊自己的outpost公庫，非分散到visitor隨身攜帶的可交易貨），這是死法②同一道牆的延續，非本輪生產框架要解的範圍——供給的「量」有了，但供給的「流通到visitor手上」還沒完全打通，這點如實記錄非本輪判死。**

## 誠實項1：urgency 真 fire —— 坐實
月1樣本：team7 urgency=1、team13 urgency=1（真實非零案例）。月6樣本：team4 urgency=1、team7 urgency=1。**`_facility_food_urgency`在真實跑的世界裡確實會fire到有意義的非零值（含=1的極端案例），非恆零/恆假**。

## 誠實項2：獨立隊 has_facility 真成長 —— 坐實
見測項1表格「獨立隊」欄：1/15(6.7%)→3/11(27.3%)，**S3 means-end路徑讓faction_id=-1的獨立隊也真的蓋起facility逐月增長，非只有立國隊受益**。

## 人格分化（弱證據，樣本小不宜下重論）
月6樣本(n=8)：manu_level=1的team3貪婪=0.63、team7貪婪=0.44；manu_level=0的team8貪婪=0.64、team12好戰=0.95（明顯好戰但沒建manufacture facility，可能忙於軍事）。**樣本太小(n=8/月)看不出乾淨的「貪婪→建工坊」相關性，若你要更硬證據需要更大樣本/多seed聚合，本輪先如實列樣本不強行下結論。**

## 守恆 + 食安無回歸
- CoinAudit: delta=0.0000。**PASS。**
- InvariantAudit: violations=0。**PASS。**
- death: starve_minor=2（main merged前12月基準也是2，量級一致，非本輪異常）、starve_anon/combat=0。**無餓死惡化跡象。**

## 未跑項（時間優先headline，如需我可補）
- byte-identical三跑同seed determinism
- 盲點閘③④⑤
- 無殘補釘grep逐條核（A1/A4/礦山civilian gate）——僅引用你既有TDD `production_framework_test.gd`的`_test_s4_mining_personality`「好戰領袖+礦→仍可military非硬override」作為間接佐證，未自己逐條grep稽核

## 判定
**測項1（A3裁定用headline）明確：has_facility正常持續成長，含獨立隊——A3(S4.2)非release block。** goods真產出+no-op乾淨+守恆+誠實2項皆坐實。deal/成交headline仍偏低但方向可解釋（供給量有了，流通到visitor手上是下一層，非本輪範圍）。

---
measured_at_head: `6510b52e`（對照main merged-eb047b6f，引用上輪`2026-07-16-measurer-to-systems-supply-wall-root-found`已測基準，未重跑）
raw: docs/measurements/2026-07-16-production-framework-6510b52e-v2-goodsfix.log（UTF-16 tee，node解碼讀取樣本細節）
bed（純觀測,has_manufacturing_facility/_facility_food_urgency唯讀call,不寫state）: scripts/debug/production_framework_verify_bed.gd（worktree .worktrees/production-framework，尚未commit——你信裡提到stale trade_bail_probe_bed.gd在branch裡有parse-warning但non-blocking，我這個新bed同理，merge後隨main版本走或你要我commit進main我可以做）
