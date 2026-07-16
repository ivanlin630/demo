---
from: blueprint
to: systems
status: consumed
topic: "[★方法翻轉·整個商業模型一次進框架再量測] 用戶裁:放棄hole-by-hole,先把整個商業框架做好、所有補釘融入,再跑量測(理由:只融一點後面又抓哪個補丁擋=打地鼠;補釘confound量測,全拆光才量得乾淨模型)。商業骨幹=B市場即地方(貨在outpost買方買stock免賣方在場,非A追人)。目標:target/execution/掛單/resolver/accessor 全收進框架+人格化+無殘補釘。這是WHAT+原則,統一架構HOW全交你。先有(統一模型revive)後磨(流動摩擦/coin/threat)"
---

# ★方法翻轉：整個商業模型一次進框架，再量測（用戶定）

用戶 step-back 到模型層,裁定**放棄 hole-by-hole,整個商業框架一次做好、所有補釘融入,再跑量測**。這翻轉前面「②co-loc 先→①牆後」的逐洞序。

## 用戶理由（我認同）
- **只融一點 → 後面又在抓「哪個補丁擋住」＝我們一路在打的地鼠**（coin→co-loc→成交牆→A/B 逐洞）。
- **補釘互相 confound 量測**——全拆光才量得到乾淨模型（單洞修完,下個補釘又擋,分不清模型對不對）。
- **與 measure-first 相容**：不是還沒找根就猜大重構（那才是 accessor <3% 白工）;是**已知模型＝補釘拼湊（你的靜態稽核 file:line 坐實）,拆光讓量測乾淨**。量測仍 gate 結果（統一模型 revive 否）,工作單位＝整個模型。

## WHAT：整個商業模型進框架（骨幹＝B 市場即地方）
**目標＝一個連貫的、framework-based、全程人格化、無殘留補釘的商業模型。** 覆蓋圖（你稽核的，全收）：
| 環節 | 現況（補釘）| 目標 |
|---|---|---|
| 要不要貿易 | ✅ DecisionEngine 人格秤 | 保持 |
| 去哪/跟誰(target) | ❌ `_merchant_trade_target` if/else 引擎外（`_market_pos` 撲空住這）| 進框架 |
| 成交執行 | ❌ `_attempt_trade_direction`/`best_arbitrage_order` 硬碼 | 進框架 |
| 掛單層 | ❌ `order_system` 人格全盲、~13 死常數、引擎外 | 進框架 + 人格化 |
| 撮合 | ❌ 雙 resolver 沒收斂 | 收斂單一 |
| 庫存讀取 | ❌ 5 散讀縫、無統一 accessor | 統一 accessor |

**骨幹＝B 市場即地方（用戶定，A 棄）**：貨在 outpost/市場 `public_storage`,買方來買 stock（免賣方在場）＝真實市場、穩、可規模化、複用 WS-2b。A（追漫遊賣方）脆＋補釘思維,棄。
- **65% 賣方漫遊根**：B 直接解（貨不跑,買方向 outpost stock 成交,免賣方 pair）。
- **保留遭遇旗艦**：遭遇貿易（荒野撞見機會性）＝風味留;市場貿易（B）＝經濟骨幹。並存。

## 原則（WHAT 級，非 HOW）
- **全程人格化**：掛單門檻、target 挑、成交條件 tolerance 全掛人格（別 flat 死常數）。
- **無殘留補釘**：這次真的全收——別留第 N 個引擎外硬碼支線讓量測再 confound。
- **守全量暫態可觀測**：新統一決策/成交/掛單路徑必接 tap（accessor 縫本身要可觀測，你稽核 flag 過）。
- **coin/threat 等「磨」項**：先別做（統一模型 revive 出 deals 後再磨流動摩擦/coin 循環/threat 韌性）。

## HOW 全交你（我這 arc 越界猜 HOW 被 measure 推翻六次，這封只給 WHAT+原則）
- 統一商業框架怎麼架（target/execution/order 層怎麼進引擎、resolver 怎麼收斂、accessor 怎麼統一、B market resolver 怎麼寫、切幾個 slice）＝**你 HOW**。
- 大小你判：可能一個大 slice 或拆數個(但目標是「拆光補釘的完整模型」再量,非融一點就量)。
- 我只要結果：**統一商業模型跑出 deals（市場首次 revive）,且無殘留引擎外補釘 confound。**

## 閘
- **這是新大框結構重構 → reviewer R② 必過**（spec 鎖後 dispatch/merge 前審設計對齊；大改 target+execution+order+resolver+accessor 多層）。
- R①？前提（補釘覆蓋圖）已靜態稽核 file:line 坐實 → R① 免,R② 足。

## 下一站
系統 spec 統一商業框架（B 市場即地方 + 全補釘進框架 + 人格化 + tap）→ R② → impl → measurer 中性 full-HD（**deals 真發生＝市場首次 revive** + 無補釘 confound）→ 我批 → 再「磨」（流動摩擦/coin/threat）。
**先有整個模型（拆光補釘）再量,不逐洞。measure-first 精神保留（量 gate 結果）,工作單位升到整個模型。**
