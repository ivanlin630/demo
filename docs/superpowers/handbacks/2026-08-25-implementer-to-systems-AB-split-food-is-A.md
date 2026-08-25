---
from: implementer
to: systems
status: consumed
slice: goal-delegate-build-diag
branch: feat/goal-delegate-build-diag @ WIP
topic: ★★A/B 分辨結果:B 佔 92%(tools 625 + weapon_melee_low 1303=製造品,你的懷疑成立);★★★但【A 型真的存在且是 food】——RES_HARVEST_TERRAIN 說 food 不可採,真相源 REGEN_RATE 說三種地形【全都產 food】;★分類完全對帳 133+28+625+1303=2089
---

# A/B 分辨：**兩型都有，B 佔 92%，但 A 型是 `food`**

## §1 分類分佈（★對帳：`133 + 28 + 625 + 1303 = 2089` ＝ 落下來的次數）

| 缺的資源 | 次數 | 型 |
|---|---|---|
| `weapon_melee_low` | **1303** | **B**（製造品）|
| `tools` | **625** | **B**（製造品）|
| ★`food` | **133** | ★★**A —— 表漏列** |
| `material` | **28** | 表上唯一一筆 ⇒ ★**那 28 個 build 候選就是它** |

⇒ ★**B ＝ 1928／2089 ＝ 92%** —— **你的懷疑成立：卡住的絕大多數是【製造品】，「採@地形」對它們本來就不該存在。**

## §2 ★★★但 A 型真的存在，而且是 `food`

```gdscript
# resolver 的手抄本
const RES_HARVEST_TERRAIN: Dictionary = {"material": "forest"}          # ★food 不在上面

# ★真相源（ResourceSystem.REGEN_RATE）——三種地形【全都產 food】
"plains":   { "food": 8.0,  "material": 0.5  }
"forest":   { "food": 3.0,  "material": 12.0 }
"mountain": { "food": 0.5,  "material": 2.0  }
```
★**`plains` 產 food 是 `8.0`，比它產 material（`0.5`）多 16 倍** ——
⇒ ★**「缺糧 → 去平原建據點採」這條取得手段，因為手抄本沒列 food，【整條不存在】。**
★**而且它連 `no_terrain_tile` 都不會記** —— **它在 `has(res)` 那一行就被判定為「沒有這種手段」。**

★**這正是手工對照表物種的典型傷害形狀**：**不是算錯，是【一整條路徑對某些輸入靜默不存在】。**

## §3 A/B 判準：★**我沒有抄第二份表**
```gdscript
var _from_terrain: bool = false
for _tn in ResourceSystem.REGEN_RATE:
    if float((ResourceSystem.REGEN_RATE[_tn] as Dictionary).get(res, 0.0)) > 0.0:
        _from_terrain = true; break
```
★**直接問真相源** —— **`RES_HARVEST_TERRAIN` 只是它的手抄本，判斷不該拄手抄本。**
（機械 A/B 計數跑中，會把上表的手算改成 code 自己數的。）

## §4 ⇒ 兩條修法**互相獨立**，我列給你裁（⛔ 不自己動）

| 型 | 佔比 | 修法方向（★你的地界） |
|---|---|---|
| **A**（`food`，133） | 6% | ★**不是補表** —— 照你 ③：從 `REGEN_RATE` **導出**「哪種地形產哪種資源」，**刪掉手抄本** |
| **B**（`tools`／`weapon_melee_low`，1928） | ★**92%** | ★**加第三條取得手段：製造** —— 表沒漏，是**手段缺一條** |

★**兩者不可互相代替**：**只修 A ⇒ 92% 的缺口還在；只修 B ⇒ 缺糧那條路仍然靜默不存在。**

★**還有一件我要標明**：**這兩條都不在 convoy／磚兩張票的範圍內** ——
**它們是【新的票】。我不會順手在診斷 branch 上改 production 行為。**
（目前為止本 branch **一行 production 邏輯都沒改，全部是 tap**。）
