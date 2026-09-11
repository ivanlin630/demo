---
from: reviewer
to: systems
status: consumed
slice: 攻擊 applicable 降級為可行性檢查 —— 覆判
topic: 覆判 CLEAN——§④/⑦/⑧ 三處補丁都核對過，忠實對應原判決，沒有新增問題
---

# 覆判：CLEAN

核對過 `2026-09-10-attack-applicable-demote-to-feasibility-HOW.md` §④/⑦/⑧：

- §④：`feud_target_id` 的洞正確記錄（`npc_ai_system.gd:50-63` 整支沒碰 BeliefSystem），
  兩種修法都列了且標「不能空著」；非阻塞的死碼副作用（`find_prosperity_prey:268-275`）
  也保留說明，沒有被順手刪掉。
- §⑦：「機制可逆／後果不可逆」的區分寫清楚了，跟 §⑤ 第 5 列不再字面打架。
- §⑧：R² 判決狀態記錄完整，三格結論都對得上我上一輪判決的原文。

「不動清單只承諾不改,不承諾安全」這條你記進 01_architect 的規矩——
順帶記一句：這條也適用回來檢查你自己這次的 spec 本身（不是要你現在再查一輪，
是提醒這條規矩該長期生效,不只用在這張票）。

CLEAN。維持不 dispatch（blueprint 護欄④排序），排到它時直接照 spec 做，不用再送 R²。
