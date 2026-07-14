---
from: systems
to: measurer
status: open
topic: "[量測·中性full-HD] 恢復flee位移@77d7687c——驗flee真逃(tile_pos變)+N1_flee aggregate回落(衡量bug佔比)+故事連貫(逃→威脅解→轉別的)"
---

# 量測：恢復 flee 位移（中性 full-HD）

> **[worker 守則] 卡住/量不到/授權不明 → handback `to:systems`,禁 `AskUserQuestion` 中斷用戶（用戶明言再犯上 hook 強制擋）。**

branch `feat/flee-restore-movement` @ **`77d7687c`**（base 最新 main）。systems 驗 diff PASS：`flee_from_pos` 欄 + 3 站設（`_flee_threat_pos` 掃 discovered 取最大 ThreatAssessment.score→belief_pos，感知鐵律）+ mover `_flee_away_tile`（away=tile_pos−from_pos，FLEE_STEP=3，純幾何零 randf）+ release 清 + 假註解修好。TDD 7 綠、headless 3+3、憲法 sites=29、兩跑 bit-identical。

## 治根提醒（別誤判）
這刀治的是 **FLEE no-op（隊永不移動）→ 恢復位移**，非加執行鎖。∴ 驗的是「flee 真的把隊移走 + 威脅因距離自然解 → churn 消」，非「re-commit 節流」。

## 要驗（★中性 full-HD）
1. **★flee 真逃**：FLEE 隊 `tile_pos` 真變動（遠離威脅），非原地凍。specimen trace：flee_from_pos 設→move_target=away-tile→tile_pos 逐步遠離。
2. **★churn 消 + 故事連貫**：Team1 式「同決策 re-commit 數千次」消——逃遠→`ThreatAssessment.score` 距離衰減<threshold→`_has_active_threat` false→release→轉別的。全生命 specimen 判：逃→到安全/威脅解→轉別的（**有終點**），非終身原地 churn。
3. **★N1_flee aggregate 回落**（中性 full-HD 重跑 vs 修前）：回落幅度＝**衡量此 bug 佔 aggregate flee 多少**（blueprint 要的數字——驗證「aggregate 逃跑巨量是 churn 虛高非危險世界」）。
4. **不誤傷真戲**：Team0 全程/Team1 前半（貿易→掠奪→戰損死）好戲數字別動——只「逃」真的逃。
5. **無回歸**：同 seed 兩跑 bit-identical；憲法 sites=29；headless 零新增。

## 跑法
- **中性 full-HD**（`force_full_hd=true`、player_id=-1）——因 flee/反應 near-gated，要 full-HD 才活（同你觀察跑）。多 seed。
- 修前 baseline（main）vs 修後（branch）對照 N1_flee + Team1 式 specimen churn。
- `GODOT_TIMEOUT=600`；log/jsonl 存前 UTF-8。

## 判定
- flee 真逃 + churn 消 + N1_flee 回落 + 故事連貫 → 真修 → QA → blueprint 批 merge。
- flee 仍不動 or churn 仍在（如 away-tile 算錯/release 沒觸）→ halt `to:systems`（別放行）。

## 下游
數字一封信 `to:blueprint`（flee 真逃 + N1_flee 修前/後 + 故事 + specimen）。溯源 raw + measured_at_head `77d7687c`。
