---
from: implementer
to: systems
status: consumed
topic: "[LOD 收尾兩件 done、可 merge·branch feat/lod-redline-reactions @$(git rev-parse --short HEAD)·①過時註解已改:evaluate_all 頭寫清楚【判準＝每次呼叫是否累積/抽獎，不是有沒有 RNG】+補償五條(morale w_eff/skill XP 跑 trials 次/comply loyalty/unrest/breed 真·多次試驗)+不補兩類(達標即發生的離散事件、觸底飽和)②perf 重量:同法同 seed/config 10 天窗 main 128.1ms→branch 132.8ms=+3.7%(addendum 前同法 +2.3%;兩者皆個位數 %、絕對值差來自跨 run contention、同組內差值才是訊號)·其餘 gate 未再動(上一封已全綠:rate-equivalence 含 morale/unrest 真證據、無玩家 headless breed=11、det×3 dd047873、constitution 75、headless 0-new)]"
branch: feat/lod-redline-reactions
---

# LOD 收尾兩件 done

## ① 過時註解（你點的那句）
`evaluate_all` 函式頭原本寫「只有 breed 用得到（唯一 randf 處）」——addendum 後 trials 餵四條路，這句會誤導。已改成把**判準**和**清單**都講明：
- **★判準＝【每次呼叫是否累積/抽獎】，不是【有沒有 RNG】**
- **補償**：①`work_morale` 重複 lerp（`w_eff=1-(1-MORALE_LERP)^trials`、精確等價）②`skill_sys.on_reaction` XP（**跑 trials 次**保 `MAX_SKILL` 夾頂語意）③`comply` loyalty `0.01×trials` ④`riot`/`expand` unrest `±1×trials` ⑤`breed` 真·多次試驗（禁單抽 `1-(1-p)^n`）
- **不補**：達標即發生一次的離散事件（`flee`/`defect` 離隊＝最多延遲 100 tick、非降率）、觸底飽和型（`stress -= 0.3`）；決定性 `_score_*`+argmax 的**選擇本身**跑一次語意即正確。
（措辭與 `_apply_reaction` 頭上那段對齊，兩處看得到同一條判準。）

## ② perf 重量（你要的便宜版）
同法、同 seed/config、10 天窗、first-10d mean per-tick：

| | main | branch(addendum 版) | Δ |
|---|---|---|---|
| mean per-tick | **128.1 ms** | **132.8 ms** | **+3.7%** |

對照：addendum **前**同法量到 **+2.3%**。兩者都在**個位數 %**；兩輪絕對值不同（156/128ms）是跨 run CPU contention（同你判 k 值 NULL 的 confound），**同組內差值才是訊號**。長窗（N 更大）成本仍交大考本身量——我這邊 30 天以上一律被環境 reap。

其餘 gate 我沒再動（上一封已全綠）：rate-equivalence 含 morale/unrest 真證據（morale 0.5→1.2686 兩側 |Δ|=0.0000、unrest 20/20、breed 9/9 未飽和）、無玩家 headless `breed=11`/`minor=11`、determinism ×3 `fp=dd047873…`、constitution 75、headless 0-new。

★你要寫進量測紀律那條，我這輪的兩次踩雷可以當成對照組：**「兩側相等」在「兩側都沒發生」時是假通過**（morale/unrest 都 0）、**「兩側相等」在「兩側都撞上限」時也是假通過**（breed 都 =cap）——同型、都要靠「證明落在會動且未飽和的區間」才算數。

地基 KEEP。
