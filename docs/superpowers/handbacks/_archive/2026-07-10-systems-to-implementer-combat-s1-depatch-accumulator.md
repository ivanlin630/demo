---
from: systems
to: implementer
status: consumed
topic: [S1 rev2] pursuit de-patch 累積器——int() 截斷病(cosmetic 假過關)改跨事件累積器
---

# 工單：S1 pursuit de-patch（截斷→累積器）

blueprint 裁（`blueprint-to-systems-s1-pursuit-truncation-depatch`）：measurer 揭 S1 現行 `pursuit_loss=int(loser.pop*0.05*factor)` 需 pop≥18 才 ≥1 → organic 14/14 小隊全 truncate 0、`loss_sum=0`=**cosmetic 假過關**（cruelty weight 永不咬）。**第 3 次截斷病**（§D4 已修）→ de-patch。

## 改（spec `specs/2026-07-10-combat-into-engine.md §S1 rev2`）
`_apply_pursuit`（`npc_combat_system.gd:544`）pursuit_loss 改**跨 pursuit 事件分數累積器**（比照 `_cas_carry` 模式）：
```gdscript
	var real: float = float(loser.population) * PURSUIT_RATE * factor
	var carry: float = _pursuit_carry.get(loser_id, 0.0) + real
	var pursuit_loss: int = int(carry)          # floor
	_pursuit_carry[loser_id] = carry - float(pursuit_loss)
```
- 加 static `_pursuit_carry: Dictionary`（key=loser team_id，同 `_cas_carry`）。
- **★顯式 erase（reviewer §D4 教訓，別重蹈 `_cas_carry` 隱式安全）**：`_pursuit_carry.erase(id)` 掛隊 erase/滅絕點（`erase_team` 或 `_end_combat`/滅絕），避免 team_id 重用洩漏。
- factor 算法（殘忍/貪婪，§S1）不變；只換 truncate→累積器。determinism 保（無新 randf）。
- 探針 `pursuit.loss_sum` 現應 >0（累積器漸進掉血）。

## gate（照 blueprint + reviewer②）
- `--import`/multi-sanity/constitution 綠、determinism 同 seed 兩跑一致。
- handback **to:measurer**：organic 三端（`end_annihilation`/`end_mortal_flee`/`capture.total` + annih 時 pursuer 殘忍值分布 + `pursuit.loss_sum>0` + `extinct.*`）。
- **★merge 閘=reviewer② CLEAN（systems 另送）+ measurer 三端 delta≤噪音（blueprint 判「殘忍軍閥見血且逃為主」達標）**。三端打亂→to:systems 調 `PURSUIT_*_W`/`FACTOR_MAX`。
