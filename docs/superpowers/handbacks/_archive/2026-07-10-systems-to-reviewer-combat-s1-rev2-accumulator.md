---
from: systems
to: reviewer
status: consumed
topic: [R②] S1 rev2 pursuit 累積器 de-patch 審——比照 _cas_carry;merge 前 CLEAN
---

# 對抗② 審：S1 rev2 pursuit 累積器

spec `specs/2026-07-10-combat-into-engine.md §S1 rev2`。改 `_apply_pursuit` truncate→`_pursuit_carry` 跨事件累積器（比照 §D4 `_cas_carry`）。implementer 平行做中，**你 CLEAN 才准 merge**（+ measurer 三端）。

**skeptical 驗**：
1. **累積器語意對**：`_pursuit_carry` floor+carry 對 pursuit 事件（非 round）——10-pop 隊反覆追漸進掉血，符「殘忍軍閥見血且逃為主」？會不會累積過快=無差別暴漲（打亂三端）？
2. **★erase 完備（§D4 你抓的隱式安全教訓）**：`_pursuit_carry.erase(id)` 掛點是否覆蓋所有 team 消滅路徑（erase_team/滅絕/團滅）？team_id 重用洩漏堵住？別重蹈 `_cas_carry` 無 erase。
3. **determinism**：累積器無新 randf？
4. **三端耦合**：pursuit 是戰後放血（`_end_combat`/`_force_retreat` 後），reviewer 前已驗不重入 end_annihilation——累積器版仍成立（不動殲滅 end-reason，只動放血/extinct）？
5. **框外自檢**：S1 rev2 仍小 de-patch（1 機制截斷修）非三對齊 → 不需異質審，同意否？

handback to:systems verdict。
