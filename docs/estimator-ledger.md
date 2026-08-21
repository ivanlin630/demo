# 估算器總帳（estimator ledger）

**立帳**：2026-08-21，**用戶令**：「**三個說謊的抓到了，別等第四個靠餓死一村曝光**」。
**審計尺**：意圖帳〈**估算器 ＝ 信念追物理真形狀**〉row。
**範圍**：引擎裡所有「**算給決策看的預估值**」。
**與缺件表互補**：**缺件表 ＝ 沒算的維度**；**本帳 ＝ 算了但算錯的**。

**分工**：**systems 列族譜＋假設欄（code-read）**／**measurer 抽驗物理欄（實測）**。
**分類**：`誠實` ／ `說謊` ／ `未驗`。**負斷言紀律：窮盡列舉、禁 `head` 截斷。**

---

## A. 已坐實「說謊」

| # | 估算器 | 假設（code-read） | 物理真值 | 偏差 | 狀態 |
|---|---|---|---|---|---|
| A1 | **`camp_marginal`**（`marginal_economy.gd:48`） | `inflow_est − forage_floor`，**且 `forage_floor` ＝「覓食能全額餬口」** | 目標族群**零被動收入**、runway 1–4 天 | **基準線與世界矛盾** ⇒ `camp_u` 天花板 **0.826** vs 對手 3.17+ | ★**修中**（折現磚） |
| A2 | **`PathSystem.eta_ticks`**（`path_system:158-160`） | `path_cost × BASE / (1−fatigue)` —— **只有疲勞** | `_move_cost` 吃**隊速／地形／疲勞／超載／車輛**＋clamp `[BASE/3, BASE×3]`；**porter 永遠超載 ⇒ 每格吃 MAX** | **系統性低估 3×** | ★**修中**（`eta-single-model`） |
| A3 | **`MOVE_TILES_PER_DAY`**（`goal_resolver.gd:525`） | **`2.0` 格/日**（自標「淺啟發」） | `BASE_MOVE_TICKS = 48` ⇒ **基準 5 格/日**（超載時 144 ⇒ 1.67） | **對正常隊高估移動時間 2.5×** | **待修**（blueprint 列首修） |
| A4 | **`BUILD_DAYS_EST`**（`goal_resolver.gd:526`） | **`3.0` 天**（自標「淺啟發，非讀細 `BUILD_TICKS`」） | `BUILD_TICKS civilian = [100,300,600]` person-ticks ÷ 勞力 ÷ 240<br>⇒ **L1 @pop=1 ＝ 0.42 天** | **高估工期 ~7×**（L1） | **待修** |

### ★★A3＋A4 的合成效果（**我在列帳時才看見的**）
**兩者都朝【高估「去做遠處／要花時間的事」的成本】偏。**
而 `goal_resolver` 的 `_estimate_delay_days` **正是折現的輸入**
（`DISCOUNT_BASE = 0.5`、**絕境→高折現率、遠 candidate 折趨零**）
⇒ ★**決策層可能系統性地「不去遠處建設」**，而**原因不是設計意圖，是兩個淺啟發常數各自偏了一截**。
**這條要 measurer 驗**（見 §C-1）。

---

## B. 待驗（`declared-unverified`）—— **假設欄已列，等 measurer 物理欄**

| # | 估算器 | 假設（code-read） | 要驗什麼 |
|---|---|---|---|
| B1 | `_inflow_est`／`migrant_marginal`／`facility_roi`／`relocate_value`（`marginal_economy.gd`） | `OUTPOST_MULT [1.0,1.4,2.0]` **鏡射** `FoodFlow.OUTPOST_MULT`；`MIGRANT_UPKEEP` ＝ 食物常數 DERIVED | **鏡射有沒有 drift**（兩份常數是否仍相等）；ROI 的 `PLANNING_HORIZON_DAYS=90` 對**非 facility** 族是否仍成立 |
| B2 | `TradeValuation`（`BASE_PRICE`／`TARGET_PER_POP`／`RESERVE_*`） | 一組 TEST VALUE 常數 | **成交價 vs 估價**的實際落差；`FOOD_RESERVE_TICKS=20` 是否讓瀕餓隊仍不賣糧 |
| B3 | 投靠吸收估（`terms.gd:189-190`、`JOIN_LOW_AMBITION_FLOOR`／`REP_MAGNET_W`） | 生存壓 ×（1 ＋ host `protector_rep` × W） | ★**QA 已坐實「投靠 util 對、執行沒接上」** ⇒ **要驗「估的收容機率」vs「實際被收容率」** |
| B4 | 派遣 ETA ＋ 口糧估（`faction_ai:3797-3799`） | `ETA_total = 去程(dist/移速) + 建程(BUILD_TICKS/pop)` | ★**與 porter 餓死案疑關聯**：**派出去的隊帶的糧夠不夠走完 ETA** |
| B5 | 可勝性／威脅估（`threat_assessment`、`power_ratio`） | `power_ratio` 貢獻 `(ratio−1)×0.5`；`ratio≳5` 才過門檻 | **估的勝率 vs 實際戰果** |
| B6 | facility score 假設層 | （待列） | —— |

---

## C. 給 measurer 的物理欄工單（**逐顆兩欄、分類 誠實/說謊/未驗**）
1. ★**A3＋A4 合成**：`_estimate_delay_days` 的**估值 vs 實際完成天數**分佈
   —— **並報「遠 candidate 是否被折現折死」**（`goal_resolver` 的 `DISCOUNT_BASE=0.5`）
2. **B1 鏡射 drift**：`MarginalEconomy.OUTPOST_MULT` **是否仍等於** `FoodFlow.OUTPOST_MULT`
3. **B3 投靠**：**估的收容機率 vs 實際被收容率**
4. **B4 派遣**：**帶糧 vs ETA** —— porter 餓死案的直接對照
5. **B2／B5**：抽驗即可，**不必窮盡**

## D. 處置原則（憲章）
- **`說謊` ⇒ 事實修正批次**（**估算器說謊 ＝ 已知壞，考前清**）
- **`未驗` ⇒ 標 `declared-unverified`**，**不假裝它是誠實的**
- ★**修正批次隨折現磚同窗**（blueprint 排程：**不搶 implementer 主線**）
