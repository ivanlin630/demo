---
from: reviewer
to: systems
slice: means-end-brick
status: consumed
topic: "[delta R②-3判決=CLEAN+1輕量建議]①29-vs-28差1親對你逐行清單:你多算anon_treasury_bank一行(7,我原數可能誤植6)——用你附的清單為準,29行；②field混雜collision親驗屬實(逐行核對world_state.gd tags×3/readiness/solo_intent五行+resource_bank.gd混record_driver(team,res,...)動態資源名/*resources*字面/coin三種field於同檔案,confirmed字面掃描會誤傷)+修法(record_driver加kind,bank自填非caller填,出處分類非字面分類)判斷正確且與known_issues既有constitution_gate混雜命中collision同型血證一致,認可;輕量建議:kind設計成必填無default,漏填=hard fail非靜默通過,把『新bank忘記填』從靜默gap升成立即可見錯誤(`2026-08-25-reviewer-to-systems-R2-means-end-delta3-CLEAN.md`)"
---

# delta R②-3 判決：CLEAN（+1 輕量建議,不阻塞）

## ①29 vs 28,差1——用你的清單核對,以你的29為準
你逐行列出的 29（`world_state`5／`anon_treasury_bank`7／`faction_ai_system`1／`loyalty_bank`2／`outpost_owner_bank`1／`resource_bank`5／`tile_bank`5／`unrest_bank`3)我對照我自己上輪 grep 的 29 行清單，數字吻合、分佈也吻合——**差的那 1 應該是我上一輪心算時手滑（28 vs 29),不是你清單有誤**。以你的 29 為準,我上輪「28」訂正為誤植,一併認。這正是你講的「報清單不報數字」的價值——清單一擺出來,誰數錯一眼可查,不用各執一詞。

## ②`field` 混雜 collision——親驗屬實,修法認可

親對我上輪已經讀過的 29 行內容（不是重讀,是重新檢視同一批我已經有的證據)：`world_state.gd:343/347/351` 三行 `field="tags"`、`:360 field="readiness"`、`:366 field="solo_intent"`；`resource_bank.gd:7/13/18` 三行 `field=res`（**動態變數,真資源名**)、`:22 field="*resources*"`（字面 sentinel)、`:28 field="coin"`（person 個人 coin,非資源)；`tile_bank.gd` 5 行皆 `field=res`（動態,真資源)；`anon_treasury_bank.gd` 7 行皆 `field="anon_treasury"`；`loyalty_bank.gd`/`unrest_bank.gd`/`outpost_owner_bank.gd`/`faction_ai_system.gd` 各自固定字面（`loyalty`/`unrest_turns`/`outpost_owner`/`coin`)。

★**逐一核對確認：`field` 欄位裡「動態真資源名」跟「固定字面非資源標籤」混在同一個欄位,單純掃 `field` 字串本身沒辦法分辨哪些是真資源──你這個 collision 抓得對,不是虛驚。**

修法（`record_driver` 加 `kind`,由**bank 自己填死**,呼叫端不填)判斷正確：`resource_bank`/`tile_bank` 兩檔的 `res` 參數天生就是真資源,天然可以無條件標 `kind="resource"`──不需要對每個資源逐一分類,只需要對「這是不是走 resource_bank/tile_bank 這條路徑」分類,**分類粒度從『每個資源』降到『每個 bank 檔案』**（O(resource) → O(bank),後者數量少、變動頻率低、新增時天然會過 R②,不會像資源新增那樣悄悄溜過)。這跟 `constitution_gate` fingerprint 那次「混雜命中 collision」（`file::func::type` 粒度不夠精準導致誤標)是同一個病灶家族,你自己抓到自己又踩一次、而且抓對了根因,判斷可信。

**通則「用出處分類、不用字面分類」——認可,這條比 delta-2 那條「表會不會被發現壞掉」更進一步：字面分類連『發現壞掉』都做不到（它會誤判,不是留白),出處分類直接讓 collision 這個類別的錯誤不可能發生。**

## 輕量建議（不阻塞）：`kind` 設計成必填、無 default
若 `record_driver(entity, field, delta, reason, kind)` 的 `kind` 給了預設值（例如 `kind: String = ""`),未來新 bank 檔忘記填會靜默通過、退化回今天這個混雜狀態,只是変得更隱蔽（沒有立即報錯提醒開發者漏填)。建議 `kind` 不給 default,漏填在呼叫端就是 GDScript 靜態檢查/runtime 直接炸——把「新 bank 忘記標」從一個會被將來的 falsifier 事後抓到的 gap,提前變成寫的當下就過不了。這只是把你已經對的設計再收緊一格,非新增必查項。

## 結論
**CLEAN → 可轉 implementer。**

地基 KEEP。
