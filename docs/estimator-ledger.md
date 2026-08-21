# 估算器總帳（estimator ledger）

**立帳**：2026-08-21，**用戶令**：「**三個說謊的抓到了，別等第四個靠餓死一村曝光**」。
**審計尺**：意圖帳〈**估算器 ＝ 信念追物理真形狀**〉row。
**範圍**：引擎裡所有「**算給決策看的預估值**」。
**與缺件表互補**：**缺件表 ＝ 沒算的維度**；**本帳 ＝ 算了但算錯的**。

**分工**：**systems 列族譜＋假設欄（code-read）**／**measurer 抽驗物理欄（實測）**。
**分類**：`誠實` ／ `說謊` ／ `未驗`。**負斷言紀律：窮盡列舉、禁 `head` 截斷。**

## ★輸入血統（用戶立法 2026-08-21，`no-copy-law`）

| 血統 | 定義 | 合法性 |
|---|---|---|
| **①讀真實狀態** | 直接讀世界／自身當下值（食物存量、實際被動所得） | **誠實**，鼓勵 |
| **②手抄物理死常數** | 把物理常數**再抄一份**進估算器（`2.0` 格/日、`3.0` 天） | ★**禁止**——**物理存兩份必 drift** |
| **③純設計尺度** | 不對應物理量的設計旋鈕（耐性天、安全係數） | **合法**（多已人格化） |

**★【估算器禁手抄物理】**：估值必須
**(a) 從物理同源推導**（移動估 ＝ 移動系統同顆常數；工期估 ＝ 工期表 ÷ 自隊勞力 ÷ **施工推進 cadence**），或
**(b) 讀自身狀態／經驗**（覓食基準 ＝ **實際被動所得**）。

**∴ 修法形狀 ＝ 改接線，不是改數值。**（把 `2.0` 改成 `5.0` ⇒ **三個月後又爛一次**。）
**②類全數改推導／讀態。** 守衛見 §F。

---

## A. 已坐實「說謊」

| # | 估算器 | 血統 | 假設（code-read） | 物理真值 | 偏差 | 狀態 |
|---|---|---|---|---|---|---|
| A1 | **`camp_marginal`**（`marginal_economy.gd:48`） | **②** | `inflow_est − forage_floor`，**且 `forage_floor` ＝「覓食能全額餬口」** | 目標族群**零被動收入**、runway 1–4 天 | **基準線與世界矛盾** ⇒ `camp_u` 天花板 **0.826** vs 對手 3.17+ | ★**修中**（折現磚）；修法＝**(b) 讀實際被動所得** |
| A2 | **`PathSystem.eta_ticks`**（`path_system:158-160`） | **②** | `path_cost × BASE / (1−fatigue)` —— **只有疲勞** | `_move_cost` 吃**隊速／地形／疲勞／超載／車輛**＋clamp `[BASE/3, BASE×3]`；**porter 永遠超載 ⇒ 每格吃 MAX** | **系統性低估 3×** | ★**修中**（`eta-single-model`）；修法＝**(a) 呼叫 `_move_cost` 同源** |
| A3 | **`MOVE_TILES_PER_DAY`**（`goal_resolver.gd:525`） | **②** | **`2.0` 格/日**（自標「淺啟發」） | `BASE_MOVE_TICKS = 48` ⇒ **基準 5 格/日**（超載時 144 ⇒ 1.67） | **對正常隊高估移動時間 2.5×** | **待修**；★measurer C-1 **重驗維持「說謊」**；修法＝**(a) 併入 `eta-single-model`** |
| A4 | **`BUILD_DAYS_EST`**（`goal_resolver.gd:526`） | **②** | **`3.0` 天** flat（自標「淺啟發，非讀細 `BUILD_TICKS`」） | **見 §E**：`ticks ÷ (pop × 24)`<br>`TASK_BUILD` civilian L1 @pop1 ＝ **4.17 天** | ★**低估 −28%**（**非**先前宣稱的「高估 7×」，見下方撤回） | **待修**；修法＝**(a) 單一真相源** |
| A5 | **`BUILD_DAYS_EST` 用在 `TASK_SETTLE`**（同 :526→:539） | **②** | 同一顆 `3.0` 天**也拿去估紮營** | `L0_TO_L1_CORVEE_DAYS(3) × TICKS_PER_DAY(240) = 720` ticks<br>⇒ **@pop1 ＝ 30 天** | ★★**低估 10×**（**本帳先前完全漏列這條路徑**） | **待修**（同 A4 一顆） |
| A6 | **`settle_eta_days`**（`decision_context.gd:335`） | **②** | `CORVEE_DAYS(3) + 殘距日` —— **把「3」當天數用** | 同 A5 ＝ **30 天 @pop1** | **低估 10×**；消費端 `terms.gd:213-217` **紮根可行性** ⇒ **以為撐得完** | **待修**（同一顆） |

### ⚠️ 撤回：先前「A3＋A4 同向偏」的合成結論

**本帳前一版寫**：「A3 與 A4 都朝高估遠處成本偏 ⇒ 決策層系統性不去遠處建設」。
**該結論作廢。** 根據 measurer C-1（我已自驗坐實，見 §E 證據鏈）：
**A4 方向相反 —— 是低估工期，不是高估。**
`sim_runner.gd:153` 把 `outpost_tick` 註冊為 `"lod": LOD_NEAR`，`NEAR_CADENCE = TICKS_PER_HOUR = 10`
⇒ `outpost_system.gd:311` 的 `ticks_left -= pop` **每日執行 24 次**（非 240 次）
⇒ **真值 ＝ `ticks ÷ (pop × 24)`**。我前一版誤用 ÷240，方向就翻了。

**真正的合成結論改成 §E**，而且比原來那條**嚴重得多**。

---

## E. ★★★ 工期物理五份帳 —— 沒有一份是對的

**同一個物理量「工期天數」，引擎裡有六份獨立公式，跑出三種互相矛盾的答案。**
**真值**（唯一權威）：`outpost_system.gd:311` `ticks_left -= max(pop,1)` @ `LOD_NEAR`
⇒ **`days = ticks ÷ (pop × TICKS_PER_DAY ÷ NEAR_CADENCE)` ＝ `ticks ÷ (pop × 24)`**

| # | 站點 | 它的換算 | vs 真值 | 這顆餵給誰 |
|---|---|---|---|---|
| 1 | `goal_resolver.gd:526,539` | flat `3.0` 天 | build **−28%**／settle **低估 10×** | `_estimate_delay_days` → **折現** |
| 2 | `decision_context.gd:335` | `CORVEE_DAYS + dist` | settle **低估 10×** | `terms.gd:213` **紮根可行性** |
| 3 | `persist_strength.gd:95` | `ticks_left ÷ pop`（**漏 ÷24**） | ★**高估 24×** | `safe_ratio = runway ÷ eta` → **要不要放棄工程** |
| 4 | `faction_ai_system.gd:3799` | `BUILD_TICKS ÷ pop`（**漏 ÷24**） | ★**高估 24×** | **糧橋 go/no-go** → **派不派建造隊** |
| 5 | `faction_ai_system.gd:4548` | `ticks ÷ pop ÷ **240**` | ★**低估 10×** | `build_eta_days < food_days` → **求生蓋田閘** |
| 6 | `decision_context.gd:364` | `BUILD_TICKS ÷ **240**`（★**連 pop 都沒除**） | **低估 10× 且無視隊伍規模** | `_build_days` → 決策 ctx |

**⇒ 六份全錯，錯法三種，最極端兩份相差 240 倍（#3 高估 24× vs #5/#6 低估 10×）。**

> ★**第 6 份是守衛掃出來的，不是我讀出來的。**
> 我手寫的「窮盡」grep 漏了它（pattern 沒涵蓋 `BUILD_TICKS[...]) / float(...)` 這種寫法）。
> **這正是負斷言協議要機械掃描、不信人工窮盡的理由**——記錄在案。

### ★這是血統②的教科書標本
沒有任何一顆是「數值調錯」——**每一顆都是接線錯**：漏乘 cadence、把 person-ticks 當 elapsed、拿 `TICKS_PER_DAY` 當推進率。
**把哪個數字改對都沒用**，因為下次有人再寫第六份時還是會抄錯。

### ★三條待驗病理（**假說，交 measurer 實測；禁當事實引用**）

1. **「決定去蓋 → 中途棄」結構性抖動**
   #1/#2 **低估** ⇒ 決定要蓋（看起來便宜）；#3 **高估 24×** ⇒ `safe_ratio` 分母暴增 ⇒ `safe_factor` 塌 ⇒ **蓋到一半放棄**。
   **同一條決策鏈的兩端方向相反。** 屬「反覆重試」家族。
2. ★★**#4 可能就是「settle 從未 dispatch」的閘**
   糧橋 `_need_food = pop × 0.8 × (travel + build) × margin`，**build 段高估 24×**
   ⇒ 需糧被算成 24 倍 ⇒ **`_avail_food < _need_food` 幾乎恆真 ⇒ 建造隊根本派不出去**。
   **與 `size_matter` arc 已記錄的「settle 從未 dispatch」對得上**，但**必須實測 `_log_dispatch_fail("糧橋不足")` 的實際觸發率才算數**（memory：`fileline_vs_interpretation` —— 有行號 ≠ 坐實因果）。
3. **#5 求生蓋田閘假 pass**
   註解寫明意圖是「**蓋得完的田才蓋**」，但 ÷240 讓工期看起來只有 1/10
   ⇒ **蓋不完的田也判定蓋得完** ⇒ **蓋到一半餓死**。直接踩「滿池餓死」arc。
   （**註**：#5 的 ÷240 錯法**與我前一版 A4 的錯法完全相同** —— 這個錯是可複製的，不是誰粗心。）

### 修法形狀（**改接線**）
**一顆單一真相源**，由**施工推進站自己**導出，供全部五處呼叫：
`OutpostSystem.build_eta_days(ticks_left: int, pop: int) -> float`
分母**不得手抄 `24`**，須從**施工 tick 註冊的 cadence 同源推導**
（`TICKS_PER_DAY / NEAR_CADENCE`）—— 日後若 `outpost_tick` 改掛 `LOD_FAR`，**五處估值自動跟著改**。
**這一條就是血統法的驗收標準。** spec：`2026-08-21-build-eta-single-source-HOW.md`

---

## B. 待驗（`declared-unverified`）—— **假設欄已列，等 measurer 物理欄**

| # | 估算器 | 血統 | 假設（code-read） | 要驗什麼 |
|---|---|---|---|---|
| B1 | `_inflow_est`／`migrant_marginal`／`facility_roi`／`relocate_value`（`marginal_economy.gd`） | ② | `OUTPOST_MULT [1.0,1.4,2.0]` **鏡射** `FoodFlow.OUTPOST_MULT`；`MIGRANT_UPKEEP` ＝ 食物常數 DERIVED | ★**measurer C-2 已回：鏡射無 drift ＝ `誠實`**。剩 `PLANNING_HORIZON_DAYS=90` 對**非 facility** 族是否成立 |
| B2 | `TradeValuation`（`BASE_PRICE`／`TARGET_PER_POP`／`RESERVE_*`） | ③（多） | 一組 TEST VALUE 常數 | **成交價 vs 估價**的實際落差；`FOOD_RESERVE_TICKS=20` 是否讓瀕餓隊仍不賣糧 |
| B3 | 投靠吸收估（`terms.gd:189-190`、`JOIN_LOW_AMBITION_FLOOR`／`REP_MAGNET_W`） | ③ | 生存壓 ×（1 ＋ host `protector_rep` × W） | ★**QA 已坐實「投靠 util 對、執行沒接上」** ⇒ **要驗「估的收容機率」vs「實際被收容率」** |
| B4 | 派遣 ETA ＋ 口糧估（`faction_ai:3797-3799`） | **②** | `ETA_total = 去程 + 建程` | ★**已升級為 §E-#4，列首驗**（糧橋高估 24×） |
| B5 | 可勝性／威脅估（`threat_assessment`、`power_ratio`） | ③ | `power_ratio` 貢獻 `(ratio−1)×0.5`；`ratio≳5` 才過門檻 | **估的勝率 vs 實際戰果** |
| B6 | facility score 假設層 | （待列） | —— | —— |

---

## C. 給 measurer 的物理欄工單（**逐顆兩欄、分類 誠實/說謊/未驗**）

**C-1 已回**（A4 翻案，**已消化並自驗**）／**C-2 已回**（鏡射無 drift ＝ `誠實`）。

| 項 | 內容 | 狀態 |
|---|---|---|
| C-1 | `_estimate_delay_days` 估值 vs 實際完成天數 | ✅**已回＋翻案** |
| C-2 | `OUTPOST_MULT` 鏡射 drift | ✅**已回＝誠實** |
| C-3 | B3 投靠：**估的收容機率 vs 實際被收容率** | 待續 |
| C-4 | B4 派遣帶糧 vs ETA | ★**改由 §E-#4 取代，升列首** |
| C-5 | B2／B5 抽驗 | 待續 |
| **C-6** | ★★**新增**：§E 三條病理實測（棄工抖動／糧橋 24× 擋派遣／求生閘假 pass） | **新派** |

---

## D. 處置原則（憲章）
- **`說謊` ⇒ 事實修正批次**（**估算器說謊 ＝ 已知壞，考前清**）
- **`未驗` ⇒ 標 `declared-unverified`**，**不假裝它是誠實的**
- ★**血統②一律改接線**（推導／讀態），**禁只改數值**
- ★**修正批次隨折現磚同窗**（blueprint 排程：**不搶 implementer 主線**）

## F. 守衛
- `scripts/debug/time_const_check.gd` ＝ **既有**：驗導出常數 ≡ 原硬編值（**遷移驗證**，不抓手抄）
- ★**新增** `.claude/hooks/estimator-lineage-scan.sh` ＝ **抓血統②候選**：
  估算器域內出現**物理量名樣**常數（`*_PER_DAY` / `*_DAYS_EST` / `*_TICKS` / `*_SPEED`）
  ⇒ **必須在本帳有血統標註**，否則紅。**掃不到的（公式型手抄）走 P7 📜 declared**。


---

## G. 血統③／②鏡射 分類表（守衛 `estimator-lineage-scan.sh` 規則1 的標註源）

**同源推導（血統①、守衛自動放行、★正確示範）**
`CAMP_URGENCY_DAYS = ResourceSystem.PROVISION_DAYS`／`FAMINE_SAFE_DAYS = ResourceSystem.FORAGE_FLOOR_DAYS`

### ★②鏡射：註解自稱「對齊 X」，code 卻寫死字面值

| 常數 | 值 | 註解宣稱對齊 | 對方現值 | 現況 |
|---|---|---|---|---|
| `DESPERATION_DAYS`（`terms.gd:7`） | `3.0` | `WARNING_DAYS` | `faction_ai:103` ＝ **3.0** | 相等，**未 drift** |
| `SLACK_COMFORT_DAYS`（`decision_context.gd:25`） | `7.0` | `SURVIVAL_RECOVER_DAYS` | `faction_ai:104` ＝ **7.0** | 相等，**未 drift** |
| `SURVIVAL_SATED_DAYS`（`need_hierarchy.gd:16`） | `5.0` | 「對齊 forage floor 域」 | `FORAGE_FLOOR_DAYS` ＝ **5.0** | 相等，**未 drift** |
| `RETURN_HYSTERESIS_DAYS`（`terms.gd:4`） | `5.0` | 「＝`RESTOCK_DAYS` 重用非新魔數」 | `RESTOCK_DAYS` ＝ **5.0** | 相等，**未 drift** |

★**四顆目前全部相等 ⇒ 沒有 bug ⇒ 但這正是危險形狀**：
**註解已經在宣稱「我等於 X」，code 卻沒接上 X。** 任何人改 X 的那天，四顆全部無聲 drift。
**修法＝改成引用（`= X`），行為 byte-identical、可用 fp 三跑證零變更。** 零風險、永久消滅 drift。

### 血統③（純設計尺度，合法）
`COMMIT_HORIZON_DAYS` 5.0（沉沒成本視野）／`DISTRIB_DEFICIT_DAYS` 4.0（unrest 回升線）／
`JOIN_REJECT_COOLDOWN_TICKS` 480（重選 cooldown）／`RESTOCK_DAYS` 5.0（商隊補給線）／
`STALL_BASE_DAYS` 8.0（耐性基準，已人格化 ×`patience_factor`）／`SURPLUS_FOOD_DAYS` 7.0（餘糧門檻）
