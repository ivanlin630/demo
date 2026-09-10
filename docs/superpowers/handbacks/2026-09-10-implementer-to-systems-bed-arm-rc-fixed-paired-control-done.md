---
from: implementer
to: systems
status: open
slice: bed-arm exit code
topic: ★交件 **21543f7c9**（落點 main）：`quit(_run())`，_run() 回 int ⇒ **FAIL 路徑 rc=1、輸出不變**｜★★成對對照兩格都跑了：白名單加一張 ⇒ 26→25 且 **rc 仍 1**；全部加進去 ⇒ **PASS 且 rc=0** ⇒ rc 真的跟著判準走｜★★★而白名單**已還原**（git diff 乾淨）—— 那 25/26 張是床層債，本票不修
---

# ① 修法照你的字：修的是【誰決定 exit code】

```
★不是在 FAIL 路徑加 return（那只修一條路）——
  ★★而是把決定權收回 _run()：`func _initialize(): quit(_run())`
  ⇒ ★★★下一個人新增第四條退出路徑時，他【必須】回傳一個碼，沒得忘。
★三條路徑：PASS 0／FAIL 1／★不可判 3（拿不到 tracked 清單）—— 3 沒有被併成 1。
```

# ② 驗收三格

```
①FAIL 路徑：rc ＝ **1**；輸出仍印「★FAIL：26 張床…」（★數字沒有被藏起來）
②成對對照：
   白名單 ＋1 張 ⇒ 「25 張床」且 rc ＝ **1**（★數字跟著動、判準沒變）
   白名單 ＋全部 ⇒ 「PASS」且 rc ＝ **0**（★★rc 真的跟著判準走，不是寫死）
   ⇒ ★★★驗完還原：`git diff --quiet docs/process/bed-arm-whitelist.txt` 乾淨
③:144 的 quit(3) 那條路改成 `return 3` 並在旁邊註明「別在重構時併成 1」
```

# ③ 一句我要記的（★這是今天第三次同一族）

```
「工具的失敗與它的發現走同一個出口」今天出現三次：
  ①ratchet 自檢：CP950 UnicodeEncodeError 吐 traceback，rc=1 與【有發現】同碼
  ②merge-gates runner：expect 以 `-` 開頭被 grep 當選項 ⇒ 閘印了 ✅ 卻判 no-verdict
  ③★本次：床印了 ★FAIL 而 exit code 被自己的呼叫端蓋成 0
⇒ ★★三次的共同形狀：**輸出說一件事，回傳碼說另一件事，而消費者只讀其中一個。**
⇒ ★★★而三次的修法都不是「小心點」，是【讓兩者同源】：
   由同一個判斷同時決定輸出與回傳碼。
```
