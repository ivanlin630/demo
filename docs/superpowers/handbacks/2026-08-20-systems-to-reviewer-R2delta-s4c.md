---
from: systems
to: reviewer
status: consumed
topic: "[R² delta 審 §4c(結果反饋迴路:建點結局→選址記憶)·spec=2026-08-20-settlement-S4c-site-feedback-HOW.md·R①免(前提=結構事實 file:line:write_memory npc_ai_system:65 簽名 subject_id:int/掛點 harvest_system:37-38 L0 decay、faction_ai:1985 relocate_abandon set_owner(-1)、outpost_system:354 upgrade_level 完工/讀取 pattern decision_context:530 join_rejected 款)·衰減公式已照你上輪要求寫進 spec 本體(SITE_MEMORY_TTL_DAYS=30 天 TEST VALUE、調整量=intensity×max(0,1−已過天數/TTL)線性衰減過期歸零、intensity 0.5 沿用 join_rejected 慣例)·★審點:①掛點選得對嗎:失敗=L0 decay+relocate_abandon、成功=upgrade_level 完工、團滅【不寫】(人死沒人記得=honest、且避免寫進已 erase 的 person)——有沒有漏掉更該算『結局』的事件(例如據點被 capture 奪走算不算失敗地?我傾向不算[那是被打不是選址錯]、你判)②★self-knowledge 邊界:寫『該 tile owner 隊的 leader』——L0 decay 那個掛點若 founder 已離開/換人怎麼判『誰該記得』?會不會誤寫給不相干的人(=假記憶)、寧可漏寫不可錯寫?③記憶隨人不隨團(leader 換人=經驗歸零)我標 intended——你判這是誠實湧現還是會讓反饋迴路實際上很少生效(leader 換人頻率高的話)④TTL 30 天量級合理嗎(vs join_rejected 2 天;選址低頻高成本)⑤掛進既有選址 util 而非新 term 線=禁 crank 守住了嗎、會不會反而讓地點品質項語意混雜(既有是『地力好不好』、現在加『我上次在這裡失敗過』)·gate:反饋真作用(同團第二次避開)+非全域(別團不受影響)+過期回復+記憶隨人+determinism·可與 §4b gate 平行·地基KEEP"
---
# R² delta 審：§4c 結果反饋迴路
spec=`docs/superpowers/specs/2026-08-20-settlement-S4c-site-feedback-HOW.md`。R① 免（前提=結構事實、file:line）。衰減公式**已照你上輪要求寫進 spec 本體**（`SITE_MEMORY_TTL_DAYS`=30 天 TEST VALUE、調整量=`intensity × max(0, 1 − 已過天數/TTL)` 線性衰減過期歸零、intensity 0.5 沿用 `join_rejected` 慣例）。
## ★審點
1. **掛點選得對嗎**：失敗=L0 decay + `relocate_abandon`、成功=`upgrade_level` 完工、**團滅不寫**（人死沒人記得=honest、且避免寫進已 erase 的 person）——**有沒有漏掉更該算「結局」的事件**（例如據點被 **capture 奪走**算不算失敗地？我傾向**不算**[那是被打不是選址錯]、你判）？
2. **★self-knowledge 邊界**：寫「該 tile owner 隊的 leader」——**L0 decay 那個掛點若 founder 已離開/換人**怎麼判「誰該記得」？會不會**誤寫給不相干的人**（=假記憶）、**寧可漏寫不可錯寫**？
3. **記憶隨人不隨團**（leader 換人=經驗歸零）我標 intended——你判這是**誠實湧現**還是會讓**反饋迴路實際上很少生效**（leader 換人頻率高的話）？
4. **TTL 30 天量級合理嗎**（vs `join_rejected` 2 天；選址低頻高成本）？
5. **掛進既有選址 util 而非新 term 線**=禁 crank 守住了嗎、會不會讓**地點品質項語意混雜**（既有=「地力好不好」、現在加「我上次在這裡失敗過」）？
gate：反饋真作用（同團第二次避開）+ 非全域 + 過期回復 + 記憶隨人 + determinism。可與 §4b gate 平行。地基 KEEP。
