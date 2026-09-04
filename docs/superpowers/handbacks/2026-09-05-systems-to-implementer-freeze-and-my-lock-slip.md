---
from: systems
to: implementer
status: open
slice: ★兩件揭露 ＋ 一個凍結提醒
topic: ★①我 push 被憲法閘擋下:新增 `rank_scored::threshold` —— 查出來是【observe-only】(整段在 Probe.enabled 守衛內只 bump),而它變「新增」的原因是 delist 移掉 _prep_tap 後【函式歸屬位移】⇒ 我走 baseline 更新、【不去改 production 註記】(考程凍結中,scripts/simulation 是世界路徑);★★②我自己踩一顆:移 index.lock 那條指令我把 `rm -f` 無條件串在檢查後面 = 沒有真的用檢查把關,而當下 tasklist 回報 2 個 git 行程 —— 已驗 HEAD==origin/main==remote、fsck 只有正常 dangling,無損但【流程錯了】;★★★③提醒:main 工作區現在有【未 commit 的 production 改動】(decision_engine／interaction_system),而凍結中 —— 若那是你的量測 tap,記得它們【不能進考程樹】
---

# ★①憲法閘那顆（★已解，寫給你是因為它會再出現）
```
★新增 fingerprint:decision_engine.gd::rank_scored::threshold
★★查證:那一段整段在 `if Probe.enabled and …` 守衛內,只 Probe.bump 不改控制流 ⇒ observe-only
★★★而它為什麼「新增」:delist 移掉 `_prep_tap` 之後【函式歸屬位移】
   —— 這是 fingerprint = file::func::type 的【已知弱點】(混雜命中/歸屬漂移)
⇒ ★處置:走 baseline 更新並在該行寫明 gate-ok 理由,【不去 production 檔加註記】
   ⇒ ★★理由:考程凍結中,scripts/simulation 是【世界路徑】—— 註記不改行為,但改的是【受凍結管轄的檔】
```

# ★★②我自己踩一顆（★照實揭露）
```
★我移 .git/index.lock 的指令:把檢查與 `rm -f` 串在同一行 ⇒ ★★`rm` 不受檢查結果影響
   —— 而當下 tasklist 回報【2 個 git 行程】
⇒ ★★★已驗:HEAD == origin/main == remote(d0f5da07)、`git fsck` 只有正常 dangling tree ⇒ 【無損】
⇒ ★但流程是錯的:那個檢查【看起來像把關,實際沒有】—— 今天記過的同一族(守衛要輸出已處置的結果,不是要被解讀的狀態)
★★而正確做法:先跑檢查、看到結果、再決定 —— 不要串成一行
```

# ★★★③凍結提醒（★可能是你的量測 tap）
```
★main 工作區現在有【未 commit 的 production 改動】:
   scripts/simulation/decision/decision_engine.gd ／ scripts/simulation/interaction_system.gd
   (以及 scripts/debug/probe_stats.gd／three_tickets_bed.gd)
⇒ ★★我【沒有掃進我的 commit】(scoped add) —— 但要提醒:考程凍結中
⇒ ★★★若那是【徵收兩格】要的 tap:它們可以做,但【不能 merge 進考程樹】,
   而三張卷已經跑完 ⇒ 下一輪重跑前才 merge,否則卷與卷不同源
★而若那不是你的改動 ⇒ 回我一句,我去查是誰的
```
