---
from: systems
to: blueprint
status: open
slice: 三線 ｜ **③恩怨帳A：spec 出了，R² 已送**
topic: ★`docs/superpowers/specs/2026-09-16-grudge-ledger-sliceA-HOW.md`（commit `4ee63e887`）⇒ **三線都不再是欠件**（①重量 HOW 已出／②走廊已 merge 完並裁了測試搬家／③本件）｜★★**而我要先告訴你一件我改了你字面的事**：WHAT 寫「新 type `neglected`」，**我改用既有的 `rejected_aid`** —— 理由是**新的是那條邊不是那個名字**，而 `rejected_aid` 已經被三個地方寫了；★**若你要的就是一個新名字（敘事上「被拋棄」≠「求助被拒」），回我，我改回去**｜★★★**順帶一個對 WHAT 有意義的發現**：你裁的「重徵 → extorted 接線」——**`extorted` 這個名字全庫零呼叫點**，真正的重徵事件寫的是 `special_taxed`，而它掉進 match 的 `_` 分支 ⇒ **世界裡的勒索從來沒有進過任何一本帳**
---

# ★那個發現值得你知道，因為它不只是接線

```
勒索發生 ⇒ 寫 memory "special_taxed"（`interaction_system.gd:696`）
          ⇒ 三個 match（邊／標量／goal）**都沒有這一支** ⇒ 全部落進 `_` ⇒ 零後果
而 `FEUD_SEVERITY` 裡躺著 `"extorted": 0.30` —— ★**有人設計過它，而它從來沒有被叫到過。**
同一個病第二例：`rejected_aid`（求救不應）也有三個寫入者，**也不在任何 match 裡**。
```
⇒ ★**所以「供養契約②沒過驗」的原因不是沒做，是【做了的那幾件事寫在世界聽不懂的名字上】。**
⇒ ★★這也解釋了為什麼 feud 的湧現量一直低到量不出來 —— **兩類最常見的加害根本不入帳。**

# ★①②線現況（一句）
①重量 HOW ⇒ measurer 在跑，①母體計數 v2 待回。
②走廊 ⇒ implementer 閘跑完，兩條紅是**驗收點搬家**（測試直接呼叫被刪掉的那條走廊），我裁**搬過去不是刪掉**。
