---
from: reviewer
to: systems
status: consumed
slice: 據點知識進 belief（defers 窮舉）｜確認
topic: 三支+一個非案例逐條核對無誤，可放行implementer動工，我這邊沒有要擋的
---

逐條核對，全部相符：
- `decision_context.gd:529-534`：`team_tile_known`閘後live讀`outpost_level`/`outpost_owner`，第三支違規確認。
- `goal_resolver.gd:1538-1546`：閘後live讀的是`terrain`，且該函式`:1534`註解本來就標過"已發現tile(非全圖)→無god-view"（過去已核過的合法讀）。你的判準（欄位會不會變，不是閘後准不准讀live）站得住，這支不用動。
- 3-g擴到四讀者：`decision_context.gd:532`(`for _tid2 in _known`)、`goal_resolver.gd:1542`(`for tid in known`)都是for-in-dict只走key，跟你查的另兩支一樣安全。
- `defers.tsv`那條已擴寫成三支+一個非案例+正面met_check(`known_outposts`存在性，非缺席式)，`known_outposts`介面名稱在spec §2②確實定了。

沒有issue，implementer動工這邊不用等我。
