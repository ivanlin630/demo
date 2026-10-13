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

# 6 追加:對 7da86e7ca／c696ae0f9(領袖結盟拒絕＋先量)的審
## 6.1 負斷言核對:FactionData.relations 無行為讀寫者——成立
```
搜索:`grep -rn "relations" scripts --include=*.gd`（排除 scripts/debug;再排除 person 層的 leader.relations／p.relations／known_outpost_relations／_update_relations／relation_edges）;
      另搜 `"ally"`／`"enemy"` 字面。
結果:faction_data.gd:41 宣告;state_fingerprint.gd:435-437 把 f.relations 放進指紋字串（只讀、只雜湊,欄位恆空 ⇒ 無行為）;player_api_mapper.gd:916 的註解自己記『全站零寫入者』。
     "ally" 字面只出現在 faction_ai_system.gd 的 _emit_goal(…,"ally")（:88,:2019,:2139）——那是目標『模式』標籤,寫進 f.goal_drivers,不是 FactionData.relations。
結論:無讀者 ⇒ 『兩勢力結盟尚無實作』的判斷成立。
並且那個 ally 目標的前提是 `_has_independent(state, f.leader_team_id)`（:2018,:2133）——它是在【招募獨立隊】,不是勢力對勢力 ⇒ 拒絕勢力領袖互盟不會讓這條 AI 目標變成無法達成。
```
## 6.2 規則的謂詞要寫準:『兩勢力領袖結盟』不是被拒集合的邊界
```
_form_alliance 被搬的只有 team_b（發起方）,且只在 team_a（收提案方）有勢力時（diplomatic_ai_system.gd:419-421）。
⇒ 『領袖被搬』的真條件＝【發起方是自己勢力的領袖 ∧ 收提案方在另一個勢力】——收提案方【不必】是領袖。
   被拒集合因此是 {領袖→領袖} ∪ {領袖→非領袖成員}。spec 的字面『兩個勢力的領袖結盟』漏了後者。
   （反向:收提案方是領袖、發起方是非領袖成員 ⇒ 發起方照搬入,不受此規則影響——那是成員換邊,保持。）
   請把謂詞寫成『發起方為領袖隊且收提案方勢力≠發起方勢力』,L2/L5 各補一格 {領袖→非領袖}。
```
## 6.3 NPC 端:拒絕要在【提案選項】層排除,不是送出後才拒
```
try_proactive_diplomacy（diplomatic_ai_system.gd:167-186）:任何有勢力的隊(不限領袖)對同格異勢力隊 score>0.6 ⇒ 送 propose_alliance 並 `return`（本輪外交就用掉了）。
被拒的後果只有 sender.diplomacy_reject_cooldown[target]（:221-223）。若照 spec 只在 _form_alliance/handle 處拒絕:
   ·領袖發起方每個冷卻週期對同一對象重送一次必被拒的提案,而且每次 `return` 吃掉那一輪的外交機會(同輪的 propose_trade／demand_tribute 選項被擠掉)——
     『同一原因禁無記憶反覆撞』（執行失敗反饋鐵律）的形狀,雖然有冷卻擋住密度。
   ⇒ 用你的 plan_alliance(a,b) 純函式在【選項生成處】判:plan 為『無動作』的結盟不列為選項(score 排序時直接跳過),讓 NPC 去做 trade／tribute;
      handle_diplomacy_message 內再判一次作為安全網(玩家端與外部呼叫也過同一支)。
handle_diplomacy_message 目前的順序:算 score → `_form_alliance` → 回 "accept"（:384-388）。要改成:先 plan,plan 為『無動作』⇒ 回 reject（並帶可映射的原因碼給玩家端),不先 form 再回 accept。
   玩家端 `_action_propose_alliance` 把原因碼經 PlayerApiMapper 映射成『兩個勢力之間的結盟還沒做』（玩家面零英文識別字的既有紀律,player_command_system.gd:~880 註解）。
```
## 6.4 『先量』的設計缺口(c696ae0f9)
```
①分母:『被搬方是領袖那一支佔全部勢力成員變動(faction.join)的比例』——world_state.gd:552-569 的 faction.join 是 set_team_faction 每次入勢力都 +1,
   含 subteam_system.gd:110/148/175（子隊繼承母隊勢力）、interaction_system.gd:1719/1748、game_setup 等 ⇒ 子隊繼承會灌大分母,把比例壓低,『不是主要管道』的結論偏向放行。
   ⇒ 分母改成『頂層隊入勢力且來源路徑歸因』(join reason 常數,見 §2)，或直接報各 JOIN_* 路徑的絕對次數,別用總 join 做分母。
②樣本:只跑 30 天 seed 1337 一個 seed。『fire 0 次』是負斷言,母體太小:至少 3 個 seed、且一個『陽性對照』(佈置一個同格的領袖→領袖／領袖→成員提案,證明修前確實 fire 這一支,量測儀器接得到)。
   (專案已記 multi sanity 無 seed、drift 不可重現——所以要的是『多 seed 的分佈』,不是一次跑。)
③報表:發起方角色 × 收提案方角色(領袖／非領袖成員／獨立)的 3×3 次數,不是單一『被搬方是領袖』;並報『那一支發生後原勢力剩幾隊、leader_team_id 是否懸空』(你已寫)。
④『停手交件』門檻:『主要管道』沒有數字。請在 spec 先寫判準(例:該支佔『頂層隊入勢力』次數 ≥ X% 或使 ≥ Y 個勢力成長),或明講『有任何 fire 就交件給藍圖看分布』;
   事後才定門檻等於用結果決定標準。
```
## 6.5 判決(追加)
```
verdict: 同 §5（issues）;追加 §6.2 謂詞、§6.3 選項層排除與 handle 順序、§6.4 量測設計,同版補;玩家端出貨不受量測影響(你已寫),本追加不擋它
```
