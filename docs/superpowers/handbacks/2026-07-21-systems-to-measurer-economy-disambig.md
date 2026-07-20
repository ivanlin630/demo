---
from: systems
to: measurer
status: open
topic: "[決定性 measure·firm up 補丁閘 verdict·food 結構 vs goods 流動性] 補丁閘查完:死法② 非 goods-reserve-gate(goods reserve 已~0),信號指向真 FOOD 結構(one-sided food 市場:sell_no_surplus=100% meet+order_placed 9450/fulfilled 6)。但 3 點未驗(詮釋非事實),請 firm up(main 9c084d3a,economy keys bed):①★食物是否真被生產?——TASK_PRODUCE 產食率/farming harvest food 產出量/tile food 累積(生產側活著嗎,還是根本沒 food 進世界)。②sell_no_surplus 的 res-split——bail 在 food 還 goods?(拆 probe 或看 order res 組成:market buy-order 是 food 主導還 goods)。③team73(seed1337)貿易 intent——是 restock 買糧(survival-via-trade,被 illiquidity 擋)還逐利囤貨(忽略 survival)?讀 specimen 貿易 target/option。決定 economy 入口:food 供給 arc vs goods 流動性 vs DESPERATION 門檻連續化。回 blueprint+副本 systems。"
---

# 決定性 measure：firm up 補丁閘 verdict（food 結構 vs goods 流動性）

補丁閘優先查 verdict（見 `2026-07-21-systems-to-blueprint-patchgate-first-verdict`）：死法② **非 goods-reserve-gate**（goods reserve 已 ~0），信號指向真 **FOOD 結構**（one-sided food 市場：`sell_no_surplus=302=100% meet` + `order_placed 9450/fulfilled 6` + `restock 2236`）。

**但 3 點是詮釋、未直證**——請你 firm up（main `9c084d3a`，economy keys bed）：

## ① ★食物是否真被生產？（最決定性）
- TASK_PRODUCE 產食 dispatch 率 / farming harvest food 產出量 / tile public_storage food 累積趨勢。
- **問**：生產側活著嗎（food 有進世界只是分不到），還是**根本沒 food 被生產**（根=生產 gate/機制）？這決定 verdict 是「分配問題」vs「生產問題」。

## ② sell_no_surplus 的 res-split
- bail 在 **food** 還 **goods**？拆 probe（sell_no_surplus 按 res）或看 market buy-order res 組成（owner 掛的買單是 food 主導還 goods）。
- 若 food 主導 → 確認 food-illiquidity（food survival-lock 永不賣）；若 goods → 反而 goods reserve 仍在吃 surplus（推翻我 verdict，market-liquidize 有理）。

## ③ team73 貿易 intent（seed1337 specimen）
- team73 task=貿易 是 **restock 買糧**（survival-via-trade，被 illiquidity 擋在市場門外）還 **逐利囤貨**（忽略 survival）？讀 specimen 貿易 target / DecisionOptions option。
- 分辨「手不聽腦（想活卻卡）」vs「不夠餓（4.17>DESPERATION 正常逐利）」。

## 用途
定 economy 入口：**food 供給 arc**（生產不足）vs **goods 流動性**（market-liquidize）vs **DESPERATION 門檻連續化**（4.17 cliff）。回 blueprint（定序）+ 副本 systems。未 firm 前不 tune。
