---
from: implementer
to: systems
status: consumed
slice: camp-access
branch: feat/camp-access @ b968f492 (pushed)
topic: 四端同秤落地+我自己第一磚的量綱錯已修;★spec §4 預測不成立——4 條投靠沒回綠,真因不是 cap 而是 _inflow_est 規模曲線(pop≥20 飽和,per-capita 單調遞減);掠奪承諾反而回綠;附一起主 dir 誤寫事故已還原
---

# camp-access：四端同秤落地，一條預測翻案

**branch**：`feat/camp-access` @ `b968f492`（已 push）
**日期**：2026-08-21
**重跑指令**（worktree `.worktrees/camp-access`）：
```powershell
.\tools\godot.ps1 --headless --script scripts/debug/headless_test.gd
.\tools\godot.ps1 --headless --script scripts/debug/discounted_flow_test.gd
.\tools\godot.ps1 --headless --script scripts/debug/constitution_gate.gd
.\tools\godot.ps1 --headless --script scripts/debug/a4_determinism_check.gd
```

---

## §1 做了什麼（**全部是接線／量綱，零調參**）

### ①`DiscountedFlow.flow_utility` 正規化 —— **我自己第一磚的量綱錯**
分子是**整段視野的現值**（PV，最長 90 天 ⇒ δ-sum ≈ 17 天份），
分母卻寫死「10 天口糧」⇒ **任何 `gain ≥ 0.88×need` 的 option 都衝破 `CAMP_MARGINAL_CAP`**
⇒ 四個選項並列封頂、**順序資訊全毀**。

★**這坐實了你在 spec §3 標成「高信度假說」的那條**：
`camp_u` 確實長期坐在 cap 上（實測 P2a(a)：紮營 term ＝ **1.5 封頂**、併入 1.59 vs 紮營 1.61 的假並列）。
**但病根不是 cap 的值**，是分母 —— 所以**沒有動 cap**（照你「本刀不動 cap」）。

**修法**：分母改用**同一段視野、同一個 δ** 的口糧現值 ⇒ `utility ＝「這選項相當於幾倍餬口」`。
δ 與 H 在分子分母相消，**delay（`wait_mult`）與 cost 仍留在分子** ⇒ 等待與前期投入照樣被折價
（人格 δ 在此才有意義）。

**TDD `gate6`（紅→綠）**：`gain == need` 必須 **＝1.000**（不是封頂值，實測修前 **1.708**）／
`2×need → 2.000`／半份 → 0.500／**視野長短不改變倍數**／`delay 30 天`仍被折價（1.000 → 0.183）。

### ②`camp_drive` 改呼**同一個入口**
原本它自造一份正規化 —— 違反折現磚模組頭條「**禁為單一 option 造一次性公式**」。現已刪。
現在 **四個 call site**（窮盡，`grep -n flow_utility scripts/simulation/decision/terms.gd`，無 head 截斷）：
`:115` 覓食／遷移找糧、`:195` 佔村、`:208` 併入、`:229` 紮營。

### ③`camp_drive` 的 `delay_days` ＝ **工期**，不是 0
`camp_target_est` 估的是 **`outpost_level=1` 的村產** —— 那份流**在走到靶地 + 紮根工期完成前根本不存在**。
你 spec 的四選項表寫得很明白：「投靠/佔村＝現成 0；**紮營/建設＝工期**」。
我先前寫 0 ＝ **白送紮營一整段免費未來**。
現在 `camp_flow_delay_days = _hex_dist(自己, 靶地) + L0_TO_L1_CORVEE_DAYS`（**既有常數、零新旋鈕**）。
實測 P2a(a)：`camp_drive` **1.414 → 1.194**。

### ④★覓食**漏了 `wild_game`** —— 這是 `糧危(food2)…應覓食` 那條紅的真因
我原本只讀 tile 的 `food` 池，但**無據點隊的覓食實際上幾乎全靠 `HuntSystem` 的被動小獵**
（`resource_system.gd` collect 迴圈：無據點 → `hunt_small_game(active=false)`）。
⇒ **一個擺了 50 隻獵物的格子被我算成零產**。
收成單一源 `DecisionContext._tile_forage_yield`：①自家 L0 營地 ⇒ 池 × `L0_FORAGE_MULT`
②有 `wild_game` ⇒ 餬口率（`_forage_subsist_buffer / FORAGE_FLOOR_DAYS`，latch 見 HuntSystem buffer）
③兩者皆無 ⇒ `min(池, 餬口率)`。**這條紅已回綠。**

### ⑤刪死常數 `CAMP_URGENCY_DAYS`
改法後**零 caller**。窮盡確認（**無 head、無 glob 截斷**）：
`grep -rn "CAMP_URGENCY_DAYS" --include=*.gd --include=*.md . | wc -l` ＝ **1**，
且唯一那 1 筆是 `docs/tick_parameters.md:154` 的說明列 —— **已同步改掉**（commit `b968f492`）。
`grep -rn "norm_days" --include=*.gd . | wc -l` ＝ **0**。

### ⑥常設 tap：`discount.camp_capped`
你 spec §3 要「saturation 率要 measurer 報才算數」。我把它做成**常設可觀測**
（分母沿用既有 `discount.camp_evaluated`，另 `Probe.note("discount.camp_raw_u")` 記未夾值）
—— **不是修完就忘**。Probe-gated，det 三跑同 fp 已證行為中性。

---

## §2 閘

| 閘 | 結果 |
|---|---|
| 憲法 | **PASS**（`sites=74, removed=1`）|
| det×3 | **穩定**：`fp=880d3adf2fe280616bd0183db85a878c` × 3（`ticks=1000`）|
| `discounted_flow_test` | **ALL PASS（fail=0）**，含新 gate6 五條 |
| headless | **12 條**（見 §3 分流）|

### headless 對帳（★同日、同機、兩邊都重跑，不是跨 commit 比）
- **main baseline ＝ 9**（3 `[FAIL]` + 6 assertion）。
  其中 `T1:覓食 base 恆 1.0` **在 main 上就是紅的**（舊編碼過期）⇒ 我改成相對斷言後回綠
  ⇒ **我這邊的 baseline ＝ 8**。
- **branch ＝ 12** ＝ 8 baseline + **4 條投靠**。

★**兩條要更正我先前的說法**：
1. `紮營=1.0` **是 baseline 紅（main 上就紅）**，不是我碰出來的 —— 我之前判它是「新曝露」，錯了。
2. `掠奪 applicable + 承諾 → 應續掠奪` **回綠了**。
   你 spec §4 判它「本刀修不掉、標 `known-blocked-by: 承諾泛化磚`」——
   實際上 ③的工期折現把紮營從 1.414 壓到 1.194 之後，**帶承諾的掠奪就贏回來了**。
   ⇒ 那條紅**原本也是紮營高估的下游**，不是承諾泛化缺件。**沒有改測試、沒有調參。**

---

## §3 ★要你裁的一條：**4 條投靠沒有回綠，spec §4 的預測不成立**

你 spec §4 預測這四條「修完應回綠」，主因記為「投靠的 host 流入秤」＋次因 cap saturation。
**兩件事我都做了**（host 流已入秤、cap 已不封頂、工期已折現），**四條仍紅**。

### 實測（P2a(a) 場景，per-option util dump，非靜態推論）

| 量 | 值 |
|---|---|
| `join_host_flow` | **5.333/日**（host ＝ plains L1、pop 30 ⇒ 16.0/日 ÷ 30 × 我方 10 人）|
| camp `gain` | **11.314/日**（plains L1、pop 10）|
| `daily_need` | **8.0** |
| ⇒ `join_drive` | 0.667 倍餬口 × rep_mult 0.75 ＝ **0.500** |
| ⇒ `camp_drive` | 1.414 倍餬口 × δ³ 工期折現 ＝ **1.194** |
| ⇒ util | 紮營 **1.533** > 併入 **1.449**（差 0.084）|

### ★真因：`MarginalEconomy._inflow_est` 的**規模曲線**（實測、非推論）

`VillageEstimate.make("plains", outpost_level=1, farming=0, pop)`：

| pop | inflow/日 | per-capita |
|---|---|---|
| 5 | 8.000 | **1.6000** |
| 10 | 11.314 | **1.1314** |
| 20 | 16.000 | **0.8000** |
| 30 | 16.000 | **0.5333** |
| 40 | 16.000 | **0.4000** |
| 60 | 16.000 | **0.2667** |

**pop ≥ 20 之後 inflow 飽和在 16.0/日，人均因此單調遞減。**
⇒ **投靠任何有規模的 host，食物上必輸自建村** —— 而且我用的還是**偏袒投靠**的算法：
真正的邊際貢獻是 `inflow(30+10) − inflow(30) = 16.0 − 16.0 = 0`。

★ 這就是 memory 裡那顆「**有大有小 arc：CASE B 規模經濟 absent**」。
⇒ **四條投靠紅不是本刀接線沒做完，是四端同秤之後、模型對「規模」的誠實回答。**

### 附帶坐實 baseline 紅 `[p2a] join weight 太低 0.41`
`weight("join")` 對 `{義氣0.9, 信義0.8, 求生欲0.8}`（**野心未給 ⇒ 預設 0.5**）：
`0.81 × clampf(1−0.5, JOIN_LOW_AMBITION_FLOOR, 1.0) = 0.405`；
**同一隊** `weight("camp") = 0.5×0.4 + 0.0×0.3 + 0.8×0.3 = 0.44`。
⇒ **人格層根本沒有把投靠拉起來的力**（義氣 0.9 的隊，join 權重反而比 camp 低）。
這條在 **main 上就是紅的**。

### 我沒動的東西 / 三條出路（**你裁，我不自己選**）
- **(a) 改 fixture**：讓 host 真的是張更好的飯票（更高 `outpost_level`／更小 pop）
  ⇒ 測「投靠 vs 紮營」的**設計意圖**仍在，只是場景要合理。
- **(b) 動 `_inflow_est` 規模曲線**（規模經濟 arc 本體）⇒ **超出本刀**，且會動全世界的經濟估值。
- **(c) 動 `weight("join")` 的 `1−野心` 懲罰**（baseline 紅本體）⇒ **超出本刀**。

⛔ **(b)/(c) 我都沒碰**：為了讓紅轉綠去調它們＝**調參掩蓋**，你 spec §4 明令禁止。
⛔ **也沒有弱化任何斷言**。

---

## §4 兩件必須主動報的事

### ①★事故：一輪編輯誤寫到 **main dir**，已還原
有一次 `python` 編輯在 `A:\GDS\demo`（**main**）而非 worktree 下執行，
把 `camp_flow_delay_days` 那 6 行寫進了 main 的 `scripts/simulation/decision/decision_context.gd`。
- `git -C A:\GDS\demo diff` 確認：**只有我那 6 行，沒有混到任何別人的改動**。
- 已 `git checkout --` **單檔還原**，該檔現在乾淨（`git status` 對它無輸出）。
- **main 上另有別 session 的 WIP**（`terms.gd`、`join_accept_measure_bed.gd`、兩封 handback、
  `MERGE_MSG.tmp`、兩份 measurement 檔）—— **我一律沒碰**。
- 之後所有編輯改成**明確 `cd` + cwd assert**。
（同族血證：memory `feedback_concurrent_session_wip_sweep`。我這次是反向——不是掃入，是誤寫。）

### ②機制意圖帳對照不符（**照協議呈報，不自己改表**）
`docs/mechanism-intents.md:19`：**「覓食 ＝ 餬口地板（淨貢獻上限數日、不積累）；緊迫度隨存糧衰減」**
- **前半仍成立**：我用的就是既有 `_forage_subsist_buffer / FORAGE_FLOOR_DAYS`。
- **後半在 term 層不再成立**：覓食/遷移找糧的 base 改成「腳下 tile 的真實日產」，
  **不再隨 `food_days` 衰減**；飢餓改由 need coeff + survival boost 表達（那兩層本來就在）。
- 這是**你 spec 明令的改法**，但表是 WHAT 權威 ⇒ **請你判要不要更表**（表只服從用戶）。

---

## §5 我沒做、建議另立的

1. **`遷移找糧` 的 delay** —— 它要走過去，現在 `delay=0`。
   你 spec 的四選項表只把工期列給「紮營/建設」，所以我**照表沒加**；
   但「現成的流打贏要等的流」這句話同樣適用於它。**要不要加，你判。**
2. **`join_host_flow` 的邊際 vs 人均** —— 現行用「host 人均 × 我方人數」（偏袒投靠）；
   嚴格的邊際是 `inflow(host+我) − inflow(host)`，在飽和區 ＝ **0**。
   等 (b) 規模經濟 arc 一起處理比較合理。

## §6 下一站

- **世界層驗收（spec §7 三條）需要長跑 ⇒ 我沒有自己下因果結論**，
  照工作流硬規則走 **measurer 產數字 → QA 故事稽核**。
  你先前要的那個免費驗收訊號我也標在這：
  **`accept.join_accept + accept.join_reject` 總和**（上輪 ＝ 4）——
  ★但請注意 §3：**四端同秤之後投靠是「秤輸」而不是「秤不到」**，
  所以這個數字**很可能不會上升**，那**不代表接線沒做** —— 判讀請用 `camp.lost_to.*` 對照。
- 我接著開 **`eta-single-model`** 那張票（spec 已讀，`eta_ticks` 只有一個 production 消費端 `_estimate_eta_to`）。
  ⛔ 不會調 `RETURN_ABANDON_ETA_MULT`。
