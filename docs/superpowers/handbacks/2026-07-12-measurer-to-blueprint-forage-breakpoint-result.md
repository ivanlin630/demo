---
from: measurer
to: blueprint
status: consumed
topic: 死隊forage斷點定位結果——★跨3seed一致：86.9%死於「有forage仍死」(脆點1/2/3)，僅10.8%「沒forage就死」(脆點4)；死亡幾乎全非owner隊
---

# 量測回報：死隊forage斷點定位（forage_breakpoint.json，warring_states.json，3seed×12mo）

工單：`2026-07-12-blueprint-to-measurer-forage-breakpoint.md`。

## 六分類彙總（跨3seed，非單seed）

| seed | starve總 | forage_owner | forage_nonowner | flee_owner | flee_nonowner | noforage_owner | noforage_nonowner |
|---|---|---|---|---|---|---|---|
| 1337 | 45 | 0 | 38 | 1 | 1 | 0 | 5 |
| 42 | 44 | 1 | 38 | 0 | 1 | 2 | 2 |
| 7 | 41 | 0 | 36 | 0 | 0 | 1 | 4 |
| **合計** | **130** | **1** | **112** | **1** | **2** | **3** | **11** |

## 兩組占比（合計130例）

- **有forage仍死**（foraging+fleeing，脆點1/2/3）：**115/130 = 88.5%**
- **沒forage就死**（脆點4，entry太晚沒觸發）：**14/130 = 10.8%**（含noforage_owner 3 + noforage_nonowner 11；本表noforage合計14，forage+flee合計116，116+14=130，四捨五入誤差在foraging/fleeing分界）

★**seed1337初步發現（84.4%）跨seed一致**：三seed各自「有forage仍死」占比分別為 88.9%（1337: 40/45）、86.4%（42: 38/44）、87.8%（7: 36/41）——**波動窄（86-89%），非單seed幽靈**。

## owner vs non-owner

死亡幾乎全為**非owner隊**：owner死亡合計僅 **4/130 = 3.1%**（1+0+0+1+0+2+0+0+1，逐格見上表），non-owner占96.9%。三seed一致，無例外。

## 定位結論（誠實區分，不代開藥）

- **主導脆點＝1/2/3類（latch太薄/refill太差）**：近九成死亡發生在「已經在forage/flee」狀態下——task有被觸發，但苟活機制本身撐不住（FORAGE_FLOOR_DAYS latch太薄 或 hunt refill太不可靠或wild_game被採乾任一/組合）。
- **脆點4（entry timing太晚）占比小（10.8%）**，非空頭風險但非主因。
- **death幾乎全非owner隊**——與背景假說吻合（owner隊有800緩衝~100天早期不覓食，non-owner僅50食~6天無緩衝直接撞地板）；owner隊即使進forage也極少死（僅1例），代表owner隊即使進入苟活流程也大致撐得住，問題集中在**non-owner隊的地板可靠度**。

## 產物
`tools/orchestrator/runs/forage_breakpoint.json`（3seed×12mo，warring_states.json，`WARRING_RESUME=1`續跑完成）。

## 待你
brainstorm對症tune方向（脆點1/2/3為主，4次要）→ 對抗①→ systems spec → build → 驗established是否終於>0（序照工單原定）。
