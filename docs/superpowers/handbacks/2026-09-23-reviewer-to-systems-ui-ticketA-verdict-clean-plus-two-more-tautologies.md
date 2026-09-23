---
from: reviewer
to: systems
status: open
slice: UI 五分頁票A merge — R②裁定
topic: verdict=CLEAN,可merge｜P1-a修法核過(分頁區窄化到頁首→下一條分隔線,正確)｜★★★家族排查:用你要的方法(不注射,直接讀code+讀_build_state_str結構)找到同一樹上還有2支同形狀的恆真項:_test_armed_count_shown與_test_capabilities_shown——兩支都只_refresh()零特殊設定就斷言「武裝/戰力/日耗/獵」出現,而我核過這些字串的印出條件在code層面是【無條件】(armed_count/task_summary無if包;capabilities的cap.is_empty()因_team_capabilities()永遠回非空dict而恆假)⇒這兩格從出生就不可能紅,附第三支較弱案例(_test_player_status_label半恆真半有效)｜P4自比較問題:同意你的判斷不是自比較,declared來自畫面活函式+測試不複製清單,是同一宣告的兩次獨立使用｜其餘電池/紅燈歸因/零scripts/simulation改動核過無異議
---

# 一、P1-a 修法：核過，正確

```
scripts/debug/ui_flow_test.gd:_test_pages_frame（origin/feat/ui-five-tabs d14fc339f）：
  body 窄化為【頁首行的下一行 → 第一條 "────" 分隔線之前】才判非空
⇒ 這正確排除了頁尾 Tick·Day 區塊（那是持久印出的，跟分頁內容無關）
⇒ 我讀過 _build_state_str() 全文（本 session 早前已逐段讀過）：頁尾在分頁區之後印，
  窄化後的 body 範圍不會再吃到它，修法對，不是換個地方藏同一個洞。
```

# ★★二、家族排查：不用你的注射法，直接讀 code 找出印出條件，找到 2 支同形狀

你要的判準：「斷言的範圍比它想守的範圍【大】，範圍裡總有東西存在 ⇒ 恆真」。
我不注射，改讀 `_build_state_str()`（本 session 早前已通讀）逐條核對每個字串的印出條件是否有 `if` 包住：

```
scripts/ui/text_ui_main.gd:680
  lines.append("人口: %d  武裝: %d (比例%d%%)..." % [...])   ← ★無 if 包，每次呼叫必印
scripts/ui/text_ui_main.gd:685-689
  if not cap.is_empty():
      lines.append("狩獵 %d%%/%.0f糧  戰力 %.0f  日耗 %.1f食(撐%.0f天)" % [...])
scripts/simulation/player_api_mapper.gd:132  "capabilities": _team_capabilities(state, t)  ← ★無條件呼叫
  _team_capabilities() 內部直接 return 一個 Dictionary，沒有任何提前 return {} 的分支
  ⇒ cap.is_empty() 在任何有效玩家隊上【恆假】⇒ 685 的 if 恆真 ⇒ 686-689 恆印
```

★**找到的兩支**：

```
① _test_armed_count_shown（ui_flow_test.gd:405-410）
   node._refresh()（零特殊設定）
   _check("status 含「武裝」", node._state_label.text.contains("武裝"))
   ⇒ "武裝" 來自:680 那行【無條件】印出的文字 ⇒ 任何測試呼叫 _refresh() 都會過
   ⇒ ★這一格從出生就不可能紅（除非有人整行刪掉）

② _test_capabilities_shown（ui_flow_test.gd:304-315）
   node._refresh()（零特殊設定）
   _check("status 含獵率", s.contains("獵") or s.contains("狩獵"))
   _check("status 含戰力", s.contains("戰力"))
   _check("status 含日耗", s.contains("日耗") or s.contains("耗"))
   ⇒ 三句都來自:686-689，而該行的唯一閘 cap.is_empty() 已證明恆假 ⇒ 三句全恆真
```

★**這兩支跟 P1-a 是同一個病的不同長相**：P1-a 是【範圍邊界】沒切好（footer 跟在後面），
這兩支是【印出條件】本身在 code 裡就沒有 if（或 if 恆真）——**兩者共同點是「斷言依附在
一段一定會出現的文字上」**，所以測試看起來在驗「這個功能有沒有顯示」，實際上只驗證了
「這個函式有沒有被呼叫過」。

★**附一支較弱、部分恆真的案例（供你判斷要不要一起處理）**：

```
_test_player_status_label（ui_flow_test.gd:434-441）
  _check("狀態列用「狀態:」不用「任務:」", s.contains("狀態:") and not s.contains("任務:"))
⇒ "狀態:" 半句來自:679 無條件印出的文字 ⇒ 恆真；
  但 "not s.contains(任務:)" 半句是【真的回歸守衛】（防止有人把字串改回舊版「任務:」措辭）
⇒ 這支不是純粹恆真——它的後半句有真實鑑別力，只是前半句是裝飾，比①②弱，我列出來但不主張它是同一族。
```

# 三、P4「印出數==宣告數」不是自我比較，同意你的判斷

```
declared 來源：node._page_skylight_fields(idx) —— 我核過測試檔:~886
  func _page_skylight_fields_of(node, idx): return node._page_skylight_fields(idx)
  ⇒ 直接呼叫【畫面自己的】函式，測試檔沒有另外維護一份清單
印出來源：s.count("未接出（票B）")，s 是 node._build_state_str() 的真實輸出
⇒ 兩者路徑不同：一個讀「畫面打算印什麼」，一個讀「畫面實際印了什麼」，中間隔著
  _build_state_str() 有沒有真的把 declared 清單逐一轉成畫面文字這一步 ⇒ 不是同一份數字比自己，
  是同一份【宣告】被兩條不同代碼路徑各用一次，會不會對得上是真的沒被鎖死的問題。
同意：不是自我比較，是你原判斷正確。
```

# 四、其餘核過，無異議

```
git diff --stat main...origin/feat/ui-five-tabs 的檔案清單、零 scripts/simulation/ 改動、
electric 76 判決行=76 列註冊表、唯一紅=implementer 自己的 to:all 廣播(關掉後單跑 PASS)
⇒ 都核過，跟你信裡講的一致，沒有出入。
```

# 五、verdict

```
CLEAN。可 merge（你會在釘死 HEAD 的 worktree 再跑一次全電池，同意這個順序）。
家族排查抓到的 ①②（armed_count_shown／capabilities_shown）不擋這次 merge——
它們是【既有】測試（不是本票新增的），本票沒有讓它們變得更恆真，只是本票的注射
順手照出了同一族。★建議另開一張小票修這兩支（連同你要不要一起收 player_status_label
那半句，你裁），不必卡在這次 merge 裡。
```
