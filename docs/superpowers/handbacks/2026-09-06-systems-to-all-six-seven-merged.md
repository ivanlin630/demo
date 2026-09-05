---
from: systems
to: blueprint
status: consumed
slice: ★⑥⑦ 已 merge ＋ CRLF 範圍圈定 ＋ defer 閘首次真觸發
topic: ★★★①⑥⑦ 已進 main(四顆 commit 全在,全閘 23/23 PASS,determinism 三跑在【乾淨樹】上 PASS——run1 多的 8 行逐行確認全是工具一次性輸出,無一是世界狀態);★★②而 merge 過程出過一次【23 支全紅而 23 支閘全都是好的】:我的聯集腳本把註冊表寫成 CRLF ⇒ expect 尾帶 \r ⇒ grep 永遠不匹配;★已修在【讀取端】(runner 剝 \r),因為寫入端有很多個而讀取端只有一個;★★★③而【確認的損害只有那一處】——我逐檔量了今天 python 寫過的 14 個檔,實測 defer-gate 的 bash -c、defer-phrase-guard 腳本本體(帶 35 個 CRLF)、全部 .md【都沒受損】⇒ 我在這條線上講寬了兩次,兩次都是自己的陽性對照打掉的;★④defer 閘【第一次真的觸發】:⑥⑦ 一 merge,modulo-same-shape-4 的條件當場達成 ⇒ 紅
---

# ★★★①⑥⑦ 已 merge 進 main

```
b172f457(⑥ 拔身分閘)／c95f6b3d(⑦ 排程事件玩家無關)／9172d3b7／b7e40d59 —— ★四顆全在 main
★全閘 23/23 PASS
★★determinism 三跑【在乾淨樹上】PASS:run2=run3 逐位元相同;
   run1 多 8 行,而 diff 只有 "1,8d0" 一段 ⇒ 其餘 3974 行三跑相同
   ⇒ ★★★那 8 行【逐行確認全是工具的一次性 import 輸出,無一是世界狀態】
★而 implementer 那 2 行尾巴雜訊【在乾淨樹上再現不出來】⇒ 坐實是他那邊的環境,結案
```

# ★★②而過程出過一次值得記的紅：**23 支全紅，而 23 支閘全都是好的**
```
成因:我解註冊表衝突時用 python 取聯集,而 `pathlib.write_text()` 在 Windows 把 \n 譯成 \r\n
⇒ `expect` 尾帶 `\r` ⇒ `grep -qE` 永遠不匹配 ⇒ 23 支全部 no-verdict
★而最毒的一格:`.gitattributes` 是 eol=lf ⇒ commit 時正規化
   ⇒ 【repo 的 blob 乾淨,壞的只有工作區那一份】⇒ ★★它不會出現在任何 diff／review 裡
⇒ ★★★修在【讀取端】(runner 讀進來先剝 \r)——因為【寫入端有很多個,讀取端只有一個】
```

# ★★★③而【確認的損害只有那一處】—— 我逐檔量過
```
逐檔量今天 python 寫過的 14 個檔:6 個有 CRLF
★而【實測未受損】(一個一個試,不是推論):
   defer-gate 的 `bash -c "$met_check"`(整份 CRLF ＋ 恆真條件 ⇒ 照樣抓到)
   defer-phrase-guard 腳本【本體帶 35 個 CRLF】⇒ 陽性對照照樣抓到
   全部 .md(git 已正規化)
⇒ ★★所以我在這條線上【講寬了兩次】(先說 defer-gate 也假綠、再說 CRLF 很危險)
⇒ ★★★兩次都是【我自己的陽性對照打掉的】,不是誰來糾正我
```
★而 implementer 在同一件事上做了同樣的動作：**他手上有一個 68/68 看起來像「我這邊也中毒」，
而他回頭問那個 68 到底在數什麼，結論是【他的 grep 答錯了問題】，他的三棵樹全是乾淨 LF。**
★★**不去替上游的假說背書，比驗出正確答案更難 —— 因為背書是省事的方向。**

# ★④defer 閘**第一次真的觸發**（★而它是對的）
```
⑥⑦ 一 merge ⇒ `modulo-same-shape-4` 的解除條件(第一批 merge 進 main)【當場達成】⇒ 閘紅
⇒ ★處置照閘自己的指示:【重新裁定並更新 defer_until】,而★★【met_check 沒有改鬆】
   —— 換的是同樣可執行的事件(⑧ merge 進 main)
⇒ ★★★而理由寫在表上:那四筆是【維護性脆弱】不是違憲(兩個 step 在 near/far 分支之外),
   而 ⑧ 正在飛 —— 【不是因為麻煩所以推】
```

# 現況
```
④③⑤⑥⑦ 已 merge ｜ ⑧ 在 implementer 手上(主體已 commit,剩五件:床頭警語已做/
   驗收床分組改法/反向斷言閘已做/defers 行/perf 真跑)｜ ①墓碑 分批② 機械替換
② 徵收:等⑧後重量 baseline(總量類被量化失真污染,而污染程度隨人格不同 ⇒ 不能用係數換算)
```
