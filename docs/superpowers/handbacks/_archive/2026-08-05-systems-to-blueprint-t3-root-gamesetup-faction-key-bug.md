---
from: systems
to: blueprint
status: consumed
topic: "[T3 root確認=game_setup faction-key bug非distribute·★distribute機制VALIDATED(3站全正確+T1救活):diagnostic 3-station tap證distribute candidate/convoy-target/settle三站全對(T2聞T1 gate_same_fac TRUE選T1同勢力OK settle terminus=T1=tile_owner OK)=distribute零bug·★真root=game_setup faction-key不一致(pre-existing bed/setup bug非info-network):game_setup:578 create_faction(int(t_cfg[id]))用leader team_id建faction key(Team0→faction0/Team2→faction2),但:583-586非leader用config faction_id查state.factions.has(fid2)·config infonet_whole.json faction_id=1(Team0/Team1)/2(Team2/Team3)→無faction keyed 1→Team1(cfg fac1)has(1)=FALSE入不了faction=factionless;Team3(cfg fac2)has(2)=TRUE湊巧==Team2 id入faction2·∴in-sim faction結構亂(config意圖T0/T1=fac1,T2/T3=fac2但實際T1 factionless/mismatch)=T2 relief『跨faction』是bed artifact非distribute錯·隱含約定=config faction_id須==leader team_id,bed違反·★判你:①distribute機制已VALIDATED(症1真解,T1救活+3站正確,cross-faction假象=setup bug)②T3 fix選項:(a)game_setup robust化=create_faction用config faction_id(:578 create_faction(int(t_cfg[faction_id])))+驗不破他bed(所有bed若faction_id==leader-team-id則neutral,差者改)vs(b)bed config faction_id=leader team_id(quick workaround只修infonet_whole.json)·此game_setup bug pre-existing非info-network scope,但小+修了T3也救活=更強arc驗證·序待你:定(a)game_setup vs(b)config→我設計→R²→build→re-measure(T3也救活?)+warring 2seed(平行measurer)→QA故事稽核→arc-done·誠實:distribute零bug是好消息,T3=setup artifact不浪漫化(gate該擋有擋,是setup把T1 T2放同faction)·地基KEEP"
---

# T3 root 確認 = game_setup faction-key bug、**非 distribute**（distribute 機制 VALIDATED）

## ✅ distribute 機制 VALIDATED（3 站全正確 + T1 救活）
- diagnostic 3-station tap 證 distribute **candidate/convoy-target/settle 三站全對**：T2 聞 T1、`gate_same_fac=TRUE`→選 T1 同勢力 OK→settle terminus=T1=tile_owner OK。**distribute 零 bug。**
- ＋T1 真救活（#7）＝**症1 distribute 機制真解**。「cross-faction 錯位」是**假象**（in-sim T2/T1 確在同 faction、distribute 正確 relief）。

## ★真 root = game_setup faction-key 不一致（pre-existing bed/setup bug、非 info-network）
- `game_setup:578 create_faction(int(t_cfg["id"]))` 用 **leader team_id** 建 faction key（Team0→faction 0 / Team2→faction 2）；但 `:583-586` 非 leader 用 **config faction_id** 查 `state.factions.has(fid2)`。
- config `infonet_whole.json`：faction_id=1（Team0/Team1）、2（Team2/Team3）→ **無 faction keyed 1**→ **Team1（cfg fac1）`has(1)=FALSE` 入不了 faction=factionless**；Team3（cfg fac2）`has(2)=TRUE`（湊巧 ==Team2 id）入 faction 2。
- ∴ **in-sim faction 結構亂**（config 意圖 T0/T1=fac1、T2/T3=fac2；實際 T1 factionless/mismatch）= T2 relief「跨 faction」是 **bed artifact 非 distribute 錯**。
- **隱含約定**：config faction_id 須 == leader team_id；bed 違反。

## ★判你
1. **distribute 機制已 VALIDATED**（症1 真解、T1 救活+3 站正確；cross-faction 假象=setup bug）。
2. **T3 fix 選項**：
   - **(a) game_setup robust 化**：`:578 create_faction(int(t_cfg["faction_id"]))`（faction 鍵用 config faction_id）+ 驗不破他 bed（bed 若 faction_id==leader-team-id 則 neutral、差者改）。
   - **(b) bed config faction_id=leader team_id**（quick workaround、只修 infonet_whole.json）。
- 此 game_setup bug **pre-existing、非 info-network scope**、但**小 + 修了 T3 也救活=更強 arc 驗證**。

## 序（待你判）
- 定 **(a) game_setup vs (b) config** → 我設計 → R² → build → re-measure（T3 也救活?）+ warring 2seed（平行 measurer 進行中）→ QA 故事稽核 → arc-done。
- **誠實**：distribute 零 bug=好消息；T3=setup artifact、**不浪漫化**（gate 該擋有擋、是 setup 把 faction 放亂）。地基 KEEP。
