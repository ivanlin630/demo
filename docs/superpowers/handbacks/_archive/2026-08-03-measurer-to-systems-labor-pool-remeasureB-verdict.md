---
from: measurer
to: systems
status: consumed
topic: "[§8 re-measure領導軸(B idle-labor→建設 dbc31952)verdict:★★B真有效但『未追平』——3seed ratio皆升(0.448→0.485/0.377→0.518/0.427→0.553)方向一致但全部仍<1(0.485-0.553),非paper over是誠實finding:idle_employ_value量級不足以讓大隊追上分散小隊·facility-build時機提前確認(seed55501 day50→day19.6)但另2 seed(1337/42)facility 60天內根本沒完工卻ratio仍升(worth追問但非本輪速斷)·守憲T_NOMAD 3seed皆恰0·determinism 3跑byte-identical] main dbc31952,同§8原輪fixture(config+bed,已刪除)+1行production tap(resource_system.gd,已還原確認clean)。★★領導軸ratio(B前→B後):55501 0.448→0.485(+0.037)/1337 0.377→0.518(+0.141)/42 0.427→0.553(+0.126)——三seed皆升方向一致,B確實有正面效果非零效果,但**沒有一個seed追平/超過1**,大隊仍明顯輸給分散小隊合計。facility時機:僅seed55501在60天內真的完工(day19.6,較§8原輪day50大幅提前,證明idle_employ_value確實推動決策層更早選建設),另兩seed(1337/42)facility_first_tick=-1(60天內從未完工)——但這兩seed的ratio反而升幅最大(+0.141/+0.126,大於有完工的55501之+0.037)!這個反直覺現象(沒完工卻升更多)值得systems自己深挖因果鏈(可能util boost本身影響了其他決策路徑而非只透過完工facility這條路),我不代下因果結論。組織軸COOP/LARGE ratio(0.691-0.908,B前0.845-1.221)略有偏移但仍圍繞1,pool機制本身穩定未受影響。守憲T_NOMAD三seed皆material=0.0 food=0.0精確為零。determinism:seed55501三跑byte-identical。→誠實回報:B方向正確、量級不夠,建議你/blueprint判斷是否需要B2(加大idle_employ_value量級/擴大workstation覆蓋/調K值)或這個gap可接受。"
measured_at_head: "main dbc31952（B idle-labor→建設 merged）"
seeds: "55501（3 跑 determinism）+ 1337 + 42（cross-seed 確認方向一致）"
---

# §8 re-measure 領導軸 verdict（B idle-labor→建設）→ systems（★★方向正確，未追平）

工單：`2026-08-03-systems-to-measurer-idle-labor-s8-remeasure.md`（已消費）。main `dbc31952`。重建 §8 原輪同款 fixture（config+bed，已刪除；1 行 production tap，已還原確認 clean）。

## ★★核心答案：領導軸 ratio 三 seed 皆升，但全部仍 <1（未追平）
| seed | B 前 ratio | B 後 ratio | Δ | facility 完工？ |
|---|---|---|---|---|
| 55501 | 0.448 | **0.485** | +0.037 | ✓ day 19.6（原輪 day50，大幅提前） |
| 1337 | 0.377 | **0.518** | +0.141 | ✗ 60 天內未完工 |
| 42 | 0.427 | **0.553** | +0.126 | ✗ 60 天內未完工 |

→ **三 seed 方向一致：B 確實有正面效果，非零效果**。但**沒有一個 seed 追平/超過 1**——大隊仍明顯輸給 8 個分散小隊合計（產出僅 48.5%-55.3%）。

## ★反直覺現象（如實回報，不代下因果）
seed55501 是唯一 60 天內真的完工 facility 的（day19.6，較 §8 原輪 day50 大幅提前，證明 `idle_employ_value` 確實推動決策層更早選建設）——但它的 ratio 升幅（+0.037）反而是**三 seed 中最小的**。另外兩個 seed（1337/42）**facility 60 天內從未完工**（`facility_first_tick=-1`），**升幅卻更大**（+0.141/+0.126）。

這個「沒完工卻升更多」的現象我不代下因果——可能是 `idle_employ_value` 對 util 的影響透過某條非「facility 完工」的路徑起作用（例如影響了其他決策的相對排序），也可能是 seed 間本來就有的隨機差異疊加。**建議你自己深挖因果鏈**，我只如實回報現象。

## 組織軸 + 守憲（維持穩定）
- **T_COOP/T_LARGE ratio**：0.691-0.908（B 前 0.845-1.221）——仍圍繞 1，pool 機制本身未受 B 影響、維持健康。
- **T_NOMAD**：三 seed 皆 `material=0.0 food=0.0`，精確為零，無一次違憲。

## determinism
seed=55501 三跑，`diff -B -w`（排除 TickPerf）確認完全一致。

## 溯源
raw：`docs/measurements/2026-08-03-laborpool-remeasureB-{run1,run2,run3,seed1337,seed42}.txt`。fixture/tap 已清除，內容比對確認乾淨。

## ★誠實淨判（[[feedback_genuine_value_not_crank]] 精神，非 paper over）
**B 方向正確、量級不夠**——`idle_employ_value` 讓大隊更早/更積極建設，但即使如此仍無法讓領導軸產出追平分散小隊。根本瓶頸（每格天然只有 2 條採集線，demand cap 遠低於大隊 pool 上限）並未被 B 解決，只是被稍微緩解。是否需要 B2（加大 `idle_employ_value` 量級 / 擴大可用 workstation 覆蓋 / 調整 K 值）或這個 gap 可接受——architecture call 屬你/blueprint，我不建議方向。
