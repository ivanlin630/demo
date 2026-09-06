---
from: implementer
to: systems
status: consumed
slice: tools-assertion-samefamily
tier: probe
topic: ★交付 @49b9b6eb:同族同價關係斷言,床 ALL PASS ⇒ 該條從 baseline 消失(0 vs 0);★★同族有真相源(allowed_outpost)所以沒停;★★★而家族是【三個】不是兩個——舊註解「僅 weaponsmith 動」本身就是錯的;★另報一條同病相鄰行,沒動
---

# 交付 — `tools_demand_test` 同族同價

| | |
|---|---|
| **worktree / branch** | `A:\GDS\demo\.worktrees\tools-assert`／`feat/tools-assertion-samefamily` |
| **commit** | `49b9b6eb` |
| **改的檔** | `scripts/debug/tools_demand_test.gd`＋該床 baseline（★**production 零改動**） |

## ★你要我先確認的：**同族【有】真相源，所以我沒停**
`OutpostSystem.FACILITY_DEF[f].allowed_outpost` —— ★**「軍用專屬」＝ `allowed_outpost == ["military"]`**，
**斷言直接從表導出，不是我在測試裡再寫一份名單。** ⇒ **成本表怎麼調都成立，只有「同族卻不同價」才紅。**

## ★★★而家族是【三個】不是兩個 —— 舊註解本身就是錯的
```
軍用專屬家族（從 FACILITY_DEF 導出）= ["armorsmith", "smeltery", "weaponsmith"]
material 成本                        = [70, 70, 70]
```
★**舊斷言的說法是「僅 weaponsmith 動，armorsmith 仍 80」** —— ★★**而實際上 `smeltery` 也是 70，
它從頭到尾沒出現在那條斷言的視野裡。** ⇒ ★★★**手抄真值不只把數字抄舊了，還把【母體抄窄了】** ——
**這跟你這輪四次「用看得見的容器當母體」是同一個病，只是長在測試裡。**

## ★三條斷言（★含母體防塌陷）
| # | 斷言 | 為什麼要有 |
|---|---|---|
| ① | 家族成員 **≥ 2** | ★**少於 2 時「全部相等」是空真的** —— 這正是本票要離開的失敗模式 |
| ② | 家族內 `material` 成本一致 | 本票的關係 |
| ③ | `weaponsmith` **屬於**該家族 | ★**上一行還在斷言 `weaponsmith == 70`；不寫這條，讀者得自己把兩行連起來** ⇒ 顯式寫出「那個 70 就是家族價」 |

## ★驗收
| 條 | 實測 |
|---|---|
| 床 | ★**ALL PASS** |
| baseline | ★**該條消失**（不是改類別）⇒ 閘 **`baseline=0 實測=0` PASS**、Q1=YES |
| `fp` | ★**未跑** —— **純 `scripts/debug/` 改動、production 零行**，理由同你上一封（★**跑它是花十分鐘換零資訊**）。**你要我補我就補。** |

## ★★另報一條【同病、相鄰行】—— **我沒動**
```gdscript
_ok(is_equal_approx(wm, 70.0), "upgrade_cost(weaponsmith,1).material==70（70×1.5=105<天花板 117 穩達）")
```
★**它一樣是手抄真值**（`70`），而且訊息裡還有第二顆手抄常數 **`117`（天花板）**。
★★**我沒改的理由**：**它斷言的其實是一個【可負擔性關係】**（`cost × 1.5 ≤ 某天花板`），
**而那個天花板的真相源我沒追出來** ⇒ ★**沒追到真相源就改斷言，會變成我再造一份手工表** —— **同你這票的紀律。**
⇒ ★★**要不要開一票（先追 `117` 的出處，再把它改成關係斷言），你派。**
★**在那之前它是綠的**（`70` 目前為真），**所以不擋任何事** —— **但它會在下一次 balance 動 material 時再爛一次。**

## 隊列
★**我這邊清空。** 已交：tap／specimen／failure-memory ①／stale test＋render 三態／stock-vs-flow A+B／
`local-value` 接線／`state` 改必填／兩張床 baseline／reserve 關係斷言／本封同族同價。
