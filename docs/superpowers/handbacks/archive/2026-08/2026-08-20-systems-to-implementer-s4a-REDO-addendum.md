---
from: systems
to: implementer
status: consumed
topic: "[§4a REDO 補充(reviewer 快查回覆、與前信一起做)·前信裁的 priority 解耦=reviewer 支持(判定:延伸統一非後門——理由 priority_for 本來就有不對稱前例:survival 走 set 隱式推導、threat 早就是顯式清單覆蓋 :451;通用 priority 欄=把顯式覆蓋推廣成一套)·★但要求兩條護欄(我已入 invariants.md 權威落點、你 code 端落實):①【值域鎖死】priority 欄只准填 TaskArbiter 既有具名常數(PRIO_SURVIVAL/THREAT/PLAYER/DISPATCH...)、【禁裸 int】——防未來隨手標 99 繞過整個優先序階梯②【必附 why-comment】任何 option 用此欄覆蓋預設須在 REGISTRY entry 留一行理由(紮根這輪本來就有、比照)·實作建議:priority_for 讀該欄時可加一道 assert/clamp 保值域(禁裸 int 落實在 code 非只靠註解)、你判形式·★另 reviewer 附帶確認你 zombie race 已修好(四呼點皆 _set_ok/_surv_ok 後 commit、to_task 零寫入)=該條收斂不需再動·★gate 補一項(measurer 那輪、你不用做):壓境頻繁區紮根隊的中斷-續建循環次數/平均完工時長 vs 無威脅區同款隊(驗 corvee_site recovery 在真 threat 密度下不變成『開工又中斷』新 churn)·其餘照前信 REDO ticket·地基KEEP"
---
# §4a REDO 補充（reviewer 快查回覆、與前信一起做）
priority 解耦=**reviewer 支持**（判定：**延伸統一非後門**——`priority_for` 本就有不對稱前例：survival 走 set 隱式推導、**threat 早就是顯式清單覆蓋**(:451)；通用 `priority` 欄=把顯式覆蓋**推廣成一套**）。
## ★兩條護欄（我已入 `invariants.md` 權威落點、你 code 端落實）
1. **值域鎖死**：`priority` 只准填 `TaskArbiter` **既有具名常數**、**禁裸 int**（防隨手標 `99` 繞過優先序階梯）。
2. **必附 why-comment**：任何 option 用此欄覆蓋預設，須在 REGISTRY entry **留一行理由**（紮根這輪本來就有、比照）。
- 實作建議：`priority_for` 讀該欄時加一道 **assert/clamp 保值域**（禁裸 int 落實在 code 非只靠註解）、形式你判。
## 另
reviewer 附帶確認你 **zombie race 已修好**（四呼點皆 `_set_ok`/`_surv_ok` 後 commit、`to_task` 零寫入）=該條收斂、不需再動。
**★gate 補一項（measurer 那輪、你不用做）**：壓境頻繁區紮根隊的**中斷-續建循環次數 / 平均完工時長** vs 無威脅區同款隊（驗 `corvee_site` recovery 在真 threat 密度下不變成「開工又中斷」新 churn）。
其餘照前信 REDO ticket。地基 KEEP。
