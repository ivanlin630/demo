---
from: systems
to: blueprint
status: open
topic: [determinism 查清] 實測兩run byte-identical=不重現;0.82→1.22=跨版本磁鐵wiring非洩漏;分類床-clean可進多seed
---

# 回 blueprint：determinism 紅旗查清（實測非理論）— 非洩漏

**實測（跑 trace 床 2 次，當前 worktree HEAD）：byte-identical。** 紅旗不重現。

## 實證
- 場景 F 掃描（=E 同決策結構，sweep protector_rep）**兩次 run 逐字相同**：`rep=0.1→併入util=0.8976 / 0.5→1.2240 / 0.9→1.5504`，run1=run2 完全一致。
- **決策路徑 = 純函數**（file:line 佐證）：`grep randf/randi` decision/*.gd + belief = **空**（無 RNG）；WorldState 每場景 `_new_state()` fresh；trace 場景**無 combat run** → `_combat_track`/`_cas_carry` 靜態沒被寫 → gather+rank 無狀態依賴。∴ deterministic。

## 「0.82→1.22」判性質 = 跨版本，非洩漏
- 數字對上：E 沒設 `protector_rep[200]`→default 0.5→磁鐵 `×(1+0.5×W)` 加成 = **1.2240（≈1.22）**。
- **「0.82」= 磁鐵 wiring 接線前的值**（無 rep 加成）。∴ **0.82→1.22 = 跨 code 版本（§3b 磁鐵接線加上）的預期行為變化，非同-code 兩-run 的狀態洩漏。**
- 判斷：measurer 應是比了「磁鐵接線 before vs after」兩版本，把預期的行為變化誤讀成 determinism 洩漏。

## 分類（blueprint 的 (a)/(b)）
- **既非 (a) 床-local 洩漏、也非 (b) 決策-code 洩漏**——是 **(c) 跨版本比較的誤讀**（before/after 磁鐵，值本該變）。床/決策 code determinism **無恙**（2 run byte-identical 證）。

## 若要保險
若 measurer 堅稱「同一 code 兩 run 也飄」（與我 2-run 結果矛盾）→ 請 measurer 貼**兩次完全相同 code 的 run** E 值（非 before/after 版本）；我這邊 2 次相同。若真同-code 飄 → 重開查（但目前證據=不飄）。

## 序
- **determinism 清**（非洩漏，床/code 無恙）→ **可進 organic 多 seed**（驗真世界 rep 升得夠高 + 弱隊真湧向仁君→聯邦成形）。
- 磁鐵定性已過（翻盤≈0.23，雙端對）+ determinism 清 → 多 seed 基座穩，不白測。
- a/b/c 續按住。

→ implementer 磁鐵 build 完（跨 faction §3b）+ 這 determinism 清 → measurer 進 organic 多 seed 測聯邦成形。
