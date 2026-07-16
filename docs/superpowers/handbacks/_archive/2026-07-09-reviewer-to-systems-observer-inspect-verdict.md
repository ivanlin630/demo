---
from: reviewer
to: systems
status: consumed
topic: observer inspect spec 審畢——1 阻塞（null-deref）+ 1 提醒，餘 CLEAN
---

# observer inspect 擴充 spec 對抗審結果

spec: `docs/superpowers/specs/2026-07-09-observer-inspect-expand.md`

## ★阻塞：`_owner_faction_of` 會 null-deref——兩處漏 guard

D2a 呼法：
```gdscript
"owner_team": team_label(state, tile.outpost_owner) if tile.outpost_owner != -1 else "（無主）",
"owner_faction": faction_label(state, _owner_faction_of(state, tile.outpost_owner)),
```
`owner_team` 行有 `!= -1` 三元 guard，**`owner_faction` 行沒有**——`_owner_faction_of` 被無條件呼叫。spec 文字描述其實作為「`state.teams.get(owner).faction_id`（team 已滅則 -1）」：

1. **`outpost_owner == -1`（無主，常態）**：`state.teams.get(-1)` 必回 `null`（-1 從不是合法 team_id）→ `null.faction_id` → **runtime error "Invalid get index 'faction_id' (on base: 'Nil')"**。中立據點（你查項#1 自己確認「該顯示」的 case）**必炸**。
2. **owner 已滅**（team_id 曾存在、`state.teams.get()` 現回 null）：spec 文字聲稱「已滅則 -1」，但給的算式字面就是 `.faction_id`（沒寫 null 檢查）——同一 crash。

**要求**：`_owner_faction_of` 內建雙 guard：
```gdscript
static func _owner_faction_of(state: WorldState, owner: int) -> int:
    if owner == -1: return -1
    var ot: TeamData = state.teams.get(owner)
    return ot.faction_id if ot != null else -1
```
兩個 null 來源（無主 -1 / 已滅 team）都要接住，不能只查一個就當作完整。

## 提醒（非阻塞，實作時明訂契約）

`_selected`(int, team)/`_selected_tile`(Vector2i, outpost) 兩 sentinel 互斥——spec 留「實作自決」，但**必須**明訂雙向清除契約，否則會有殘留選取洩漏：
- `select_team(tid)` 須把 `_selected_tile` 重置回 sentinel（如 `Vector2i(-1,-1)`），否則選隊後 `_render_detail` 若 tile-check 排前面，會繼續印舊據點而非新隊。
- `select_tile(tpos)` 對稱須把 `_selected` 重置回 `-1`。
- `_render_detail` 內兩分支判斷順序需固定（誰先查、誰後查），且 `refresh()`（既有:54，週期性重跑）呼叫 `_render_detail()` 時两 sentinel 都要能正確反映「目前真正選的是隊還是格」。
落地時把這條寫進 code 或至少 commit message 提一句即可，非需再送審。

## 其餘查項：CLEAN

1. **`query_outpost` 邊界**：`outpost_type=="" or outpost_level<=0` 判存在、`outpost_owner` 另欄——中立(owner=-1)但 type+level 合法的據點**確會顯示**（不被此 gate 濾掉），符合你自己的設計意圖，非漏 case。
2. **owner 已滅 degrade**（撇開上面 null-deref 修完後）：`team_label` 對 null team 本就回「隊N(已滅)」（`observer_query_api.gd:8-9` 既有邏輯，非新寫）——與 `owner_faction` 修好後回 `""`（`faction_label(-1)` 既有回空字串，`observer_query_api.gd:18-19`）搭配一致，graceful degrade 合理，不用特別標「原主已滅」（faction空字串+隊名帶"(已滅)"已夠明確）。
3. **`tile_selected` emit 確認**：`world_map_view.gd:265-277` 核實——`_observer` 分支內、`here.is_empty()`（點空 tile 無隊）時才 emit，非玩家模式外的路徑不會誤觸，與 spec 描述完全一致。
4. **field 名**：`tile_data.gd` 逐一核對 `resources`(:6)/`resource_cap`(:7)/`outpost_type`(:13)/`outpost_level`(:14)/`outpost_owner`(:15)/`weaponsmith_level`(:22)/`garrison`(:24)——全對，無誤植。

## 裁決

**1 阻塞（`_owner_faction_of` 雙 guard）修完即可鎖 spec**，不需再審一輪（純加 2 個 if，非架構改）。`_selected`/`_selected_tile` 契約提醒供實作參考。
