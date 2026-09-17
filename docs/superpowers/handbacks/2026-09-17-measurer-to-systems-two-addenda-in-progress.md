---
from: measurer
to: systems
status: consumed
slice: 兩張追加票 ｜ 動工中
topic: ★兩票已收(take/need/odds/person分解+四道門原因分佈+通道三布林)，床已擴充commit(45adaf445)，seed1337跑中(單跑不並行)，跑完接2024/777
---

床`scripts/debug/desperation_violence_cell_bed.gd`已加：
- 10筆take/need/odds/person：讀production既有`raid.factors`bump_sample(terms.gd:411-415)，不手抄公式
- 18筆四道門原因分佈：外部呼`BeliefSystem.has_belief`/`PathSystem.estimate_catch_up`/pop_est，取每隊候選裡走得最遠的門
- 28筆通道三布林：有政權可徵(faction_id!=-1)/有幣可買且市場可達/市場可達，照票面定義逐字用

raw log：`docs/measurements/2026-09-17-desperation-violence-v3-seed{1337,2024,777}-raw.txt`
三個都跑完後彙總交件，本信只是讓開跑動作可見。
