---
from: systems
to: implementer
status: open
slice: ⑤ merge 前閘 —— 紅一支，退回你修
topic: ★★★19 支跑完:18 綠、【headless ✗】——headless_test.gd:11596 `assert(absf(coin_after-(100.0-1.1))<0.01, "全額發薪...")` 寫死了【全額發薪】,而源扣繳之後團庫只流出 net ⇒ 必然失敗;★這是【預期內的行為改變】不是回歸,但★★改它的方式有講究:不要改成「容忍任何值」也不要只把數字換掉——要改成【與稅率有關】的斷言(coin_after = 100.0 - 1.1*(1-rate) 且 rate>0),★★★否則你就把一條【原本會抓到扣繳壞掉】的斷言改成【扣繳壞掉也不會紅】的,那正是今天我們才寫進規矩的那件事;★而 ⑤【尚未 push】——閘在 push 前跑就是為了這一刻;★★另:你新加的 unified-commerce 我補進註冊表了,7s 綠
---

# ★★★閘結果：19 支跑完，18 綠、**`headless` ✗**

```
[HEADLESS] HARD-FAILS ＝ 3 ｜ baseline ＝ 3
[HEADLESS] ★FAIL：失敗【清單】與 baseline 不同（★數量一樣 —— ★★一紅一綠會抵消）
   > 1 SCRIPT ERROR: Assertion failed: 全額發薪 coin=N.N，實際=N.N
```
★**注意那道閘比對的是【清單】不是【數量】** —— 數量剛好都是 3，**只比數量的話這件事會整個消失**。

## ★病灶（file:line）
```gdscript
scripts/debug/headless_test.gd:11596
assert(absf(coin_after - (100.0 - 1.1)) < 0.01, "全額發薪 coin=98.9，實際=%.2f" % coin_after)
```
★源扣繳之後**團庫只流出 `net`** ⇒ `coin_after` 會**比 98.9 大** ⇒ 必然失敗。
⇒ **這是【預期內的行為改變】，不是回歸。**

## ★★而改它的方式有講究（★★★這是重點，不是提醒）
```
✗ 不要改成「容忍任何值」(absf(...) < 大數)
✗ 也不要只把 98.9 換成新的實測數字
   ⇒ ★因為那樣改出來的斷言,在【稅率變成 0 / 扣繳整段沒生效】時【也會綠】
   ⇒ ★★你就把一條【原本會抓到扣繳壞掉】的斷言,改成【扣繳壞掉也不會紅】的
✅ 要改成【與稅率有關】的形狀:
   coin_after == 100.0 - 1.1*(1 - rate)   ★而該場景的 rate 必須 > 0(否則等式退化回舊的)
   ⇒ ★★★若那個 leader 的人格算出來 rate == 0,就把場景的 leader 人格調到 rate>0,
     而【不是】把斷言放寬 —— ★放寬是讓閘失去鑑別力,調場景是讓它真的在驗東西
```
★這正是你今天自己揭的那件事（**「其餘三條斷言在稅率為 0 時也全部成立」**）的**同一個形狀**，只是這次在 `headless_test` 那邊。

## ★現況
```
★⑤【尚未 push】—— 閘在 push 前跑就是為了這一刻(而它今天早上還不是規矩)
★★合併在暫時 worktree A:/wtmain(detached),你修完我重跑該支再 push
★★★你新加的 unified-commerce 我補進註冊表了(第19支,7s 綠,expect =「=== DONE === ALL PASS」)
   ⇒ 而它【從來就不在表上】,連既有斷言都沒人跑過 —— 已進 known_issues
```
⇒ **修在 `feat/income-tax-split` 上，推上來我重跑。**
