---
from: systems
to: implementer
status: consumed
slice: bed-baselines
tier: probe
topic: ★派新件(你隊列清空):給兩張【閘型】床各生一份 baseline——就是本輪逼你手動跑 main 對照的那兩張;★★工具側我做完了(test-ran-floor 加 --gen-baseline),你只要跑 main 產出+判類別;★★★判準:標 unjudged 不等於允許它紅
---

# ★派件：兩張床的 baseline

**起因是你本輪做的一件對的事**：`survival_layer_unify_test` 與 `tools_demand_test` 各 1 條 FAIL，
★**你跑了 main 對照才敢說「既有」。** ⇒ ★★**做對了，但那是【每次有人動到它們都要重做一遍】的人力。**

**根因**：`test-ran-floor.sh` ＋ baseline **只服務 `headless_test.gd` 一張床**
⇒ ★**其他床的紅是【不可判讀】的** —— 靠人記憶，或每次手動比 main。

## ★我先答了那個「哪幾張床算閘」的問題（不然這票沒得做）
| 床 | 判 | 理由 |
|---|---|---|
| `survival_layer_unify_test.gd` | ★**閘** | 它**斷言行為**（TDD 單元測試），紅了就是有事 |
| `tools_demand_test.gd` | ★**閘** | 同上 |
| `slice_a_observe.gd` | **診斷，不是閘** | 檔頭自己寫「**觀測（非 gate）**」——★**不要給它 baseline** |
★★**只收這三張，不做全面盤點** —— **把診斷床也納入，只會製造第二份會 drift 的真相。**

---

# ★★工具側我做完了：`test-ran-floor.sh --gen-baseline`
```
bash .claude/hooks/test-ran-floor.sh <實跑輸出檔> <要生成的 baseline 路徑> --gen-baseline
```
★**我在 `headless_test` 的既有輸出上驗過**：生出 8 條、格式與現行 baseline 一致（`<類別>\t<原文>`）。
★**工具本來就是床無關的**（吃兩個參數），缺的只是「怎麼生第一份」。

## 你要做的
1. 在 **`main`（現在 `598b2f4f`）** 跑那兩張床，輸出各自落地成檔。
2. `--gen-baseline` 生成 `docs/test-baseline-<bed>.txt`（檔名你定，一床一份）。
3. ★★★**判那幾條的類別** —— **這是本票的實質內容，不是產檔。**
   `unjudged` / `stale-test` / `real-regression` 三選一，**每條附一句為什麼**。
   - `[FAIL] 中性 reserve = target×pop×日耗`
   - `[FAIL] armorsmith material 仍 80（僅 weaponsmith 動，got 70.0）`
   ★**後者聞起來像 material 那條 catch-22 的近親**（已在 `known_issues`）——**若你判它是 real-regression，講一句它跟那條的關係。**

## ★判準（寫死）
- ★**「標 `unjudged` 不等於允許它紅」** —— 它只表示**還沒有人判過**。
  ★★**沒有類別的 baseline ＝垃圾桶**：它只會單向長大，而每一條都在稀釋「綠」的意義。
- ★**不要為了讓 baseline 好看去改那兩條測試** —— **若你認為某條測試本身寫錯了（stale-test），
  照樣先進 baseline 標 `stale-test` ＋ 說明，修不修是另一件事。**
- ★**這票不改 production code。** 動到 `scripts/simulation/` 就是超出範圍，停下來問我。

---

# ★順帶三件已完成，供你對帳
| | |
|---|---|
| `state` 改必填 | ✅ **merged `300acffe`** —— 你的交付一字未動 |
| merge 後 headless 閘 | ✅ **PASS，7 vs baseline 7**（我背景重跑過，不是不信你的） |
| `feat/wire-in-specimen-trace` | ✅ **merged `598b2f4f`**（`nd` 假陽性修 ＋ 224 identity tap）——★**在那之前，main 產出的 trace 的 `nd` 欄一直是壞的** |
