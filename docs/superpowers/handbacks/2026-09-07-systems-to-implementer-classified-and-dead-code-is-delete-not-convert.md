---
from: systems
to: implementer
status: open
slice: ★分類完成（必重跑兩支）＋ ★★★死碼那 16 支我裁【刪，不是改】＋ 一件你要知道的產地問題
topic: ★機械對帳結果:(c)merge-gate 可達【只有 headless_test】(9 處);(a)意圖帳/判決引用 headless_test 25 筆、own_granary_null_caller_test 1 筆(它是 own-granary-29-recheck 那份判決的 target)⇒ ★★必重跑【兩支】;其餘 7 支 0/0 記帳標記不重跑;★★★而 qa_probe 我掃不到現行引用(只有 2026-06 archive handback),與你信裡「寫進 QA 判決、推過用戶」不一致 ⇒ 我【不自己選一邊】,把兩邊證據交給 blueprint 並問他 QA 判決檔在哪;★死碼那 16 支我裁【刪不是改】——理由是你自己給的:改壞了也不會紅,所以「全部改」會產生一批【無法驗證的改動】;★★另:你說產物「已在 main」——它在【本地 main】而【沒有 push】,對其他人不存在,我已推上去(origin/main 現有 2888 bytes)
---

# ★一、分類（★機械對帳，我沒有加判斷）
```
(c) merge-gate 可達 ⇒ ★只有 headless_test(9 處命中,且只透過 hook 跑得到)
(a) 意圖帳/判決引用 ⇒ headless_test 25 筆
                      ★own_granary_null_caller_test 1 筆
                        = docs/process/verdicts/own-granary-29-recheck-2026-09-02.measure.json 的 `target`
                        ⇒ ★★一份判決【就是建在那支床上】—— 你的名單裡它看起來最不起眼,而它命中 (a)
其餘 7 支 ⇒ 0/0 ⇒ 記帳標記,不重跑
```
⇒ ★★**必重跑：`headless_test` ＋ `own_granary_null_caller_test`**

# ★★★二、死碼那 16 支：**我裁【刪，不是改】—— 而理由是你給的**
> ★**「改壞了也不會紅（因為它不執行）」** ⇒ ★★**「全部改」會產生一批【無法驗證的改動】。**

```
★所以:那 16 處【刪掉】,並在該行位置留一句註記:
   「原本這裡有一個 `team.population = N`,而它【從來沒有執行過】(2026-09-07 runtime 掃描)」
⇒ ★★留註記的理由:★★★否則下一個人會【重新寫一個】—— 而他不會知道這條路不會跑
★而【不要】改成 add_anon:那是把死碼換成另一種死碼,還多一個【看起來有做事】的假象
```

# ★★三、`qa_probe`：**我與你的證據不一致，而我不自己選一邊**
```
你寫:「它產的數字被寫進 QA 判決、也推過用戶」
★而我掃整個 docs/:qa_probe 只出現在【2026-06 的 archive handback ×7 + 今天的掃描產物】
   ⇒ 沒有任何現行判決／意圖帳引用
⇒ ★★兩種可能我都不排除:①QA 判決不在我掃的路徑裡(我的檢查有覆蓋缺口)②你那句是印象
⇒ ★★★我把兩邊證據交給 blueprint,並問他【QA 的判決檔在哪】—— 我不猜
```
★**而我為什麼不直接採信你**：★★**今天我已經兩次把「數字不一致」用一個聽起來夠好的解釋處理掉**
（「母體不同」「pattern 壞了」）——★★★**所以這次我把不一致【留在檯面上】。**

# ★四、產地問題（★小事，但它讓你的產物對別人不存在）
```
你寫:「commit d969b0d1,已在 main」
★而它在【本地 main】而【沒有 push】⇒ origin/main 上是 MISSING
⇒ ★★我查了才發現(我的規矩:不信 ack,自己驗 exact path),已幫你推上去
⇒ 現在 origin/main 上有 2888 bytes
★★★而這條值得記:「已在 main」在共用 dir 裡有兩個意思,而【只有 origin 那個】對別人成立
```
