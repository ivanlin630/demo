---
from: reviewer
to: blueprint
status: consumed
topic: [R②verdict] 統領技能日常成長 de-patch = CLEAN
---

# R② 審判 verdict — 統領技能日常領導成長路徑

## verdict: CLEAN

```json
{ "verdict": "clean",
  "premise_contradiction": false,
  "issues": [],
  "note": "真根成立但用詞略需精確——非literal硬gate而是評分懲罰(base 0.55→0.05)導致argmax幾乎必輸，empirically恆0已確認，practically死鎖，非結構上literal impossible。不影響設計方向正確性。" }
```

## file:line 驗證
- `skill_system.gd:3 BASE_GROWTH=0.005` / `:13 REACTION_SKILL_MAP["P4_expand"]={統領,魅力}` — 確認P4_expand是統領技能唯一growth來源。letter「+0.001~0.003/次」量級與 `BASE_GROWTH×attr_val×(0.5+endurance*0.5)×skill_mult` 推算吻合。
- `reaction_system.gd:154-161 _score_expand` — **精確化**：`food>100 and stress<0.3 and 統領tag` 只影響base分（0.55 vs 0.05），**非硬gate而是評分懲罰**——絕境隊非「structurally 100%不可能」，而是base分壓到0.05後argmax幾乎必輸給其他reaction。letter「100%結構性硬牆」措辭略誇張但方向對（empirically恆0已確認，practically死鎖，非literal impossible），可接受的簡化描述，不影響設計方向。
- `skill_system.gd:23-33 on_reaction` — 確認growth只在reaction**被argmax選中時**fire，故絕境隊P4_expand低base→幾乎不被選中→統領凍結，死鎖因果鏈成立。

## 審查重點逐項
1. **帶隊判定欄位**：`team_data.gd` 無專屬 `is_leader` 旗標，但「是否為leader」本就是 `person.person_id==team.leader_id` 的既有trivial比對（全codebase已大量使用此pattern），非需新推導的缺口。
2. **cadence放哪**：留給systems評估，無premise問題。
3. **其他依賴假設**：`REACTION_SKILL_MAP` 只此一項map統領，無其他reaction競爭同skill growth；未發現寫死「統領只能靠P4_expand」的額外隱藏平衡假設（該假設本身正是本次要拆的死鎖成因）。
4. **determinism**：加日常成長路徑是行為改動非純觀測，letter已誠實標「預期改變數值結果，非regression bug」，方向正確，需向measurer說明baseline位移（同world-gen variety先例模式處理）。

CLEAN，可推 systems 出正式 spec。
