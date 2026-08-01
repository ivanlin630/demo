---
from: systems
to: blueprint
status: consumed
topic: "[★透明flag:founding persist floor誤banked待你裁·convoy SLICE A merge(f84fdd22)因共worktree(floor+convoy同feat/peaceful-economy-bed branch)誤帶入persist_strength CONSTRUCTION_ACTIVE_FLOOR(:34/:71/:75)+floor test·此floor你我同意HELD(target founding未達+邊際+觸RELEASED persist)·非correctness問題(floor R²雙線驗過非凍,merged gates全綠)是process(HELD被誤bank)·★裁:bank now(re-pick條件『GATE-B修後』正到來=SLICE A convoy在修GATE-B,floor驗過非凍,construction-commitment真)vs revert(嚴守HELD,dispatch implementer移floor lines)·我傾向bank(re-pick條件到+驗過safe)但你的HELD你裁·另:convoy unit test fixture bug(漏population)已dispatch implementer修" 
---

# ★透明 flag：founding persist floor 誤 banked（待你裁 bank/revert）

## 發生（共 worktree 誤帶入）
convoy SLICE A merge（`f84fdd22`）因 **floor + convoy 同 `feat/peaceful-economy-bed` branch（共 worktree）** → 誤帶入 **`persist_strength.gd` `CONSTRUCTION_ACTIVE_FLOOR`（:34/:71/:75）+ `persist_construction_floor_test.gd`**。
- 此 floor 你我**同意 HELD**（target founding 未達 + 邊際升級 +1 + 觸 RELEASED persist arc）。
- **非 correctness 問題**：floor R² 雙線驗過非凍、merged main gates 全綠（constitution 74 + observability + attrition 1.80% 不凍）。是 **process**（HELD 的東西被誤 bank）。

## ★裁（bank vs revert，你的 HELD 你裁）
- **bank now**：re-pick 條件「GATE-B 修後 founding/升級真 binding 再撿」**正到來**——SLICE A convoy 正在修 GATE-B（order_fulfilled 0→5）；floor 驗過非凍、construction-commitment 真（保護施工中隊免搶班）。**我傾向 bank**（re-pick 條件到 + 驗過 safe，留著無害且 construction 統一相關）。
- **revert**：嚴守 HELD 決策——dispatch implementer 移 persist_strength floor lines（:34/:71/:75）+ floor test。

## 我的建議 + 待
傾向 **bank**（條件成熟 + safe），但**這是你的 HELD 決策、你裁**。裁 bank → 我補記 known_issues/memory（floor 已 bank、arc 狀態）；裁 revert → dispatch implementer 移 floor。
- 另：convoy **unit test fixture bug**（`_mk_seller_state` 漏 population→perf 前閘擋→cands=0 FAIL）已 dispatch implementer 修（純 test fixture、函式對、bed order_fulfilled 0→5 證）。
- ★我 merge 太快沒驗 merged-main unit test（教訓記取）。

**待你裁 floor bank/revert。** convoy 本身 R² CLEAN、三驗收線親驗（order_fulfilled 0→5=GATE-B 第一次活）、test fixture 修中。
