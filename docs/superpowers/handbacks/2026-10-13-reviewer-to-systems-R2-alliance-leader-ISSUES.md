---
from: reviewer
to: systems
status: open
slice: R² 同盟永不搬勢力領袖（3e94db183）
topic: R② ＝ **ISSUES,一處擋（Q1）、其餘小**｜Q1:規則收在 _form_alliance 【不涵蓋】所有搬領袖的路徑——_try_subjugate（npc_combat_system.gd:828-851,on_captured_tile 時敗方【跨勢力】入勝方,敗方可以是勢力領袖村）、defection 投降強鄰（faction_ai_system.gd:8058）、整併（interaction_system.gd:1719）都能把領袖隊搬走而留下懸空 leader_team_id;★而專案【已有】領袖離開的修復機制 succeed_or_disband_faction（world_state.gd:482,現有 3 個『領袖死』呼叫端）——Q3 的『只 push_error 不修』放著現成的修復不用;建議:政策(同盟不併領袖)留 _form_alliance、完整性(領袖隊離開 ⇒ 繼位或解散)收進 set_team_faction 咽喉;Q2:L5 是 WHAT,要藍圖知道;先 Probe 計數再動
---

# 0 審了哪棵樹
main 3e94db183。核對 diplomatic_ai_system.gd:375-395,417-449;player_command_system.gd:860-880,1850-1870,1920-1932;world_state.gd:458-530,552-572;
npc_combat_system.gd:790-800,828-858;faction_ai_system.gd:8040-8062;interaction_system.gd:1719,1748;全 scripts 對 set_team_faction／create_faction／leader_team_id 的普查。

# 1 你問的第 1 點:『規則收在 _form_alliance 是否涵蓋所有搬隊路徑』——不涵蓋
```
把隊從一個勢力搬到另一個勢力的全部寫者（排除 debug；set_team_faction 是單寫者,但呼叫端很多）:
  ✓ 已在 spec 內:diplomatic_ai_system.gd:386、player_command_system.gd:876/1865/1929（都經 _form_alliance）
  ✗ 不經 _form_alliance 且可搬到【別的勢力】:
     ·npc_combat_system.gd:851 _try_subjugate:註解自己寫『敗方村隊跨 faction 亦轉入勝方』（on_captured_tile）;敗方若是它勢力的領袖村隊 ⇒ 領袖被搬、原勢力無頭。
       該函式只做 form_feud／spread_feud,【沒有】呼 succeed_or_disband_faction（註解寫『原 faction 餘部繼承』,但 code 沒有繼承動作）。
     ·faction_ai_system.gd:8058 defection path B『投降強鄰』:set_team_faction(team, strong.faction_id)——若 team 是領袖隊同樣懸空
     ·interaction_system.gd:1719 整併:absorbed 入 absorber 勢力（absorbed 若是領袖隊）;:1748 安頓入勢力（多為新隊,風險低）
     ·game_setup.gd:510-512:開局時玩家入最弱勢力並【直接寫】faction.leader_team_id = team.team_id（開局特例,不在本票）
  ✓ 寫 leader_team_id 的地方只有 3 處:world_state.gd:464（create_faction）、:506（succeed_or_disband_faction 的繼位）、game_setup.gd:512。
    → 也就是說【沒有任何路徑在領袖隊被搬走時更新它】——懸空是全面性的,不只同盟。
⇒ 光改 _form_alliance 只堵住用戶撞到的那一條,其餘三條仍會製造無頭勢力（讀 .leader_team_id 的地方 grep 有 72 處）。
```

# 2 你問的第 3 點:『只 push_error＋Probe 不擋』不夠——現成修復沒被用
```
world_state.gd:482 succeed_or_disband_faction(faction_id, dead_leader_tid, also_dead):候選=該勢力 member_team_ids 扣掉 dead_leader_tid,
   依 統領 技能→人口→team_id 全序選繼位者;沒有候選 ⇒ disband_faction。現有 3 個呼叫端全是『領袖隊死亡』（world_state.gd:919、faction_ai_system.gd:5168、npc_combat_system.gd:795）。
『領袖隊離開勢力』與『領袖隊死亡』對勢力是同一件事（領袖不在了）。專案已經有這個語意的單一實作;不呼它、改成只記 log,是把一個『會毀一局』的缺陷降成『可觀測』而不修。
建議（HOW,你定）:
  set_team_faction（world_state.gd:552）在 erase 舊勢力名冊【之後】:若 舊勢力.leader_team_id == team.team_id 且 reason != LEAVE_FACTION_DISSOLVED
     ⇒ 呼 succeed_or_disband_faction(舊fid, team.team_id) 並 Probe `faction.leader_left.<reason>`。
  ·它不『擋』任何路徑（你擔心的『擋會改其他路徑行為』不成立:搬還是搬,只是勢力不再無頭）;
  ·disband_faction 內部走 set_team_faction(…, LEAVE_FACTION_DISSOLVED)（:515-522）,要豁免它,否則解散時對每個成員遞迴；
  ·判斷『是領袖隊』要在 erase 之前讀,但呼叫繼位要在 erase 之後（候選才不含離開者）——寫明順序。
這會讓 L7『每個勢力 leader_team_id 都指向 faction_id==該勢力 的隊』由 set_team_faction 保證,而不是靠每條路徑自律。
來源歸因:你寫『>0 ⇒ 列出來源路徑』——headless 沒有呼叫堆疊（多格移動票已證 get_stack 為空）,加入勢力的呼叫端也沒傳 reason（現在只有『離開』有 LEAVE_* 常數,join 恆為 unset）。
   ⇒ 要歸因就替 join 也加 reason 常數（JOIN_ALLIANCE／JOIN_SUBJUGATE／JOIN_DEFECT／JOIN_ABSORB…）,呼叫端各傳一個;『unset／unknown』桶必須恆 0（沿用 A#27 的紀律,world_state.gd:524-530 註解）。
```

# 3 你問的第 2 點:L5(NPC↔NPC 兩領袖結盟不併)是 WHAT,不是玩家可見批的順手
```
同意『同一條規則、不分玩家』（玩家零特殊物理）;但要分兩層:
  ①完整性（領袖不得離開卻不留繼位）:世界缺陷,適用所有人,不必問藍圖;§2 的 set_team_faction 修復就是它。
  ②政策（兩勢力領袖結盟 ⇒ 『只結盟不併入』）:這把『兩個勢力能不能經結盟統一』從世界裡拿掉——之後結盟在兩領袖之間只剩 +0.2 名聲、沒有結構效果。
     修前這條路的實際行為就是『一方領袖被搬 + 原勢力無頭』（缺陷）;修後變成『無事發生』。兩者之間還有第三種:整個勢力併入（被搬方領袖帶全勢力一起入對方勢力,原勢力解散）。
     選哪個是遊戲世界規則（WHAT）,請藍圖知道;不擋本票出貨（會毀一局的是玩家被搬,L1–L4 優先）。
建議出貨方式:規則保持在 _form_alliance 一處（不分玩家/NPC）,【但】先在 guard 命中點 Probe 計數
   `alliance.leader_guard.{player_involved,npc_npc}`,30 天世界印出 npc_npc 次數;fp 若變,二分到只動 _form_alliance 那一處（你已寫）。
   npc_npc 次數若很多（結盟本是 AI 的重要結構事件）⇒ 交藍圖決定 ②,不要先吞掉。
```

# 4 其餘（小）
```
·方向統一::1865 `_form_alliance(from_team, pt)` 的 from_team 是【發起方】,放在 team_a(收提案方)位置——錯。改 (pt, from_team) ✓ 你寫的對。
   同一處的回傳句 `"接受同盟，加入勢力%d" % from_team.faction_id`:改完後 from_team 可能是被搬進來的一方,句子要改用 _form_alliance 的實際結果（你的改法 3）。
   順手::1862-1864『雙方皆獨立 ⇒ create_faction(from_id) # NPC 為領袖』覆寫了 _form_alliance 兩獨立分支的『人口多者為領袖』規則;改方向後這個覆寫仍在——兩條『誰當領袖』的規則並存,
   請在 spec 寫明保留哪個（建議刪覆寫,交 _form_alliance 的單一規則;玩家獨立接受 NPC 同盟時若 NPC 較弱,玩家反而成領袖,這是語意變化,要在結果句寫出來）。
·:876 重複呼叫:核實——handle_diplomacy_message（diplomatic_ai_system.gd:384-387）在 accept 時已 _form_alliance(self=tgt, sender=pt);:874-875 的 create_faction 前置判斷在那之後才跑,已永遠為假（兩隊此時至少一方有勢力）。
   :874-876 整段可刪,名聲 +0.2 重複計入也隨之消失（L6 ✓）。
   但注意:第一次呼叫的方向 team_a=tgt(收提案)、team_b=pt(發起)——玩家發起、對方有勢力、玩家也有勢力時,玩家(team_b)被搬進 tgt 的勢力:L3 ✓ 涵蓋,守衛放在 _form_alliance 本體才會擋到這一次。
·:1929 _accept_diplomacy_as_leader:方向正確(pt=收提案方),但 from_team 可能是別勢力領袖被搬進玩家勢力⇒ 守衛涵蓋;句子『自立後接納 Team%d，勢力%d』同樣改用實際結果。
·結果型別 {moved_team,to_faction,created_faction}:建議拆成【純函式 plan_alliance(a,b)→plan】+【apply(plan)】,提案行預告讀同一個 plan（你寫『同一個函式的試算版』）;
   加一格斷言『plan 的預告 == 實際發生』（跨 L1–L5）。
·L7:『任一格結束時每個勢力 leader_team_id 都指向 faction_id==該勢力的隊』——掛進 InvariantAudit（專案已有,merge-gate 跑它）,不要只是這支床的一個斷言;
   這樣另外三條路徑若再製造懸空,全電池就紅。
·L5 『修前若會換 ⇒ 這格也修前紅』:佈置要真造兩個不同勢力的領袖隊並讓 NPC 流程自己走到 handle_diplomacy_message（不是直接呼 _form_alliance）,才算走真路徑。
```

# 5 判決
```
verdict: issues
擋出貨的只有 §1/§2 的覆蓋面（否則用戶修好、其他三條路徑照樣製造無頭勢力）;做法=set_team_faction 咽喉呼 succeed_or_disband_faction（加 §2 的順序與豁免）
§3 通知藍圖（L5 是 WHAT）、§4 同版補
補 §2 後不需再審;若選擇不用 succeed_or_disband_faction 而保留 log-only,請寫理由回我
```
