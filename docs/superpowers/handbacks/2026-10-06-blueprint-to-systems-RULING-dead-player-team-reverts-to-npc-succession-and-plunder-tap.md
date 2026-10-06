---
from: blueprint
to: systems
status: open
slice: QA 死後七日故事判決的兩件
topic: ★①玩家死後原隊變成 pop=1 殘餘隊：真因不是 overflow，是【玩家隊死了領袖之後沒走 NPC 的繼承路】（handle_player_succession 無繼承人 ⇒ game_over 就停，named_members 空時沒做 anon 晉升）⇒ 隊 leaderless ⇒ effective_pop_cap 崩到 1 ⇒ 次日溢出掃把 7/8 人與資源切給新隊。裁：game_over 之後原玩家隊＝普通 NPC 隊（#43 零特殊物理），走 on_leader_death 同一條（best named → anon 晉升 → 皆無才滅團），不准停在 leaderless；②掠奪 util 倒數第二卻被選中、合成分數看不到＝tap 缺口（全量暫態可觀測性）：決策引擎必須把每個候選的【最終合成分數】與各層輸入一起印進 specimen，再請 QA 重讀那一段；在 tap 補上之前不下「決策壞了」的結論
---

# ①

```
現況（QA file:line）：event_system.gd:80-82 無繼承人 ⇒ game_over；player_command_system 分支永遠不呼 check_overflow 那兩行；但 population_system.gd:78 全域掃描對 leaderless 一樣掃 ⇒ cap=1 ⇒ _create_overflow_team 把 7/8 切走。
裁：玩家絕後 ⇒ 設 game_over（故事結束，票 #2 已做）⇒ ★同一 tick 原隊交回 NPC 繼承路：named 有人 ⇒ 繼位；named 空 ⇒ anon 晉升（NPC 隊本來就這樣做）；都沒有 ⇒ 滅團（釋放據點／資源照既有路）。
   ⇒ 不會有「leaderless 活隊」這種狀態存在超過一 tick；pop cap 不崩；溢出掃描不切。
   ★順帶：leaderless 隊 cap=1 這條對任何隊都成立——若 NPC 隊也可能卡在 leaderless（繼承失敗路徑），同一支床要掃全世界「leaderless 且活著 ≥1 天」的隊數＝0。
床：玩家隊 named 空、anon ≥2，玩家死 ⇒ 次 tick 該隊有 leader、pop 不變、7 天後 pop 不是 1；陽性對照＝把交回 NPC 繼承那步拿掉 ⇒ pop 掉到 1 必紅。
```

# ②

```
QA 看不透的那一步（L384：掠奪 util 0.0106 倒數第二，卻被選；需求層值 [0,0,0.958,0.381,0]）＝ specimen 缺【最終合成分數】那一欄。
裁：決策引擎每個候選印「原始 util／需求層加權／人格調製／最終合成」四欄進 specimen（tap，不改決策）；補上後 QA 重讀同一段；若合成後掠奪真的最高＝設計如此（需求層壓過原始 util），若不是＝真缺陷另票。不變量：tap 不耗 RNG、不改 fp。
```

# 序

```
①是真 bug 且會在票 #2 之後每次玩家死亡都發生 ⇒ 排在威脅欄票之前。②tap 小，可併 ①。
```
