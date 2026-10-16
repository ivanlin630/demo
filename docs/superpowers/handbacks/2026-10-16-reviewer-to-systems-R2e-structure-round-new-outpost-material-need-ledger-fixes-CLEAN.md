---
from: reviewer
to: systems
status: open
slice: 結構輪探針 §三之三 新點缺料進需求帳（main 0eb2abe97，R²d 之後的 diff）
topic: R② 第五輪（只看 diff）＝ **CLEAN，帶一處小補**｜M9–M13 全部對得上；「施工隊認定抽成共用函式」若會掃全隊就破壞 O(1)
---

# 核對
```
✓ M9：① 五個條件寫全（task、move_target 兩個不等、目標格 outpost_level==0 且 construction_team_id==-1、子隊 build_type／母隊 camp_team_id+camp_level==1）。
  排除三群我逐一對過：建設／自救建田（options.gd:77/99，move_target==腳下）、復工工人（目標格有別人工地）、升級設施（outpost_level>0）。N2b 三格＋n23 對位。N1 另有正例（真的在走），所以排除不是靠「根本沒有隊進得了①」。
✓ M10：§三 :129 確實有「進行中的工地也用它：carried 傳 site_stock，need 讀 construction_target[need]」這條既有規則，② 沿用，不加參數，合理。N6b（gather_left 70 vs 5）＋n24（carried 傳 0）對位。
✓ M11：五個讀者與「不受影響」的結論和我掃的一致；N8 對位。
✓ M12：② O(1)（子隊 tile_pos／母隊 corvee_site）；吃料者＝active_team；N4／N4b 走 InvariantAudit；n25。
✓ M13：N5 拆 (a) 值 (b) 行為；現況段改正「施工隊賣盤整段跳過」。
✓ 上限：n=min(新點,CAP)、f=min(設施,CAP−n)；N6c（80+80 ⇒ 100，新點 80、設施 20）＋n26（反序 ⇒ 新點 20 ⇒ 紅）。
✓ coin_treasury.gd:54：已讀，那是 coin_need 的「afford×1.5」缺口，改讀 _construction_need 後在路上要買料的隊會替買料向外抽幣；合理，且在 spec 交代。
```

# 小補（不擋、補完不需再審）
```
S1 「施工隊」認定「抽出來兩邊都呼」：_tick_construction 的 active_team 是 outpost_system.gd:376-381 對【全部 state.teams】迴圈找第一支同格 TASK_BUILD 的隊。
   若共用的是這支「找隊」函式，② 進了 need_keep 熱路徑就變 O(teams)，M12 的 O(1) 又被吃掉。
   請共用的是【逐隊謂詞】is_site_worker(team, tile)＝(team.tile_pos==tile.tile_pos ∧ team.current_task==TASK_BUILD) ∨ (tile.construction_team_id==team.team_id ∧ team.corvee_site==tile.tile_pos)，
   O(1)；_tick_construction 仍可自己迴圈挑第一支，但挑的條件呼同一支謂詞。吃料（active_team）與讀需求（逐隊謂詞）因此對同一個格不會各說各話。
   已知殘差：同格有兩支都滿足謂詞（原施工隊離格以 corvee_site 認領，另一支接手工人站在格上）⇒ 兩支都把同一份 gather_left 算進自己的需求，買單可能雙倍。
   請在 spec 一句話認這個（或讓離格的原施工隊不算），交件信印「同格雙需求」次數。
   驗收補 N3b：同一工地兩支隊都滿足謂詞 ⇒ 計數 >0 被印出（不要求值）；n27：共用函式改成掃全隊 ⇒ 用 Probe「perf.need_keep.us」前後對比（同 option_term_cost_bed 的碼表）不得超過基線的 noise 帶。
S2 簽名：_construction_need(state, team, res) 少了 leader_values；_construction_facility_need 需要 lv（need_oracle.gd:160）。補上，coin_treasury.gd:54 已有 lv 可傳。
```

# 判決
```
verdict: clean（帶 S1／S2 小補）
補完不需再審；§三之三可進 dispatch
```
