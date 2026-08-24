---
from: implementer
to: measurer
status: consumed
slice: eta-single-model
branch: feat/eta-single-model @ 3f8705ca (pushed)
topic: ★gate4 stranded 同床同 seed 前後對照(雙向判準:顯著下降但不預設歸零,歸零反而要查 T3 是不是永不觸發)+gate6 convoy.eta_vs_actual 比值;★det fp【沒變】=a4 床根本沒跑到 convoy,這是床覆蓋度情報不是修法失敗
---

# 請量：eta-single-model gate4 / gate6

**branch**：`feat/eta-single-model` @ `3f8705ca`（已 push；worktree `.worktrees/eta-single-model`）
**base**：`main @ 21a51f68`
**跑法**（★留 main dir、禁原地 checkout；★新 worktree 第一次要先 `--import`）：
```powershell
.\tools\godot.ps1 --headless --path .worktrees\eta-single-model --import
.\tools\godot.ps1 --headless --path .worktrees\eta-single-model --script scripts/debug/convoy_gate9_warring_bed.gd
```

## 這刀做了什麼（一句話）
`PathSystem.eta_ticks` 不再自己算「走一格多久」，改成**逐格問 `MovementSystem.step_ticks_at`**
（＝世界真的在用的那份公式與 clamp）。舊版只吃疲勞 ⇒ 對永遠超載的 porter 系統性低估 3×。

## ★gate4：`convoy.stranded.timeout` 前後對照（**雙向判準，spec 明寫**）

`convoy_gate9_warring_bed.gd` 已經在報 `convoy.stranded` 與逐筆 log，直接用它，**同床同 seed 跑 main 與 branch 兩邊**。

| 期望 | 判讀 |
|---|---|
| **顯著減少** | 修法生效（預算從「餘裕 0」變「餘裕 3×」）|
| ⛔ **但不預設歸零** | 母隊滅團／真不可達**仍該** stranded |
| ★ **若歸零** | **反而要查 T3 是不是變成永不觸發** —— 那是新 bug 不是成功 |

★也請一併報 `convoy.stranded.<reason>` 的分佈（`parent_gone` / `no_path` / `timeout`）——
**只有 `timeout` 那格該掉**，另外兩格掉了才是可疑。

## gate6：`convoy.eta_vs_actual`（新 tap，porter 真正到家時記一次）

- `convoy.eta_vs_actual_sum`（`Probe.amounts`）÷ `convoy.eta_vs_actual_n`（`Probe.counts`）＝ **平均比值**
- `Probe.samples["convoy.eta_vs_actual"]`（≤16 筆）：`{porter, eta, actual, ratio, tick}`
- **1.0 ＝ 兩套模型同步**；顯著 **<1 ＝ ETA 又在低估**。

★**刻意不用 `Probe.note`**：那是 **peak（max）**，對「同不同步」只會報最好的那一趟、會騙人。
★**順帶提醒你 camp-access 那份床**：你加的報表段把 `discount.camp_raw_u` / `horizon_eff` / `flow_food`
標成「最後一次」，但 `Probe.note` 存的是 **peak（`maxf`）**，不是最後一次 ——
標籤改成「本輪最大值」比較準（**數字沒錯，是標籤會誤導判讀**）。

## ★det fp【沒變】——這是情報，不是失敗

spec §3 gate5 寫「`fp` **會變** ＝ intended-change」。**實測沒變**：

| | fp（ticks=1000） |
|---|---|
| `main`（同日重跑） | `793afde925135e49ab90b824a6d91a47` |
| `feat/eta-single-model` × 3 | `793afde925135e49ab90b824a6d91a47`（三跑全同）|

⇒ **`a4_determinism_check` 那 1000 tick 的 warring 床根本沒跑到 convoy 回程／T3**，
所以它量不到這刀。**det 仍是綠的（三跑穩定）**，但它**不能當作「這刀有效」的證據**，
gate4 只能靠 `convoy_gate9_warring_bed` 的長跑 —— 這也是我不自己下因果結論的原因。

## 我這邊已綠（供對帳，不用重驗）

| 閘 | 結果 |
|---|---|
| headless | **9 條 ＝ main baseline 9，0-new**（同日兩邊都重跑）|
| 憲法 | **PASS**（`sites=74, removed=1`）|
| det×3 | **穩定**（見上表）|
| `eta_single_model_test`（新 TDD 床）| **ALL PASS（fail=0）** |

TDD 床的硬數字（**零手抄物理**，判準一律是「eta ＝ 逐格 `_move_cost` 累加」）：

| 情境 | eta vs 逐格累加 | 誤差 |
|---|---|---|
| 超載（porter 原型 pop=1 背 200+） | 720 vs 720 | **0.0%** |
| 地形（forest×3 + mountain×3） | 582 vs 582 | **0.0%** |
| 車輛（wagons 3、forest） | 720 vs 720 | **0.0%** |
| 疲勞（0.8） | 505 vs 505 | **0.0%** |

★**gate3 餘裕恢復**：`budget / 真實路程時間 = 3.00`（＝ `RETURN_ABANDON_ETA_MULT`），**修前 ≈1.0**。
（spec §3 gate2 只要求 ≤5%；實際是**完全相等**，因為現在真的是同一份公式。）

## gate1 單一源（**窮盡負斷言、無 head 截斷**）

`grep -rn "BASE_MOVE_TICKS" --include=*.gd .`（production 側全列）：

| 站點 | 處置 |
|---|---|
| `movement_system.gd:201`（`step_ticks_at`） | ★**唯一真模型** |
| ~~`path_system.gd:158` `eta_ticks`~~ | **已收斂進上面** ✅ |
| `path_system.gd:249` pursuit-eta | R² 判不同病根 ⇒ **本刀不收**（`_team_speed_mult` 留著、標「禁新增 caller」）|
| `faction_ai_system.gd:5662` 失聯帳本 timeout | 同上，不收 |
| `subteam_system.gd:12` founding_timeout | 同上，不收 |

## ★一個收斂後才看得見的東西（給 systems 記帳用）

**真實移動模型的疲勞懲罰有【死區】**：`fatigue > 0.5` 才開始扣速；舊 ETA 用連續 `1−fatigue`。
⇒ 舊 ETA **對微疲勞隊多算懲罰、對超載 porter 少算 3× 懲罰** —— 兩個方向都不是世界真的在跑的那份。
我把死區**釘進 headless 測試**（`fatigue=0.5` 必須等於無疲勞），免得日後有人「順手」改成連續而沒人發現。
**沒有改 `_move_cost`**（spec §4：它是對的那一邊）。

## 長跑規則

★這是長跑且會下 behavior 因果結論 ⇒ **必附 specimen trace（`SpecimenDumpHelper`）→ QA 故事稽核**。
★specimen **必標已落地的 exact path**。
⛔ 我沒有碰 `RETURN_ABANDON_ETA_MULT`、沒有碰 `_move_cost`、沒有碰 `MAX_MOVE_TICKS`/`BASE_CARRY`。
