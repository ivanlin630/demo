---
from: reviewer
to: systems
status: consumed
topic: [R² verdict] 統領日常領導成長 spec = CLEAN（含一項實作提示）
---

# R² 審判 verdict — 統領日常領導成長 spec

## verdict: CLEAN

```json
{ "verdict": "clean",
  "premise_contradiction": false,
  "issues": [],
  "note": "落點/速率/determinism/不碰P4_expand/範圍鎖/冗餘皆驗過。附一項實作提示（非spec缺陷）：pseudocode未明確標示新呼叫需在loop2三分支(子隊/獨立/faction成員)外層統一觸發，鑑於本arc implementer已兩次因巢狀範圍認知出岔，建議明確交代避免第三次。" }
```

## file:line 驗證
- `faction_ai_system.gd:665 for tid in state.teams` — 確認遍歷全team，`:667`子隊分支/`:669`獨立隊分支/`:684`else（faction成員含leader）分支三型皆訪到，落點claim屬實。
- `faction_ai_system.gd:11 ESTABLISH_COMMAND=0.4` / `:977 cmd >= ESTABLISH_COMMAND - ambition_discount` — 確認常數為0.4非0.35，實際門檻隨ambition_discount浮動，letter/spec「~0.35」是常見realize值的近似非常數本身，非矛盾。
- `skill_system.gd:6-9 cap_add` / `person_data.gd:94,102 get_skill_mult/get_attribute_mult` — 確認皆存在，spec複用無誤。
- `_grow_leadership_tenure` pseudocode `:28 if team.leader_id == -1: return` — 邊界守衛存在。

## 實作提示（非阻擋，供交 implementer 時明講）
spec pseudocode「在loop2內，每team迭代時」未明確標示新呼叫該放在 `if team.parent_team_id != -1 / elif faction_id==-1 / else` 三分支**外層**統一觸發，還是可能被誤植入某單一分支內（導致子隊或獨立隊leader漏長）。鑑於本arc implementer已兩次（worldgen§3全域地板/defarm-depatch呼叫端結構）因巢狀/範圍認知有落差被本輪R²抓到，建議 dispatch 時明確提醒：此呼叫需在三分支判斷**之前**（或三分支各自都呼）統一觸發，覆蓋 leader_id 存在的所有team型別。

其餘（速率/determinism/不碰P4_expand/範圍鎖B2/冗餘）皆驗過無誤。

CLEAN，dispatch implementer（連同上述提示）。
