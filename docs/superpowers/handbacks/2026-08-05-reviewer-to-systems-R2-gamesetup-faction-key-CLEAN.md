---
from: reviewer
to: systems
status: consumed
topic: "[R②CLEAN+2澄清項] game_setup faction-key robust——root親驗坐實且比claim更明確:world_state.gd:121 f.faction_id=_next_faction_id(sequential計數器)確認;game_setup.gd:578現況 state.create_faction(int(t_cfg[\"id\"]))連回傳值都沒接(非只是『用錯值』,是根本沒存),:585-586 state.factions.has(fid2)+set_team_faction(...,fid2)直接拿config faction_id當actual id用,精準對應T1誤入/T3 factionless症狀;fix新增var actual_fid capture+cfg_to_actual map結構正確;★澄清①:598/607『god-view創世seed同faction discovered』那段fa/fb比對是純config-vs-config自比(從不碰state.factions/state.teams[...].faction_id)不是同款bug,不需要照樣改成actual id,spec『掃全檔一併改』的指示對這處是可做但非必要的多工,要求implementer分辨清楚別為了掃描完整度誤改可能引入不必要風險;★澄清②:『conforming bed=config faction_id剛好0..N-1』這個neutral判準不夠精確,真正條件是『leader在teams_cfg陣列裡出現順序跟config faction_id遞增順序一致』(因為_next_faction_id按leader在陣列中出現順序分配非按config數值排序),這個更精細的條件已經被spec自己要求的驗不破他bed步驟涵蓋,非新增工作只是提醒measurer解讀時注意;determinism/scope/其餘結構性claim皆親驗成立;CLEAN→build續feat/info-network-whole→re-measure症1(T3救活對稱)+warring 2seed"
---

# R②判決：game_setup faction-key robust — CLEAN + 2澄清項

## root——親驗坐實，且比claim描述更明確
親讀`world_state.gd:116-130`確認`create_faction`：`f.faction_id = _next_faction_id`（單純per-world遞增計數器）、`_next_faction_id += 1`——跟leader team自己的config faction_id完全無關，純粹依呼叫順序分配。這個claim坐實。

親讀`game_setup.gd:567-586`（`_setup_explicit_teams`）確認現況比spec文字描述的還更直白地壞：**`:578 state.create_faction(int(t_cfg["id"]))`連回傳值都沒接**——不是「用了錯的值」，是這個函式的回傳值（真正的actual sequential id）**根本沒被存下來、直接丟棄**。`:585-586`——`if state.factions.has(fid2) and state.teams.has(tid): state.set_team_faction(state.teams[tid], fid2)`——這裡把`fid2`（原始config faction_id）直接當成actual in-sim faction id去用，`state.factions.has(fid2)`只是「剛好有某個actual sequential faction id數值上等於這個config數字」的巧合判斷，一旦巧合成立就把這隊塞進去——精準對應診斷描述的Team1誤入Team2的faction、Team3查無此id變factionless。

## config→actual map——親驗邏輯正確
spec提出的修法：`:578`改成`var actual_fid: int = state.create_faction(...)`並存入`cfg_to_actual[fid] = actual_fid`；`:585-586`改成用`cfg_to_actual.has(fid2)`查、`set_team_faction(..., cfg_to_actual[fid2])`用actual id指派——這個map的建法（leader建立時登記，非leader查表用）邏輯正確，且對「map查不到」的情況（例如某config faction_id從沒有對應leader）沿用舊code同款「靜默不指派、team留factionless」的行為，非新增一種失敗模式。

## ★澄清①——`:598/607`那段不是同款bug，非必須跟著改
spec要求「掃game_setup全檔config faction_id用點...一併改用actual id」，我親讀`:592-616`（god-view Slice B創世知識seed、②同faction互discovered邏輯）發現這段的`fa`/`tb_cfg.get("faction_id",...)`比對是**純粹config值跟config值互相比較**（`fa == int(tb_cfg.get("faction_id", -1))`）——從頭到尾**沒有碰`state.factions`或`state.teams[...].faction_id`**，純粹問「這兩筆config記錄有沒有標同一個faction_id分組標籤」。這跟`:578/585-586`那種「拿config值去查/寫actual狀態」的bug性質不同——只要同一個config faction_id最終都映射到同一個actual sequential id（這正是這次修法要保證的事），「config相同⟺actual相同」這個等價關係自然成立，`:598/607`繼續用config值互比完全正確、不需要改寫成查actual id。**要求**：implementer執行「掃全檔」時區分清楚這兩種性質——`:578/585-586`是真bug必修，`:598/607`是安全的config-only自比較，硬要跟著改成actual id版本不是錯，但是多餘的工，若手滑改錯（比如改成查一個此時還沒建好的actual id）反而可能引入新bug。非阻塞，是給執行階段的精確範圍提醒。

## ★澄清②——「conforming bed」判準需要更精確描述
spec講「conforming bed（config faction_id恰==sequential建序）→neutral」——這個判準略微不夠精確。親讀`:571-578`確認`_next_faction_id`的分配順序是**leader在`teams_cfg`陣列裡出現的順序**，不是「config faction_id數值大小排序」。也就是說，就算一個bed的config faction_id剛好是0,1,2...連續無跳號，如果陣列裡leader出現順序跟faction_id遞增順序不一致（比如faction_id=1的leader排在faction_id=0的leader前面），舊code跟新map仍然可能給出不同結果——conforming的真正條件是「leader出現順序跟config faction_id遞增順序一致」，比「id剛好0..N-1」更嚴格。**這不是新增驗證項**——spec自己已經要求「跑warring/economy/lord_distribution bed確認faction結構不變」，這個既有要求本來就會把這個更精細的條件實測出來；我只是提醒measurer解讀「為什麼某個bed結果不同/相同」時，別只看config faction_id是不是0..N-1這個表面特徵。

## determinism/scope——親驗成立
`cfg_to_actual`純粹跟著`teams_cfg`陣列既有順序建、零RNG，determinism不變。這次改動完全侷限在`game_setup.gd`（test-infra），親讀確認沒有碰`create_faction`本身（engine，in-sim建國仍照舊運作）、沒有碰任何`decision/`或`faction_ai_system.gd`——scope=test-infra claim坐實，跟感知鐵律/決策層無關（faction structure setup非決策讀值，這輪不用檢查god-view/genuine那套判準）。

## 判決
**CLEAN + 2澄清項（`:598/607`不需要跟著改；conforming bed判準更精確的說法供measurer參考，皆非阻塞）→ 回systems → build（續`feat/info-network-whole`）→ re-measure症1端到端（★T3也救活對稱、T1仍救活）+ warring 2seed → QA故事稽核。** root/修法邏輯都親自往下讀到比claim描述更直白的證據（回傳值根本沒接住），這次是test-infra範疇的correctness修正，不涉及感知鐵律/決策genuine那條審查線。
