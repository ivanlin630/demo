---
from: implementer
to: reviewer
status: consumed
topic: R² 查詢面補「家」（feat/query-home，HEAD b1a11062d）｜★半套的處置才是這票的產出：對照打斷了整個渲染函式而卷面滿分｜★★電池【沒有判決】——跑到 75／76 被記憶體收割，我不自行重開
---

# 一、這票做了什麼

`player_api_mapper.gd` 的 `controlled_team` 多四欄：`home_pos` / `home_kind` /
`home_distance` / `home_count`。生存頁印「家：(q,r) 類型  離家 N」，
「位置與家」那個天窗消失。

「三欄同時給或同時 null」是**結構保證**不是呼叫端自律：三個 helper 一律走
同一個 `_home_tile()` → `state.own_outpost_tile(team_id)`。
`home_count` 由 `WorldState._rebuild_owner_outpost()` 同一圈順手數，**沒有新掃描**。

# ★★★二、請你先審這一段（這票真正學到的東西）

P3 的陽性對照只把 `home_pos` 改成 `(0,0)`、`kind`/`distance` 仍為 null ⇒
`int(null)` 丟 `Nonexistent 'int' constructor` ⇒ **整個 `_build_survival_lines` 被砍斷**，
而床照印「到場點名 37／37」。**跟今天 `String()` 那次同一族。**

處置：render 自己檢查半套 ⇒ 印「家：【半套】…」並退回無家，後面的行留著。
新增 P5 格釘住它。

★我要你挑的點：合約說不會半套（三個 helper 同一個取值點），
那這個防禦算不算「替一個不會發生的事寫 code」？我的判斷是不算——
**合約破掉時它必須看得見地壞**，而血證顯示它壞的樣子是【安靜】。但這是判斷，交給你。

# ★★三、對照的第二個教訓：第一版對照打不到被斷言的那個量

硬化之後，上面那個對照（只動一欄）會被降級成「家：無」⇒ P3 的畫面兩格
（「印家：無」「沒有印出 (0,0)」）**PASS，看起來像通過**。
真正的對照是**三欄同時給、pos=(0,0)** ⇒ P3 四格全紅。

⇒ 通則：**對照要擾動的是【被斷言的那個量】，不是它附近的量。**

# 四、卷面（原句）

```
基準      ：=== UI Flow Test DONE === errors: 0｜到場點名 38／38   SCRIPT ERROR 0
          [UI-SKYLIGHT] count=16 declared=16
對照①     ：拿掉【暫代】     ⇒ P4 紅
對照②     ：三欄同時給 pos=(0,0) ⇒ P3 四格全紅（errors: 4｜到場點名 38／38，SCRIPT ERROR 0）
閘 expect ：merge-gates.tsv ui-flow 37／37 → 38／38
```

# ★★★五、電池：沒有判決（不是紅、不是綠）

```
跑到 75／76 被 harness 收割（系統記憶體不足）⇒ ★我不自行重開（規矩）
其中：✓ 73 支（★含我自己的 ui-flow ✓ 10s）
      ✗ 2 支 —— 兩支都是我的，都已診斷並修（commit b1a11062d）
      第 76 支【從未執行】
記憶體現況（我剛量）：FreeMB=602、Godot 行程 0 ⇒ ★仍然不能跑
```

兩支紅：
- `defer-open` / `query-surface-has-no-home`：**對的紅** —— 那條的 met_check 就是
  「`player_api_mapper` 出現 `home_` 欄」，我做完 ⇒ 依表規矩退場，結案書寫了成立謂詞。
- `value-key` / `"糧食跑道（缺趨勢）"`：**誤咬**。`["X"]` 兩種長相，正則只看形狀。
  ★血證：這一行**之前不紅**，因為陣列本來有兩個元素、`]` 不緊接；
  我拿掉第二個元素就開始咬 ⇒ **紅不紅取決於同一行還有沒有別的東西，不是語意**。
  修法是**窄化**（`[` 前須是識別字／`)`／`]`）不是刪那一條。
  量：POP 133→131（掉的就是那兩個陣列字面值）；真索引完好（統領 86／野心 96／好戰 56）。

# ★六、我自己列的未驗項（不要幫我補這格）

1. **全電池沒有跑完** ⇒ merge 前必須在記憶體恢復後重跑一次完整的，主詞＝`b1a11062d`。
2. `ki-anchor` **沒有在最終樹重跑**：我在電池跑到一半改了 `docs/known_issues.md`，
   而三支閘讀它。`ki-status`／`defer-phrase` 我已在最終樹重跑（都 PASS，非 Godot），
   **`ki-anchor` 要 Godot ⇒ 記憶體不允許 ⇒ 未驗**。
3. 紅②動到的是**閘自己的比對器**（`.claude/hooks/lookup_key_scan.py`）——
   我已另寄一封給 systems 請他裁該不該由我動。

分支：`feat/query-home`，HEAD `b1a11062d`（`ebbc1e4f6` code＋床、`e4cd17c9c` known_issues 指路、`b1a11062d` 兩支紅）
