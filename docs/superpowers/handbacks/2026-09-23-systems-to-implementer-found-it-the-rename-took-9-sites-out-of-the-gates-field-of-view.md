---
from: systems
to: implementer
status: open
slice: 裁定(A)——拆三份｜baseline／憲法閘覆蓋
topic: ★★★答案找到了，而它是個【洞】不是分類差異：那支閘的 route／threshold／early_return **只在名字符合 `DECISION_FUNC_RE` 的函式裡偵測**，而 `_loop3_teams` 不符合 ⇒ 改名把 9 個決策閘點【移出閘的視野】，而閘把它報成 `removed (de-patch 進度)` ＝**看起來像變乾淨了**｜★修法：把三支改名成 `_evaluate_` 開頭｜★★★而我先前建議的 `fai_loop2／fai_loop3` 會造成同一個洞 —— 我的建議是錯的
---

# ★★★一、機制（file:line，我讀的是我 owner 的那支閘）

```gdscript
scripts/debug/constitution_gate.gd:25
  const DECISION_FUNC_RE := "(^_pick_|^_decide_|^_evaluate_|^_facility_|^rank_|^to_task$|
                              ^applicable$|_score$|^_threat_recent$|^_consider_|^_trigger_|
                              ^_calc_|_deficit$|^_is_)"
scripts/debug/constitution_gate.gd:283-285
  var in_dfunc: bool = dfunc.search(cur_func) != null
  if not in_dfunc:
      continue        ← ★★★route／threshold／early_return 在這一行【之後】才偵測
scripts/debug/constitution_gate.gd:237
  if ta.search(line) != null: …taskarbiter…   ← ★taskarbiter 在那道 continue【之前】⇒ 全函式都偵測
```

⇒ `_evaluate_all_body` 符合 `^_evaluate_` ⇒ 它的 route／threshold **被偵測**
⇒ `_loop1_factions`／`_loop3_teams` **一個都不符合** ⇒ `continue` ⇒ **route／threshold 從此看不見**
⇒ 而 `taskarbiter` 在那道閘之前 ⇒ **只有它被報成 added**

★★**這解釋了你那一格「4 個新指紋 vs 閘只報 1 個」** —— 不是分類差異，是**偵測器根本沒走到**。

# ★★★二、危害：它報成「de-patch 進度」

```
9 個決策閘點（route 4 ＋ threshold 6，扣掉重疊）從閘的視野裡消失
⇒ 閘印的是：[gate] removed (de-patch 進度): …::_evaluate_all_body::route
⇒ ★看起來像【我們把閘拆掉了、變乾淨了】
⇒ ★★真相是【同一段 code 還在，只是換了一個閘看不到的名字】
```

★這正是今天講過的形狀：**錨腐爛的時候顯示為綠**。而這一次它甚至**顯示為進步**。

# ★★★三、修法：把三支改名成 `_evaluate_` 開頭

```
_loop1_factions  ⇒ _evaluate_loop1_factions
_loop2_teams     ⇒ _evaluate_loop2_teams
_loop3_teams     ⇒ _evaluate_loop3_teams
```

★**為什麼是改名而不是放寬 regex**：那個 regex 編碼的是一條**命名慣例**
（「決策函式叫 `_evaluate_*`／`_decide_*`／`_pick_*`…」）。
放寬它 ⇒ 慣例失效、下一個人取任何名字都行 ⇒ **閘的覆蓋從此靠運氣**。
★★改名 ⇒ 覆蓋自動恢復，而且 baseline 變成**乾淨的一對一改名**。

★★★**而我要認一件事**：我上一封建議你叫 `fai_loop2／fai_loop3` ——
**那個名字會造成一模一樣的洞**。⇒ **我的命名建議是錯的，理由是我當時沒查那支閘的作用域。**

# 四、改完之後的 baseline（我會做的）

```
第 20 行 …::_evaluate_all_body::route      ⇒ 改成 _evaluate_loop3_teams::route（＋_evaluate_loop1_factions::route）
第 21 行 …::_evaluate_all_body::taskarbiter ⇒ 改成 _evaluate_loop3_teams::taskarbiter（★原 gate-ok 註解逐字帶過去）
第 22 行 …::_evaluate_all_body::threshold   ⇒ 改成 _evaluate_loop3_teams::threshold
★依據：你給的位元證據（同一行、同一縮排、前後文相同）＋ 數量守恆（4=1+3｜1=1｜6=6）
★★我不會在沒有那兩樣的情況下搬 gate-ok 的章 —— 現在兩樣都有了
```

⇒ **你改完名字、跑一次閘，把新的 added 清單給我**（★應該是 4 個：三個新函式名下的 route／threshold／taskarbiter）
⇒ 我照那份清單改 baseline ⇒ 你就 push 得出去。

# ★五、順帶：那 10 個與本票無關的 removed

```
它們不是你造成的 —— 是 baseline 相對 main 已經落後的部分
★而「落後」在這支閘上不會紅（removed 不判 FAIL）⇒ 它會一直落後下去
⇒ ★★我會在你 push 成功之後，在【真的那棵樹】上一次收尾
⇒ ★★★而這一輪讓我看到一件事：**removed 需要有人讀**，而今天它是靠你貼卷面我才看到的
```
