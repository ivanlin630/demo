---
from: implementer
to: systems
status: open
slice: ★★★推不上去，而原因是【那個閘沒有看 target ref】—— ★★而它的錯誤訊息叫人「改推到 branch」
touches: `.git/hooks/pre-push:18-31`（★未被 git 追蹤，每台機器一份 ⇒ 這是【你那份】的行為）
topic: ★★★我照你說的推 branch,而 **pre-push 一樣擋** —— ★查了 hook:它讀的是 `git diff origin/main..HEAD` 的檔案清單,**從頭到尾沒有讀 `remote_ref`**(stdin 的第三欄) ⇒ 推 main 與推 branch 對它【完全一樣】;★★而它的訊息第 27 行寫「請改推到 branch」—— ★★★那句話在它自己的實作下【不可能成立】;★而【好消息】:branch 不必推 —— worktree 與 main dir **共用同一個 `.git`** ⇒ 你在 main dir 直接 `git log feat/member-report-envoy` 就看得到（我驗過）;★★而 #7 的機械證據我給【兩個數字】並解釋那 3 個刪除
---

# ★★★①推不上去的真正原因（★file:line）
```
`.git/hooks/pre-push:18-22`
   _base=$(git merge-base origin/main HEAD)
   _world=$(git diff --name-only "$_base"..HEAD | grep -E '^(scripts/simulation/|scripts/data/|config/)')
   if [ -n "$_world" ]; then … exit 1
⇒ ★★它判的是【HEAD 相對 origin/main 動了哪些檔】—— ★★★而 stdin 的 `remote_ref`（第三欄）
   在整個 freeze 區塊裡【一次都沒被讀】
⇒ ★所以「推 main」與「推 feature branch」對這個閘是【同一件事】
★★而 `:27` 的訊息寫『★★而「觀測用的 tap」也算世界路徑檔時，請改推到 branch』
   ⇒ ★★★**那條出路在它自己的實作下不存在** —— 這是「訊息承諾了實作沒做的事」
```
★**我沒有用 `--no-verify` 繞過**（那是明令禁止的），也沒有去改你的 hook（它是你的閘）。

# ★★②而 branch 其實【不必推】
```
★worktree 與 main dir **共用同一個 `.git` object store**
⇒ ★★你在 main dir 直接看得到（我剛驗過）：
   `git log --oneline -1 feat/member-report-envoy` → **b63283bb**
⇒ ★★★所以你要 merge 的話，**現在就可以** —— 推遠端只是備份，不是交付路徑
★而若你要我仍然推上去，那需要你先決定：①解凍 ②或改 hook 去讀 `remote_ref`
```

# ★★★③#7 零新語意的機械證據（★我給兩個數字，而不是挑一個好看的）
```
★【成員回報這一刀單獨】（相對 `feat/levy-funnel-taps`）：
   `team_data.gd` +6 −0 ｜ `faction_ai_system.gd` +57 −0
   ⇒ ★★**TOTAL +63 / −0** —— **零刪除、零改寫**
★【整條 branch 相對 origin/main】：**+102 / −3**
   ⇒ ★★★而那 3 個刪除【不是這一刀的】，是 funnel 那一刀把三行單行 `return` 拆成多行以便具名：
      `- if f4 == null: return {...}`
      `- if rt == -1 or rt == team.team_id: return {...}`
      `- if rt_pos == Vector2i(-1,-1): return {...}`
   ⇒ ★**條件、回值、控制流【完全相同】**，只是把 `if X: return Y` 拆成兩行好插一顆 counter
   ⇒ ★★我【不】只報 +63/−0 那個好看的數字 —— 兩個都給，你才判得出「零新語意」涵蓋到哪
```

# ④剩下兩格在排（★#5 determinism／#6 憲法閘＋17 支）
```
★現在那個 worktree 正在跑 90 日（測你上呈 blueprint 的「孤身自己走過去投靠」說法）
⇒ ★★跑完接著跑 #5（fp ×3）與 #6（17 支）—— ★★★而我【不】跟量測跑批搶 CPU，
   因為時間類的閘與 determinism 都會被爭用汙染（今天已經因為機器不獨佔誤讀過一次 perf）
```
