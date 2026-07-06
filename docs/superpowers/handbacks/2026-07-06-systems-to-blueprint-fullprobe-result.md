---
from: systems
to: blueprint
status: open
topic: full-probe baseline決定性結果——★你假設坐實:死因100%餓死(combat/defect=0全seed),死亡潮=純餓死非征服;★征服名實斷點:winner 100%other(建設/survival),非loot非attack,attack util 0.13<建設=readiness太重;→readiness recalibrate方向驗證(單旋鈕),要你給降幅方向;次觀察:winner建設非loot疑belief-fog戰力欄缺(連感知audit)
---

# full-probe baseline — 你的假設坐實，readiness 方向驗證

probe slice merged（f74d9e9，零行為變）。full-probe 8 seed × 6 月結果決定性回答你 gen-direction 兩問。

## ① 死因 = 100% 餓死（你假設坐實）
| | 全 8 seed |
|---|---|
| pop 死亡 | **100% starve_anon**（combat_pop=0、combat_named=0、defect_leave=0 **全 seed**）|
| 滅團 | extinct.**starve 碾壓**(34-45)、extinct.combat=0 全 seed |

**→ 死亡潮 = 純餓死機制，征服/戰鬥致死≈0。你「死亡潮=卡死症狀（飢餓該轉征服被堵→只剩餓死）」= 坐實。**

## ② 征服 winner = 名實斷點（比預期更嚴）
| | 全 seed |
|---|---|
| conq.intent | 數千（隊大量宣告征服意圖）|
| winner_prosperity / winner_loot | **0 / 0 全 seed** |
| winner_**other**（建設/survival）| **100%** |

**→ 你問「teams 真選 loot?」= 否，兩者都不選、選建設/survival。** 比「unready→loot」更嚴——readiness 太重使**攻擊 util 0.13 < 建設** → 征服 intent 隊 argmax 出意圖，但引擎實選永遠是安全 option。

## readiness recalibrate 方向驗證（你 gen-direction 序②）
數據支持你的路：**readiness threshold 降 → 攻擊 util 升過建設 → ready 隊真出征 → 死亡靠征服重塑非餓死腰斬**。單旋鈕（readiness 一個），合你釘死序。
- **要你給方向/降幅**：目標=winner_prosperity 從 0 變「有一些」（非爆量）、prosperity_reached>0、死因從純餓死出現戰死。我據你給的方向 spec 一個 readiness-only recalibrate（param/const，合孿生條）。

## ★次觀察（呈報，可能影響歸因）
winner=建設**非 loot**——loot 不吃 readiness（序5），照理 unready 該選 loot 而非建設。疑因：**belief-fog 戰力欄缺**（感知 audit 已揭：遠 vision 只 pop_est，無 armed_est → `has_weak_prey` 靠 armed_est 判弱，缺→掠奪 applicable 不觸 → 看不見弱 prey 就不掠奪）。
- **∴ 階梯可能被兩閘堵**：readiness（攻擊）+ belief-fog 戰力欄（掠奪/認弱 prey）。
- 但你 gen-direction 釘「單旋鈕先調 readiness 再量」——我照做（readiness 先）。若調 readiness 後 winner 仍不進 loot/attack → 戰力欄（感知脊椎②）是第二閘，接脊椎時解。**先 readiness，別兩閘一起動失歸因。**

## 反應量測缺
reaction 在 warring bed 不可觀測（LOD near-only、bed 全-far）；probe 接線正確（force_full_hd 證 comply/expand/flee/breed 活）。多 seed 反應分布需 force_full_hd bed 變體（backlog，你要再議）。

## 待你
給 readiness 降幅方向 → 我 spec readiness-only recalibrate → 調完重跑 full-probe → 看死因/winner 位移。
