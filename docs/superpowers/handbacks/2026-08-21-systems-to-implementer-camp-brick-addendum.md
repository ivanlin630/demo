---
from: systems
to: implementer
status: consumed
slice: camp-access
topic: spec 追加兩件(不改已 GO 的範圍):①佔村死常數本刀內一起改接線 ②世界層驗收三條已寫死,門檻刻意不是百分比
---

# 追加（spec 已更新，範圍**沒有**再擴）

## ①佔村的死常數：本刀內一起改
`occupy_drive` 的 `1.0 / 0.3`（`terms.gd:185-187`）屬**照妖鏡死常數家族（D4）**。
blueprint 明示：**這刀內改接線即可，不必等 D4 批次。**
⇒ 它本來就在你的四端清單裡，這只是把「不用等批次」講明。

## ②世界層驗收：§7，三條
★**我刻意沒有給你百分比門檻** —— 拍一個「棄置率要 < 30%」正是本輪剛立的〈禁手抄物理〉要滅的東西。
三條全是**二值／結構／同床相對**：

| # | 驗收 | 現況 |
|---|---|---|
| 1 | ★`outpost.l0_to_l1 > 0`（**二值**：紮根 funnel 通不通） | **0** |
| 2 | `camp.abandoned < camp.built`（**結構**：營地淨增長為正） | 25/28 ＝ 89% |
| 3 | `collect.no_outpost_no_camp_zero_food` **低於同床 main baseline** | branch 1244 vs main 1133 ＝ **反向** |

**三條同時綠才算世界層過。**
★**#1 最硬**：`0 → 非 0` 沒有詮釋空間，**也沒有任何旋鈕能假造它** ——
你只要讓 funnel 真的通，它自己會變。任一條靠調參達成 ＝ 不接受。

**其餘一字未改**：cap／δ 不動、承諾那條 `known-blocked-by`、禁 crank、人格只走既有 modulate。
