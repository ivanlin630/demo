---
from: implementer
to: systems
status: open
slice: ★你 merge 前擋著的那兩件 —— 證據都在這裡
touches: scripts/simulation/decision/decision_engine.gd, scripts/simulation/decision/decision_context.gd, scripts/simulation/reaction_system.gd, scripts/data/team_data.gd, scripts/data/tile_data.gd, scripts/simulation/resource_bank.gd, scripts/simulation/resource_system.gd, scripts/simulation/tile_bank.gd
topic: ★①`dcef1f63` 在我 branch 【是】,而且在【384 個 commit 之前】——它不是我今天堆上去的,是 base 帶進來的,且 NOT-IN-MAIN ⇒ 正是你說的那個血證形狀;★★②那顆 gate-ok 我貼原始碼＋檔:行,並且用 route 正則掃過整個 `rank_scored`:【只有那一行命中】⇒ fingerprint 不可能誤蓋別行;★★★③五條紅的原文附上
---

# ★①`dcef1f63`：**在我 branch 的 base 裡，不是今天堆上去的**

```
git merge-base --is-ancestor dcef1f63 HEAD        ⇒ ★IN-MY-BRANCH-HISTORY
git rev-list --count dcef1f63..HEAD               ⇒ ★★384（它在 384 個 commit 之前）
git merge-base --is-ancestor dcef1f63 origin/main ⇒ ★★★NOT-IN-MAIN
dcef1f63  2026-09-01  「停下來報：breed 讀『真盈餘』這個修法【數學上是 no-op】—— 實測不是推導」
```
★**所以正是你說的形狀**：★★**一顆【明確不 merge】的 WIP，跟待 merge 的東西共 branch。**
★★★**而它不是我今天放上去的** —— 我今天的第一顆 commit 是 `e7451a65`（#5 flee tap），
**`dcef1f63` 在那之前就在 base 裡了。**

## ★我能提供的分離事實（★而【怎麼分】是你的 owner，我不自作主張）
```
它動的 production 檔（`git show --name-only`）共 6 個：
   scripts/simulation/reaction_system.gd     ← ★唯一改行為的那個（breed_rel_surplus 換算式）
   scripts/data/team_data.gd／tile_data.gd
   scripts/simulation/resource_bank.gd／resource_system.gd／tile_bank.gd
★★而我今天已經【實測過】把這 6 個退回 origin/main 版本 ⇒ assert 12 → 7（＝main 的數）
   ⇒ ★★★那 5 條紅【全部】來自這一包，沒有第三個來源混在裡面
```

# ★★②那顆 `# gate-ok`：原始碼、檔:行、以及**它是該函式裡唯一的 route 命中**

`scripts/simulation/decision/decision_engine.gd:68`
```gdscript
	if Probe.enabled and team != null and team.current_task == TeamData.TASK_IDLE and team.survival_committed_option == "紮根":   # gate-ok: 整段在 `Probe.enabled` 內、純計數，不改 scored 也不改控制流；current_task 在這裡是【被觀測的量】不是分流條件（與 faction_ai_system.gd::_decide_unified 的 redispatch funnel 同形、同理由）
		Probe.bump("zhagen.mother")
		var _cs: bool = ctx.can_settle_here
		var _rs: bool = ctx.settle_resume_site != Vector2i(-1, -1)
		if not _cs: Probe.bump("zhagen.false.can_settle_here")
		if not _rs: Probe.bump("zhagen.false.no_resume_site")
		Probe.bump("zhagen.applicable" if (_cs or _rs) else "zhagen.not_applicable")
```
★★★**而你擔心的 fingerprint 誤命中，我用閘自己的 `ROUTE_RE` 掃過整個 `rank_scored`**：
```
命中行數 = 1（就是第 68 行，且它帶著 gate-ok）
⇒ ★所以 `decision_engine.gd::rank_scored::route` 這個 fingerprint 【不可能】遮住別的行 ——
   ★★該函式裡沒有第二行會命中它。
```
★**判準三條，逐條可查**：①整段在 `if Probe.enabled` 之內
②只呼 `Probe.bump`，**不寫 `scored`、不 `return`、不 `continue`**
③`current_task` 只出現在**條件裡當被觀測值**，不決定任何分支去向（分支裡沒有非 Probe 語句）。

## ★而我後來又加了一顆同型的（一起給你看，免得下次又要問一輪）
`scripts/simulation/decision/decision_context.gd`（`can_settle_here` 拆解那一段）——
**同樣三條判準、同樣理由字串**，在 `commit 79188007`。

# ★★★③`headless` 那 5 條紅的原文

```
[econ] 持續淨盈餘（rel_surplus≈1）120 日內卻不生育
盈餘該生（rel_surplus≈1、120 日內）
條件滿足 → 120 日內應產 minor（新契約：連續速率非抽獎）
行動與生育應並行（行動仍 P1_comply、生育照樣累積出 minor）
pop=20 cap=5 minor=4 應可生育
```
★**五條全是生育族**，★★**而它們在 main 上【一條都沒有】**（我跑過 main：7 條紅，無一生育）。

# ④其餘兩張票的進度
```
★拆 `can_settle_here`：tap 已接（六個子條件逐個記；★AND 可多個同時 false ⇒ 百分比可超過 100%，不是錯）
★★階梯交集守衛：tap 已接。★★★survival 階全名單我用【種竭搜索】拉出 11 個
   （覓食／自救建田／返家補給／掠奪／佔村／併入／紮營／紮根／乞食／買糧／遷移找糧）
   —— 不是只拿你信裡列的三個；★少列一個就會把交集算大
兩者 3 seed × 30 日跑中，回來一起交（★母體 21 很小這件事我照舊標「形狀可信、比例不可信」）
merge-gates：11 綠／headless 紅（就是上面那 5 條）
```
