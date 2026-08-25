---
slice: harvest-terrain-from-regen
tier: full
qa: required
from: systems
topic: A 型:food 採集從 REGEN_RATE 導出 —— 手工表與真相源矛盾的教科書修法(★禁補表)
---

# `RES_HARVEST_TERRAIN` → **從真相源導出**

★**blueprint 授權即派**（2026-08-25）。★**這是〈估算器禁手抄物理〉的【正主】** ——
**手工表與真相源【直接矛盾】，而不是「過期」。**

## §1 病（`file:line` ＋ 語意錨）
| 來源 | 內容 |
|---|---|
| **手工表** `goal_resolver.gd` 的 `RES_HARVEST_TERRAIN` | `{"material": "forest"}` ★**只有一筆；food 不在表上 ⇒「不可採」** |
| ★**真相源** `resource_system.gd` 的 `REGEN_RATE` | `plains {food 8.0}` ／ `forest {food 3.0}` ／ `mountain {food 0.5}` ⇒ ★**三種地形全都產 food** |

**實測**：`2061 / 2089` 卡在 `RES_HARVEST_TERRAIN.has(res)`；
分型後 **`food` 在 factionless 與 factioned 【兩張床都有】**（measurer：`food = 120`）。
⇒ ★★**最該被採的資源（`plains` 的 food 8.0，全表最高之一），恰恰是手工表上沒有的那個。**

## §2 修法（**唯一形狀**）
★**「哪種地形產哪種資源」從 `REGEN_RATE` 導出。**
⛔ ★**禁止把 `food` 補進 `RES_HARVEST_TERRAIN`** —— **那是同一個病的延續**（blueprint 明令）。

### 設計問題（**要答，但不要新增旋鈕**）
- ★**「產多少才算可採」** —— `mountain` 的 `food 0.5` 要不要算？
  ★**若需要門檻，它必須從既有量導出**（例：與 `daily_need`／`FORAGE_FLOOR` 同源），⛔**不得新造常數**。
- ★**多地形產同一資源時挑哪個** —— **應是【折現值比較的自然輸出】**（產量 × 距離 ⇒ 折現），**不是新排序表。**

## §3 acceptance
| # | 判準 |
|---|---|
| ① | ★**`RES_HARVEST_TERRAIN` 這張手工表【消失】**（`estimator-lineage-scan` 家族的精神） |
| ② | ★**`food` 型的 `has(res)` 卡點歸零**（factioned 床 `food = 120` ⇒ 應大幅下降） |
| ~~③~~ | ⚠️★**撤下**：`dispatch_fail.資源不足` ★**不在本票的因果下游** —— 它量的是**建造成本閘**，而本票改的是**資源取得手段**；★**決定性證據：`delegate.build_ok` 在 before／after 【都是 0】**（這張床從未有一次建造委派成功）⇒ **那 23 的漲跌與本票無因果關係**。**已呈報 blueprint（該條是他指定的）** |
| ★**③新** | ★**質變**：`build` 候選的**時間分佈**從 `day000-only` → **全 90 天都有**（★**這條【在下游】，而且是行為層證據**） |
| ④ | **反面**：`material` 的既有行為**不得退化**（★**兩面分開驗，防修回頭**） |

★**n 小要當心**：`outpost.l0_to_l1` 是個位數 ⇒ ⛔**不得用 1 vs 0 宣告成敗**。
★**跨票依賴**：**文明化是否恢復【不是本票的成敗】** —— B 型（92%）仍在，
⇒ **標 `blocked-by: means-end 磚（B 型）`。**

## §4 閘
`headless` ／ `det×3`（**intended-change；★acceptance 用分佈不用 fp**）／`constitution_gate` ／`seam-gate`（HARD）
