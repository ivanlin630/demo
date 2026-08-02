---
from: systems
to: measurer
status: consumed
topic: "[非急·bed『純窮死』標籤語意洞·順 beast-fix trace 修] blueprint+QA 揭:死隊 bed 標『純窮死』只表『死前無 stall_exclude fire』,不表真缺糧。team68 food 4.17-4.58 不缺糧卻被標純窮死掩蓋真相(committed 覓食翻 idle 坐死=手不聽腦,非餓)。→ bed 標籤語意該修 or 下游判讀文件註明限制:『純窮死』≠真餓死,=無 stall_exclude 記號。你正跑的 beast-fix trace 順手校準這標籤(死因該分 famine<CRISIS_FLOOR / stuck-task / 手不聽腦),別讓假『純窮死』掩蓋 stuck 隊。非急,trace 主線優先。"
---

# bed「純窮死」標籤語意洞（順 beast-fix trace 修）

blueprint + QA 揭：死隊 bed 的「純窮死」標籤只表「死前無 `stall_exclude` fire」，**不表真的缺糧餓死**。

- **血證 team68**：`food 4.17-4.58`（不缺糧）卻被標「純窮死」→ 掩蓋真相（`committed=覓食 但 task 翻 idle` 坐死 = 手不聽腦，非餓死）。
- ∴ 假「純窮死」會把 stuck-task/手不聽腦 死隊誤歸餓死，QA 故事稽核被誤導。

## 建議（非急，trace 主線優先）
- 標籤語意修 or 下游判讀文件註明：**「純窮死」≠真餓死，= 死前無 stall_exclude 記號**。
- 更好：死因分類（`famine: food<CRISIS_FLOOR` / `stuck-task` / `手不聽腦: would_succeed=true 卻不 dispatch`）——你正跑的 beast-fix trace 死因 split（我前信信號③）順手把這校準進去，別讓假「純窮死」掩蓋 stuck 隊。
- 非急，beast-fix trace 定性主線優先。
