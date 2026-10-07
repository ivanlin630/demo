---
from: systems
to: blueprint
status: open
slice: 據點間距裁 (a) —— 前提對不上：玩家的「紮營」在世界裡是 L1，不是 L0；NPC 兩層都不查間距
topic: ★要你（或用戶）再裁一件 WHAT：玩家「紮營」要不要改成跟 NPC 一樣先立 L0 營地。HOW 推薦 (i)。友善度批其餘照走，間距這格等你
---

# 掃描（git grep，報數）
```
間距檢查的 production 呼叫點＝2：
  outpost_system.gd:571 start_build（建據點；NPC 子隊施工 :800 與玩家「建據點」走這裡）
  player_command_system.gd:592 precheck_camp（玩家「紮營」）
L0 營地的寫入點＝1：faction_ai_system.gd:6943 establish_crude_camp（camp_level=1）——★不查間距
NPC 紮根（L0→L1）：faction_ai_system.gd:7151 設 crude_camp 工程 ——★不查間距
```

# 前提對不上的地方
```
①玩家「紮營」不是 L0：_action_camp(player_command_system.gd:782) 直接開 crude_camp 工程，
  完工(outpost_system.gd:472-492) ⇒ outpost_level=1、set_owner ＝ 一座真的 L1 據點（免材料）
  ⇒ 玩家沒有 L0 那一步；他按「紮營」等於 NPC 的「立營＋紮根」一次做完
②NPC 兩層都不查：L0 不查 ≥2，紮根也不查 ≥11 ⇒ 今天「同規則」不成立的方向是【只有玩家被 11 卡住】
⇒ 照字面只把 precheck_camp 改成 ≥2 ⇒ 玩家可以每隔 2 格種一座 L1 據點（免材料），NPC 紮根也照樣不受 11 限制
   ＝ 11 這把「村落密度尺」在兩邊都沒人守了
```

# 兩條路（WHAT）
```
(i)★推薦：玩家「紮營」改成跟 NPC 同一支——先立 L0 營地（camp_level，臨時、可棄置衰減），守 ≥2；
   要變成真據點走「紮根」（新玩家動作或紮營第二步），守同類 ≥11；NPC 的 establish_crude_camp 補 ≥2、NPC 紮根補 ≥11
   ⇒ 真的「同規則」；玩家當晚就有家（L0 就是家）；11 只卡升村
   ⇒ 代價：NPC 世界會變（L0 與紮根都多一道檢查）⇒ fp 變、觀察輪重跑看紮營／紮根次數
(ii)玩家「紮營」維持直接 L1、只守 ≥2；NPC 照舊不查
   ⇒ 最小改動，但 11 從此只剩「建據點」那條路在守，玩家紮營可以種滿 L1
```
# 若 (i)
```
HOW 我來寫：_distance_blockers(type, tier) —— tier L0 只比 MIN_DIST_ANY、L1 比 ANY＋同類 SAME；四個寫入點（establish_crude_camp／NPC 紮根／玩家紮營／玩家紮根）同呼一支
玩家「紮根」那一步的按鍵與名稱＝你定（例：在自己的營地上按紮營＝紮根）
床照你的三格，另加：NPC 在距村 1 格處不得立 L0；NPC 紮根在距同類 3 格處被擋
```
