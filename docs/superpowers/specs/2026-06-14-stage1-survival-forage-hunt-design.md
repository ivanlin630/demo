# 階段1 開局生存：覓食 + 狩獵 — Design

> 日期：2026-06-14
> 議題：玩家核心迴路定為 Kenshi 型「下而上生存起家」。但無據點的流民小隊**現在沒有任何食物收入**（`collect_resources` 卡 `outpost_level>0`、無 forage），吃完初始糧必餓死 → 開局不可玩。本 spec 補開局生存地基：覓食（食物地基）+ 狩獵（texture / 激情時刻），玩家側與 NPC 側對稱。
>
> 本 spec 屬玩家核心迴路 4 階段拆分的**階段1**（階段2 招人 / 階段3 據點 / 階段4 成勢力，皆後續獨立 spec）。
>
> **修訂（2026-06-14 量測後 — subsistence 改狩獵唯一）**：初版被動覓食（`_forage_from_tile` 抽 tile food）2 年量測露餡為**食物噴泉**（無據點小隊 income ~44/天 >> burn ~7 → 累積 300+ 天存糧、無遷徙/定居壓力，違背「減緩餓死不餵飽」意圖）。根因：每小時採 ×24/天 + 平原 regen 回填快過抽取 → 枯竭沒咬到。**改為：無據點隊零被動食物，subsistence = 狩獵（小獵物 roll + 野獸），靠 `wild_game`（有限/枯竭/慢再生）。** 解噴泉 + 回到「食物=離散狩獵事件非無聲進度條」+ 真遊牧獵人精準度。下記 §1/§2 為修訂後設計；初版被動覓食碼待 Plan 2c 移除。

## 設計核心

- **無據點隊零被動食物，subsistence = 狩獵**：食物只來自獵 `wild_game`（小獵物 roll）+ 野獸（肉）。無 game 的格 → 無糧 → 必遷。`wild_game` 有限、枯竭、慢再生 → 遊牧獵人精準度，逼定居（農田=穩定糧）。
- **大軍不能靠狩獵活，是數學自然結果**：`wild_game` 每格有限上限、命中 roll，大群人均獵獲趨零 → 大軍靠補給/劫掠非狩獵。NPC 不亂獵靠 survival AI 一條 path + 戰力/糧況門檻（不是戰略引擎）。
- **狩獵分層**：小獵物 = 抽象求生 roll（緩檔一行字）；危險野獸 = 進遭遇戰（激情時刻，全控真風險）。野獸 = 臨時 pseudo-team，復用既有兩條戰鬥路徑。
- **節奏雙檔**：緩檔 zero grind（設 task → 跳時間 → 食物以離散敘述 episode 進，岔路才介入）；激情檔玩家冒險自找（全手動、真傷亡）。
- **對稱**：覓食 / 狩獵玩家與 NPC 走同一套食物 + 戰鬥數學，無玩家專屬機制。

## 不變量

- **無據點隊食物唯一來源 = 狩獵**：無被動 tile-food 採集；material / ore / goods 仍需 outpost。
- **狩獵必枯竭且 scale-capped**：獵獲扣 `wild_game`（有限/慢再生）；每格 game 有限 + 命中 roll → 大群人均獵獲趨零（大軍不能靠狩獵活）。此為「逼遷徙/定居」與「大軍不靠狩獵」的保證，不得用特例 code 取代。
- **野獸守恆中性**：beast pseudo-team 無 coin / 有限資源；給的「肉」= 食物（不在 coin_eq 審計），用完即清。野獸不持有、不路由有限資源，不破守恆。
- **狩獵風險真實**：失敗 / 反擊走**既有戰鬥傷亡機制**（encounter 逐 unit body_parts；npc_combat `_apply_casualties` 依 named:anon 比機率挑人 + 隨機部位累傷 → 要害 critical / 肢體 severed 才死），**非飢餓的「弱者先死」順序**（那是斷糧 minor→anon→named）。minor 不參戰、不在戰鬥傷亡內。成員陣亡為永久後果。
- **對稱**：任一新機制（forage path / 狩獵 / 野獸戰）NPC 必須同樣能用，無玩家專屬分支（見 invariants「對稱性」）。

## 1. Subsistence = 狩獵（無被動覓食）

### 無據點隊零被動食物
`collect_resources` 的 `outpost_level==0` 分支**不採 tile food**（移除初版 `_forage_from_tile`）。無據點隊食物收入歸零 → 必須狩獵。`tile.resources["food"]` 池保留供 outpost 經濟，不再被無據點隊抽。

### 食物 = 狩獵 `wild_game`
小獵物（兔/鹿）抽象 roll（§2）+ 野獸肉（§3）。`wild_game` 有限、每格上限、慢月再生 → 一格獵完即枯 → 遊牧。命中 roll + 有限存量 → 大群人均趨零（大軍不靠狩獵）。

### 表現：離散敘述 episode（不變）
獵獲走離散事件流（「獵得野兔 +N / 空手而回 / 追鹿入林→遭遇戰」），日邊界彙整避免 spam（沿用 `forage_today` + episode 管道）。

## 2. 小獵物（抽象 roll，subsistence 主力）

無場景的低風險小獵（兔/鹿），求生技能判定 — **這是無據點隊的主要食物源**：

```gdscript
# 求生(+偵查) → roll 命中 → +食物（扣 1 wild_game）；失敗 → 空手
# active=主動狩獵（高命中）/ passive=移動/駐紮時自動嘗試（低命中）
# 命中率/產量須撐得起「能活但險」的遊牧獵人（待量測 tune）— 非噴泉、非餓死
# 無 wild_game 的格 → 0 產出 → 逼遷徙找獵物 / 定居
```

## 3. 野獸 + 狩獵（texture / 激情時刻）

### 生成源（野獸不憑空跳出）
`world_generator` 灑 tile 資源（類 `wild_horses`），規律生成 / 再生：
- `wild_game`：平原 / 森林常見（鹿/豬），可獵、月再生（類 `_regen_wild_horses`）
- `predator_density`：稀有猛獸（熊/狼群），森林 / 山多，低機率，月再生 + 可事件遷入
- 隊伍經過 tile → 觸發狩獵 / 伏擊（見偵測），野獸**從該 tile 密度生成**

### 持久性模型（丙：環境 + emergent 惡獸）
- **環境獸**（本 spec 做滿）：= tile `wild_game` / `predator_density`，打完該次即清，無個體身分。未來任務只能「清剿某區猛獸」（指地點）。
- **惡獸**（晉升 hook 輕量做，完整留任務系統 spec）：掠食者**存活且殺夠人 → 累積 infamy → 晉升持久遊蕩實體**（得身分 / 惡名 / 跨 tick 存在），未來 bounty 可指名獵殺。emergent，非預設。
- **階段1 範圍**：環境獸全做 + 掠食者 infamy 計數 hook；**惡獸的持久遊蕩 / 身分 / bounty 接點留後續 spec**（spec 此處只宣告實體模型走向，不堵死未來）。

### 野獸 = 臨時 pseudo-team（環境獸）
beast tag 的輕量 TeamData：無 leader / 無裝備 / 無外交 / 無 coin。「units」= 動物（單體熊 / 多體豬群 / 狼群）。stats：戰鬥力 + 行為類。獵畢 / 戰畢即清除（惡獸晉升後改持久，後續 spec）。

### 行為 2-3 類（不做個別動物 AI）
- **逃型**（鹿）：嘗試逃離 → 復用既有 pursuit / flee；挑戰 = 追到（reward = 逮住）
- **戰型**（豬/熊）：主動近戰，獠牙 → body_part 損傷
- **伏擊型**（猛獸主動）：路過隊被野獸發起遭遇戰（獵人↔獵物反轉，不請自來的高潮）

### 伏擊偵測（復用 vision system）
猛獸 = **低 exposure 實體**（動物天生隱蔽，森林 `TERRAIN_EXPOSURE_MULT` 再砍半 → 林中最難察）。隊伍將踏入 / 位於有掠食者的 tile 時，擲偵測：

```gdscript
# 復用 vision_system._can_detect 模型：偵查(+求生 bonus) vs 獸 exposure × 距離
# 高 → 偵測成功：預警 + 決策岔路（避開繞路 / 備戰 / 反過來主動獵）
# 中 → 模糊 tier 情報（「林中有大型獸痕」，知道有不知精確 — 認知≠真實）
# 低 → 偵測失敗：被伏擊 → encounter 開場野獸當 attacker + 突襲優勢
#       （復用既有 entry position / pursuit_edge_offset → 有利進場位 + 可能免費首輪）
# 對稱：NPC band 同擲，高偵查繞開 / 低被咬
# 技能成長：成功偵測/閃避 → 長 偵查/求生（reuse _grow_skill）；被伏擊不長
```

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
- 野獸：玩家 encounter 獵獸（勝得肉/敗受傷）、NPC auto 獵獸（弱隊掉人）。
- 伏擊偵測：高偵查隊預先偵測掠食者（得預警/可避）、低偵查隊被伏擊（野獸 attacker + 突襲優勢）、森林降偵測率、掠食者 infamy 計數累積。
- 整合：`game_sim_multi` 4 config × 2 年 — 無荒謬全滅、coin_eq delta 0、`team_trace` 確認大軍不亂覓食、開局 survival config 小隊撐過。
- 對稱性：NPC 與玩家走同覓食 / 戰鬥數學的證據（log）。
