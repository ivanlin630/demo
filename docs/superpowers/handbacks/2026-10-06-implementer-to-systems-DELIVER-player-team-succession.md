---
from: implementer
to: systems
status: consumed
slice: 故事結束之後原玩家隊照 NPC 的路補領袖（＋決策 tap「掠奪」）
topic: ★**交件｜BATTERY_RC=0｜102 綠／0 紅**（run-id `36605-20261006-184757`，HEAD `ea7c5f94b`）｜branch `feat/player-team-succession` 遠端 tip **`4371bfd76`**（基於 `fae319cb4`；origin/main 之後多的 10 顆只動 docs/superpowers／progress，沒碰 scripts／註冊表 ⇒ 沒 rebase）｜①改世界 ②只加觀測 兩顆分開｜P2 負對照紅的長相 ＝ QA 的 8 → 1｜fp 沒變（基準不動）
---

# 一、commit（`fae319cb4..4371bfd76`）

```
9e36e1229  ①改世界：抽 _npc_succession（全庫唯一一份）＋ handle_player_succession 絕後分支 return _npc_succession
           ＋ 新床 player_team_succession_bed ＋ 註冊列 player-team-succession
4ca9134fe  床：P1／P2／P7 改用 QA 那條佈置（理由見 §三①，★這是我第一版做錯的地方）
36cab7c91  ②只加觀測：CMP_DUMP_OPTS ＝ ["收留","攻擊","偵查","掠奪"]（原本兩行各抄一份清單 ⇒ 具名成一份）
bab5290be  負對照原文：docs/measurements/2026-10-06-player-team-succession-negative-controls.txt
e60766702  headless_test._test_succession_player_extinct 翻極性（電池抓到的床側讀者，§四）
1f2ddee93  ②之二：「掠奪」自己的輸出桶 raid.composition（★只加清單 ＝ 沒接電，§五）
ea7c5f94b  接電證明原文落地
4371bfd76  scripted_exploration artifact 落這一輪（記的 sha ＝ ea7c5f94b）
```

# 二、①（`event_system.gd`）

```
·on_leader_death 的 NPC 繼承段（best named → anon 晉升 → 皆無崩潰）抽成 _npc_succession(state, team) -> bool
  ⇒ NPC 分支 `return _npc_succession(state, team)`（行為不變）
·handle_player_succession：named 空、player_id ≠ -1 ⇒ game_over／reason 照設 ⇒ 原本 `return false`
  ⇒ 改 `return _npc_succession(state, team)`（★`:84` 選繼承人那支沒動；`player_id == -1` 那支沒動）
P3 反向掃：event_system.gd 裡 generate_for_team(…, "member") 的非註解行 ＝ [66]（1 處）
```

# 三、驗收的數（床 `player_team_succession_bed.gd`）

```
P1  Team15：死前 named（玩家以外）0｜玩家是領袖｜玩家人物仍在 persons ＝ true（QA 的形狀）
    game_over ＝ true「玩家絕後（Team15 無繼承人）」｜原玩家隊 leader_id ＝ 43
P2  推 tick 0 → 1441（跨過溢出檢查邊界 1440）｜pop 8 → 8｜leader_id 43
    ★負對照（`return _npc_succession` 改回 `return false`）：
      pop 8 → 1｜leader_id ＝ -1 ← ★正是 QA 讀到的長相
      同一次另外紅：P1 leader ≠ -1、P4 勢力留下、P7 兩格（Team15 首見 tick 1440 leaderless、pop 1）
P4  勢力（戰死真路徑 NpcCombatSystem._kill_named_npc ⇒ 經過 npc_combat_system.gd:786-790 那個讀者）
    盟主絕後、有匿名人口可補 ⇒ 勢力 0 仍在、盟主仍是 Team15
    ★反向：清空匿名人口（AnonCohort.total ＝ 0）⇒ 盟主變 Team0（交出）—— 那條路沒被弄死
P7  7 天、每個每日邊界掃全世界活隊（非野獸）最多 21 隊：leaderless 且 pop ≥ 1 連兩個邊界 ＝ 0
    ★先量（第一次跑）：原玩家隊以外 ＝ []（★沒有既有洞）⇒ 才升成「全世界 ＝ 0」的斷言
```

## ★★①我第一版做錯的地方（4ca9134fe 修掉，紀錄留在證據檔）

```
第一版 P1／P2／P7 用戰死真路徑 `_kill_named_npc` 佈置 ⇒ 負對照（改回 return false）**P2 不紅**（pop 8 → 8）
真因：_kill_named_npc 最後會 erase 玩家人物 ⇒ loop3 安全網（faction_ai_system.gd:1549）每 tick 重呼
  on_leader_death 時 get_player_team_id() 查不到玩家隊 ⇒ 走 NPC 路**自己補上了**
而 QA 那支（＝spec 指定的 story_end_not_physics_bed:67-73 殺法）玩家人物**留在 persons**
  ⇒ get_player_team_id() 仍回原隊 ⇒ 安全網每次都走玩家分支 ⇒ 舊版永遠 return false ⇒ 永遠沒領袖
⇒ 我偏離 spec 的佈置（以為「真路徑」更好）而那條路恰好不經過缺陷 ⇒ P2 在那個佈置上沒有鑑別力
⇒ 改回 spec 的佈置；戰死路徑只留給 P4（它要的是勢力交接的讀者）
★順帶看到的（給你判，沒動）：戰死路徑與 QA 那條路的差別只在「玩家人物在不在 persons」，
  而它決定安全網走哪個分支 ⇒ 舊版的病在戰死時會**自癒一個 tick 後**、在 QA 那條路上**永遠不癒**
  ⇒ 真實遊戲裡玩家怎麼死、人物留不留在 persons，決定這個病會不會出現（有幾條死法我沒全數）
```

# 四、★電池抓到的第二個讀者（spec 的爆炸半徑沒數到）

```
headless_test.gd `_test_succession_player_extinct`：`assert(not ok, "player 絕後 → false")`
  ⇒ 那支隊 0 named、5 匿名 ⇒ 改後晉升成功 ⇒ true ⇒ 紅
⇒ 翻極性：game_over 照設 ＋ ok ＝ true ＋ leader_id ≠ -1（舊斷言劃掉留理由）
⇒ 重跑 headless：HARD-FAILS 3 ＝ baseline 3｜失敗清單逐條相同
同檔另三處呼繼承的格我逐一看過：兩格是選繼承人分支（不受影響）；`_test_no_heir_game_over` 那隊無匿名人口
  ⇒ 晉升失敗、只斷言 game_over ⇒ 綠是名副其實的
★spec §3 的母體是「產線裡讀回傳值的地方」⇒ 床側讀者不在裡面；這一格是電池接住的
```

# 五、②決策 tap

```
·decision_engine.gd：`_cmp`／`_cmp_on` 兩行各手抄一份 ["收留","攻擊","偵查"] ⇒ 具名 CMP_DUMP_OPTS 並併入「掠奪」
·★★只加清單 ＝ **沒接電**（我第一顆就是這樣交的，自己再讀才抓到）：`_cmp` 的輸出依選項**分桶**
  （攻擊 → attack.composition、偵查 → recon.composition、收留 → shelter.composition），「掠奪」沒有桶
  ⇒ 算了而**一筆都不會印** ⇒ 量測員開了 Probe 也讀不到 Team11 那幾次掠奪
  ⇒ 1f2ddee93 補 `if opt == "掠奪": Probe.bump_sample("raid.composition", _cmp, 150)`
  ⇒ 接電證明（臨時腳本：Probe.arm、warring_states、seed 1337、10 天；跑完已刪）：
     raid.composition 150 筆（cap）｜attack 150｜recon 150｜shelter 0
     第一筆：{ drive 0, weight 1, after_weight 0, coeff 0.534, after_coeff 0, fail_mult 1, after_fail 0, final 0,
               terms [loot_drive:d=0.000 w=1.000, intent_fit:d=0.000 w=1.000], opt 掠奪 }
·T3（final ＝ 引擎拿去排序的數）：`_cmp["final"] = snappedf(u, 0.001)`（`:400`）之後到 `scored.append({"u": u…})`（`:478`）
  再到排序（`:548-549`，鍵 ＝ `u`）之間 `u` 沒有再被改 ⇒ 相等，差在 0.001 的四捨五入
  ★欄名對照（spec 的四欄是你的判斷，我沒改既有欄名）：原始 util≈terms／after_weight｜需求層加權≈coeff／after_coeff｜
    人格調製≈weight（DecisionTerms.weight(..., leader_values)）｜最終合成＝final —— 對不上的話告訴我
·★scripts/debug/player_death_7day_specimen.gd **沒動**（開 Probe、重產 specimen 是量測員的活）
·★既有洞（沒動，回報）：`shelter.cmp.drive_sum／after_weight_sum／after_coeff_sum／final_sum` 四行
  **沒閘在「收留」**（在 `if _cmp_on:` 底下、`if opt == "收留":` 外面）⇒ 攻擊／偵查早就混進收留的總和
  （同處註解寫著「不要混母體」）⇒ 現在掠奪也會混進去 ⇒ 讀那四個 sum 的人拿到的不是收留的數
·T2：fp 逐位元組不變 ⇒ 本信那一輪 world-fp ✓（280s；world-fp-ctrl ✓ 559s）
·T2 負對照：tap 位置無條件多耗一次 randf() ⇒ final_fp ＝ e2f55820e4074c4f2b2fcda5f15ff9d9 ≠ 基準 8c9b2d72e28aef7116edef1283ab9974
  ⇒ world-fp 對「tap 改變被觀測物」有鑑別力
  ★誠實限：實際的 ② 在 Probe 關時整段不跑 ⇒ fp 不變是**結構**保證；Probe 開的那一輪（specimen）會不會耗 RNG
    world-fp 量不到 ⇒ 靠的是 `_cmp` 那段本來就只做字串拼接（我讀過，沒有 randf／rng 呼叫）
```

# 六、fp（P5：先量）

```
①＋② 之後 world-fp ✓、world-fp-ctrl ✓ ⇒ final_fp ＝ 8c9b2d72…（基準）⇒ **基準不動**
為何沒變：world_fp_snapshot_bed.gd:99 `player_id = -1` ⇒ handle_player_succession 在 `:78-79` 就 return
  ⇒ 被改的那一行（player_id ≠ -1 才到）在 fp 床上結構上不可能觸發；NPC 分支只是抽函式、行為不變
```

# 七、新列（四欄；expect 從輸出逐字抄）

```
id      player-team-succession
cmd     powershell -NoProfile -File ./tools/godot.ps1 --headless --script scripts/debug/player_team_succession_bed.gd
expect  === player_team_succession DONE === errors: 0
```

⇒ 接著回去做威脅欄那張（停在 `ca345f27c`，回來會 rebase 到你 merge 之後再整輪重跑）。
