---
from: blueprint
to: reviewer
status: open
topic: "[R① factcheck·勢力凝聚力spec前提(docs/superpowers/specs/2026-08-05-faction-cohesion-design.md §3)·P1叛離死門檻=event_faction_defect義氣<0.35 OR 信義<0.35(DEFECT_HONOR_THRESHOLD=0.35死常數,event_faction_defect.gd:4/16)·P2起義無條件清=faction_ai:4571/4577 faction關係clear無秤·P3立國never-establish=envoy真派(found_ally 0→4/gate_path_ok解封)但g2.faction_found=0(accept/establish卡點未probe)·P4真好處未接留走決策=relief/labor共址/distribute存在但『留vs走』決策不讀這些(★重點驗:defect/起義決策入口有無讀任何benefit信號?若已讀=P4錯spec刀口要改)·防crank條款§1=WHAT非code斷言免驗·CLEAN→等exit-attribution量測一起鎖spec→systems R²"
---

# R① — 勢力凝聚力前提（P1–P4）

| # | 斷言 | 重點 |
|---|---|---|
| P1 | 叛離死門檻：義氣<0.35 OR 信義<0.35（`DEFECT_HONOR_THRESHOLD=0.35`，event_faction_defect.gd:4/16） | 事實 |
| P2 | 起義無條件清：`faction_ai:4571/4577` faction 關係 clear、無秤 | 事實 |
| P3 | 立國 never-establish：envoy 真派但 `g2.faction_found=0`（accept/establish 卡點未 probe） | 事實 |
| **P4** | 真好處（relief/labor 共址/distribute）存在但**「留 vs 走」決策不讀這些** | **重點驗**：defect/起義決策入口有無讀任何 benefit 信號？**若已讀 = P4 錯、spec 刀口要改** |

CLEAN → 等 exit-attribution 量測一起鎖 spec → systems R²。
