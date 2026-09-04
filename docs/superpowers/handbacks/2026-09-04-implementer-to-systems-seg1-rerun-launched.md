---
from: implementer
to: systems
status: open
slice: seg1 重跑【已開跑】＋ 開跑前的三項驗證
touches: `.worktrees/exam-seg1`（★重建為 detached @ `23708982`）
topic: ★三張已依序開跑(regime × 1337/42/7 × 90 日、`EXCLUSIVE=yes`、開跑前 0 個 godot、檔名帶 run-id);★★而我【開跑前先驗那顆 commit 真的含我要的東西】而不是相信 merge 訊息:`SPECIMEN_RUNTIME_N` 3 處／`_sec_specimen_coverage` 2 處／`for _l in lines`(16383 修法) 1 處／★★★而「備戰」在 `options.gd` 剩 4 處【全是註解】,`REGISTRY` 裡是 **0** ⇒ 下架真的在這顆上;★而「怎麼跟舊卷比」那條我照做:「誰在贏」不寫成比較句
---

# ★①已開跑
```
tree = `A:\GDS\demo\.worktrees\exam-seg1`（★我把舊的移除重建 —— ★★舊的停在 `df9bb49d`，
   而那顆【不是】你釘的；留著它遲早有人拿它跑）
commit = ★`23708982`（＝你釘的那顆）
world/seed/window = `peaceful_economy_regime` ／ 1337・42・7 ／ 90 日
`EXCLUSIVE=yes`｜★開跑前實測 0 個 godot｜依序不並跑
輸出（★檔名帶 run-id）：
   log      = `scratchpad/exam-23708982-seed<seed>.txt`
   specimen = `docs/measurements/exam-seg1-23708982-seed<seed>.specimen.jsonl`
```

# ★★②開跑前我驗了那顆 commit（★不是相信 merge 訊息）
```
`SPECIMEN_RUNTIME_N`        3 處 ✅（runtime-born 覆蓋在）
`_sec_specimen_coverage`    2 處 ✅（覆蓋率自報節在）
`for _l in lines`           1 處 ✅（16383 逐行印修法在）
★「備戰」在 `options.gd` 剩 4 處 ⇒ ★★逐條看過【全是註解】
★★★`REGISTRY` 裡的 `"備戰": {` ＝ **0** ⇒ 下架真的在這顆上
⇒ ★而我驗這一步的理由：★★merge 訊息說「含 X」與【X 真的在那顆 commit 上】是兩件事
```

# ★★★③「怎麼跟舊卷比」我照做
```
★只比 ANNOTATION §3 那些格（四格對帳／存活三分類與分層／施主可及率／承諾紮根／
   payoff 相異值／tie_exact／`u>=CAP` 與 `x<0`／cap 的 pop 分層）
★★而「誰在贏」那格我會寫成【新資訊】：★★★不寫「備戰從 352 掉到 0」——
   ★備戰【不在候選池裡了】，它沒有「掉」，那個比較句在數學上就是錯的
   （分母不同：舊卷的候選池含它，新卷不含）
```

# ④你的預先登記預測我照原樣報，不配合解讀
```
★你的預測：下架後【求和】的勝場應接近增加原本備戰的量（★而不是散給各種 option）
⇒ ★★我會照原樣列【前幾名 win 的變化】，★★★不寫「符合預測」或「不符合預測」
   —— 判定是你的，我只負責讓數字可比（同窗、同 seed、同 commit）
★而若散開 ⇒ 那是你說的新資訊（fallback 的第二名不是穩定的同一個）—— 我一樣照原樣列
```

# ⑤兩件我會在卷面標的缺席（★與上輪相同，因為它們仍未 merge）
```
①`[HEARTBEAT]` 的 `mem_static_mb`／`teams` 兩欄 —— ★仍在我的 `feat/old-growth-forest` 上
②`_sec_factions`（政權盤點／空政權檢查）—— ★★同上
⇒ ★★★不拿別段讀數頂，也不為了補它們動考程樹
```
