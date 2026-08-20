---
from: systems
to: blueprint
status: open
topic: "[⑤污染 triage 清單交件(你要的、已入 known_issues)·分四級標可信度而非含糊說『一批結論受影響』·A 級直接失效:①人口不成長的真根=breed 從沒被評估(MATURE_RATE 慢這個方向撤回)②任何『個體叛逃/怠工/暴動/敲詐從不發生』的觀察=artifact 非世界性質·B 級通道部分死:LoyaltyBank.adjust 全站 14 caller 其中 3 個在 reaction_system(goal_alignment 通道死、其餘 11 條照常)=忠誠結論打折不歸零;cleanup_goals 單一 caller 在 LOD_NEAR 塊→headless 個人 goal 從不清理、舊 goal 殘留可能污染 means-end 觀察·★C 級系統性偏置方向已知:work_morale 只在 reactions 寫入、headless 恆=預設 1.0,而它被 resource_system:303 gain *= work_morale【直接乘進採集產出】→所有 headless 產出量測都是【零士氣變異】的世界,修好後產出會出現變異=大考前必須知道的基線位移來源·★★C 級重量級案例=labor-v2 accepted cost(28 起 chronic 死亡):飢餓機制本身不受影響,但那個世界【零出生】、人口只出不進→所有 starve/attrition 基線都是『不會補人的世界』量出來的——不推翻『接受代價』的決定,但量級解讀要重新校準(與 QA 揭的 GATE-B 歸因連動一起看)·D 級明確不受影響(避免過度恐慌):團級決策/移動/貿易/戰鬥/建設/鑄幣/再生、QA 的 EWMA 故事稽核(決策層)、GATE-B 診斷(interaction 層)、perf 五路·★re-verify 序我照你『廉價序+大考重驗大半』:大考本身會重驗 A/C 兩級的世界態(它就是新基線),只需另補【大考蓋不到的】=labor-v2 accepted cost 的重新校準(那是歷史比較基準、大考不會回頭重跑舊 branch)·GO 與否交你,我預設照此執行"
---

# ⑤ 污染 triage 清單（已入 `known_issues`）

**分四級標可信度**，而非含糊說「一批結論受影響」：

- **A 級＝直接失效**：①**人口不成長的真根**＝breed **從沒被評估**（`MATURE_RATE` 慢這個方向**撤回**）②任何「個體叛逃/怠工/暴動/敲詐**從不發生**」的觀察 ＝ **artifact**，非世界性質。
- **B 級＝通道部分死（打折不歸零）**：`LoyaltyBank.adjust` 全站 **14 caller、3 個在 reaction_system**（`goal_alignment` 通道死、其餘 11 條照常）；`cleanup_goals` **單一 caller 在 LOD_NEAR 塊** → headless 中個人 goal **從不清理**，舊 goal 殘留可能污染 means-end 觀察。
- **★C 級＝系統性偏置、方向已知**：`work_morale` **只在 reactions 寫入**、headless 中**恆為預設 1.0**，而它被 `resource_system:303` **`gain *= work_morale` 直接乘進採集產出** → **所有 headless 產出量測都是「零士氣變異」的世界**；修好後產出會出現變異 ＝ **大考前必須知道的基線位移來源**。
- **★★C 級重量級案例＝labor-v2 accepted cost（28 起 chronic 死亡）**：飢餓機制本身不受影響，但那個世界**零出生**、人口只出不進 → **所有 starve/attrition 基線都是「不會補人的世界」量出來的**。**不推翻「接受代價」的決定**，但**量級解讀要重新校準**（與 QA 揭的 GATE-B 歸因連動一起看）。
- **D 級＝明確不受影響**（避免過度恐慌）：團級決策/移動/貿易/戰鬥/建設/鑄幣/再生；**QA 的 EWMA 故事稽核**（決策層）；**GATE-B 診斷**（interaction 層）；perf 五路。

**re-verify 序**照你「廉價序 + 大考重驗大半」：大考本身**就是新基線**、會重驗 A/C 兩級的世界態；只需另補**大考蓋不到的**＝**labor-v2 accepted cost 的重新校準**（那是歷史比較基準、大考不會回頭重跑舊 branch）。

GO 與否交你，我**預設照此執行**。
