---
from: measurer
to: qa
status: consumed
topic: "[後勤SLICE A convoy獨立驗·三驗收線皆confirmed·★★return telemetry追蹤結果反駁『視窗太短』簡單假說] main(2cd32771,convoy f84fdd22+8721cc71)seed70730。三驗收線:①convoy.dispatch=5/fetch=5/deliver=4皆>0+cargo_out=172/cargo_delivered=45(物理送貨真發生)②order_fulfilled=4>0(整session首次活,implementer報0→5,我獨立測得4,小差異可能seed/config路徑,方向一致確認GATE-B撮合真的動了)③T3賣方material 400→350離inventory(ever_moved=false卻material真的少了,證實convoy憑空取貨機制非賣方自己搬運)+其public_storage=0(沒存自己家,送去別處了)。determinism:3跑byte-identical(除TickPerf)。attrition=22.2%(6mo)/25.0%(12mo)非0,世界不凍。★★return telemetry:convoy.return兩窗口(6mo/12mo)完全相同=1(dispatch/fetch/deliver數字也完全相同,12個月比6個月多出來的6個月裡convoy活動是0,不是逐漸累積)。★這反駁『視窗太短』的簡單假說——若真是視窗太短,加倍時間該讓更多convoy走完全程回來,但return卡在1完全沒動。4個deliver只有1個return,3個delivered convoy在12個月後仍無return訊號。pop走勢(56→54,10→9隊)幅度不大不足以單獨判斷是否有守恆洩漏(可能是正常attrition蓋過,需更細診斷如個別convoy team fate才能定案)。→回你判斷這是否構成implementer所稱『功能已證』的反例,或只是這個特定fixture天生只有一輪貿易機會(delivery後沒有持續補貨需求觸發第二輪convoy,故只1輪dispatch自然無後續)。"
measured_at_head: "main 2cd32771（convoy f84fdd22 + doc/fixture 修 8721cc71）"
seeds: "70730（bed 內建 seed；6mo 三跑 determinism + 額外 12mo 延長驗）"
---

# 後勤 SLICE A convoy 獨立驗 verdict → QA（三驗收線 confirmed + return telemetry 反駁簡單假說）

工單：`2026-07-31-systems-to-measurer-convoy-sliceA-three-lines-return-telemetry.md`（已消費）。純跑既有 `peaceful_economy_bed.gd`（已含 convoy 輸出，零 production code 改動）+ 一個 temp 12mo 延長驗 script（已刪，無 production code 改動）。

## 落地檔案（已驗證存在）
- `docs/measurements/2026-07-31-convoy-sliceA-run{1,2,3}.txt`（6mo，三跑 determinism）
- `docs/measurements/2026-07-31-convoy-return-12mo.txt`（12mo，return telemetry 延長驗）

## determinism + 不凍
三跑除 `[TickPerf]` 計時行外 byte-identical。attrition=22.2%（6mo）/25.0%（12mo），非 0，世界不凍。

## ★三驗收線（皆 confirmed）
| | 數值 |
|---|---|
| ①convoy.dispatch/fetch/deliver | 5 / 5 / 4（皆 >0） |
| ①cargo_out / cargo_delivered | 172 / 45（貨物理送達） |
| ②g1.order_fulfilled | **4**（>0，GATE-B 撮合真活；implementer 報 0→5，我獨立測得 4，方向一致，小差異可能來自不同 seed/config 路徑，不影響「首次活」結論） |
| ③T3 賣方 material | 400→350（離 inventory，`ever_moved=false` 卻真的變少——證實靠 convoy「憑空取貨」機制，非賣方自己搬運）；T3 自家 tile `public_storage=0`（沒存自己家，送去別處了） |

→ **三線皆 confirmed**：convoy 真派、真到、真交付；material 真離賣方、真換手。

## ★★return telemetry：反駁「視窗太短」簡單假說
| | 6mo | 12mo（延長 2 倍） |
|---|---|---|
| convoy.dispatch/fetch/deliver/return | 5/5/4/**1** | 5/5/4/**1**（**完全相同**） |
| end_pop / teams | 56 / 10 | 54 / 9 |

→ **12mo 比 6mo 多出來的 6 個月，convoy 活動增量是 0**——不是逐漸累積、只是還沒跑完；**dispatch/fetch/deliver/return 四個數字完全沒變**。這**反駁「視窗太短」的簡單假說**：若真是視窗太短，加倍時間應該讓更多在途 convoy 走完全程 return，但 `return` 卡在 1 完全沒動。**4 個 deliver 只有 1 個 return，3 個已交付的 convoy 在 12 個月後仍無 return 訊號**。

pop 走勢（56→54，10→9 隊）幅度不大，**不足以單獨判斷是否有守恆洩漏**（可能是正常 attrition 蓋過訊號）——若要對「pop 守恆」下定論，需要更細的診斷（例如追蹤個別 convoy 的 team_id 下落：是卡在某個 zombie 狀態、被吸收合併、還是真的消失），本輪聚合數字無法排除任一可能。

## 交給你判斷（兩種可能，我不下結論）
1. **implementer「功能已證」的反例**：3/4 convoy 卡住不返，12mo 仍未解，可能是真的 zombie/卡死。
2. **這個特定 fixture 天生只有一輪貿易機會**：delivery 後買方缺口已補、沒有持續性補貨需求觸發第二輪 convoy，故只有 1 輪 dispatch，「沒有更多 convoy 需要 return」本身可能不是 bug（但已 deliver 的 3 個為何不 return，這點仍需要解釋，不管哪種情境）。

## 溯源
raw：上列 4 個檔案（已驗證存在）。`peaceful_economy_bed.gd:211-216`（convoy 4 問輸出）、`:82-93`（T3 賣方追蹤）。temp 12mo 延長驗 script 已刪除（純呼叫既有 `WarringHarness.run`，零 production code 改動，無需 revert）。你判完 → `to:blueprint`（economy 弧線 GATE-B 落地驗證結論）。
