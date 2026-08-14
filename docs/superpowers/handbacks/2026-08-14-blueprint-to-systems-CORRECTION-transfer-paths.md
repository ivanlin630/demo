---
from: blueprint
to: systems
status: open
topic: "[★用戶記憶又抓over-claim:『capture/flip=encounter-only』REFUTED——四條非encounter易主路存在、其一=現成認領機制·①npc_combat:391/:500呼OutpostSystem.capture=NPC戰鬥能佔村(你的『走NpcCombat根本不到flip分支』錯、flip分支在OutpostSystem.capture:693非只encounter:1402)②★faction_ai:5095佔領計時器=現成搶鬼城機制:站owner=-1據點滿OUTPOST_TAKEOVER_DAYS→takeover——被S1a bug餓死(死不釋放→-1幾乎不存在)、9居民第三路疑=它(30個relocate_abandon的-1地)③uprising守城自立takeover(:5156)④diplomatic alliance轉讓(:267)·★兩含意:(A)settlement S1b再縮:認領機制現成、S1a修好即活;HOW必先查佔領計時器路(它跟settle分支關係、decision端誰會『想去站』鬼城=目標池仍需)、禁平行造、S1b settle分支動不動=查完定(B)戰爭之路(b)改寫:非管線斷頭、是全年僅2次戰鬥發生在據點格(raid.combat_at_outpost=2)=戰鬥地點/頻率問題+capture條件(decisive win at tile)·派:①code-read佔領計時器全條件(gate/天數/誰跑此檢查/9居民是否此路=可從1mo specimen驗)②戰爭之路verdict更版(b)③S1b HOW對照現成timer重擬(能靠S1a+目標池就不碰settle)·roadmap戰爭之路條目我已更·write-side教訓+1(encounter-only斷言沒查npc_combat)·evidence-only"
---

# 用戶記憶抓 over-claim:capture 非 encounter-only、四條易主路

①npc_combat:391/:500 → OutpostSystem.capture=NPC 戰鬥能佔村②★faction_ai:5095 佔領計時器=**現成搶鬼城機制**(站 -1 據點滿 N 天→takeover)、被 S1a 餓死、9 居民第三路疑=它③uprising takeover④alliance。
含意:(A)S1b 再縮:認領現成、S1a 修好即活;HOW 先查 timer 路、禁平行造、settle 分支動不動查完定(B)戰爭之路(b)改寫:非斷頭、是全年僅 2 次戰鬥在據點格+capture 條件。
派:①timer 全條件 code-read+9 居民驗證②war-path verdict 更版③S1b HOW 對照重擬。evidence-only。
