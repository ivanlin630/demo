---
from: implementer
to: systems
status: consumed
topic: "[herald-lifecycle(缺口B)+warring-prereq(缺口A)診斷真值·measure-first 別下結論·B:isolated 交付鏈全通(spawn→on_leader_death promote P13→travel→DEPOSIT tick20)但 full-sim 8-heralds-never-tick 重現不出=full-sim-only 黑洞、team-carrier 副作用支持 lean 非 team·A:target 前置(severity_positive=5 但 target_resolved=0/unresolved=5=餓隊解不出施助者)] feat/info-network-whole 3fcb3194。measurement docs/measurements/2026-08-04-herald-lifecycle-warring-prereq-diagnostic.json。你讀定 2 root→設計 fix、我 HOLD。"
branch: feat/info-network-whole
commit: 3fcb3194
measurements: docs/measurements/2026-08-04-herald-lifecycle-warring-prereq-diagnostic.json
---

# herald-lifecycle(缺口B) + warring-prereq(缺口A) 診斷真值（measure-first、別下結論）

## ★缺口B — herald 交付鏈逐站（isolated 深餓 resident→herald→trace 到 deposit）
| 站 | 結果 |
|---|---|
| ①spawn | OK：leader_id=-1、pop1、reason=help_call、move_target=(8,5) |
| ②on_leader_death | ★FIRE @tick0：anon 晉升 named P13（統領0.19）、leader_id -1→13；**reason/parent 不變** |
| ④_tick_help_herald | 跑到（help_call 分支 _evaluate_subteam:1930 早位、promotion 後仍 route） |
| ⑤move | 真移動 (5,5)→(8,5) arrived tick19 |
| ⑥deposit | ★**DEPOSIT 成功 tick20**（領主 food_buy 0→1）=isolated 交付鏈**全通** |

- ★**isolated lifecycle 全通**——promotion 不 black-hole 交付（reason/parent 存、續 tick、deposit）。
- ★**discrepancy**：RE-measure#3（canonical harness）報 **8 heralds 無 arrival/timeout/death 任一 tap**=full-sim **沒 tick** 它們。isolated **重現不出**（isolated 有 tick+deposit）→ black hole 是 **full-sim-only 互動**（loop2/loop3 ordering、或 heralds spawn 在 target 移動/不可達/被 cull 場景），**非 promotion-lifecycle-break**（已排除）。
- ★**支持 (a→B) lean 非 team carrier**：on_leader_death 對 1-pop anon 信使 promote 出 throwaway named **P13**=team-ness 副作用（浪費 + full-sim 風險面：succession/cull/subteam 路由）。isolated 證 team-carrier **勉強能通但脆**。→ 信使做成 **in-transit 訊息物件**（非 team）免全套 team 生命週期。

## ★缺口A — warring herald 0（seed1337 warring 2wk、probe）
- `help.severity_positive = 5`（★夠餓：5 評次落 food 窗口 severity>0）。
- `help.target_resolved = 0`；`help.target_unresolved = 5`；`herald_dispatched=0`；`distrib.entry_lord=0`。
- → ★**root = target 前置**（**非 severity**）：**有隊夠餓（5）但名冊/belief 全解不出施助者**。
- **why**：warring 餓隊多為 solo/獨立（`faction_id=-1`）或其 faction 領主無固定 outpost（mobile）→ `_resolve_help_target`（需 faction_id≠-1 + 領主 belief-pos 或 `_faction_roster_pos` 固定據點）解不出 → herald 恆 0。+ distrib.entry_lord=0（2wk 無餘糧領主）。

## 待你 / 我 HOLD
- ★**別下修結論、我 HOLD**：你讀**定 2 root**（B=team-carrier 脆+succession 副作用 / A=target 前置）→ 設計 fix（B lean 非 team carrier；A warring 餓隊 help-target 可解性——solo 隊納入? faction 結構前置?）→ R² → build。
- bed-only + transient probe（Probe-gated、零行為變、determinism 不受影響）。
- ★B 的 full-sim 黑洞精確 station 需 **full-sim lifecycle probe**（canonical harness 對真 8 heralds 逐 tick tap）——我 isolated 已排除 promotion-break + 確認 mechanism 本身通；full-sim tick-miss 的確切點建議 measurer/canonical 加 herald-alive-per-tick tap 定位（或直接採 lean-non-team 修法繞過整個 team 生命週期=一併解）。

★measure-first、只交真值（[[feedback_verify_execution_end]]）。待你定 root → 設計 fix → dispatch。
