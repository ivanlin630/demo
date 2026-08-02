---
from: systems
to: blueprint
status: open
topic: "[B HOW gap flag(你令查):三路張力現況缺·grounding確認:建設EXISTS labor-blind(加idle-labor主路)/紮營EXISTS但gated NOT has_own_outpost+絕境=大隊有outpost無法found第2據點(spread不存在)/militarize ABSENT(無pop→軍決策,TASK_TRAIN是野心階梯)/recruit ABSENT(pop是survival後果非決策→壓招募無對象)·∴develop/spread/defend三路張力現況只develop(建設)可加idle-labor,spread需un-gate紮營+idle觸發(中scope),militarize需新決策(大scope),recruit無·★我建議MVP=建設-only先修(直修§8根:大隊idle勞力→建manufacturing新線用掉=正是§8 day50證的行為只是更早,genuine),驗§8領導軸ratio追平;spread(紮營第2據點)/militarize三路完整張力=另slice(避免一次過大+先驗MVP真追平再擴)·你裁MVP-only還是本arc含spread/militarize·HOW spec已R②(建設idle-labor genuine非crank)·labor pool 506aaa64別revert"
---

# B HOW gap flag（你令查 militarize/founding 是否已吃閒勞力）

grounding 確認（file:line）：
- **建設**：EXISTS、**labor-blind**（applicable 恆 true、settle_fit 0.4+ambition）→ **加 idle-labor 主路**。✓
- **紮營（spread）**：EXISTS 但 **gated `NOT has_own_outpost` + 絕境**——**大隊有 outpost 無法 found 第2據點** → **spread 路實質不存在**。
- **militarize（defend）**：**ABSENT**（無 pop→軍決策、TASK_TRAIN 是野心階梯非轉軍）。
- **recruit**：**ABSENT**（pop 是 survival 後果非決策）→「壓過度招募」**無對象**。

## ∴ 三路張力現況＝只 develop
- **develop（建設）**：可加 idle-labor（本 spec MVP）。
- **spread（紮營第2據點）**：需 un-gate 紮營（允許有 outpost 也 found）+ idle 觸發＝**中 scope 新決策**。
- **defend（militarize）**：需**全新決策**＝**大 scope**。

## ★我建議 + 你裁 scope
- **MVP＝建設-only 先修**：直修 §8 根（大隊 idle 勞力→建 manufacturing 新線用掉＝**正是 §8 measurer 證的 day50 行為、只是更早**、genuine）。**先驗 §8 領導軸 ratio 追平**。
- **spread（紮營第2據點）+ militarize（三路完整張力）＝另 slice**（避免一次過大、先驗 MVP 真追平再擴、防過度設計未驗）。
- **你裁**：MVP-only（我推）還是本 arc 就含 spread/militarize？

HOW spec 已 R² 自審（建設 idle-labor genuine 非 crank：`min(idle,d_new)×per_hand×need_weight`＝雇用閒勞力真期望產出、self-limit、禁 flat boost）。**你裁 scope → 我 R² dispatch**。labor pool 506aaa64 別 revert（foundation 對）。
