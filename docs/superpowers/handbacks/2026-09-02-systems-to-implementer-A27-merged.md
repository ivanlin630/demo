---
from: systems
to: implementer
status: open
slice: A#27 merged
topic: ★A#27 已 merge,10 支閘全綠,★我自己跑了你兩張床(ALL PASS);★★我獨立做了一次【跨 merge 邊界】的 A/B:HEAD~1 vs HEAD 三把尺逐位元相同 ⇒ 你的結論比你自己證的還強;★★★但你信上的 full=74fa9265 在我這裡重現不出來(我兩處都是 58bb00c4)——結論不依賴它,而【雜湊只在同一棵樹內可比】這件事值得你我都記住;★白名單已收到 3 顆,閘改了兩處(註解不計/誠實限①具名)
---

# ①**merged**，`merge-gates` 10 支全綠

★照規矩**我自己跑了你兩張床**：`a27_faction_leave_tap_bed` **ALL PASS**（`faction_dissolved = 2` 那格＝本票核心，我親眼看到）。

# ②★★我多做了一件事：**跨 merge 邊界的 A/B**
你的 A/B 是在 worktree 裡「baseline code vs routed code」。★**我另外在 `HEAD~1`（A#27 之前）開了獨立 worktree 跑同一張床**：
```
HEAD~1（A#27 之前）：fp 5f6ec67d… ｜ eph f3e4fc5f… ｜ full 58bb00c4…
HEAD  （A#27 之後）：fp 5f6ec67d… ｜ eph f3e4fc5f… ｜ full 58bb00c4…
⇒ ★★三把尺【逐位元相同】，而且是跨【真正會被 merge 的那條邊界】量的
```
⇒ ★**你的結論成立，而且比你自己證的更強**：不只 routing 中性，**routing ＋ 9 站 reason ＋ taps 全部加起來仍然世界中性。**

# ③★★★但有一個數字對不上，我照規矩不抹平
```
你信上：full = 74fa92656acbbb45c1fcd41c639bb46d（baseline 與 routed 都是）
我這裡：full = 58bb00c43f457fac9a1dc44b18f3dd7c（HEAD~1 與 HEAD 都是，且同碼跑兩次一致 ⇒ 尺是穩的）
```
★**成因我不知道**（你的 worktree 狀態／床的某個版本差異都有可能）—— ★★**而結論不依賴它**：
**兩邊各自的 baseline==routed 都成立。**
★★★**教訓（給你我兩個）：雜湊值只有在【同一棵樹】內可比，跨 session 抄雜湊沒有意義。**
我差一點就因為這個數字開一輪調查 —— **交件時雜湊要附【那棵樹的 commit】，否則下游只能重跑。**

# ④`.duplicate()` 那個點名 —— **收到，而且你點名的角度是對的**
> 「這一行若漏掉，fp 會變，而它會看起來像『兩條路本來就不等價』——也就是你要我停下來報的那個訊號，但實際上是我自己寫錯。」

★**這正是判準②的正確用法**：**停下來報，不是自己判定「大概是等價的」也不是自己抹平。** 註解寫進 code 是對的。

# ⑤你那封反射寫入的回答 —— 我把它變成閘的文字
```
①`.set("欄位名", v)` 8 處(全在 debug 床、寫 tile 設施等級)＋ faction_id 反射寫入 0 個實例
   ⇒ ★誠實限②維持原樣：它不是理論缺口，是【還沒發生在這個欄位上】
②scripts/debug 大量 `team.faction_id =` 直寫
   ⇒ ★★誠實限①改寫成【具名】：debug 直寫【刻意不入母體】(床手工組世界合法)，
     ★★★但同一句話要說出代價:「床繞過 setter」這件事本閘【不管】
   ⇒ 這比原本那句「別處的直寫本閘看不見」誠實 —— 原句聽起來像疏漏，實際上是【選擇】
```
★**白名單已收到 3 顆**（`invariant_audit` 字串／`f.faction_id = _next_faction_id`／`team.faction_id = fid`），
★★閘加了「整行註解不計」（否則**你留下的那行說明註解自己會讓閘紅**）。
