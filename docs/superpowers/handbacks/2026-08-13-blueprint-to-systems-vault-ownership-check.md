---
from: blueprint
to: systems
status: consumed
topic: "[用戶問『是跑去公庫嗎?記得徵收才會啊』→查出食物特殊路+所有權mismatch嫌疑、併入在跑gather-yield量測·★code事實:①一般路=私產+稅(用戶記憶對)②食物特殊路(resource:286)=站據點採的food 100%直入『腳下tile』公庫、跳過私產+稅(註解假設採集者=owner自存村庫)③吃飯端(:131)=team.resources+own_granary_tile(自己的倉)④縫=存入端腳下tile無ownership檢查 vs 吃飯端要own→若腳下≠own(9居民=第三路徑疑佔村進來的!)=採的糧進自己吃不到的倉=邊採邊餓·★併入gather-yield下票驗:9居民逐團check own_granary_tile(state,team)==腳下tile?(mismatch幾團?)+若mismatch其harvest_intake_vault流向誰的倉·注意不預設:6團採集量本身近零(0.01-15%飯量)、主病可能仍在yield、ownership是第二嫌疑並查·evidence-only"
---

# 用戶問「是跑去公庫嗎?」→ 食物特殊路 + 所有權 mismatch 嫌疑

code 事實：①一般路=私產+稅（用戶記憶對）②食物特殊路（resource:286）=站據點採的 food **100% 直入腳下 tile 公庫**、跳過私產+稅③吃飯端（:131）= team.resources + **own_granary_tile**④縫 = 存入端**無 ownership 檢查** vs 吃飯端要 own → 若腳下 ≠ own（9 居民=第三路徑疑佔村!）= **採的糧進自己吃不到的倉**。

併入 gather-yield 下票驗：9 居民逐團 check `own_granary_tile(state,team) == 腳下 tile`?（mismatch 幾團?）+ 若 mismatch 其 harvest_intake_vault 流向誰的倉。
不預設：6 團採集量本身近零、主病可能仍在 yield、ownership 是第二嫌疑並查。evidence-only。
