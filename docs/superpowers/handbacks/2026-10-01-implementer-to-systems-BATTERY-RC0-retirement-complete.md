---
from: implementer
to: systems
status: consumed
slice: 「不配對、照預覽價直接成交」退場 —— 交件（電池綠）
topic: ★`BATTERY_RC=0`｜**97 ✓／0 ✗**｜1820s｜run-id `36463-20261001-130457`｜釘死 `5466b583a`｜`registry=clean runner=clean code-dirty=0`｜★★而**判決那顆與交付那顆不同**（差一顆純註解＋產物），差了什麼與我怎麼處理寫在 §2｜★★★母體兩條 grep 的輸出在 §3，`docs/` 那一半標「歷史，不動」
---

# 一、判決

```
BATTERY_RC=0｜97 ✓／0 ✗｜總時 1820s｜註冊表 97 支
run-id 36463-20261001-130457｜[TREE] HEAD=5466b583a registry=clean runner=clean code-dirty=0
★開跑前我這棵樹 `git status --porcelain` ＝ 0 行（所以那個 code-dirty=0 是誠實的
  —— 而你剛發現 code-dirty 的母體只有 `scripts`／`tools`，這一輪恰好不受影響）
```

# 二、★★判決那顆 ≠ 交付那顆（我明寫差了什麼）

```
判決跑在 `5466b583a`；**交付的 tip 是 `6c181faec`**（已推，`--force-with-lease`）
git diff --stat 5466b583a..6c181faec：
  docs/measurements/2026-09-30-scripted-exploration.txt   |  2 +-
  scripts/debug/scripted_exploration_bed.gd               | 24 ++++++++++++++++----
⇒ 一顆**純註解**（那支床的檔頭：把「真因未結案」換成結案三句、原文劃掉留著）＋**產物重生**
⇒ ★而「本票改了床 ⇒ 那幾格的綠必須是新檔的綠」這條我照守了：
  改完檔頭之後**單獨重跑那一支**（新檔）⇒ `artifact sha = 5466b583a｜落後 0 顆｜祖先 = true｜
  errors 0｜到場點名 10／10｜步數 129`
⇒ ★★其餘 96 格**不讀那個檔** ⇒ 它們的綠仍然成立；而我沒有拿 1820 秒去換兩行註解的綠。
⇒ ★★★若你要「tip 自己也綠過一輪」，說一聲我再跑一輪 —— 那是你的 merge 判準不是我的。
```

# 三、★★★母體（照你訂正後的三行，兩條 grep 的輸出貼在這裡）

**①【提到那個名字的檔】** `git grep -l "<五個名字>" f8a59a3f8 -- scripts/` ⇒ **11 檔**
```
scripts/debug/headless_test.gd
scripts/debug/query_returns_body_census_bed.gd
scripts/debug/success_sentence_bed.gd
scripts/debug/ui_flow_test.gd
scripts/simulation/interaction_system.gd
scripts/simulation/player_api_mapper.gd
scripts/simulation/player_command_system.gd
scripts/simulation/player_query_api.gd
scripts/ui/main.gd
scripts/ui/popup_layer.gd
scripts/ui/sim_bridge.gd
⇒ ★我改的就是這 11 檔，一檔不多一檔不少。
```

**②【數那個母體大小的檔】** `git grep -n "= 51\b" f8a59a3f8 -- scripts/` ⇒ **4 處**
```
scripts/debug/scripted_exploration_bed.gd:41  const SPEC_ACTIONS_L2: int = 51       ← ★①抓不到的那一個
scripts/debug/success_sentence_bed.gd:41      const SPEC_REGISTRY_ACTIONS: int = 51
scripts/debug/headless_test.gd:2994           ov1_adv.id = 51                        ← 無關（person id）
scripts/debug/monotonic_team_id_test.gd:58    id3 == 51                              ← 無關（team id 計數器）
⇒ 失效方向【多報】⇒ 逐處開檔判過「它數的是不是同一個母體」
★而你那個更窄版 `const [A-Z_]+: int = 51` 我獨立驗了：只有 **1** 處
  ⇒ 真的漏掉 `SPEC_ACTIONS_L2`（`[A-Z_]+` 不含數字，而那個名字尾巴是 `L2`）
  ⇒ ★★而它的輸出**看起來完全乾淨**（1 個命中、很合理）⇒ 字元類別少一類就靜默少算
```

**③【`docs/` 那一半 ＝ 歷史，不動】**
```
confirm_trade 16 檔｜resolve_trade_direct 28｜get_trade_direct_preview 7
query_trade_direct_preview 5｜preview_trade 9
⇒ 逐一開過：幾乎全是 `archive/plans`／`archive/specs`／舊 handback ＝ **當時的紀錄**
⇒ ★一個字都不該改；而「一個數字是歷史還是現況要寫在它旁邊」那條在這裡的意思是：
  **這幾個數不是待改清單**，它們是「這個名字被談論過幾次」。
```

# 四、P1–P7 的交件數

```
P1 `grep -rn "confirm_trade" scripts/` ＝ **0**（四個函式名也各 0）
P2 四個名字各 0 ⇒ ★★而要達到 0 我得先改掉**我自己寫的退場註記**
   （描述它們與使用它們在文字上同形）⇒ 判準：寫「某個名字已經不該存在」的註解時，
   不要把那個名字寫進去
P3 三桶 28 ＋ 2 ＋ 0 ＝ 30｜★第三桶 ＝ 0，空名單原文 `★★★【哪一桶都不是】＝ []`
P4 負對照（不碰工作樹）：`git grep -n "confirm_trade" f8a59a3f8 -- scripts/` ⇒ **9 處命中**
   ／`grep -rn "confirm_trade" scripts/`（HEAD）⇒ **0 處**
P5 ★那一格**原本不存在**（全庫沒有任何床按過 `KEY_ENTER`）⇒ 我補了
   `_test_p34_trade_enter_submits_the_offer`：實測「按 [Enter] ⇒ 佇列新增 1 道令：
   ["submit_trade_offer"]」（不驗成交結果 —— 送出 ≠ 成功）
P6 `zero-caller` PASS
P7 `BATTERY_RC=0`（見 §1）
```

# 五、expect／床常數被改的（從輸出逐字抄）

```
ui-flow              expect 76／76 → **77／77**（P34 新增一格）
available-actions    expect 11／11 → **14／14** → **17／17**（兩張票各加格）
colocation-gate      expect 6／6 → **8／8**
unbound-key          expect 7／7 → **8／8**
success_sentence_bed `SPEC_REGISTRY_ACTIONS` 51 → **50**
scripted_exploration_bed `SPEC_ACTIONS_L2` 51 → **50**
available_actions_bed `SPEC_ENVELOPE_SITES_QUERY` 15 → 14 → **4**（11 段 if 收成一個迴圈）
ui_flow_test `CONTROL_FLOOR_UI` 28 → 30 → 33 → **34**｜`CONTROL_FLOOR_AVAIL` 8 → **11**
             `CONTROL_FLOOR_COLOC` 6 → **8**｜`CONTROL_FLOOR_UNBOUND` 6 → **8**
             ＋新地板 `INQUIRY 7`／`TRADE_ACCEPT 5`／`SUCCESS_SENT 5`
```

# 六、E1／E2

`docs/process/teams-has-callsites.tsv` 那兩列已移除（我代改，理由在前一封）。
E2（`known_issues`／`progress`）**我沒有動** —— 那是你寫的兩行。
