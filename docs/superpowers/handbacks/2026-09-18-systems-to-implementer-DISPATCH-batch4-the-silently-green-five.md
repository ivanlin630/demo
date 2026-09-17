---
from: systems
to: implementer
status: consumed
slice: 到場點名 第四批（★最高優先）
topic: ★★★**reviewer 掃出【第三種形狀】，而它是最兇的一種**：`_initialize` 與 `_run` **共用一個 `_fail` 計數** ⇒ `_run` 中途死掉時計數**停在假的 0** ⇒ 外層照印 `=== DONE === ALL PASS`、**rc 也是 0** ⇒ ★**runner 兩道防線【全部通過】＝ 靜默變綠**｜★★**前兩種形狀至少會紅**（毒值型 ⇒ FAIL／`quit(_run())` 型 ⇒ 沒橫幅）—— **這一種不會**｜★**五支**：`valuation-clamp`／`world-schedule-due`／`envoy-ptype`／`board-price`／`wage-penalty`（★**第六支 `escrow-audit` 你批三已經修掉了**）｜★★這一批**插隊到最前面**
---

# 一、形狀（reviewer 親眼核對，六支逐字相同）

```gd
var _fail: int = 0
func _initialize() -> void:
    _run()
    if _fail == 0: print("=== DONE === ALL PASS")
    else:          print("=== DONE === %d FAIL" % _fail)
func _run() -> void:
    ...（真正的斷言都在這裡面，失敗時 _fail += 1）
```
★**`_run()` 中途死掉** ⇒ 它的 frame 沒了、**`_fail` 停在死之前累積到的值**（若還沒撞到任何真 FAIL ⇒ **0**）
⇒ ★★`_initialize` **不知道 `_run` 死過**，照樣讀 `_fail == 0` 為真 ⇒ **印 `ALL PASS`**
⇒ ★★★而 `_initialize` 自己跑完、正常 return ⇒ **Godot 正常結束 ⇒ rc ＝ 0**

# 二、★★為什麼它比前兩種嚴重

```
毒值型（zhagen）      ⇒ 斷言自然紅              ★會紅
quit(_run()) 型（bed-arm）⇒ 沒有橫幅 ⇒ expect 不命中  ★會紅
★★★這一種             ⇒ 橫幅【照印】且內容是 ALL PASS、rc ＝ 0
                        ⇒ runner 的 RC 檢查過、expect 也命中 ⇒ **兩道全過**
```
★**我們之前立的那句「expect 釘的 token 要印在最後一格之後」對這一種【不夠】** ——
**因為橫幅確實印在最後，只是【它的內容是假的】。**
⇒ ★★**唯一夠用的守衛就是到場點名本身**（已把這句補進要件③）。

# 三、要做的（照要件③，五支）

```
① 先注射（死亡放在該格自己 frame 的第一行）⇒ ★預期看到「ALL PASS、rc=0」——★★那就是洞的證據
② 加到場點名 ⇒ 同一個注射 ⇒ N／M 對不上 ⇒ 紅
③ expect 同步改（★別忘了註冊表那一行，兩件分開做會紅一次）
```
★**這五支的 `_run` 可能只有一格**（像 `escrow-audit` 的 `1／1`）—— ★★**那也要加**：
**`1／1` 不是「只有一格」，是「這支床的格粒度就是 `_run`」**，而它守的正是這個洞。
★★★**若某一支注射之後【沒有】印 ALL PASS（例如它其實會紅）⇒ 照實回報，不要硬加。**

# 四、★這一批插隊的理由
**前面幾批修的是「會紅但紅得難看」的床；這一批修的是【根本不會紅】的床。**
⇒ **先修不會紅的。**
