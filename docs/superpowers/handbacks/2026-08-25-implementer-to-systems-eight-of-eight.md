---
from: implementer
to: systems
status: consumed
slice: means-end-brick
branch: feat/means-end-brick @ 2c9c11ce (pushed)
topic: ★八條交付閘【全部完成】;★★第5條(估工時禁手抄 rate)落地後 fp 未變=「改接線不改數值」拿到機械證明;★可以派 measurer / 進 R² 了
---

# 八條交付閘全數完成

| # | 閘 | 狀態 |
|---|---|---|
| 1 | 缺設施 vs 缺原料分得開 | ✅ TDD 綠 |
| 2 | 遞迴 ＋ 環偵測 | ✅ TDD 綠（用 `weapon_melee_high → ore_steel → ore_iron` **資料真鏈**，非捏造）|
| 3 | `horses` 在 `public_storage` | ✅ `stock_sources` 兩處都讀 |
| 4 | 無手段終止不得靜默 | ✅ `means_end.no_means.<res>`（帶資源名）|
| ★5 | **估工時禁手抄 `rate`** | ✅ **本輪完成，見 §1** |
| 6 | `estimator-lineage-scan` | ✅ **PASS** |
| 7 | 驗收判準集合型 | ✅ falsifier ＝「未分類桶 ＝ 空集合」 |
| 8 | 交接標 exact path | ✅ 見 §3 |

## §1 ★第 5 條：產率權威單一化

| 抽出 | 誰共讀 |
|---|---|
| `worker_rate_of()` | ★**tick 路徑 與 means-end 同一支**（原本 inline 在 tick 迴圈 ⇒ 圈外唯一選擇是再寫一遍）|
| `runs_per_day()` | ★`TICKS_PER_DAY / NEAR_CADENCE` **導出**（產線在 near pass 的 per-team step）——**同 `build_ticks_per_day()` 的形狀** |
| `daily_output()` | ★`rate_const` 一律經 `RATES` 解析 —— **不讓任何人把名字背後的數字 inline 進來** |
| `_avg_skill` | 改 static ⇒ 兩邊同一支 |

★★**fp 未變（`5c1fa2fc…` ×3）＋ headless 8 ＝ baseline** ——
★**這正是重點**：**這顆 commit 改的是接線不是數值，而【相同的 fp 就是「抽出來的公式等於原本 inline 那行」的機械證明】。**
（★對照：A 那顆是真行為改動 ⇒ fp **該變**；這顆是等價重構 ⇒ fp **該不變**。**兩種預期我都事先講了，也都對上。**）

## §2 ★★★`predator_density` 那件事我收下你的訂正
> **出處分類消滅【碰撞】，但取代不了【語意判斷】；`tile.resources` 這個容器本身就混雜。**

★**我照裁定只做兩件**：**一次性標 `not_acquirable` ＋ falsifier 記錄它**。
⛔ **沒有為它動資料模型**（那是結構債，你已記進 `known_issues`）——
★**塞進這張票就是 scope 爆炸，而且會讓「means-end 有沒有做對」變得無法單獨判定。**

## §3 ★已落地 exact path
```
磚        A:\GDS\demo\.worktrees\means-end-brick\scripts\simulation\decision\acquisition_paths.gd
產率權威  A:\GDS\demo\.worktrees\means-end-brick\scripts\simulation\manufacturing_system.gd（worker_rate_of / runs_per_day / daily_output）
falsifier A:\GDS\demo\.worktrees\means-end-brick\scripts\debug\resource_shape_falsifier.gd
TDD       A:\GDS\demo\.worktrees\means-end-brick\scripts\debug\headless_test.gd（_test_meansend_*，3 顆）
輸出      C:\Users\I12\AppData\Local\Temp\claude\A--GDS-demo\f76908de-f9c2-467e-adba-8032fba7e243\scratchpad\shape_falsifier2.txt
```

## §4 ★還沒做的，我明講（不當作已完成）
- ★**磚還沒被【接進決策】** —— 目前它是一支可被呼叫的推理器，**但沒有任何 production 路徑呼叫它**。
  ⇒ ★★**acceptance ①「`tools`／`weapon_melee_low` 卡點顯著下降」現在【不可能達成】**，因為**沒人在用它**。
  ★**這是刻意的**：接線點（`_resolve_resource_prereq` 的手段 3／4）**會改變決策行為**，
  而**手段模型剛定案、我想先讓磚本身通過驗證再接**。
  ⇒ ★**要我現在接，還是先讓 reviewer / measurer 看這一版？你裁。**
- ⏸ `flow_utility` 的 stock 語意 —— **你說另開票，我沒碰。**
