---
from: measurer
to: systems
status: open
slice: 票 #9 地圖記憶 段1——玩家隊 team_tile_known 是不是空的
topic: ★回應派工：不是空的，①>0（33/73/114）。而讀碼第一版預測的「玩家隊走 SoloAI 會被排除 ⇒ harvest 從沒被呼」被實測推翻——真正讓玩家隊也被 harvest 到的是另一條路（loop3 ambient G2c），不是 SoloAI。
---

# 一、佈置

```
樹 HEAD=a075f1081（跑的時候；床已 push）
世界：MeasureBedHelper.arm_and_setup("res://config/default.json", false)（玩家附身，join_mode=independent）
玩家隊 Team15｜faction_id=-1｜起點(9,2)｜對照 NPC：Team0｜faction_id=0（faction成員）｜起點(2,13)
地圖邊界（從 world.tiles 量出）：x∈[0,16]｜y∈[0,16]
玩家隊走法：真走 SimBridge.command_player("move_to",...)（同玩家按鍵同一條路），
目標設地圖四角輪流，move_target 清空就換下一角；之後用 runner.advance_tick 自己逐 tick 推。
第5天附近玩家隊遇野獸戰敗、leader 死亡觸發 choose_heir（世界會凍住等繼承人選擇）——
床自動選第一個選項讓它不卡死（模擬玩家真的會按鍵接繼承），逐 tick 日誌見床內 print。
跑法：.\tools\godot.ps1 --headless --script scripts/debug/ticket9_seg1_tile_known.gd
```

# 二、三個時點的五個數（逐字抄自輸出）

| 時點 | ①玩家隊tile_known | ②NPC tile_known | ③玩家走過格數(地板) | ④market_known／known_outposts | ⑤team_discovered可解析比例 |
|---|---|---|---|---|---|
| 第1天(tick=1440) | 33 | 33 | 5 | 0／0 | 1/1（100%） |
| 第3天(tick=4320) | 73 | 33 | 12 | 4／3 | 4/4（100%） |
| 第7天(tick=10080) | 114 | 41 | 22 | 5／4 | 5/5（100%） |

★③母體地板非 0（玩家隊真的在走），①③同時非 0 且①隨③單調長大 ⇒ 這不是「世界沒走所以恆空」的假陰性。

# 三、★★★讀碼第一版的預測被這份數據推翻——記在這裡，不默默改

```
派工信與本床開場註解都先推論：faction_ai_system.gd:4557 `_evaluate_solo_body`
一進來就「if team.leader_id == state.player_id: return」，玩家隊預設 join_mode=independent
⇒ 玩家隊走 SoloAI 的 solo 路徑 ⇒ harvest_tile_known 應該從沒被玩家隊呼叫過。
★★實測①在第1天就是33（非0）——這條推論不成立。
```

往回追，真正的入口是 `faction_ai_system.gd:_evaluate_loop3_teams`（:1526）那個 **for tid in state.teams.keys()** 迴圈——它對**每一支隊**（沒有像 SoloAI 那樣排除玩家）在
`team.current_task == TASK_IDLE` 時會跑 G2c ambient 填格（:1732
`DecisionContext.gather(state, team, not uses_unified(team))`），而 `gather()` 內部無條件呼叫
`_find_occupy_target` → `BeliefSystem.harvest_tile_known`。這條路**沒有複製** SoloAI 那一行的
player 守衛 ⇒ 玩家隊只要曾經 IDLE 過（移動指令之間、戰鬥結束後等），就會被這條路 harvest 到。

★本床只確認「不是空的、哪條路在餵」這兩件事到此為止——**1732 那個 ambient 迴圈是不是故意要讓
玩家也走到，還是漏了一個跟 SoloAI 一樣的排除**，是判讀層的事，交你／藍圖決定（spec §2 原文的
判讀分支：①>0 ⇒ 地圖記憶可純 render——本輪數據落在這一支）。

# 四、旁證（④⑤之外，你沒點名但量出來時發現，供判讀參考）

```
SimBridge.has_tile_intel()（sim_bridge.gd:247）完全不讀 team_tile_known——
它讀 team_discovered + BeliefSystem.best_estimate（別人回報的位置剛好等於那格）。
SimBridge.query_tile()（sim_bridge.gd:189）更直接：不經任何 belief，直讀 state.world.tiles。
★地圖記憶實際上至少有三條互相獨立的線（tile_known／has_tile_intel／query_tile 的 god-view 直讀），
哪一條線接到玩家畫面本票沒有追（spec §2 的題目只問 tile_known），如實列出不擴權判讀。
```

# 五、落地

```
床：scripts/debug/ticket9_seg1_tile_known.gd
跑法：.\tools\godot.ps1 --headless --script scripts/debug/ticket9_seg1_tile_known.gd
（純聚合計數/結構性讀取，非 motive→action→outcome 的行為因果結論，不需 QA 故事稽核）
```
