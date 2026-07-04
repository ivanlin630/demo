# Hand Back: OutpostOwnerBank（outpost_owner 單一 owner）

## 實作摘要

Pattern B 第四池集中化：`tile.outpost_owner` 全部寫入收斂到單一 chokepoint
`OutpostOwnerBank.set_owner`。**行為零變**（保 last-writer-wins，不改 race-policy）。

### Bank API

`scripts/simulation/outpost_owner_bank.gd`（新檔，`class_name OutpostOwnerBank`）

```gdscript
static func set_owner(tile: HexTileData, owner: int, reason: String = "") -> void:
	if tile.outpost_owner == owner:
		return            # 同值 no-op
	tile.outpost_owner = owner
	Probe.bump("g1.outpost_change")
```

- 唯一 owner 寫端；同值 no-op（不重複 bump）；每次真易主 `Probe.bump("g1.outpost_change")`。
- last-writer-wins 不變（無 race 仲裁）→ 既有 capture/takeover/construct/abandon/uprising/alliance 測全綠。

### 路由清單（16 寫者 / 6 檔）

| 檔案 | 行(舊) | tile 變數 | reason |
|---|---|---|---|
| diplomatic_ai_system.gd | 167 | tile | alliance（結盟接管居民團 outpost） |
| encounter_system.gd | 1349 | cap_tile | capture（敗方所在格據點易主） |
| encounter_system.gd | 1416 | occupied_tile | capture（居民接受投靠易主） |
| encounter_system.gd | 1441 | tile（_massacre_residents） | capture（屠村空殼易主） |
| encounter_system.gd | 1458 | tile（_force_occupy） | capture（強佔） |
| faction_ai_system.gd | 2190 | tile | camp（NPC 紮營 crude camp） |
| faction_ai_system.gd | 2450 | tile | takeover（接管無人 outpost 逾期） |
| faction_ai_system.gd | 2492 | tile（`if tile:` 守衛保留） | takeover（起義守城奪 outpost） |
| game_setup.gd | 175 | state.world.tiles[key] | init（independent_settled） |
| game_setup.gd | 332 | tile（_build_outpost_tile） | init |
| game_setup.gd | 470 | tile（explicit op_cfg） | init |
| outpost_system.gd | 271 | tile | construct（build 完工） |
| outpost_system.gd | 301 | tile | construct（crude_camp 玩家紮營完工） |
| outpost_system.gd | 316 | tile | demolish（拆除 → -1） |
| outpost_system.gd | 592 | tile（capture()） | capture（control 佔領） |
| player_command_system.gd | 535 | tile | abandon（玩家棄置 → -1） |

> 註：`encounter_system.gd:1349` 與 `diplomatic_ai_system.gd:167` 處保留既有 `old_owner` 讀取（print 用），僅替換寫行。`faction_ai_system.gd:2492` 保留 `if tile:` 守衛（瞬時懸空容忍，未改 require）。

### grep 驗證

`grep 'outpost_owner\s*=[^=]'` over `scripts/simulation/**`：
唯一殘留 = `outpost_owner_bank.gd:8`（bank 本體寫端）。其餘 0 裸寫。
（headless_test.gd fixture 直設 `tile.outpost_owner = -1` 為測試夾具，不在 simulation 範圍，照舊。）

### 2 年 world_sim 易主結果

`scripts/debug/world_sim.gd`（max_ticks=172800 = 2.0 年，teams=8，純 NPC）：
- `=== world_sim DONE ===`（exit 0），`[world_sim] 不變量違反累計=0`（InvariantAudit 0）。
- `[ProbeSummary] g1.outpost_change = 8` → 易主確實發生（含 init 轉移 + 6 次 [CrudeCamp] 紮營）。
- SCRIPT ERROR=0、InvariantViolation=0 → 無 anomaly。
- 觀察到的所有權變動 print（6 例，皆 [CrudeCamp] NPC 紮營）：Team4/5/0 @ military、Team9/17/18 civilian。

### 回歸

`headless_test.gd`：`=== DONE ===`、SCRIPT_ERROR=0、`outpost owner bank OK`、
既有 [Capture]/[Takeover]/[Uprising A/B] 行為印出、InvariantAudit population/faction/subteam OK、coin_eq 守恆。

## 連動風險

- **無已知行為連動風險**：純集中化，last-writer-wins 不變，既有測全綠。
- `g1.outpost_change` 為新 probe key（純觀測，flag-gated）；不影響模擬數學。

## 待主 session 確認

- **Pattern B 剩餘池 = resources**（~110 寫，最後且最大一池）。建議下一塊。
- **race-policy 解析 + `pending_owner_change_tick` 退役 = 後續 refinement**（本塊刻意不做；
  有了 set_owner chokepoint 後才好掛 race 仲裁）。
- `occupying_outpost_since`（faction_ai takeover 計時器）未動，仍為各 caller 自管狀態
  （非 owner 寫端，不在本塊範圍）。

## 驗證輸出

- headless_test：`=== DONE ===`、SCRIPT_ERROR_count=0、DONE_count=1、`outpost owner bank OK`。
- world_sim 2 年：`g1.outpost_change=8`、不變量違反=0、SCRIPT ERROR=0、exit 0。
