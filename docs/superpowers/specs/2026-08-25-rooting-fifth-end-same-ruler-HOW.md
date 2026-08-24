---
slice: rooting-fifth-end-same-ruler
tier: full
qa: required
from: systems
topic: 紮根納入折現同尺 —— 四端同秤漏掉的【第五端】(blueprint:分佈坐實則直接修,無需回報)
---

# 紮根：**同秤的第五端**

★**授權**：blueprint 2026-08-25 —— **紮根 ＝ 建點類，用戶折現磚裁定原文已授權「建點／建設類」**
⇒ ★**把 `rooting_drive` 換到折現真流同尺 ＝ 同一裁定的【補完】，不是新 WHAT。**
**分佈坐實即直接修，無需回報。**

## §1 現況（`file:line`）
`DiscountedFlow.flow_utility` 的 caller ＝ **4 個**（`terms.gd:117 / 198 / 211 / 232`）：
覓食・遷移找糧／佔村／併入／紮營。
★**`rooting_drive` 不在其中**，它回傳：
```gdscript
_feasible * clampf(ctx.settle_site_quality, 0.0, 1.0)   # ★[0,1] × [0,1]
```
⇒ **值域 [0,1]、典型值必然很小**（實測 `root_u 0.09~0.14`，對手 `winner_u 1.395`）。

★**真母體**：`terms.gd` 的 `*_drive` 類 term **共 21 個** —— **「四端」是我的工作範圍，不是母體**
（已入負斷言帳，見 `00_roles §覆蓋欄`）。

## §2 ★前置量測（**擋在動工前；可證偽點已寫**）
**要的**：四個 `flow_utility` 消費端的**實際 util 分佈** vs `rooting_drive` 的分佈（min／median／max）。
| 結果 | 判定 |
|---|---|
| `flow_utility` 端典型值**明顯高於** `rooting_drive` | ✅ **尺不同成立 ⇒ 動工** |
| ★兩者**同量級** | ★**推論垮 ⇒ 不做本票**，回頭查 `_feasible` 或 `settle_site_quality` 哪個把它拉死 |

## §3 修法
**`rooting_drive` 改走 `DiscountedFlow.flow_utility`**，與另四端**同一個入口**：
- **flow** ＝ 建成 L1 據點後的**真實被動所得**（同 `camp_target_est` 家族，**禁第二份產能常數**）
- **delay** ＝ ★**工期**（`OutpostSystem.build_eta_days` —— **單一真相源已在**）＋ 殘距
- **baseline** ＝ **真實被動所得**（同磚語意）
- ⛔ **不得為紮根造一次性公式**（折現磚模組頭條）

★**既有的兩項「真值」語意保留**：可行性（撐不撐得過）與選址品質 ——
**它們應該進 flow／delay，而不是外面再乘一次 [0,1]。**

## §4 acceptance（blueprint 指定：**照舊**）
| 面 | 判準 |
|---|---|
| ★**文明化閘** | 同床 **`outpost.l0_to_l1` > 0**，且**不低於 main** |
| ★**四端不退** | 既有四端的 `lost_to` 分佈**不得因此崩壞**（**兩面分開驗，防修回頭**） |

★**n 很小要當心**：`l0_to_l1` 在這個世界是**個位數**
⇒ ★**不得用 1 vs 0 宣告成敗**（我犯過一次）——**要看多 seed 或更長窗。**

## §5 閘
`headless` ／ `det×3`（**預期會變 ＝ intended-change；但 ★acceptance 用分佈不用 fp**）／
`constitution_gate` ／ `seam-gate`（HARD）
