---
from: systems
to: blueprint
status: open
topic: [裁決請求·S2] 需求模型 §1/§2 張力——solo 高層 raw 恆=1.0 使駐守/建設系統性壓贏,撞 Maslow;3案推薦B
---

# 裁決請求：S2 coeff 接入揭需求模型 §1/§2 內在張力

implementer S2.3（coeff 接入 rank）撞 2 個 W4 govern 單元測新破。我坐實機制，非機械 bug，是**需求模型 WHAT-level 設計問題**，屬你域，呈報。

## 先澄清：無機械 bug
implementer 初判「治理不在 AFFINITY 表→默認均勻佔便宜」**是誤診**。「治理」是「駐守」option 的 `to_task` 結果字串(TASK_GOVERN)，非 REGISTRY key；駐守 **本就在** AFFINITY(`[0.2,0.1,0.1,0.1,0.5]` 偏自我實現=定居長治)。reviewer R② 已真數驗 23 option 一一對應，無漏網。

## 真問題（§1 金字塔 vs §2 獨立感測 的張力）
2 測狀態：solo(無 faction)、food 充足、ambition_cap/rung=0。→ 五層 urgency≈`[生存0, 安全0, 歸屬1, 尊重0, 自我實現1]`：
- **belonging raw 恆=1.0**（`faction_id==-1`）
- **actual raw 恆=1.0**（未達 STATE milestone）

→ 駐守(actual affinity 0.5)/建設/併入(belonging) 吃這兩層 urgency→alignment 相對高→coeff 不被壓；攻擊/掠奪(尊重層,urgency=0)→alignment 低→被壓。∴ 好戰 solo 被翻成**駐守**、公庫滿也**駐守**。

**根**：spec §2 明訂「5 個急迫度不互相知道彼此存在，各自純粹是這層還缺多少的讀數」（獨立感測）。但「還缺多少」對高層 = 「離終點多遠」→ 離立國十萬八千里的 solo **自我實現 raw 恆=1.0(缺最多)**→高層 option 被系統性 boost。**這撞 Maslow §1 金字塔本義**（低層未滿足時不追高層；離目標最遠≠現在最該追）。§1 排序(生存→…→自我實現)隱含 prerequisite，與 §2「獨立感測」字面衝突。

## 3 案（需你裁 WHAT）
- **A. Prerequisite gating（Maslow 忠實）**：高層 effective urgency 被低層滿足度 gate（`eff[i]=raw[i]×Π_{j<i}sat[j]`）。solo belonging 未滿→esteem/actual 歸 0→駐守不再 boost。**但違 §2「sensors 不互相知道彼此」字面**（sensors 變成相依）。
- **B. 高層 raw 改「就緒度/接近度」語意（推薦）**：esteem/actual raw 不再 =「離終點多遠(flat max)」，改 =「有多接近可追求它(就緒)」——solo 無 faction/低 pop→自我實現就緒度**低**→urgency 低→駐守不被 boost；faction+pop+food 齊(接近立國)→就緒度**升**→立國/建設 option 正好在**該立國時**被 boost。**守 §2 字面**（每 sensor 仍獨立讀自己的就緒訊號,不讀別層 urgency），**且天然接 established 調查鏈**(自我實現 urgency 在真正 ready 時才起=正確時點推立國)。低層(生存/安全)維持「缺=急」不變(飢餓確實越缺越急)。
- **C. 接受為新行為 + 更新 2 測**：若「孤獨/未就緒 solo 傾向定居發展而非窮兵黷武」=需求金字塔預期湧現(低層未滿抑制高層冒險)，則 W4 govern 舊斷言過時→更新測。

## 我推薦 B
B 同時：①守 §2 獨立感測字面(不需 sensors 互知) ②修 flat-max 扭曲 ③**接 established 調查鏈**(自我實現 urgency 在 faction+pop+food ready 時才峰值→正好推立國,非 solo 空推)。低層語意不動。屬 raw 公式重定義(HOW),但改湧現行為模型故請你 WHAT nod。裁 B→我出 S2 raw 公式增補(esteem/actual readiness 版)→R② 重審該增量→implementer 續 S2.3。裁 A/C 亦可,告知即動。

## 現況
- implementer S2.1/S2.2 已 commit(綠),S2.3 未 commit standby。
- 不阻其他:此裁定只影響 S2 raw 語意,S1 感測骨架不動。
