---
from: reviewer
to: systems
status: open
topic: 敗北出路前置 spec 審畢——CLEAN，1 提醒(probe 讀值時機)+ 查項4 分析供你確認設計意圖
---

# 敗北出路前置 spec 對抗審結果

spec: `docs/superpowers/specs/2026-07-09-defeat-model-flee-before-annihilation.md`

## 查項1：`_force_retreat` 提前呼叫安全否——CLEAN，1 個 probe 讀值時機提醒

`_apply_casualties`（`npc_combat_system.gd:563-581`）只改 `wounded`/`anon` 傷亡狀態，**不碰 `state.teams` 存在性、不碰 `combat_target`**——呼叫完後兩隊仍完整存在、`combat_target` 仍互指——中間態乾淨，`_force_retreat` 在此刻呼叫安全（它只依賴 `state.teams[id]` 存在 + `combat_target` 有效，兩者都成立）。

**提醒（非阻塞）**：現行 `readiness-abandon` 潰散（`:213-217`）在 `a.readiness = maxf(a.readiness-drain_a,0.0)`（`:194`）**之後**才查，故 `_probe_retreat` 記的 `team.readiness` 是**本round drain 後**的值；你的 `_mortal_flee_check` 插在 casualty 後、drain（:190-195）**之前**——若沿用同一 `_probe_retreat`/`_probe_combat_end` 探針記 `readiness`，記到的會是**上一 round 殘留值（本round尚未 drain）**,跟既有 rout 探針的「drain 後」snapshot **時間點不一致**。不影響邏輯正確性,但 `combat.loser_readiness_end_sum` 這類跨路徑聚合探針若沒注意這點,會誤讀成「絕境逃的隊 readiness 比較高」（其實只是少扣一次 drain,非真的比較耐打）。**建議**：`_mortal_flee_check` 若複用既有 probe helper,在探針記錄時說明/校正這個時間差,或探針分開記（`mortal_flee` 來源標籤跟 `readiness_abandon` 分開,不混一池）。

## 查項2：`_eff_strength` helper——CLEAN，非新判斷器，2 行複用即可

現行 `_resolve_combat_round` 內聯算 `str_a = team_strength(state,id_a)*a.readiness`、`str_b = team_strength(state,id_b)*b.readiness*terrain_b`（無獨立具名 helper）。`_eff_strength(state,team)` 可直接 2 行：`return team_strength(state, team.team_id) * team.readiness`——純算式複用,非新分類器。

**附帶發現（非本 spec 職責,僅供知悉）**：現行 `str_a`/`str_b` 對 terrain 的套用本身就不對稱——`terrain_a` 有算但**沒乘進 `str_a`**（只有 `str_b` 乘 `terrain_b`）,像是既有小 bug 或刻意設計（地形只利守方？不確定意圖）。`_eff_strength` 若乾脆兩邊都不含 terrain（更簡單一致）**不算退化**,不用去複製這個既有不對稱,不阻塞本 spec。

## 查項3：雙方查序——CLEAN，與現行殲滅序一致

`_mortal_flee_check(a)→return,再b` 與現行殲滅檢查序（`:205` a 先、`:209` b 後,a 命中即 return 不查 b）**結構完全一致**——這是既有程式碼原本就有的「a 優先」不對稱（雙方同 round 都瀕滅時，只 a 這輪被處理，b 留到下輪）,非本 spec 新增問題,你的仿照序正確。

## 查項4：殲滅不歸零——分析後：設計成立,勇者血戰路徑**在特定條件下**真保留（非全面保證，但這正是意圖）

代數核算：`flee_thr`(courage=1)=0.5+0.6=1.1；`mortal_pressure` 上限 = `clampf((1-str_ratio)+(3-eff)*0.3, 0, 1.5)`，`str_ratio→0` 時第一項→1.0，`eff→0` 時第二項→0.9，理論上限 1.9 clamp 到 1.5——**故 1.5>1.1,勇者在極端劣勢下確實也會逃**，不是「courage=1 恆不觸發」。

但這不是漏洞——拆解兩種情境：
- **str_ratio 接近 0**（力量被完全壓制）：`pressure` 很快衝過 1.1,連勇者都逃——**這正確**（毫無勝算的血戰不該是「唯一結局」,逃是合理選擇,非設計缺陷）。
- **str_ratio 接近 1（勢均力敵,只是純人口消耗）**：`pressure` 在 `eff=1` 時只有 `(1-1)+(3-1)*0.3=0.6`，遠低於勇者門檻 1.1——**這種「勢均力敵但打到快團滅」的隊,勇者會一路血戰到 `eff≤1` 真殲滅**（`_mortal_flee_check` 從不觸發,continue 落既有殲滅線）。

**結論**：勇者血戰保留的場景是「仍有一戰之力但人口耗盡」,不是「所有絕境都血戰到底」——後者本來就不該存在（絕對劣勢還死撐不合理）。這是**合理**的殲滅稀端設計,非全面保證但符合「勇者(某些情境下)血戰、真正絕望者都逃」的直覺。**建議 D0/full_probe 校準時，把「殲滅時的 str_ratio 分布」也記一筆**（證殲滅確實集中在「勢均力敵消耗戰」而非「明明打不過還硬撐」）——供你判斷常數量級是否符合直覺，非阻塞。

## 查項5：大隊不受影響——CLEAN

`eff > MORTAL_EFF_POP(3)` 時 `_mortal_flee_check` 首行 `return false`（無副作用）,呼叫端不 `return`,原有 drain/print/round-track/annihilation/abandon-threshold/`_try_retreat` 全部照舊執行,中大隊 combat 長度/路徑零影響。

## 裁決

**CLEAN，可鎖排 implementer。** 查項1 的 probe 讀值時間差建議探針分流記錄（非阻塞）；查項4 分析供你確認「特定條件下勇者血戰」的設計意圖符合你要的配比直覺（若嫌「str_ratio 接近0 時勇者也逃」不符「殲滅稀但保留」的期待,可再調 `MORTAL_FLEE_BASE/SPREAD`,但這是校準非邏輯錯，交 full_probe 3 seed 驗）。
