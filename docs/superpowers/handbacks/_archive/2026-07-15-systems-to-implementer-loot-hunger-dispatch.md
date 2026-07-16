---
from: systems
to: implementer
status: consumed
topic: "[DISPATCH] 絕境掠奪對準糧源(hunger-weighted prey)——新分支feat/loot-hunger-targeting;R²CLEAN;單一連續公式;TDD"
---

# Dispatch：絕境掠奪對準糧源

spec：`docs/superpowers/specs/2026-07-15-loot-hunger-targeting.md`（§Fix 已鎖單一連續公式）。
R² CLEAN：`2026-07-15-reviewer-to-systems-loot-hunger-r2-clean.md`（真根/感知鐵律/②c/不誤傷/身分=權重全過）。

## 在哪：新分支
`feat/loot-hunger-targeting`，base 最新 origin/main（含 desperation A/B/A-2 + confound 修）。`git fetch && git log origin/main -1` 確認 base = `1c43c750`+。

## 做什麼（單一連續加權公式，★無離散門檻切主鍵）
`faction_ai_system.gd _find_weakest_prey` 排序改：
- 保 beatability 硬門檻（`pop_est < team.population×0.7` 不動）。
- 可打候選內用**單一連續 `prey_score`**：
  ```
  hunger = clampf((DESPERATION_DAYS - looter.food_days)/DESPERATION_DAYS, 0, 1)   # 連續,sated→0
  prey_score = <pop 弱勢項> − FOOD_PULL × hunger × <food_est 正規化>
  ```
  選 prey_score 最優。`FOOD_PULL`/正規化＝TEST VALUE，implementer 定（deterministic）。
- **sated（food_days≥DESPERATION）→ hunger=0 → food 項歸零 → 精確等同現行 pop_est-only**（strategic raid 零退化，這是硬要求）。
- **★禁 `if food_days<X` 切排序主鍵**（那是路徑切換違身分=權重）——只連續加權。
- food_est 用 `bel.food_est`（belief best_estimate，非 god-view）；不加 food 硬濾（②c 血訓，無糧目標仍在候選只是排後）。

## 守則
- 純確定性 belief 讀 + 排序，零 randf；憲法零新 try_set（既有 finder 內排序改）；不動 A/B/A-2。

## TDD
1. **飢餓 looter**（food_days<DESPERATION）+「弱但無糧 vs 稍強但糧多可打」→ 斷言選**糧多**（food 拉高）。
2. **sated looter**（food_days≥DESPERATION）→ 斷言選**最弱**（hunger=0，行為 = 現行 pop_est-only，byte-identical）。
3. **連續性**：food_days 掃過 DESPERATION 附近，prey 選擇**連續變化無跳變**（非門檻突變）。
4. 標準：determinism 兩跑同；憲法 sites=29；headless 零新增。

## 完成後
→ measurer **中性世界**重跑（confound 已修）：day24-26 殘留 thrash 消 + 絕境 looter 掠奪成功 food 真回升 → QA 故事複判 → blueprint 批 merge。
完成判定 = systems + reviewer/QA + measurer 中性重驗。scope 疑義/前提 gap 走 `to:systems`（不自標 REDO）。
