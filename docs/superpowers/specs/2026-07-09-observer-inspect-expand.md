# Observer Inspect 擴充 Spec — 隊全資源 + 據點 inspect（read-only）

- from: systems
- 工單: `docs/superpowers/handbacks/2026-07-09-blueprint-to-systems-observer-inspect-expand.md`（藍圖 WHAT；用戶親提；read-only 系統自決 seam 不需 sign-off）
- 並行: A2c-1（不同子系統，互不擋）
- 邊界: **純觀測 god-view read-only**，零 WorldState 寫入。唯一願景約束=呈現「人看得懂」（承 ticker 人話原則，非 raw dump）。

## 現況架構（grep 確認 2026-07-09）
- `ObserverQueryApi`（`observer_query_api.gd`，全 static、對 state 零寫）：`query_team`(:40) 回 DTO，**只含 food+coin**（`resources` 其餘 18 種沒露）。`query_map_tiles`(:85) 有 outpost_type/level/owner 但**無單據點 query**。
- `ObserverInspectPanel`（`observer_inspect_panel.gd`）：`_render_detail`(:68) 只印 food+coin 行。
- `ObserverBridge`：`query_team`(:67)/`query_all_teams`/`query_map_tiles` thin wrapper。
- `world_map_view.gd`：`_unhandled_input`(:265) 點隊 emit `team_picked`；**點空 tile 已 emit `tile_selected(hex)`(:277)**——但 `observer_main.gd`(:135) 只接 `team_picked`，`tile_selected` **沒接**（outpost inspect 直接複用此既有 signal）。
- `HexTileData`（`tile_data.gd`）欄：`resources`/`resource_cap`(dict)、`outpost_type`(""/civilian/military)、`outpost_level`(0-3)、`outpost_owner`(team_id)、`weaponsmith_level`(0-3)、`garrison`(person_ids array)。

## 缺口 1：隊詳情露全資源

### D1a. `ObserverQueryApi.query_team` 加 `resources_nonzero`
```gdscript
# query_team return dict 加一欄（非零項，god-view 全露；空 dict 亦合法）
"resources_nonzero": _nonzero_resources(t.resources),
```
新 static helper：
```gdscript
static func _nonzero_resources(res: Dictionary) -> Dictionary:
    var out: Dictionary = {}
    for k in res:
        if abs(float(res[k])) > 0.0001: out[k] = res[k]
    return out
```
- **food/coin 保留現有專屬行**（含 food_flow），`resources_nonzero` 呈現**其餘非零項**（material/goods/gem/ore×4/weapon×6/mounts/wagons/arrows/medicine/tools/armor×2）。避免 food/coin 重複可在 render 端排除，或全列（實作自決，人看得懂為準）。

### D1b. `ObserverInspectPanel._render_detail` 加資源行
- food/coin 行後加「資源持有」段：iterate `d["resources_nonzero"]`，**非零項**以「名:量」呈現（分組或單行皆可；空則印「（無其他資源）」）。
- 資源 key→中文標籤複用既有映射若有（grep `resource` label helper）；無則 key 原樣可接受（人看得懂優先，但傾向中文）。

## 缺口 2：據點 inspect path

### D2a. `ObserverQueryApi.query_outpost(state, tile_pos) -> Dictionary`
```gdscript
static func query_outpost(state: WorldState, tpos: Vector2i) -> Dictionary:
    var tile: HexTileData = state.world.tiles.get(tpos)
    if tile == null or tile.outpost_type == "" or tile.outpost_level <= 0:
        return {}   # 非據點格 → 空（panel 印「此格無據點」）
    return {
        "tile_pos": tpos,
        "outpost_type": tile.outpost_type,          # civilian | military
        "outpost_level": tile.outpost_level,
        "owner_team_id": tile.outpost_owner,
        "owner_team": team_label(state, tile.outpost_owner) if tile.outpost_owner != -1 else "（無主）",
        "owner_faction": faction_label(state, _owner_faction_of(state, tile.outpost_owner)),
        "weaponsmith_level": tile.weaponsmith_level,
        "garrison": tile.garrison.size(),
        "resources_nonzero": _nonzero_resources(tile.resources),
        "resource_cap": tile.resource_cap.duplicate(),
    }
```
- `_owner_faction_of` **雙 null guard（reviewer 阻塞修）**——無主(-1) + 已滅 team 兩來源都接：
```gdscript
static func _owner_faction_of(state: WorldState, owner: int) -> int:
    if owner == -1: return -1
    var ot: TeamData = state.teams.get(owner)
    return ot.faction_id if ot != null else -1
```
  （`state.teams.get(-1)` 回 null → 若無 guard 則 `null.faction_id` runtime crash；中立據點 owner=-1 是常態，必炸。）
- **owner=team_id 需轉人看得懂**（隊名 + 勢力名），非印裸 id（願景「這據點是誰的」）。owner 已滅→`team_label` 回「隊N(已滅)」、`faction_label(-1)` 回 ""，graceful degrade（reviewer 確認一致）。

### D2b. `ObserverBridge.query_outpost(tpos)` wrapper
```gdscript
func query_outpost(tpos: Vector2i) -> Dictionary:
    return ObserverQueryApi.query_outpost(_state, tpos)
```

### D2c. 據點詳情呈現 + 接 `tile_selected`
- **panel 複用**（傾向）：`ObserverInspectPanel` 加 `select_tile(tpos)` + `_render_outpost_detail`——選 tile 時 `_detail` 改印據點詳情（類型/等級/擁有隊+勢力/駐軍數/武器坊等級/資源產出）；非據點格印「此格無據點」。選隊時仍印隊詳情（互斥切換，`_selected` 用 sentinel 或加 `_selected_tile` 區分）。
  - 或新 `ObserverOutpostPanel`（實作自決；複用省 layout 工，傾向複用）。
- **wiring**（`observer_main.gd:135` 區塊加）：
```gdscript
_map.tile_selected.connect(func(tpos: Vector2i):
    _inspect.select_tile(tpos))
```
- map 端 `tile_selected` 已 emit（`world_map_view.gd:277`），**無需改 map input**。
- **★sentinel 互斥契約（reviewer 提醒，實作必守）**：`_selected`(int,team,-1 sentinel)/`_selected_tile`(Vector2i,-1,-1 sentinel) 雙向清除——`select_team` 須重置 `_selected_tile`、`select_tile` 須重置 `_selected`；`_render_detail` 兩分支判斷順序固定；`refresh()`(:54 週期重跑) 呼 `_render_detail` 時兩 sentinel 正確反映「現選隊 or 格」。防殘留選取洩漏（選隊後仍印舊據點）。

## 觸及檔
| 檔 | 改點 | D |
|---|---|---|
| `scripts/simulation/observer_query_api.gd` | +`_nonzero_resources`；`query_team` +`resources_nonzero`；+`query_outpost`；+`_owner_faction_of` | D1a/D2a |
| `scripts/ui/observer_bridge.gd` | +`query_outpost` wrapper | D2b |
| `scripts/ui/observer_inspect_panel.gd` | `_render_detail` +資源行；+`select_tile`/`_render_outpost_detail`（或新 panel） | D1b/D2c |
| `scripts/ui/observer_main.gd` | 接 `_map.tile_selected` → `_inspect.select_tile` | D2c |

**不碰**：`world_map_view` input（`tile_selected` 已 emit）、sim/state（純 read）、belief（觀測無迷霧）、A2c-1 檔。

## 驗收法
1. 無 GDScript 錯；`--headless --import` 綠。
2. **query 層 headless 驗**（`observer_query_api` 純 static 可直測）：構 state 含多資源隊 + 一 civilian + 一 military outpost → `query_team` 回 `resources_nonzero` 含非零項；`query_outpost` 回正確 type/level/owner_team/faction/garrison/weaponsmith；非據點格回 `{}`。
3. **GUI 手驗**（用戶跑 ObserverMain）：點隊→詳情見完整非零資源；點據點格→見據點詳情（誰的/產什麼/多強）；點空非據點格→「此格無據點」。
4. read-only 確認：跑中 inspect 不改 sim（determinism 不受影響）。
5. 呈現人看得懂（中文標籤、非 raw key dump）。

## 流程
spec → reviewer 審（read-only 低風險，seam 正確性/DTO 完整為主）→ 下游實作（並行 A2c-1）。
