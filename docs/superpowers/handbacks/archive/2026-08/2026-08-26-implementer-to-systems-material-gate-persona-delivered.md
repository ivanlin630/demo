---
from: implementer
to: systems
status: consumed
slice: material-gate-persona
tier: behavior
topic: ★交付 @f5c0c99a:三閘收斂+人格化,六條驗收逐條綠;★★中性零漂實測 1.50000000000000000 逐位元;★★★而【build_ok 仍是 0】——照你開頭寫死的,那是預期不是失敗,我把它當結果報而不是當問題報
---

# 材料閘人格化 — 交付

| | |
|---|---|
| **worktree / branch** | `A:\GDS\demo\.worktrees\gate-persona`／`feat/material-gate-persona` |
| **commit** | `f5c0c99a` |
| **新檔** | `scripts/simulation/decision/build_afford.gd`（共用判斷）＋`scripts/debug/build_afford_persona_test.gd`（fixture） |

## ★驗收六條
| # | 條 | 實測 |
|---|---|---|
| 1 | ★**中性零漂 == 1.5 逐位元** | ✅ **`1.50000000000000000`**（最小 dict／全中性 dict／空 dict 三種都是） |
| 2 | ★★**分化真的改變結果** | ✅ 同 `cost=50`、同池 `avail=75.0`：**大膽放行、慎重擋下**（margin 1.000 vs 2.000） |
| 3 | **三閘收斂** `grep 'cost\[k\]) \* 1\.5' scripts/simulation/` | ✅ **0** |
| 4 | **血統掃描** | ✅ **PASS**（新常數全具名 ＋ `TEST VALUE`） |
| 5 | ★**不驗解鎖** | ✅ **`build_ok` 仍是 0** —— ★見下 |
| 6 | **headless 閘** | ✅ **PASS，7 vs baseline 7** |
| ★ | **`fp` 會變** | ✅ **`07285478f6182fbcaf4f6603f0f3f938`**（main 是 `5c1fa2fc…`）—— **真實引數改了，該變** |

★★**兩個 fixture 都呼叫真正的 production 函式**（`BuildAfford.margin_of` / `can_afford`），
★**沒有在測試裡自己重寫 `avail < cost * margin`。**
★★★**而且我加了兩個陽性對照**：`avail=0` 連大膽也擋下、`avail` 充足連慎重也放行 ——
**否則「大膽過、慎重不過」有可能只是恆真／恆假的巧合。**

## ★★★`build_ok` 仍是 0 —— **照你開頭寫死的，我當【結果】報不當【問題】報**
**`cost 50`、`avail` 從未超過 20** ⇒ **緩衝拔到 `MARGIN_MIN = 1.0` 也過不了。**
⇒ ★**這票改的是【誰決定緩衝】，不是【緩衝擋住了什麼】。**
★★**能把 `avail` 推到 ≥50 的是 A（初始庫存）與 B（伐木場）** —— **不在本票。**

## ★形狀（照既有照妖鏡家族）
```gdscript
MARGIN_NEUTRAL 1.5   ★中性錨點（＝收斂前的全域值，零漂靠它）
MARGIN_CAUTION_K 0.6 慎重斜率   MARGIN_DARING_K 0.4 膽大斜率（好戰／野心取大）
MARGIN_MIN 1.0（剛好付得起）    MARGIN_MAX 2.0（最保守）
margin = 1.5 + (慎重-0.5)*K_c - (膽-0.5)*K_d，clamp[MIN,MAX]
```
★**連續、單調、有界**（第三條 fixture 掃 慎重 0→1 驗單調不遞減 ＋ clamp 兩端）。
★★**上下界數字請你看一眼**（你說選定後回 reviewer 那幾行）：**`MIN=1.0`／`MAX=2.0`**
——★**`MIN=1.0` 的語意是「剛好付得起」，再低就是【舉債動工】，我判斷那是另一條路、本票不開。**

## ★★`INVEST_SAFETY` 那行
改成 **`= BuildAfford.MARGIN_MAX`**（零新常數），註解改成陳述現況：
**送料用組 A 上界、村端 `_can_afford` 檢查用 1.0×** —— ★**不複述那條不存在的耦合。**
★**並用 fixture 釘住**：`INVEST_SAFETY ≥ 最保守領袖的 margin`（實測 `2.00 ≥ 1.800`）
⇒ ★★**你指出的「本票新產生的失效模式」現在有測擋著，不是靠註解提醒。**

## ★邊界
**只動組 A 三閘 ＋ `INVEST_SAFETY` 一行。`coin_treasury.gd:46`（組 C）一行未動。**
