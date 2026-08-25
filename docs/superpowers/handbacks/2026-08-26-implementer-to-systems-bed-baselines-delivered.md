---
from: implementer
to: systems
status: open
slice: bed-baselines
tier: probe
topic: ★交付 @c41aa925(exact path 在內);★★★但工具在這兩張床上【本來生不出東西】——0 條 + Q1=NO,而 0 條讀起來像綠;要先給它們一個閘聽得見的通道,才有 baseline 可判;★兩條都判 stale-test,各附證據
---

# 交付 — 兩張閘型床的 baseline

| | |
|---|---|
| **worktree / branch** | `A:\GDS\demo\.worktrees\bed-baselines`／`feat/bed-baselines` |
| **commit** | `c41aa925` |
| **落地** | `docs/test-baseline-survival_layer_unify_test.txt`／`docs/test-baseline-tools_demand_test.txt` |
| **原始輸出** | `…\scratchpad\bed_survival_v2.txt`／`bed_tools_v2.txt`（★另有改動前的 `bed_survival_main.txt`／`bed_tools_main.txt`） |

## ★★★先講擋路的那件：**工具在這兩張床上生出 0 條 ＋ Q1=NO**
**我照你的指示直接跑 `--gen-baseline`，結果**：
```
[test-floor] Q1 跑完了嗎 → ★NO（無結尾標記）
[test-floor] ★已生成 baseline：…（0 條，全部 unjudged）
```
★**而那兩張床當下明明各有 1 條 FAIL。**
**原因**：工具的兩個機制**都還是 `headless_test` 專屬**——
①**完成標記** `[TEST-SUITE-COMPLETE]`（這兩張床印的是 `=== DONE === 1 FAIL`）
②**列舉軸 ＝ Godot severity 前綴**（這兩張床的失敗走 `print`，★**根本不進引擎通道**）
⇒ ★★**「工具本來就是床無關的」這句，在【生成】這一側不成立** —— **它床無關的是【比對】，不是【看得見失敗】。**
★★★**而失敗形態正是最糟的那種**：**0 條 baseline ＋ 綠燈，實際上床是紅的。**

### ★我的處置（**動的是 `scripts/debug/`，沒碰 `scripts/simulation/`**）
兩張床各加兩件：
```gdscript
push_error("[FAIL] %s" % msg)     # ★會叫、不會停（assert 會停，撞第一條之後全不跑）
print("[TEST-SUITE-COMPLETE]")    # ★沒有它，Q1 只能答「不知道跑了多少」
```
★**這是【床的慣例】改動，不是我一張床的私事** ⇒ ★★**你可能會想把它標準化到所有閘型床**，
**所以我把它單獨講，而不是埋在 commit 裡。**（★若你要改成別的形狀，我照改，這兩處很小。）

# ★★判類別（**本票的實質**）—— 兩條都是 `stale-test`，各附證據

## ①`survival_layer_unify_test`：`[FAIL] 中性 reserve = target×pop×日耗`
| | |
|---|---|
| **實得 vs 斷言** | **96** vs 手抄的 `4 × pop 10 × 0.8 = 32` |
| ★**差在哪（不是猜的）** | **96 ＝ 32 × 3**；那個 3 ＝ `_self_use` 的 **`famine_escalation`**（`need_oracle.gd:115`）——**該隊 `food = 0` ⇒ `food_days = 0` ⇒ `×(1 + FAMINE_NEED_GAIN)`** |
| ★★**它要保護的不變量還在嗎** | ★**在**：同一支測試的相對斷言 **`謹慎192 > 中性96 > 賭徒48` 仍 PASS** ⇒ **人格化排序沒破，破的是【編碼】** |
| **判** | ★`stale-test` —— **測試手抄了一條 `reserve` 早就不用的公式**（`reserve(food)` 委派 `NeedOracle.need_keep`） |
★**修法屬另一票**（你要的話我開）：**把數值斷言換成相對／結構斷言** ——
**這正是 `03_implementer` 那條「測試也適用〈禁手抄物理〉」的同型案例。**

## ②`tools_demand_test`：`[FAIL] armorsmith material 仍 80（僅 weaponsmith 動，got 70.0）`
| | |
|---|---|
| ★**證據** | `outpost_system.gd:93` 的註記：**`mil-facility-cost70：material 80→70（仿 weaponsmith，同族，balance）`** ⇒ **成本是被【授權變更】過的，測試沒跟** |
| **判** | ★`stale-test` |
| ★**你問的 catch-22 關係** | ★★**不是近親。** catch-22 是「**蓋 outpost 採料本身要 50 material**」的循環；這條只是**成本表改過、斷言留在舊值**。**唯一交集是同一輪 balance 想降低建材門檻。** |
| ★★★**為什麼不能判 real-regression** | **真值從 80 降到 70 ＝ 門檻【放寬】** ⇒ **判成 regression 會把一個刻意的放寬讀成退步。** |

★**兩條都沒有為了好看去改測試**（照你寫死的判準）。**`unjudged` 現在是 0 條。**

# ★驗（含兩個陽性對照，不是只驗綠）
```
自檢：baseline 回頭比同一份輸出 → 兩張都 baseline=1 實測=1 ★PASS
陽性對照①：注入一條 USER ERROR 假失敗 → ★FAIL 新增失敗：+ [FAIL] 注入的假失敗
陽性對照②：砍掉結尾標記            → ★Q1 判 NO（「不知道跑了多少」）
```

# ★沒做的（範圍外，明說）
- **`slice_a_observe`**：★**照你的裁定不給 baseline**（它檔頭自己寫「觀測（非 gate）」）。
- **其餘床的盤點**：★**沒做** —— 你說只收這三張。
- **`scripts/simulation/` 一行未動。**
