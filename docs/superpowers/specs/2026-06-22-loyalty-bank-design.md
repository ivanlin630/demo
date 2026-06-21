# Pattern B banker — loyalty（第二個 banker，HIGH 嚴重度）

> `state-fight-scope` Pattern B：loyalty ~25 寫/12 檔，delta(薪資/義氣/aid/fatigue) vs **絕對 set**(split lifecycle 0.25-1.0 / defect=0 / recruit=0.5) → 絕對洗掉累積 delta（HIGH）。本塊設 LoyaltyBank 單一 owner（承 UnrestBank 模式 merge `3a883a6`）。

## 病
loyalty 散 25 寫無 banker：delta 累積（多處 `+=/-=`，部分**無 clamp 可負**）+ 絕對 set（split/defect/recruit/init）last-writer-wins 洗掉累積。

## 修：LoyaltyBank 單一 owner（cap 參數保 clamp 語意）
新 `scripts/simulation/loyalty_bank.gd`：
```
static func adjust(p, delta: float, reason := "", cap := 1.0) -> void
    p.loyalty = clampf(p.loyalty + delta, 0.0, cap)
static func set_baseline(p, value: float, reason := "") -> void   # lifecycle 蓄意基線
    p.loyalty = clampf(value, 0.0, 1.0)
```
- **delta 寫者** → `adjust`（cap 預設 1.0；**salary overpay 傳 cap=MAX_LOYALTY(0.95)** 保專屬上限）。原無 clamp 可負的 site → 現 clamp [0,cap]（負 loyalty = 潛在 bug，clamp 為正確化；回歸驗無依賴負值）。
- **絕對 set 寫者**（split 6 種 transfer-type 基線 / defect=0 / recruit=0.5 / init game_setup/generator/tutorial）→ `set_baseline`（lifecycle 正當基線，現為唯一絕對路徑、有 reason、可審）。
- 禁裸 `p.loyalty =`（除 bank 內）= 約定（grep 驗）。

## believability / 行為
- **clamp 寫者行為保留**（同數學 + cap 參數）；**無 clamp 寫者** 現 clamp [0,1]（正確化，balance 中性=負 loyalty 無語意）。回歸驗既有 loyalty/defect/salary/split 測不變。
- lifecycle 基線（split/defect/recruit）語意保留（轉移即重設忠誠），但現為唯一絕對路徑。

## 守恆
- loyalty 非守恆量 → InvariantAudit 無關；不碰 resources/coin → coin_eq 0。

## 驗收
- LoyaltyBank adjust(含 cap)/set_baseline 單測。
- 既有 loyalty 鏈測全綠（減薪/超付 cap 0.95/義氣/aid/defect=0/split 基線 行為不變）。
- 2 年 world_sim：loyalty/defect/分裂 行為近基準、headless 全綠、coin_eq/InvariantAudit 0。
- grep 驗無裸 loyalty 寫（除 bank）。

## 檔案
- 新 `scripts/simulation/loyalty_bank.gd`。
- 改 ~25 寫者（grep 定位）：`event_unrest_split.gd`(122-127 set_baseline)、`faction_ai_system.gd`(1399 adjust)、`game_setup.gd`(208,485 set_baseline)、`npc_combat_system.gd`(266 adjust)、`interaction_system.gd`(410,735,982 adjust)、`person_generator.gd`(54 set_baseline)、`player_command_system.gd`(618,662 adjust,1317 set_baseline)、`recruit_tutorial.gd`(20 set_baseline)、`reaction_system.gd`(26,76,254 adjust,276 set_baseline=defect 0)、`resource_system.gd`(333 adjust)、`sim_runner.gd`(299 adjust)、`salary_system.gd`(68 adjust cap=MAX_LOYALTY,73 adjust)。
- `headless_test.gd`：LoyaltyBank 單測 + 既有沿用。
- 2 年 world_sim。

## 非本塊
- resources/anon_treasury/outpost_owner banker = 各別 slice（resources 110 寫/anon_treasury coin **守恆敏感需嚴審**）。
