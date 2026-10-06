---
from: systems
to: implementer
status: open
slice: 故事結束之後原玩家隊照 NPC 的路補領袖（＋決策 tap「掠奪」）
topic: ★**派工，R² CLEAN（`30a82d3fa`）**｜spec ＝ `A:/GDS/demo/docs/superpowers/specs/2026-10-06-player-team-succession-after-story-end-HOW.md`｜★序 ＝ **插在威脅欄那張之前**（藍圖裁）｜★兩顆 commit 分開：①改世界 ②只加觀測
---

# 一、①改世界（一顆）

```
·抽 `event_system.gd:41-65`（on_leader_death 的 NPC 繼承段）成 `_npc_succession(state, team) -> bool`，
  NPC 分支呼它（行為不變）
·`handle_player_succession` 的 **`:83` `return false`**（★不是 `:84` —— `:84` 是 named 非空 ⇒ 選繼承人的分支，**不動**）
  ⇒ 改成 `return _npc_succession(state, team)`；`game_over` 照設
·★只有一份繼承邏輯（不准在 player 分支抄一份）
·★爆炸半徑已窮盡（R² 追完 6 個呼叫點）：`on_leader_death` 回傳值唯一讀者 `npc_combat_system.gd:786-790`
  ⇒ 改後原玩家隊若是盟主 ⇒ 勢力**留下**（以前會交出／解散）⇒ P4 盯這件
```

# 二、②只加觀測（另一顆，★在 ① commit 之後）

```
·`decision_engine.gd:315` 的 `_cmp_on` 清單併入「掠奪」—— 既有四欄拆解，不新寫一套
·★它被 `Probe.enabled` 閘住，而 R² 核過 `scripts/debug/player_death_7day_specimen.gd` **零 `Probe` 字樣**
  ⇒ 不開的話四欄一個都不會印 ⇒ 那支 specimen 床要開 Probe（★那支床是量測員的檔 ⇒ 你只加清單，
    開 Probe 與重產 specimen 由量測員做，我會派；你交件時說清楚「清單加了、那支床沒動」）
·T2：fp 逐位元組不變（`_cmp_on` 在 Probe 關時是 false ⇒ 預測不變；預測不是授權，量）
```

# 三、驗收重點（全表在 spec §4／§4b）

```
P1 絕後後 `game_over == true` **且** 原玩家隊 `leader_id != -1`（母體地板：named 真的空）
P2 推過一個 OVERFLOW_CHECK_INTERVAL ⇒ pop **沒有**被切到 1（印前後）
   ★負對照：`:83` 改回 `return false` ⇒ 必紅，而紅的長相要是 QA 讀到的那個（8 → 1）
P3 反向掃：「從 anon 晉升」的呼叫 ＝ 1
P4 勢力：盟主絕後 ⇒ 勢力仍在；★反向：named 與 anon 都空 ⇒ 照舊交出／解散（那條路不能被弄死）
P7 全世界「leader_id == -1 且 pop ≥ 1 且連兩個每日邊界都如此」＝ 0
   ★先量：掃出原玩家隊以外的 ⇒ 既有洞，逐隊印 id／何時／哪個死亡路徑，**回報不擴票**
P5 fp 先量
```
