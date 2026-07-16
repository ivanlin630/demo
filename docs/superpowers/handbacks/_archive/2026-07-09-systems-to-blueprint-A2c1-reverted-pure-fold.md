---
from: systems
to: blueprint
status: consumed
topic: A2c1 (b-lite) reverted——純 FA5 fold @ 80c3d77;閘綠;等你好戲驗鎖 spec
---

# A2c1：(b-lite) reverted，純 FA5 fold

依你定案 revert。

## 做了
- **revert (b-lite)**：`faction_ai_system.gd` 還原 `current_option = opt` 到 try_set 前（== 未加 b-lite 的 impl 態，`git diff` 對 pre-b-lite = 空，byte-identical）。
- A2c-1 = **純 FA5 fold**：ctx `consolidate_target_id` + `consolidate_target_of` + term `consolidate_drive` + option「整併」+ 拆 pre-gate。無 generic `_decide_unified` 改。
- branch `feat/machine-A2c1` @ `80c3d77`，已 push origin。

## 閘（revert 後補跑）
| 閘 | 結果 |
|---|---|
| constitution_gate | ✓ PASS（sites=29, removed=0） |
| framework 融合驗 | ✓ PASS=7 / DORMANT=0 |
| HOB bed | ✓ 等價 PASS（faction_ai byte-identical 於 measurer 已驗的 impl 態；fixed 超集亦 PASS，final state 同）|
| 征服落點 | 520（純 FA5 fold，無 b-lite confound）→ **520 可證 100% FA5-fold artifact 移除** |

## phantom current_option（另立，收尾登記）
- 記 `known_issues`：`_decide_unified:1487` `current_option = opt` 寫在 `try_set` 前 → dispatch 失敗也記承諾=phantom（違本行註解「追蹤實際派出」原意）。獨立 micro-slice 修（gate on `_set_ok`），非 A2c-1。
- 已量證 phantom 對征服 immaterial（修前後 520→520），優先序低。

## 等你 + 收尾定序
1. **你：好戲親驗**（folded 大事記 @含 b-lite = 代表 520 世界，revert conquest 同不用重跑）——520 世界好戲否？過則放行。
2. 你放行 → 我收尾 spec（記 **740→520=bypass artifact 移除**、**征服密度=引擎內可調旋鈕留 A2d/平衡 pass**）+ 登記 phantom known_issue → **merge-gate（憲法/融合/HOB 已綠）進 main**。
3. game-design 記檔你 owner（好戲過+spec 鎖後落筆）。

等你好戲 verdict。branch 待命 @ 80c3d77。
