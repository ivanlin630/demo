# Spec：specimen 交易執行 + 威脅來源 tap（觀測不變量履行·QA 缺口①②）

status: draft（待 reviewer R② CLEAN → dispatch implementer）
owner: systems
premise_verified: 執行鏈/threat 位置 file:line 坐實；R① 免（前提 code 坐實，非新概念大框）
driver: `2026-07-14-blueprint-to-systems-execlock-qa-gaps-hold.md`（QA 故事判官 regime 首跑抓 2 缺口，HOLD execlock merge）
governing_invariant: `invariants.md §全量暫態可觀測性`（決策依賴的暫態沒接 tap＝違憲盲點）

## 一句話
QA 故事判官讀 execlock specimen 抓到 2 個**觀測盲點**：①有錢餓死窗口**無買糧執行證據**（食物卡 0、winner 一直「買糧」、2 人餓死，但 specimen 無交易明細→分不出「引擎真沒買到=換皮不換骨」vs「買到 food 入帳沒 tap」）；②survival/flee 鎖 target=[-1,-1] 但**無威脅來源欄**（分不出鎖有無真威脅驅動）。**補這 2 tap＝履行觀測不變量，非 scope creep。**

## 根因（執行鏈/threat 位置坐實）
- **買糧執行鏈**：`order_system.gd:133 post_order(buy,food)`→`team.active_orders`+看板（`:43 [Order] buy food`）→ 隊須抵市集 outpost（`read_market_board:194`/`g1.market_arrive`）有賣方 → `interaction_system:706 _resolve_market` 成交 food 入 `team.resources` → `settle_orders:265` 沖單（`g1.order_fulfilled`）。∴「買糧完成」= 抵市集 + 成交 + food 入帳，缺一不成。specimen 現只 snapshot food_private（見卡 0），**不顯 active_orders/市集抵達/成交**→ 無法判卡在鏈哪環。
- **威脅來源**：`decision_context.gd:82 threat_id`/`:83 threat_pos`/`:81 threat_react`（gather :166 設）。`rank_scored:16` ctx local → `:18 capture_options(state,team,scored)` 是乾淨 tap 點（ctx 在手，只是沒傳）。

## Fix 1（交易執行 tap，缺口①）：`_snapshot` 加交易執行欄
`specimen_tracer.gd _snapshot`（純讀，守觀測不變量）加：
```gdscript
# 買糧執行鏈可觀測：單張了沒/到市集沒 → 分「換皮(單卡never成交)」vs「成交沒tap」
var _buy_food_qty: int = 0
var _orders_summary: Array = []
for o in team.active_orders:
    _orders_summary.append({"kind": o["kind"], "res": o["res"], "qty_rem": int(o["qty_remaining"])})
    if o["kind"] == "buy" and o["res"] == "food":
        _buy_food_qty = int(o["qty_remaining"])
var _tile: HexTileData = state.world.tiles.get(team.tile_pos.x*1000 + team.tile_pos.y)
var _at_market: bool = _tile != null and _tile.outpost_level > 0   # 在市集 outpost（可讀板成交前提）
# → snapshot dict 加 "active_buy_food_qty":_buy_food_qty, "at_market":_at_market, "orders":_orders_summary
```
- **QA 據以判缺口①**：food 卡 0 + active_buy_food_qty>0（單張了）+ at_market=false 全程（never 到市集）→ **換皮真相**（執行鎖持 task 但買不到＝無可達糧市/賣方，這刀核心主張「買糧完成」**未達**，非 tap-miss）。反之 at_market=true 但 food 不升 → 無賣方或 food 入帳 tap 另需查。
- **食物入帳事件（選配，implementer 判）**：若要精準顯「成交那刻 food +N」，可加讀 `g1.order_fulfilled` Probe delta 或 settle 事件；但 active_orders+at_market+per-tick food snapshot 三者已足判鏈卡點，成交事件為 nice-to-have。

## Fix 2（威脅來源 tap，缺口②）：`capture_options` 收 ctx threat
`decision_engine.gd:18`：`capture_options(state, team, scored, ctx)`（加傳 ctx，ctx 已 local）。`specimen_tracer.gd capture_options` 收 ctx → 存 scratch → 進 entry「想什麼」：
```gdscript
# capture_options 簽名加 ctx（rank_survival:124 同步加傳）
_scratch(team.team_id)["threat"] = {
    "threat_id": ctx.threat_id, "threat_pos": ctx.threat_pos,
    "threat_react": snappedf(ctx.threat_react, 0.01),
}
# capture_decision 組 entry 時把 scr.get("threat") 放進「想什麼」block
```
- rank_survival（:124 也呼 capture_options）同步加傳其 ctx；threat 純讀 ctx 欄，零改。
- **QA 據以判缺口②**：survival/flee winner + threat_id != -1 → 真威脅驅動（合理原地戒備/逃）；threat_id=-1 + threat_react≈0 → **無威脅的空鎖**（慢版 thrash 嫌疑，回報）。

## 觸及檔
- `specimen_tracer.gd`：Fix1 `_snapshot` 加交易欄；Fix2 `capture_options` 收 ctx + entry 加 threat block。
- `decision_engine.gd`：`capture_options` 兩呼點（`:18 rank_scored`/`:124 rank_survival`）加傳 ctx。
- **純觀測 tap（讀 team.active_orders/tile/ctx），零 state mutation、零 RNG、零行為改。**

## invariant 守
- **★全量暫態可觀測性（本 slice 履行它）**：補決策依賴的暫態（買糧執行、威脅來源）進 tap＝正向落地不變量。
- **觀測非侵入**：純讀 + append entry；`capture_options` 加 ctx 參數不改 rank 邏輯（ctx 本就 gather 出來）。determinism byte-identical（no-op-unless-specimen，非 specimen 零成本）。
- **憲法 site-freeze**：無新 try_set → sites 不變。

## 驗收法（measurer 重跑 + QA 複判）
1. **交易執行可判**：重跑 seed1337 Team20（同世界）specimen → jsonl 含 `active_buy_food_qty`/`at_market`/`orders` → QA 能判 pop3→1 死亡窗口是「換皮(單卡never到市集)」還是「tap-miss」。
2. **威脅來源可判**：survival/flee entry 含 `threat_id`/`threat_react` → QA 能判空鎖有無真威脅。
3. **★團滅 specimen（blueprint #3，measurer 指定死透 team_id）**：補一份完全滅隊的 trace，驗「死得連貫（掙扎後死，非 idle/thrash 死）」——Team20 沒死透撐不起。
4. **不回歸**：determinism byte-identical（純觀測）；憲法 sites 不變；既有 specimen 欄不壞。
5. → QA 複判乾淨綠 → blueprint 批 execlock merge。

## dispatch 註（reviewer R② CLEAN 後）
- R②：tap 純讀不改 state/行為？`capture_options` 加 ctx 參數不擾 rank？threat/trade 欄是否足判缺口①②？
- 非三對齊（tap 擴充，履行既定不變量，非強結論 redirect 大工）→ 標準 R②。
- 完成判定 = systems + reviewer/QA。implementer TDD：specimen 跑一次斷言 jsonl 含新欄（active_buy_food_qty/at_market/threat_id）。
