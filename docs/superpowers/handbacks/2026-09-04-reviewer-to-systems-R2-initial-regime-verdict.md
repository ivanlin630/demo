---
from: reviewer
to: systems
status: open
slice: initial-regime-in-worldgen
topic: R②判決:issues(重)——①負斷言翻車:確實有第二條創世建政權路(game_setup.gd:589的_setup_explicit_teams,per-team faction_id/is_faction_leader),而且27個沒factions區塊的config全部是mode:explicit,factions區塊對它們是死config從不被讀;真正0政權的只有4個(econ_bed/infonet_scale_econ_concentrated/peaceful_economy/survival_start,is_faction_leader計數皆為0),不是27個;A/B/C三案全部瞄準_generate_factions,對這27個世界通通無效;②fcfg預設值問題現在對這4個config是無意義的問題,真正該問的是explicit模式沒人標is_faction_leader時預設哪隊當leader;③疑慮是真的且更嚴重:徵收/歸建需要faction裡有除leader外的成員可以課,peaceful_economy.json 12隊全部faction_id:-1彼此無分組,只給一隊當leader會產生「只有領袖沒有成員」的空政權,徵收/歸建applicable母體不會變成>0,這需要決定「哪些隊該分進同一個政權」這種WHAT級分組決策,建議這格真的回去問blueprint/用戶
---

# 判決：`issues`（重），`premise_contradiction: true`（在①，這會改變整張spec的目標函式）

## ★★★①負斷言——**翻車了，而且翻得比小修正嚴重：整張spec瞄準錯的函式**

窮盡查了 `create_faction(` 全部呼叫點（排除 debug/test bed）：
```
world_state.gd:283        func create_faction 本體
game_setup.gd:314         _generate_factions 內（你已查到，只在 mode="random" 執行）
game_setup.gd:589         ★★★_setup_explicit_teams 內（per-team faction_id/is_faction_leader，只在 mode="explicit" 執行）
diplomatic_ai_system.gd:253 / npc_combat_system.gd:797 / player_command_system.gd(×4)   ★runtime動態建政權，非worldgen
```
**確實有第二條創世建政權路**——`game_setup.gd:589`，在 `_setup_explicit_teams` 裡，讀的是**每隊自己的 `faction_id`/`is_faction_leader`**，跟 `_generate_factions` 讀的 `config.factions.{count,...}` 完全是兩套 schema、兩個函式，`game_setup.gd:39-51` 的 `mode` 分支決定只會執行其中一條。

★**再往下查，發現這不只是「有第二條路」，是【27 個沒 `factions` 區塊的 config 全部是 `mode:"explicit"`】**：
```
grep -L '"factions"' config/*.json → 27 個，逐一核對 mode → ★★★27/27 都是 "explicit"
grep -l '"factions"' config/*.json → 9 個，逐一核對 mode → ★★★9/9 都是 "random"
```
**這個切分是乾淨的、沒有例外**——`factions:` 這個 config key 只被 `_generate_factions` 讀，而 `_generate_factions` 只在 `mode:"random"` 時執行；對 27 個 `explicit` config 而言，**`factions:` 區塊是死 config，寫不寫、預設值是什麼，都不會被讀到**。

**再進一步核對這 27 個 explicit config 裡，有幾個真的一個政權都沒有**：
```
逐檔 grep "is_faction_leader" 計數 → 23/27 至少有 1 個 true → ★這些世界【已經有政權】
   真正 leaders 計數為 0 的只有 4 個：econ_bed.json／infonet_scale_econ_concentrated.json／
   peaceful_economy.json／survival_start.json
```
⇒ **「27/36 政權數＝0」這個前提本身是錯的**——真正 0 政權的世界是 4 個，不是 27 個。**你的三案（A/B/C）全部改 `_generate_factions` 的 `fcfg`，而這個函式對這 27 個世界（不管其中真的 0 政權還是已經有）全部【不會被執行】——三案對本票要解決的問題全部無效。**

⇒ **這不是「案 C 要不要動 27 行」的效率問題，是整張 spec 瞄準的函式從一開始就是錯的**。真正該動的是 `_setup_explicit_teams`（`game_setup.gd:571-599` 一帶）——若掃過 `teams_cfg` 一輪後沒有任何 `is_faction_leader:true`，給一個預設 leader（例如第一支隊，或人口最多那支）。

## ②`fcfg` 預設值——**對這 4 個真正的問題世界是問錯的問題**

`fcfg`（`count`／`teams_per_faction_range`）是 `_generate_factions`（random 模式）的參數，這 4 個 config 都是 explicit 模式，根本不會讀到它。★**真正該問的參數是**：`_setup_explicit_teams` 在【沒人標 `is_faction_leader`】時，該把哪一隊選為預設 leader？——這也不該手抄一個規則（例如「永遠選 id=0」太武斷），但這是另一個問題，不是 `fcfg.count`/`teams_per_faction_range` 那個問題。

## ★★★③你自己不放心的那格——**疑慮是真的，而且比你想的更嚴重**

查了 `peaceful_economy.json`：**12 隊，全部 `faction_id: -1`，彼此之間【毫無分組關係】**——這個世界從設計上就是「12 支互相獨立的隊」，config 裡沒有任何一絲「這幾隊該算同一國」的線索。**若只是給其中一隊加 `is_faction_leader:true`，產生的是【只有領袖、零成員】的空政權**——`徵收`/`歸建`（這兩個 option 的 `faction_stakes`/`faction_tribute_target` 之類，都是「對自己政權底下的其他成員」才有意義的義務）**沒有第二個成員可以課、可以召回，applicable 母體不會因為多了一個空政權就從 0 變成 >0。**

⇒ **這不是「還需要別的前置」這種小補丁能解決的**——這是【哪幾隊該被分進同一個政權】這種分組決策，性質上跟 `warring_states.json` 的 `count`/`teams_per_faction_range`/`independent_ratio`（決定幾個政權、每個政權幾隊、獨立隊比例）是同一類參數，**explicit 模式現在完全沒有對應的「分組」機制**——不是加一行 default leader 就夠，是要幫 explicit 模式也生出一套「這幾隊算同一國」的邏輯（或者，退一步：這批 peaceful/econ 系 config 原本就是刻意設計成「12 支獨立隊，互相之間沒有政權關係」，那麼驗收③（徵收/歸建 applicable > 0）本身可能就【不該對這些 config 成立】——這是設計意圖層級的問題）。

★**我同意你自己提的方向**：這一格該回去問 blueprint／用戶，不是我們自己選——**具體要問的是**：「這批 peaceful/econ 系世界，原本設計意圖是不是就是『無政權/全獨立』？若是，驗收③就不該對它們要求母體>0（換一張有分組的 config 來驗）；若不是（用戶要的是每個世界都該有政權互動），才需要決定要不要給 explicit 模式也做分組。」

## ⇒ 要你補的
1. ①：spec 前提整段訂正——`_generate_factions` 對 27 個 explicit 世界不會執行，A/B/C 三案全部無效；真正 0 政權的世界是 4 個，不是 27 個；真正該修的函式是 `_setup_explicit_teams`。
2. ②：`fcfg` 預設值問題擱置（對這 4 個世界無意義），改問「explicit 模式無 leader 時預設選誰」。
3. ③：回去問 blueprint/用戶——這批世界是不是刻意設計成無政權；若要有，需要一套 explicit 模式的分組機制，不是加一行預設 leader 能解決。

**premise_contradiction: true（①），這不是小修，整張 spec 需要重新定位目標函式跟真實母體後再送 R②。**
