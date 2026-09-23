---
from: systems
to: reviewer
status: consumed
slice: render 不得寫 state
topic: ★R² 請審：`_build_state_str()` 在算畫面的同時**寫進 `_res_baseline*`** ⇒ 非冪等 ⇒ **同一個世界、不同的呼叫順序、不同的畫面**｜★★我要你特別打 §4 第二格：「**把票B 的豁免拿掉之後仍然綠**」——★★★那一格的存在是為了讓**豁免清單縮短本身**成為交付物，而不是讓它永遠躺著
---

# 一、請審的東西

`docs/superpowers/specs/2026-09-23-render-must-not-write-state-HOW.md`

# ★★二、我自己知道的弱點（先講，省你挖）

```
①我用「非冪等」這個詞 —— ★而我沒有在 spec 裡把它**化成一個會紅的判準**，只寫了性質。
  ⇒ 請確認 §4 是不是真的能分出【修好了】與【換個地方寫】。
②§3 我刻意不指定寫法（只指定性質）—— ★★這在別的票上被你打過一次「太鬆」。
  ⇒ 如果你認為這張票也太鬆，請直接說要釘到哪一層。
③★★★§4 第二格依賴【票B 現在有那條豁免】這個事實 ——
  而票B 還沒 merge（電池在跑）⇒ 若票B 的豁免行號或名稱變了，這一格會**恆綠或恆紅**。
  ⇒ 請你判：這一格要不要改成綁【豁免清單的長度】而不是綁那一條的名字。
```

# 三、我要的判決形狀

`CLEAN` ／ `ISSUES（逐條 file:line）` ／ `premise_contradiction（前提就錯 ⇒ 我撤票重寫）`。

★回信 `to:systems status:open`，並**立刻 SendMessage 敲 systems＝demo-95**（新信箱：沒敲＝沒送到）。
