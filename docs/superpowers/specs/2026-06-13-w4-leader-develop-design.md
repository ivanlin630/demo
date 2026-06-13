# W4 收尾：Leader 駐家發展 + 派工公庫提領 — Design

> 日期：2026-06-13
> 議題：fief-economy 機制健全（公庫建造單元測試通過、coin 守恆、Laffer 湧現）但 W4 未由 emergent 路徑解。fief handback + 後續 code 查證確認雙根因：
> - **B 漏接**：`_dispatch_builder`（:1378）新據點派工 gate 只查 leader 私產口袋，不看 leader 腳下公庫。leader 的稅金鎖在公庫卻派不出工（升級/擴建路徑 fief 已改吃公庫，新據點漏網）
> - **A 缺失**：`_evaluate_solo`（:893）leader idle 決策只有 攻擊/掠奪/外交/逃跑/製造/貿易，**無「駐家發展」**。好戰/野心 leader 永遠漫遊 → 自家 outpost 空轉 → 一般稅無人產 → 公庫不積 → 循環窮
> 一般稅自動（採集即觸發，leader 站家就積），故 W4 真解 = 讓 leader 願意駐家（A）+ 累積的公庫能派工（B）。特別稅頻率不動（光桿勢力無封臣 → 稀有合理）。

## 設計核心

- **A 駐家發展傾向**：leader idle 決策加「治理」選項 — 有自家 outpost + 建設需求 + 慎重個性 → 回家駐守。駐家 idle 自動採集 → 一般稅自動積自家公庫。好戰/野心高 leader 仍漫遊擴張（個性決定，不強制）
- **B 派工腳下公庫提領**：`_dispatch_builder` gate + funding 改吃「leader 腳下 tile 公庫 + 私產」。leader 站自家 outpost 派工 → 從腳下公庫提建材裝進子隊背包（caravan-load）。嚴格本地不破（人在現場實際搬貨，非遠端建遠端付）

## 不變量

- 嚴格本地維持：只能用施工/派工團**腳下 tile** 的公庫（leader 站自家才提得到）；漫遊在外腳下無公庫 → 只能用私產（誠實限制）
- A 不強制：駐家是個性驅動的**一個選項**，與攻擊/掠奪競分。好戰 leader 不駐家 = 合理湧現（靠征服擴張非建設）
- 守恆：公庫→子隊背包 = 轉移（caravan-load 不憑空生滅）

---

## 1. A：Leader 駐家發展傾向

`_evaluate_solo`（:906 scores dict）加「治理」選項：

```gdscript
# 治理/駐家發展：有自家 outpost + 公庫未達建設門檻 + 慎重個性 → 回家攢建材
var own_pos: Vector2i = _find_own_outpost(state, team)
if own_pos != Vector2i(-1, -1):
    var caution: float = float(leader_p.values.get("慎重", 0.5))
    var build_drive: float = float(leader_p.values.get("野心", 0.5))   # 野心也想擴張(建設)
    # 公庫建材是否不足以蓋下一個（粗估 OUTPOST_COST civilian L1 material）
    var home_tile: HexTileData = state.world.tiles.get(own_pos.x*1000 + own_pos.y)
    var vault_mat: float = float(home_tile.public_storage.get("material", 0)) if home_tile else 0.0
    var need_develop: bool = vault_mat < GOVERN_MATERIAL_TARGET
    if need_develop:
        scores["治理"] = (caution * 0.4 + build_drive * 0.2 + 0.15) * _tag_weight(team, "治理")
```

```gdscript
# best_task match 加：
"治理":
    solo_target = own_pos   # 回自家 outpost；抵達後 idle-on-home → 自動採集 + 一般稅積公庫
```

- `GOVERN_MATERIAL_TARGET`：const，約 1 個 civilian L1 cost ×1.5（TEST VALUE，如 75）。公庫攢夠就不再優先治理 → 放手去攻擊/擴張
- 抵達自家 outpost 後 task 完成回 idle → 下個 tick 仍 idle-on-home（採集自動跑）。若公庫已夠 → `_evaluate_infrastructure` 派工（B）；不夠 → 再評治理續留
- `_tag_weight(team, "治理")`：治理 tag 權重，PRODUCE/統領傾向加成（沿用既有 tag 機制；若無對應 tag fallback 1.0）
- **同樣套用 faction leader 路徑**：`_evaluate_infrastructure`/`_update_goals` 的 leader 若有 own outpost + 公庫不足 + 非戰鬥 → 不強拉去徵收/攻擊前，先給治理機會（與既有 goal 競分，不硬性）

行為湧現：
- 慎重/建設型 leader → 駐家攢公庫 → 蓋據點 → 升級 → 強村（W4 解）
- 好戰/野心型 leader → 治理分低 → 漫遊征服 → 靠打仗擴張（合理，不同玩法）

## 2. B：派工腳下公庫提領（caravan-load）

`_dispatch_builder`（:1373）gate（:1376-1381）+ funding 改吃 leader 腳下 tile 公庫：

```gdscript
func _dispatch_builder(state, leader_team, target_pos, outpost_type, level) -> bool:
    var cost: Dictionary = OutpostSystem.OUTPOST_COST[outpost_type][level - 1]
    # 腳下 tile 公庫（leader 站自家 outpost 才有）
    var home_tile: HexTileData = state.world.tiles.get(
        leader_team.tile_pos.x*1000 + leader_team.tile_pos.y)
    var vault: Dictionary = {}
    if home_tile != null and home_tile.outpost_owner == leader_team.team_id:
        vault = home_tile.public_storage
    # gate：公庫 + 私產合併池 ×1.5 安全餘量
    for k in cost:
        if k == "ticks": continue
        var avail: float = float(vault.get(k, 0)) + float(leader_team.resources.get(k, 0))
        if avail < float(cost[k]) * 1.5:
            _log_dispatch_fail(leader_team.faction_id,
                "資源不足 1.5x: %s 有 %.0f(公庫%.0f+私%.0f)" % [k, avail,
                float(vault.get(k,0)), float(leader_team.resources.get(k,0))], cost)
            return false
    # ...advisor / pop gate 不變...
    var sub_id: int = SubteamSystem.new().dispatch(...)
    if sub_id == -1: ...
    # caravan-load：從腳下公庫提領 cost 裝進子隊（公庫優先，不足補私產）
    _fund_subteam_from_vault(state, leader_team, state.teams[sub_id], home_tile, cost)
    ...
```

```gdscript
# 新：公庫優先提領裝子隊（取代 _dispatch_builder 內既有 _fund_subteam_cost 呼叫）
func _fund_subteam_from_vault(state, owner, sub, home_tile, cost) -> void:
    var vault: Dictionary = home_tile.public_storage if (home_tile != null \
        and home_tile.outpost_owner == owner.team_id) else {}
    for k in cost:
        if k == "ticks": continue
        var need: float = maxf(float(cost[k]) - float(sub.resources.get(k, 0)), 0.0)
        if need <= 0.0: continue
        # 先提公庫
        var from_vault: float = minf(need, float(vault.get(k, 0)))
        if from_vault > 0.0:
            vault[k] = float(vault.get(k, 0)) - from_vault
            sub.resources[k] = float(sub.resources.get(k, 0)) + from_vault
            need -= from_vault
        # 不足補 owner 私產
        if need > 0.0:
            var t: float = minf(need, float(owner.resources.get(k, 0)))
            owner.resources[k] = float(owner.resources.get(k, 0)) - t
            sub.resources[k] = float(sub.resources.get(k, 0)) + t
```

子隊揹著建材走到 target_pos → 抵達 `start_build` 用子隊自己 resources 蓋（cost 已在背包）。

注意：`start_build` 已（fief Task2）吃「腳下 tile 公庫 + 私產」，但新據點目標格**尚無公庫**（還沒蓋）→ 自然 fallback 子隊私產（已 caravan-load 進去）→ 蓋得起。一致。

## 連鎖效果（自動湧現）

- 慎重 leader 駐家 → 一般稅自動積公庫 → 公庫達標 → 派工提領 caravan-load → 蓋新據點 → W4 解
- 好戰 leader 不駐家 → 靠征服擴張 → 不同勢力不同發展路徑（建設型 vs 軍事型）= 戰略多樣性
- 新據點落成 → 新居民團生產 → 更多公庫 → 正循環（打破馬爾薩斯/封建死結）

## 測試

1. A 治理選項：慎重高 leader + 自家公庫不足 → `_evaluate_solo` 選「治理」、move_target = 自家 outpost
2. A 個性分流：好戰/野心高 leader → 攻擊/掠奪分 > 治理 → 不駐家
3. A 攢夠不續留：公庫 material ≥ GOVERN_MATERIAL_TARGET → 治理分降 → 不再優先治理
4. B gate：leader 站自家 outpost、公庫 material 足、私產 0 → `_dispatch_builder` 通過（原本失敗）
5. B 漫遊不通：leader 不在自家 outpost（腳下無公庫）→ 只算私產 → 私產不足則失敗（嚴格本地）
6. B caravan-load：派工後子隊背包含 cost（公庫提領）、公庫扣對應量（守恆）
7. B 抵達建造：子隊到 target_pos → start_build 用背包 cost 蓋成（新格無公庫 fallback 子隊私產）
8. 守恆：公庫→子隊背包→建造 全鏈 material 總量不變；coin 等值 delta 0
9. multi 2 年：慎重型 leader 駐家 → 公庫累積 → **新據點建造 > baseline（W4 解）**；好戰型漫遊擴張；ALL INVARIANTS PASSED

## 風險

- 全參數 TEST VALUE（GOVERN_MATERIAL_TARGET 75、治理 score 係數）
- A 治理可能與 survival（飢餓）/threat（守城）競爭 — 確認優先序：戰鬥/存亡 > 治理（治理是 idle 層 PRIO_DISPATCH，不蓋過高優先反應）
- A leader 駐家期間若遇襲 → 既有 threat/survival 自然接管（治理非 sticky，可被高優先 override）
- B caravan-load 後子隊半路被 survival 飢餓搶走/中斷 → 建材卡子隊背包（既有 construction timeout 退料機制部分覆蓋；但退料進子隊私產非公庫，量小）
- 好戰勢力完全不建設 → 若全圖好戰型 → 仍無據點增長（但這是個性分布問題，config 可調 leader 個性驗證建設型運作）
- 治理駐家可能讓 leader 過於被動（守成不擴張）→ GOVERN_MATERIAL_TARGET 設太高會卡死在攢錢；需 multi 觀察攢夠後是否順利轉攻擊/派工
