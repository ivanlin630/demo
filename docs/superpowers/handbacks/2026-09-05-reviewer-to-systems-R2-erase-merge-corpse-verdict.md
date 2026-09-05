---
from: reviewer
to: systems
status: open
slice: erase-merge-corpse
topic: R②判決:issues(中)——不反對100%相關的機械坐實,但§2③「刪vs標記」是假二選一:讀code發現erase_teams(world_state.gd:527-654)已是「所有死法(戰鬥/饑荒/併入/滅族)」的單一chokepoint,逐項比對§2①點名的每個懸空引用(social_target/order_target_id/member_team_ids/belief條目)全部已在裡面處理;而subteam_system.gd:211-212 _erase_absorbed_team已經在merge_teams的population<=0分支呼叫state.erase_team——這條路是通的;真正該做的是查【觀測到的16→112屍體是從哪個merge/absorb call site漏過這個chokepoint】,不是先蓋一套新的mark/delete機制;第三案=路由進既有chokepoint(=delete)+複用既有capture_death的reason欄位(目前全域只用一個字串"erase_teams",從未區分死因)存merged_into事實,零新live欄位、零per-team迴圈過濾成本
---

# 判決：`issues`（中），`premise_contradiction: false`

不反駁測量本身——「空殼 ∩ 合併被吸收側 ＝ 100%，跨兩世界四張卷，母體 16→112」是機械坐實，我沒有理由懷疑這個相關性。但讀了現有 code 之後，我認為 **§2③「刪 vs 標記」這個二選一問錯問題**——有第三案，而且它比兩個既有選項都便宜。

## ★★★先講結論：這張票的成本結構跟 spec 假設的不一樣

Spec §2③ 的取捨是「刪＝乾淨但丟事實 vs 標記＝保事實但要逐處過濾」。**但這個取捨的前提是「要新蓋一套清理/過濾機制」——而讀 code 發現這套機制【已經蓋好了】，且已經在跑。**

## 讀 code：`erase_teams` 已經是§2①要的那個東西

`world_state.gd:527-654`，逐項比對 §2① 點名的每一個懸空引用：

| §2①點名的引用 | `erase_teams` 現有處理 | file:line |
|---|---|---|
| `social_target` | 死者 id 出現在他隊 → 清成 -1 | `world_state.gd:622-623` |
| `order_target_id` | 同上 | `world_state.gd:624-625` |
| faction `member_team_ids` | `.erase(tid)` | `world_state.gd:594` |
| `known_member_states`（faction） | `.erase(tid)` | `world_state.gd:595` |
| 別人的 belief 條目 | `team_known`/`team_discovered`/`team_intel` 逐 observer row erase | `world_state.gd:632-648` |
| （§2①沒點名但同類）`combat_target` | 走 `clear_combat_target` setter | `world_state.gd:615-621` |
| （同上）`known_reputations`／`invite_cooldown`／`diplomacy_reject_cooldown`／`strategic_assignments` | 逐項 `.erase(dtid)` | `world_state.gd:626-630` |
| （同上）outpost owner | 死者持有的 outpost → `owner=-1` | `world_state.gd:605-609` |
| （同上）市集看板 order | `origin_team` 是死者的單子整批清 | `world_state.gd:559-574` |

而檔案自己的註解白紙黑字寫（`world_state.gd:545`）：**「所有死法（戰鬥／饑荒／併入／滅族）都得經過 erase_teams ⇒ 一個掛點解多個觀測缺口」**——「併入」已經被列進去了，不是這張票要新發明的概念。

## ★★而「併入」這條路，讀 code 發現【已經接上】這個 chokepoint

`subteam_system.gd:211-212`：
```gdscript
func _erase_absorbed_team(state: WorldState, absorbed_id: int) -> void:
    state.erase_team(absorbed_id)
```
`merge_teams`（`subteam_system.gd:214-283`）在 `absorbed.population <= 0` 時（:268-270）就呼叫這支——**也就是說，完全吸收（population 歸零）的合併路徑，本來就會走到 `erase_teams`，本來就會拿到上面整張表的清理。**

另外，同類型的「屠村」路徑（`encounter_system.gd:1460`）也是直接 `state.erase_team(rid)`，註解自己寫「清光所有 ref」——這是**第三個**已經正確接上 chokepoint 的死法。

## ★★★所以真正該問的問題，spec 目前沒問

**如果「完全吸收」這條路本來就會 erase，那卷面上那 16→112 個屍體是從哪裡漏出來的？** 讀 code 我只能定位到一個可疑點，但沒有機械坐實它就是唯一源頭，誠實列出：

`interaction_system.gd:389-396`（同 faction、雙 IDLE 的自發合併）：`all_npcs` 只包含 `leader_id + named_members`（**不含 anon**），丟給 `merge_teams` 時 `transfer_anon` 用預設 `-1`（比例自動算）。而 `merge_teams` 內部（:226-247）有 `capacity` 上限：若 absorber 剩餘容量不夠，`actual_npcs`／`anon_xfer` 都會被砍——這種情況下 `absorbed.population` **不會**歸零，會走「部分合併」分支（:273-277，掛 `TAG_SUBTEAM`，`parent_team_id=absorber`，population>0，這是正常、非屍體的中間態）。**如果**這個部分合併後的子隊之後又透過飢餓等其他機制掉到 population==0，理論上該由 `faction_ai_system.gd:1029-1039` 那個無條件全域掃描（`for tid in state.teams.keys(): if team.population<=0: _on_team_extinct(...)`）撿到——這個掃描**沒有**排除 `TAG_SUBTEAM` 或 `parent_team_id!=-1`，照理也會抓到。

**⇒ 我沒有找到一個確定會漏網的 call site**——這代表兩種可能之一：①真正的漏洞在我沒讀到的某個 merge/JOIN 變體（JOIN resolver `_resolve_join`/`_try_merge` 我沒往下展開讀），②或者漏洞不在「有沒有呼叫 erase」而在「呼叫了但某個中間條件讓它提早 return」。**這正是 spec 動工前該補的一步**：不是先決定 mark-vs-delete 的新架構，是先用 SpecimenTracer 或屍體本身的 `parent_team_id`/`tags`/`faction_id` 欄位反查這 16→112 隻屍體，分類它們各自死於哪個 call site——這通常能把範圍收斂到 1-2 個具體漏接點，而修法可能只是「把那個漏接點接上既有 `erase_team`」，不需要動 §2③ 的任何一個選項。

## ★§2③ 的第三案（如果查完發現真的需要新東西）

若診斷後發現某條路徑**設計上就不該**在population歸零時走 full erase（例如需要先做別的事），那我的建議仍是 **delete（路由進既有 `erase_team`），不是 mark**：
- delete 直接拿到上面整張表的清理，零新增迴圈。
- mark 的唯一論點「保留誰併進誰的事實」——**這個事實已經有現成的存放處**：`SpecimenTracer.capture_death`（`specimen_tracer.gd:238`）本來就是「死亡瞬間快照＋死因字串」的既有機制，`world_state.gd:550` 目前唯一呼叫點寫死傳 `"erase_teams"` 這個【完全不分死因】的字串——**這本身就是被浪費掉的欄位**（不只這票，戰鬥死/餓死/併入死目前在 specimen 卷裡全部長得一樣）。把這個字串改成帶死因/併入對象（如 `"merged_into:%d" % absorber_id`），「誰併進誰」的故事事實就進了既有 archive，零新 live 欄位、零 per-team 迴圈過濾成本——**delete 拿到 mark 唯一想要的東西，不用付 mark 的代價**。

## ③守恆——同意，沒有意見

驗收 #3（合併前後資源/人口總量對得上）是對的機械證據，跟今天徵收那條線同一種紀律，沒有要補的。

## ⇒ 要你補的
1. §2③ 先別在「刪/標記」二選一，動工前先用既有 specimen/`parent_team_id`/`tags` 反查那 16→112 隻屍體各自的死因 call site——大機率能把「要修哪裡」收斂到 1-2 個具體漏接點。
2. 如果診斷後仍需要新的一般化清理，方向定為「路由進既有 `erase_team`」（delete），「誰併進誰」的故事需求改用 `capture_death` 的 `reason` 參數帶（目前該參數被浪費成單一固定字串），不要另開 `merged_into` 活欄位。
3. §2①/③ 都不算「錯」——是「問題問早了一步」；找到具體漏接點之後，這張票很可能從「架構決策」縮小成「補一個呼叫」。

**premise_contradiction: false（測量本身沒問題）；建議先做上面第 1 點的診斷再定 §2③ 方向，做完即可整票 CLEAN。**
