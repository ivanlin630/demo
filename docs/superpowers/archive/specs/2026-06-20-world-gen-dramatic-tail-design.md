# world-gen 戲劇性尾巴（dramatic tail）— 設計 spec

> 系統(HOW)spec。回應藍圖 ruling `2026-06-20-blueprint-to-systems-measurement-rulings`（修訂 #0）。藍圖定 WHAT（多數凡人 + 關鍵少數狂人，狂人驅動立國/血仇/陰謀），分佈形狀 = 系統 HOW。

## 1. 問題（藍圖追到的真因）

2 年量測立國/血仇/裁決/誘殺全 0。藍圖追 `person_generator.gd` 找到根因：**世界沒極端值，人人平庸**。
- `values[v] = randf_range(0.2, 0.8)` → 無一人野心/殘忍/計謀 >0.8。
- `skills base = randf_range(0.0, 0.3)`（leader +0.1）→ 人人起始無能。
- 複合戲劇門檻（好戰>0.7 AND 野心>0.6）幾乎跨不過 → 無 outlier = 無戲。

**雙路徑都中**：(a) procedural `generate`（anon→named 晉升、member 生成、random 模式）= 系統根；(b) explicit config leader（量測 config 的值也中庸，max 好戰 0.8 無 0.9+、無高計謀）→ 2 年世界漂向平庸。

## 2. 解法：集中式 outlier 尾巴

**多數凡人 + 關鍵少數狂人**（非人人微 quirk）。對齊藍圖 feel + payoff（謀士識破全隊吞的謊）。

### (a) `PersonGenerator.generate` 戲劇尾巴（procedural 根）
- **多數平庸**：values 預設窄帶（比現 [0.2,0.8] 更收 → 凡人更凡）。
- **per-person outlier roll**（TEST VALUE 機率；leader 更高）：命中 → 抽一個**連貫 archetype 簇**推極端：

| archetype | 極端 values | skills 抬升 |
|---|---|---|
| 霸主 | 野心+好戰+統領 高 | 統領 |
| 屠夫 | 殘忍+好戰 高、信義 低 | 戰鬥 |
| 謀士 | 計謀 高、慎重 高 | 計謀+偵查 高起點 |
| 懦夫 | 求生欲 高、好戰+野心 低 | — |

- **skills 尾巴**：多數仍低（0.0-0.3），但 leader + outlier 給高起點（宿將/老謀斥候）→ 解 #2「裁決恆 0」（高計謀謀士才識破）。
- 極端帶/窄帶/outlier 機率/leader 倍率 = 全 TEST VALUE。

### (b) 量測 config 種子極端 leader（讓重量立即有戲）
- `config/world_sim.json`（+ 視需要 `game_sim_test.json`）：把幾個 leader 值改極端（1 霸主 0.9 野心、1 屠夫 0.9 殘忍、1 謀士 0.8 計謀+高偵查 skill）→ 重量不必等晉升即有狂人。
- config 自由改域（CLAUDE.md）。

## 3. 範圍

- **只做 #0**（藍圖最高優先，root，最可能連帶解 #3 魂）。
- **OUT（後續）**：#1 經濟閉環+腐壞壓力（並行軸，下一輪）、地圖尺寸（系統評估，藍圖「分佈 > 地圖」延後）、觸發場景（#0 重量後數據決定）。
- **守恆 / 行為**：只改 person 生成值，不碰 state 流/守恆。既有 explicit config 隊的 leader 值由 config 定（generate 不覆寫 explicit）——確認 generate 只用於 procedural，不污染 explicit。

## 4. 風險 / 注意

- **explicit vs procedural 邊界**：`GameSetup._setup_explicit_teams` 的 leader/named 值來自 config（不走 generate）；generate 只 procedural（晉升/member/random）。改 generate 不影響 explicit 既設值 → 故 (b) config 種子必要（否則重量 explicit 隊仍中庸，要等死亡晉升才見尾巴）。確認此邊界。
- **平衡未知**：極端值入世界 → 行為更激烈（戰爭/分裂/脫軌變多）。可能破壞既有平衡假設（TEST VALUE 場景）。回歸驗不崩 + 守恆；feel 偏差回呈藍圖。
- **可重現**：generate 已 seeded（seed_offset）；outlier roll 用同 rng → 可重現。

## 5. 驗收

- headless 全綠、coin_eq=0、InvariantAudit 0（極端值不破守恆/不崩）。
- `generate` 產出分佈：多數窄帶 + 可見極端尾巴（測試驗：N 抽樣中有 >0.85 與 <0.15 的 values、有 >0.5 的 skills）。
- **world_sim 重量**：立國/血仇(feud)/裁決/vendetta 至少數項**由 0→非零**（藍圖預測狂人驅動魂自己冒）→ 證實 #0 是 root。
- 既有測試行為變化（極端值入世界）= 預期，非零漂移；既有精確值斷言放寬或用固定 seed。

## 6. 給實作（plan 拆）

- Task1 `PersonGenerator.generate` 戲劇尾巴（窄帶 + outlier archetype 簇 + skills 尾巴）+ 分佈測試。
- Task2 量測 config 種子極端 leader（world_sim.json 幾個 archetype）。
- Task3 回歸（headless 守恆）+ world_sim 重量 + emergent 0→非零回報。
