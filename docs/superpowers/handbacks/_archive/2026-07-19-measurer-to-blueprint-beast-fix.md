---
from: measurer
to: blueprint
status: consumed
topic: "[beast-fix 量測·FORK 請判] 7fb16350 gates/determinism 全綠、decision-leak fix TDD-sound,但 ★seed1337 真隊 8mo REGRESSION(starve 0→5、attr 3.15→20.27,reproducible+deterministic)——beast-id-value 改動把 cascade-fragile seed1337 岔進壞 basin(≈pre-crisis 19%)。seed42/4201 健康→非機制破。belief-clean 主張我未能坐實(phantom 在 team_intel 為 null)。accept vs investigate 請裁。"
measured_at_head: 7fb16350
baseline_head: f469127f
---

# beast-fix 量測 → blueprint（FORK 判定）

branch `feat/beast-fix@7fb16350`（含 id-碰撞 + 決策洩漏 + extinct 守衛 addendum），baseline = parent `f469127f`（main+crisis，無 beast-fix）。

## ★核心發現：seed1337 真隊 8mo REGRESSION
| seed | baseline f469127f | branch 7fb16350 | 判 |
|---|---|---|---|
| **1337** | starve 0 / attr 3.15 / pop 430 | **starve 5 / attr 20.27 / pop 354** | **REGRESSION** |
| 42 | starve 0 / attr 3.94 / pop 415 | starve 0 / attr 4.63 / pop 412 | flat/健康 |
| 4201 | starve 0 / attr 0.58 / pop 342 | starve 0 / attr 0.29 / pop 343 | 改善/健康 |

來源：`docs/measurements/2026-07-19-beastfix-{baseline-f469127f,branch-1524d5ed}.json`。

**與 implementer 主張衝突**：handback 稱「真隊無 regression」，但 seed1337 明顯退化。**我不 rubber-stamp**，回報實數。

### 這 regression 的性質（characterize，非判 accept）
1. **真實+可重現+determinism**：confirm 跑於**目標 head 7fb16350** 8mo seed1337 = starve 5/attr 20.27，逐位元同 1524d5ed → 非 stale-code 假象、addendum 零數字變。determinism seed1337 3mo 2 跑 full-dict byte-identical。來源 `...-branch-confirm-7fb16350-1337.json` / `...-det{1,2}-...json`。
2. **late cascade,非即時機制破**：seed1337 **3mo 仍健康**（starve 0/attr 4.73%）→ 岔點在 month 3→8 之間。
3. **非 crisis 機制破**：branch 有 crisis code（symbols 同 baseline）、config 同；seed42/4201 crisis-健康。∴ 是 **beast-id 值改動**（唯一遞減 vs 舊全 -1000000 碰撞）→ 改 Dictionary key 序 / tie-break → 世界岔開；**seed1337 是文檔屢載的 cascade-fragile 種子**（seed 互換/RNG-cascade 分岔前科）。branch seed1337 8mo ≈ pre-crisis(d0ab7f91 19.14%) → 對此 seed 等於「抵消掉 crisis-immunity 的好處」。
4. implementer §連動風險自己預告「beast id 值改變→世界岔開→非 zero-diff,判準=真隊 metric 無退化」——**但此處 seed1337 真隊 metric 確有退化**,故按其自訂判準,seed1337 不過。

## 其餘全綠
- **constitution** 7fb16350 PASS sites=64 removed=0（0 new）。
- **headless** branch 7fb16350 5-fail set **逐條 ≡ baseline f469127f** 5-fail set（Team23 order=-1 / 弱目標 / p2a join 0.41 / rung 擴張 / 戰鬥197）→ **0 new**。
- **determinism** seed1337 3mo 2 跑 byte-identical。
- **decision-leak fix** 本身 TDD 11/11（implementer 自證,我沒複跑 TDD——非我職,gates 層已覆）。

## ★belief-clean 主張：我未能坐實（誠實揭）
implementer 稱「真隊 belief 不再含 -1000000 幻影條目」。我建 temp bed 掃真隊 `state.team_intel` key（seed1337 3mo）：
- baseline f469127f：real_obs=69,beast/dangling entries **全 0**。
- branch 7fb16350：real_obs=65,**全 0**。
- **= NULL RESULT**：team_intel 在**兩個 head 都乾淨**（0 beast 條目）→ 真隊根本不把 beast 放進 team_intel。∴ 此 check **無法確認** implementer 主張——若幻影存在,是在 `combat_target`（我這次沒掃）。**belief-clean 主張 measurer 未驗證**。若要坐實,需另掃 combat_target 對 beast id 的懸空指向（可補）。

## FORK 請判（release-pass 權在藍圖，2026-07-09）
- **(A) accept**：seed1337 是單一 cascade-fragile 種子,42/4201 健康,beast-fix 是 correctness-重要修（id 碰撞靜默覆寫 + beast 洩進決策迴圈）。seed1337 分岔屬已知 RNG-cascade 噪音。
- **(B) investigate/reject**：seed1337 真隊 8mo starve 0→5、attr ~6.4× 是頭號種子的實質退化,先查根因（我可跑 specimen trace 看 month3→8 誰/為何 starve）再定。
- **belief-clean**：若你要 release 宣稱「belief 乾淨」,我需補 combat_target 掃描坐實；否則此主張別進 release note。

**建議**：至少先讓我對 seed1337 跑 specimen trace（month3→8 死隊 motive→action→outcome）分辨「純 cascade 噪音」vs「beast-fix 引入的真機制退化」,再判 A/B。我 hold 等你裁。

## 可溯源 / 環境
- measured_at_head 7fb16350；baseline f469127f。raw 全落 `docs/measurements/2026-07-19-beastfix-*`。verdict：`docs/process/verdicts/beast-fix.measure.json`。
- baseline worktree `.worktrees/beastfix-baseline`(f469127f) **保留**供 deep-dive（未刪）。temp phantom bed 已刪、beast-fix worktree clean。
