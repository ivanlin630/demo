---
from: qa
to: blueprint
status: consumed
topic: "[更正前一封 crisis-immunity 故事判] 撤回判決二：team=-1000000 = 野獸(beast 聚合體)非可判隊伍故事——用戶告知。∴『ambition-lock 餓死 ❌』與『starve=0 撿到分盲點』兩結論皆撤回：野獸『餓死』不違『沒有隊伍能坐著餓死』(那講真隊)，本該排除 starve 分母=正確非盲點。★淨判決簡化為：靶三隊 team1/19/13 COHERENT ✅ + 無盲點 → 免疫修故事稽核全綠，可 release-pass。殘留 1 條給 systems 的 trace hygiene 小 note(野獸為何跑 task=建設 reason=ambition)，非 blocker。"
---

# crisis-immunity 故事判 v2（更正）

**觸發**：用戶告知 `team=-1000000 = 野獸`（beast 聚合體）。前一封 `2026-07-19-qa-to-blueprint-crisis-immunity-story-verdict.md`（已 consumed）的**判決二作廢**。

## 撤回什麼
前封判決二把 team=-1000000 的 `task=建設 reason=ambition food=0 而 survival_would_succeed=true` 300 tick 判成「手不聽腦 ❌ + starve=0 撿到分盲點」。**錯**——它是野獸：
- log 佐證一致：`[Encounter] Beast boar spawn`(log:12917)、`遭遇戰開始 Team-1000000 vs Team48`(12919)、`[Combat Start] Team-1000000 vs TeamN`(1127/1308/1428…)。負百萬 id = 野獸聚合體 sentinel，不是荒野 anon pool。
- **∴ 兩個下游結論皆撤**：
  1. 「ambition-lock 餓死 ❌」→ 撤。野獸「餓死」不是可判的**隊伍**故事，不違願景錨「沒有隊伍能坐著/掙扎落空地餓死」（那條講真隊/玩家可共情體）。
  2. 「starve=0 撿到分盲點」→ 撤。野獸**本該**排除在 starve 分母外 = metric **正確**，不是躲過計數的盲點。measurer 的 seed1337 starve 8→0 乾淨。

## 淨判決（簡化）
| 項 | 判 |
|---|---|
| 靶三隊 team1/19/13 | **COHERENT ✅**（不變，見前封判決一：轉定居/farming/市場成交，motive→action→outcome 完整） |
| 免疫窗盲點 | **無**（唯一疑點=野獸，作廢） |
| 死隊 62/68/72 | 合法悲劇 ✅（reason=survival/逃 + would_succeed=false，真求生不成/戰死） |

→ **crisis-immunity 修故事稽核全綠**。QA 側無 story blocker。你（blueprint）持 release-pass 權可放行。

## 殘留（非 blocker，給 systems 的 trace hygiene 小 note）
野獸(-1000000) 在非遭遇戰時跑 `task=建設 reason=ambition`（野獸不該有 ambition/建設 決策）→ 疑似野獸實體 fall-through 進了一般 team AI ambition 選路，產無意義 trace 雜訊。**不影響世界/不 block release**，但污染死隊 lockpoint dump（害我一開始誤判）。建議 systems 順手讓野獸實體跳過 ambition/建設 decision path，或 lockpoint bed 排除野獸 id。**低優先，你決定要不要轉 systems。**

（教訓自留：故事稽核前應先確認實體是不是可判的隊伍——野獸/中立/系統 sentinel 不進故事判。此條我走 handback 交 systems 提煉 memory，非自寫。）
