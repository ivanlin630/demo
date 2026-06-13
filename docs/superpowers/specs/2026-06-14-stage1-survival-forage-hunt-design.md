# 階段1 開局生存：覓食 + 狩獵 — Design

> 日期：2026-06-14
> 議題：玩家核心迴路定為 Kenshi 型「下而上生存起家」。但無據點的流民小隊**現在沒有任何食物收入**（`collect_resources` 卡 `outpost_level>0`、無 forage），吃完初始糧必餓死 → 開局不可玩。本 spec 補開局生存地基：覓食（食物地基）+ 狩獵（texture / 激情時刻），玩家側與 NPC 側對稱。
>
> 本 spec 屬玩家核心迴路 4 階段拆分的**階段1**（階段2 招人 / 階段3 據點 / 階段4 成勢力，皆後續獨立 spec）。

## 設計核心

- **覓食不是新資源模型** — 是現有 `collect_resources` 的小 delta：去掉 outpost 閘 + 限食物 only + 比 outpost 更低的 forage 率。枯竭/回填/scale 鎖全用現成基底。
- **大軍不能靠覓食活，是數學自然結果**：收入端 `pop_mult` 封頂 2.0、消耗端 `pop` 線性 → 大群人均收入趨零。NPC 不亂覓食則靠 survival AI 加一條 path + viability 門檻（不是戰略引擎）。
- **狩獵分層**：小獵物 = 抽象求生 roll（緩檔一行字）；危險野獸 = 進遭遇戰（激情時刻，全控真風險）。野獸 = 臨時 pseudo-team，復用既有兩條戰鬥路徑。
- **節奏雙檔**：緩檔 zero grind（設 task → 跳時間 → 食物以離散敘述 episode 進，岔路才介入）；激情檔玩家冒險自找（全手動、真傷亡）。
- **對稱**：覓食 / 狩獵玩家與 NPC 走同一套食物 + 戰鬥數學，無玩家專屬機制。

## 不變量

- **覓食只給食物**：material / ore / goods 仍需 outpost；forage 不繞過據點經濟。
- **覓食必枯竭且 scale-capped**：抽取率 > tile 回填率（停駐→當地抽乾）；收入隨 `pop_mult`（≤2.0）封頂、消耗隨 `pop` 線性 → 大群人均趨零。此性質是「大軍不能覓食」的唯一保證，不得用特例 code 取代。
- **野獸守恆中性**：beast pseudo-team 無 coin / 有限資源；給的「肉」= 食物（不在 coin_eq 審計），用完即清。野獸不持有、不路由有限資源，不破守恆。
- **狩獵風險真實**：失敗 / 反擊走既有 body_parts 損傷 + 死亡順序（弱者先死）；成員陣亡為永久後果。
- **對稱**：任一新機制（forage path / 狩獵 / 野獸戰）NPC 必須同樣能用，無玩家專屬分支（見 invariants「對稱性」）。

## 1. 覓食（食物地基）

### tile 基底（已存在，不改）
`tile.resources["food"]`（平原初始 100-300）、`resource_cap["food"]`、`regenerate_tiles`（平原 8×harvest_factor/tick 回填至 cap）。

### 改動：`resource_system.collect_resources`
現況 line 47 `if tile.outpost_level == 0: continue` → 無據點直接跳過。

改為：無 outpost 時走 **forage 分支**（限食物、低率），有 outpost 維持現狀。

```gdscript
const FORAGE_RATE: float = 0.02   # TEST VALUE — 低於 COLLECT_RATE(0.05)；只減緩餓死不餵飽
# outpost_level == 0：
#   只採 tile food（material/ore/goods 跳過）
#   gain = productivity × tile.food × FORAGE_RATE × pop_mult × work_morale × harvest_factor
#         （無 outpost_mult、無 farming_level）
#   食物進 team.resources["food"]（不課稅、無公庫）
#   抽乾本格 food（既有扣減邏輯）→ 枯竭
```

枯竭 + scale 鎖（pop_mult≤2 vs burn 線性）→ 停駐慢性餓死、大軍人均趨零，自然逼遷徙 / 定居 / 改劫掠。

### 表現：離散敘述 episode
覓食所得**不靜默涓滴**，而是離散事件流。緩檔推進中跳出具體結果（採到野莓 +N / 一無所獲 / 追獵入林）。技術：復用既有 event / message 流（`SimMessageSystem` 或 event log），日邊界結算彙整成一條，避免 per-tick spam。

## 2. 小獵物（抽象 roll）

緩檔內，低風險小獵物（兔/鳥）= 求生技能判定，無場景：

```gdscript
# 求生(survival skill) + 偵查 → roll 命中 → +食物（小塊）
# 失敗 → 空手 / 偶發小傷（flavor）
# 同樣抽 tile.wild_game（見 3）→ 枯竭
```

## 3. 野獸 + 狩獵（texture / 激情時刻）

### 世界基底
`world_generator` 灑 tile 資源（類 `wild_horses`）：
- `wild_game`：平原 / 森林常見（鹿/豬），可獵、月再生（類 `_regen_wild_horses`）
- 稀有猛獸（熊/狼群）：低機率，可獵**且能伏擊**路過隊

### 野獸 = 臨時 pseudo-team
beast tag 的輕量 TeamData：無 leader / 無裝備 / 無外交 / 無 coin。「units」= 動物（單體熊 / 多體豬群 / 狼群）。stats：戰鬥力 + 行為類。獵畢 / 戰畢即清除。

### 行為 2-3 類（不做個別動物 AI）
- **逃型**（鹿）：嘗試逃離 → 復用既有 pursuit / flee；挑戰 = 追到（reward = 逮住）
- **戰型**（豬/熊）：主動近戰，獠牙 → body_part 損傷
- **伏擊型**（猛獸主動）：路過隊被野獸發起遭遇戰（獵人↔獵物反轉，不請自來的高潮）

### 兩條戰鬥路徑（對稱）
| | 玩家獵（激情時刻） | NPC 獵（自動） |
|---|---|---|
| 走 | `encounter_system`，beast 當 attacker/defender，整套機制原封 | `npc_combat_system`，beast = 一個 `team_strength` 值對撞 |
| 行為 | `decide_action` 加 beast 分支（逃 / 戰） | 抽象強度勝負 |
| 結算 | `resolve_encounter_end`：勝 → 肉=食物（+皮=material）；敗/傷走 body_parts | win → 食物進團；casualties 套 `_apply_casualties` |

### 風險報酬（分獸級，TEST VALUE）
- 鹿/兔：逃型，低險中糧，挑戰=追到
- 野豬：戰型，中險中高糧（獠牙傷腿/軀幹）
- 熊/狼群：高險高糧，能伏擊
- 風險 = 部位傷 + 成員陣亡（3 人隊損 1 = 重創）+ 耗箭/時間

## 4. NPC 側（survival AI 對稱）

### forage path（`faction_ai_system._trigger_survival`）
現有 cascade：Path1 回家 / Path2 掠奪 / Path3 投靠 / Path4 乞食 / 全失敗→idle。

插入 **forage path + viability 門檻**：

```gdscript
# viability：本格 food × FORAGE_RATE × pop_mult 預期收入 ≥ burn × 某比例？
#   （粗略等價：小群划算 / 大群不划算）TEST VALUE
# 划算 → TaskArbiter.try_set(TASK_FORAGE, 本格或鄰近高 food 格, PRIO_SURVIVAL)
# 不划算 → 不攔截，掉下去走現有 Path2 掠奪 / Path3 投靠 / Path4 乞食
# 位置：放在乞食(Path4)之前 — 小隊優先覓食而非空轉乞食
```

→ 小流民隊覓食活、大軍門檻擋掉走劫掠 → **無大軍蟑螂、無特例**。

### NPC 獵獸
NPC band 經過有 `wild_game` 的 tile 且飢餓 → 可發起 `npc_combat_system` 對 beast pseudo-team。弱隊獵硬獸掉人 = 真實，無特例。

## 5. 開局 config

3 身分劇本（config 可選）：孤身 / 流民小隊 / 逃兵。首劇本 = 直接丟（無教學）：幾人、少量初始糧、破刀、大半迷霧、無被塞目標。新增 `config/survival_start.json`（或類似）。

## 風險（給實作者）

- **forage 率 / viability 門檻 / 獸級數值全 TEST VALUE**：給粗值 → 跑 2 年 multi → `team_trace` 量測。**重點觀測：大軍有無亂覓食（門檻失效）、小隊能否靠覓食撐過開局、世界有無因 forage 放寬而食物通膨**。先量測再 tune，勿空想（交接「避免鑽牛角尖」教訓）。
- **faction_ai_system 已 2000+ 行**：forage path 是「插一條 + 一門檻」，勿趁機重構（另案）。改動限 `_trigger_survival` 局部。
- **兩戰鬥系統雙改**：beast 需同時接 `encounter_system`（玩家）與 `npc_combat_system`（NPC）。pseudo-team 路徑降低重複，但兩處整合點都要測。
- **守恆審計**：加 beast / forage 後必跑 coin_eq delta（應維持 0）+ ALL INVARIANTS PASSED。
- **episode spam**：覓食敘述必須日邊界彙整 + diff，勿 per-tick print 灌爆 log。

## 測試

- `headless_test` 單元：無 outpost 隊覓食得食物、forage 限食物（material 不增）、tile food 枯竭、大 pop 隊覓食人均收入趨零。
- 野獸：玩家 encounter 獵獸（勝得肉/敗受傷）、NPC auto 獵獸（弱隊掉人）、猛獸伏擊觸發。
- 整合：`game_sim_multi` 4 config × 2 年 — 無荒謬全滅、coin_eq delta 0、`team_trace` 確認大軍不亂覓食、開局 survival config 小隊撐過。
- 對稱性：NPC 與玩家走同覓食 / 戰鬥數學的證據（log）。
