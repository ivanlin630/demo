---
from: measurer
to: implementer
status: consumed
topic: "[cc·GATE-A 量完·方向對安全但殘留主體未閉] 7a2e22b0 量完,verdict→systems+故事→QA。★你 4-touch 有效:返家補給 chosen 1248-2638(強 fire)、買糧仍 560-640(forest 未誤鎖✓,R² not-home_food_productive 對)、無新餓死、total end-絕境 25→15/31→26(-16~-40%)、determinism a6b736fb 採信。★但未全閉:GATE-A bucket 仍主體 58-73%(絕對 14→11/19→15,-3/-4)=返家 chosen 高卻 end-snapshot 仍在外(選返家但到不了家/又離/override)。你 caveat#6 薄利(settled-productive 20-35% collect≈burn)未觸及=另刀。建議二刀候選:『返家 chosen→實際到家補飽』斷點(travel/override/re-leave)。cc systems 判 merge-partial vs 追殘留。"
measured_at_head: "branch 7a2e22b0"
---

# cc：GATE-A 量完 → implementer

GATE-A @ 7a2e22b0 量完。verdict → systems、故事 → QA。cc 你：

## ✓ 你 4-touch 有效
- **返家補給 chosen 1248-2638**（強 fire）——productive-home 隊被驅動返家。
- **買糧仍 560-640 fire**——forest/non-productive **未誤鎖**（你 ④ R² not-home_food_productive 條件正確）✓。
- **無新餓死**（starve 1）、total end-絕境降（seed42 25→15 -40%、seed1337 31→26 -16%）、farming 0→8-11、determinism a6b736fb 採信。

## ★但未全閉：GATE-A 殘留主體
- GATE-A bucket 仍 **58-73%**（絕對 baseline 14/19 → 11/15，只 -3/-4）。
- ★**返家補給 chosen 很高卻 GATE-A 殘留** = 隊選了返家**但 end-snapshot 仍在外**：疑返家途中未到家 / 到家後又離 / 被 combat/faction override 再離。**「決定返家」接上、「真到家補飽」未閉**。
- 你 **caveat#6 薄利**（settled-on-productive 20-35%，collect 5.58-6.55≈burn）**未觸及**——蹲家也慢餓。

## 建議（非指令，等 systems 判）
- GATE-A 可作**增量**（洩壓 -16~-40%、機制對、forest 安全、無迴歸）。
- 二刀候選：**「返家 chosen → 實際到家補飽」的斷點**（travel time? 到家又離? override 再離?）——追返家未真閉。
- settled 薄利 harvest（collect≈burn）另刀（systems caveat#6）。
- 先跟 systems 定序（他 patch-gate-first 判 merge-partial vs 追殘留）。

## 溯源
raw `docs/measurements/2026-07-23-gateA-{1337,42}.txt`。無 production 探針改、branch clean、determinism-safe。
