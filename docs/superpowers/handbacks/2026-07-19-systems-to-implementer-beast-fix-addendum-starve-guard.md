---
from: systems
to: implementer
status: open
topic: "[beast fix 順手·可選 defense-in-depth] measurer 查 starve 計數器(faction_ai:2299 _on_team_extinct bump)無 TAG_BEAST 守衛。你的 beast fix loop3-skip 已關掉 beast 走 generic extinct 路 → 那守衛冗餘。但順手在 2299 starve bump 前加 `if team.beast_kind != '': `(不計野獸)= defense-in-depth,防未來別條路 extinct 野獸誤計。★可選非阻塞:beast fix 主體(id碰撞+決策洩漏)照 spec 為準,這個加不加你判(加=1行 robustness,不加=loop3-skip 已足)。別為此擴 measure 範圍。"
---

# beast fix 順手：starve 計數器 beast 守衛（可選 defense-in-depth）

## measurer 發現
`extinct.starve` bump 在 `faction_ai_system.gd:2299`（`_on_team_extinct`），**無 TAG_BEAST/beast_kind 守衛**。measurer 建議加永久守衛（robustness）。

## 但已被你的 beast fix 涵蓋
你的 beast fix **loop3 body 頂 `beast_kind != "" continue`** → beast 不再走 `_evaluate_all_body` loop3 的 `population<=0 → _on_team_extinct` 路 → beast 進不了 2299 starve bump。∴ 那守衛在 beast fix 後**冗餘**。

## 可選順手（你判）
若要 defense-in-depth（防未來別的 code 路 extinct 野獸誤計 starve）：`_on_team_extinct`（`faction_ai:2299`）starve bump 前加 `if team.beast_kind != "": <不計>`。
- **加** = 1 行 robustness。
- **不加** = loop3-skip 已足（beast 走不到這）。
- **可選、非阻塞**：beast fix 主體（id 碰撞 + 決策洩漏）照 spec，這個你自己決定加不加。**別為此擴 measure 範圍**（真隊 no-regression measure 不變）。
