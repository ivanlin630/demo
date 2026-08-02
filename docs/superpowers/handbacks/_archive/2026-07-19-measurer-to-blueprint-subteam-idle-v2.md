---
from: measurer
to: blueprint
status: consumed
topic: "[subteam-idle v2 量測·NOT clean-pass·must-pass FAILED] ab3044c3 供給環機制大致對(囤糧封頂~10、live-parent forager 交糧,v1 的 200-2000 囤糧消)——但 ★must-pass『seed42 famine→0』FAILED(仍 4)+★seed1337 WORSENED(6→10,attr28%,最差版)+orphan-forager 囤糧 edge(tid76 parent=0 卡 483 days 無法交)。gates 綠。遞迴 seed-cascade:每版翻不同 seed。建議 blueprint/systems 裁:gate-tune / orphan 處理 / 接受 cascade / rethink——非我單邊。"
measured_at_head: ab3044c3
baseline_head: c5ab36d9
---

# subteam-idle v2 量測 → blueprint（NOT clean-pass·must-pass FAILED）

v2（我 send-back 後 implementer 加供給環：forager 除非 sated(food≥10) 或 parent 缺糧(<3) 才留 forage，否則歸建 try_merge_back 交糧）。baseline c5ab36d9（v1 沿用）。

## ✅ 供給環機制大致對
SITRACE seed42：多數 forager（54/61/62/64/68/73/77/56）food_days **封頂 ~10-11**（sated→歸建交糧），vs v1 囤 209。**v1 的 200-2000 food-days 囤糧現象大致消**。機制正解。

## ❌ 但 must-pass 沒過 + seed1337 惡化
| seed | baseline | v1 | **v2** | 判 |
|---|---|---|---|---|
| **1337** | 7 | 6 | **10**（attr28.38）| **v2 惡化,最差版** |
| **42** | **0** | 10 | **4**（attr12.04）| v1→v2 改善,但 **must-pass →0 FAILED** |
| 4201 | 0 | 0 | 0 | identical |

- **seed42 famine→0 是 implementer 標的 v2 核心 must-pass**：實測仍 **4**（非 0）→ **未達標**。
- **seed1337 反被 v2 惡化**：6→10、attr 19→28%（比 v1、比 baseline 都差）。供給環的條件歸建-交糧時序在 seed1337 context 岔更壞。

## ★orphan-forager 囤糧 edge（供給環閉不了的洞）
tid=76 `parent=0` 全程卡 forage 16040t、囤 **483 food-days**、pop 長到 6、從不交糧。**parent 消失/不可達 → 歸建無處交 → 續囤**。供給環假設 parent 在；parent 缺席時閉不了。

## 判定：NOT clean-pass
供給環機制正解（囤糧大致封頂、live-parent 交糧），但：
1. **must-pass seed42→0 FAILED**（仍 4）。
2. **seed1337 惡化**（10,最差）。
3. **orphan-forager 囤糧 edge**（parent 缺席無法交）。
4. **遞迴 seed-cascade**：v1 翻 seed42、v2 翻 seed1337——每版條件-merge 時序岔不同 seed，**沒收斂**。

## 為何交你裁（非我單邊）
- gate 值（SATED=10/PARENT_LOW=3）是 TEST VALUE，implementer 要我 tune——但 sated 封頂已生效(~10)，**seed1337 惡化 + orphan edge 不像純 gate-value 問題**，較像條件-merge 時序的 seed-敏感 + 缺 orphan 處理。
- 盲 sweep gate 值（多 run）在「code 方向未定」時違量測協議（迭代期禁大窗盲跑）。**先要你/systems 定方向**：
  - (A) **gate-tune 試**（我 sweep SATED/PARENT_LOW 找 seed42→0 且 1337 不惡化的值,若存在）
  - (B) **orphan 處理**（parent 缺席 forager → 轉獨立/faction 交糧,非續囤）+ 查 seed1337 惡化根因
  - (C) accept 現狀（seed-cascade 內在,囤糧機制已大改善）
  - (D) rethink（條件-merge 時序沒收斂,換法）
- 我傾向 **(B)+查 seed1337**：must-pass 沒過 + 最差版惡化,不宜 accept；orphan edge 是真洞。

## gates（綠）
constitution 64/0-new、headless 0-new、determinism implementer bac0e781（未獨立重跑）。

## 下一站
你裁 A/B/C/D → 我照裁跑（gate sweep / seed1337 根因 trace / orphan 量）或回 systems。verdict `docs/process/verdicts/subteam-idle-latch-v2.measure.json`、raw `docs/measurements/2026-07-19-subteamidle-v2-*`。SITRACE 已 revert、branch clean。
