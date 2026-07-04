# Pattern B banker — outpost_owner（第四池，最小集中化）

> `state-fight-scope` Pattern B：outpost_owner 16 寫/5 檔，戰鬥佔領/AI 接管/起義/結盟/棄守 last-writer-wins 同 tick race；`pending_owner_change_tick` 是繞它的 buffer hack。承 banker 模式。

## 病
`tile.outpost_owner` 散 16 直接 set 無 banker：combat capture / AI takeover / construction / abandon(-1) / init，last-writer-wins。無集中點 → race-policy 無處掛、無審計。

## 修：OutpostOwnerBank 最小集中化
新 `scripts/simulation/outpost_owner_bank.gd`：
```
static func set_owner(tile, owner: int, reason: String = "") -> void:
    if tile.outpost_owner == owner: return
    tile.outpost_owner = owner
    Probe.bump("g1.outpost_change")
```
- 路由 16 直接 set → `set_owner(tile, owner, reason)`。
- **保 last-writer-wins 行為**（本塊只集中化+審計，**不改 race 解析**=純機制、零行為變）。race-policy（誰同 tick 勝）= 後續 refinement（有了單一 chokepoint 才好掛）。
- outpost_owner 是 tile int，**無反向索引**（非 faction member 雙向）→ 純路由、無 bidir 顧慮。
- 禁裸 `tile.outpost_owner =`（除 bank）= grep 驗。

## believability / 守恆
- 行為零變（同 last-writer-wins）→ 既有 combat/capture/construction/abandon/起義/結盟 測不變。
- outpost_owner 非守恆量；不碰 resources/coin → coin_eq/InvariantAudit 無關（但回歸驗 0）。

## 驗收
- OutpostOwnerBank.set_owner 單測（設 owner / 同值 no-op / probe）。
- 既有佔領/接管/建造/棄守/起義/結盟 測全綠（行為不變）。
- 2 年 world_sim：佔領/易主正常、`g1.outpost_change` 出現、headless 全綠、coin_eq/InvariantAudit 0。
- grep 驗無裸 outpost_owner 寫（除 bank）。

## 檔案
- 新 `scripts/simulation/outpost_owner_bank.gd`。
- 改 16 寫者（grep）：diplomatic_ai_system/encounter_system/faction_ai_system/game_setup/outpost_system/player_command_system。
- `headless_test.gd`：set_owner 單測 + 既有沿用。
- 2 年 world_sim。

## 非本塊
- race-policy 解析（同 tick 多寫誰勝）= refinement（集中化後可掛）。
- `pending_owner_change_tick` buffer hack 退役 = refinement（race-policy 做時一起）。
- resources banker（110 寫,最大）= 各別 slice。
