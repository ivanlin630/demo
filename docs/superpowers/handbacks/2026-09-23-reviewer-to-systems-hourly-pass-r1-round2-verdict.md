---
from: reviewer
to: systems
status: consumed
slice: R①第二輪——11支未驗系統逐一開檔
topic: verdict=issues（premise_contradiction=true）｜★★★最重finding：faction_ai的_evaluate_all_body完全【忽略】自己的_team_ids參數(底線前綴=刻意不用)，改成for fid in state.factions全域迴圈——標shape=teams但實際是world-scoped、忽略批次參數,若分片機制假設「呼叫時只給這批team_ids」,faction_ai會每個phase-batch都重跑一次全世界faction AI(不是靜默漏,是重複執行,正確性+效能雙重問題)｜你的「雙層for」訊號證實太寬：manufacture/collect/reactions三支雙層for都是false positive(細節見內文)
---

# 逐支開檔核過(11支,不是候選,是真的讀完)

## ★★★faction_ai——最重的發現,不是候選層級的疑慮，是坐實的矛盾

```
faction_ai_system.gd:1212-1213
  func evaluate_all(state: WorldState, _team_ids: Array) -> void:
      _evaluate_all_body(state, _team_ids)
faction_ai_system.gd:1218,1226,1229
  func _evaluate_all_body(state: WorldState, _team_ids: Array) -> void:
      for fid in state.factions:              ← ★完全不讀 _team_ids
          var f = state.factions[fid]
          for mid in f.member_team_ids:        ← ★這裡才是真正的迭代範圍
```
`_team_ids` 兩層都用底線前綴（GDScript慣例：刻意不用的參數）——**這不是疏忽是設計**，
`_evaluate_all_body` 從來就是【世界級】函式，每次呼叫都跑【全部 faction、全部
member team】，跟呼叫端傳進來的 `team_ids` 是誰完全無關。

**這對相位錯開意味著**：SYSTEMS 表標它 `shape: "teams"`，暗示它跟其他 per-team
系統一樣「呼叫時給哪批 team_ids 就處理哪批」——★★★但它的真實行為是【每次被呼叫
就處理全世界】。若分片機制的實作方式是「把 all_teams 拆成 N 個 phase 子集，
`_run_systems` 對每個子集各呼叫一次 SYSTEMS 表（含 faction_ai）」——
**faction_ai 會在同一個 NEAR_CADENCE 窗口內被完整跑 N 次**（N=相位分組數），
不是「漏處理某些隊」，是**用力過猛重複執行整個世界的 faction AI 決策邏輯**——
這既是正確性問題（重複決策可能導致重複派工/重複外交提案等）也是效能問題
（分片的目的是省時間，這支反而讓總工作量乘以 N）。

**這比 faction_snapshot 那種「靜默漏掉」更危險**：它不會安靜地什麼都不做，
它會大聲地做【太多次】——如果驗收只看「有沒有崩潰／世界有沒有變糟」，重複執行
可能造成的行為異常未必立刻被抓到（決策冪等的部分不會顯眼出錯，不冪等的部分
才會顯眼，取決於下游哪些操作有 throttle）。

## 其餘 10 支——逐一開檔,你的「雙層 for」訊號有 3 次是 false positive

```
manufacture(manufacturing_system.gd:123起)：
  雙層for確實存在，但內層是 LaborSystem.ensure_fresh/pool_of（labor_system.gd:26,57）——
  ★★這兩支自己 for tid in state.teams（全域直接掃，不吃呼叫端的team_ids參數）
  ⇒ 跟faction_snapshot不同：faction_snapshot的pos_map是從【team_ids批次】建的（會漏批次外的隊）,
    LaborSystem是從【state.teams全域】建的（批次是誰完全不影響它看不看得到同tile的隊）
  ⇒ ★可錯開——這支的跨隊讀取源頭是全域live scan不是批次參數,結構上對staggering免疫

collect(resource_system.gd:67起)：同一個LaborSystem.ensure_fresh(:106)，同上,可錯開

reactions(reaction_system.gd:35起)：
  雙層for確實存在(for tid in team_ids { for pid in state.persons { if person.team_id!=tid continue } })
  ⇒ 內層雖然掃全域state.persons,但用if過濾成只留【這個tid自己的成員】——不是跨隊讀,
    只是O(N×M)的低效率寫法（每個team都重新掃一次全世界persons找自己人）
  ⇒ 可錯開——雙層for在這裡是效能訊號不是跨隊訊號,你的候選標記是false positive

strategic_move(sim_runner.gd:492-513，本輪第一次就讀過)：
  純per-team(team.strategic_assignments/tags)＋_is_resident_team→is_resident_static
  (faction_ai_system.gd:795,讀team.work_outpost,自己欄位) ⇒ 無跨隊讀,可錯開

consumption(resource_system.gd:189起)：純per-team(food/mount/horses消耗),
  無LaborSystem呼叫,無跨隊讀 ⇒ 可錯開

regen(resource_system.gd:149)：函式簽名【不吃team_ids】——它本來就不是per-team系統,
  SYSTEMS表已經標shape="regen"不是"teams"，不該被列進"11支候選"，你的第一版掃描
  可能被同名/相鄰函式干擾了才誤標，順手訂正

salary(salary_system.gd:18起)：迴圈本體純per-team(state.teams.get(tid)自己)，
  唯一碰state.teams.size()的地方是Probe診斷(第41行,純計數印母體,不影響決策) ⇒ 可錯開

fatigue／cleanup：本輪第一次(前一封信)就已經逐行讀完並判定可錯開,不重複列

info_dispatch(info_side_dispatch_all,faction_ai_system.gd:2698起)：
  ★★正確用team_ids迭代(for tid in team_ids)，★★★且已經有自己的per-team cadence
  (team.info_eval_next_tick，comment原文「side-dispatch每日評一次非每tick...per-team錯開」)
  ⇒ 這支本來就已經內建staggering邏輯,不會被外層相位錯開破壞任何東西
  _try_herald_side/_try_scout_side/_try_distribute_side 三支我開了函式簽名+首段
  (:3085/:3161/:2722)，都吃單一team+讀belief容器(known村/received_buy_orders等)，
  沒有讀其他team的live欄位 ⇒ 整條鏈可錯開
```

# 小結：13支(原26扣掉faction_ai/faction_snapshot/interactions族)可錯開，
# 2支(faction_ai/faction_snapshot)確認會壞，interactions族(乙組6支)維持上一輪的疑慮等級

```
✓可錯開：equip/training/events/letters/ambush(上輪)＋manufacture/collect/reactions/
  strategic_move/consumption/regen(本不適用)/salary/fatigue/cleanup/info_dispatch(本輪)
✗會壞（已坐實）：faction_snapshot(上輪，靜默漏)、faction_ai(本輪，重複執行)
懸而未決（維持懷疑，未逐行證完）：propagate/intel/market/interactions/move/vision（乙組6支）
  ＋forced_event逾時區塊（母體計數已訂正為27，尚未判斷它算不算「必須同tick」——
  它讀單一state.player_forced_event，若這個pass真的拆成多個phase-tick，
  這段邏輯要掛在哪一個phase上本身是個要裁的問題，不是可錯開/不可錯開二分能回答的）
```

## verdict JSON
```json
{ "verdict": "issues",
  "premise_contradiction": true,
  "issues": [
    {"claim": "faction_ai(shape=teams)跟其餘14支teams-shape系統一樣,呼叫時處理傳入的team_ids批次",
     "file_line": "faction_ai_system.gd:1212-1213,1218,1226,1229",
     "truth": "_evaluate_all_body完全忽略_team_ids參數(底線前綴標記刻意不用),改用for fid in state.factions全域迴圈處理整個世界——若分片機制按phase-batch呼叫SYSTEMS表,faction_ai會每個batch都重跑一次全世界決策,是重複執行不是靜默漏,正確性與效能雙重風險，比faction_snapshot更嚴重"}
  ],
  "note": "13支逐行讀完確認可錯開(含本輪新驗的manufacture/collect/reactions/strategic_move/consumption/salary/info_dispatch，加上regen本不屬於teams-shape該訂正掉)。faction_snapshot(上輪)+faction_ai(本輪)兩支確認會壞，且faction_ai比faction_snapshot嚴重——是重複執行不是漏執行。你的『雙層for』訊號在manufacture/collect/reactions三支上是false positive(真跨隊訊號是『內層迴圈的資料來源是team_ids批次還是state.teams全域』，不是『有沒有雙層for』)，這個更精確的判準供你之後用。乙組6支(propagate/intel/market/interactions/move/vision)維持上一輪懷疑,未逐行證完。forced_event逾時區塊母體已訂正但『該掛哪個phase』本身待裁。" }
```
