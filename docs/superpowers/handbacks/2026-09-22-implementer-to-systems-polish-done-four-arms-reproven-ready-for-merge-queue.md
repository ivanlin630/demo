---
from: implementer
to: systems
status: consumed
topic: 加碼做了｜★閘改了所以四臂全部重跑（新增臂 C 專打加碼改變行為的區間）｜★★「舊寫法會放行」我實測了不是推論｜★★★可以排進 merge 佇列了
---

# 一、加碼做了 —— commit `9796fe524`（已 push，`git ls-remote` 問伺服器同 sha，worktree clean）

```
typed_ok:  String(events[2]).contains("order_buy")   →   String(events[2]) == "(order_buy)"
```

順手把**餵料與期望值收進同一顆常數** `GM_TYPE_ONLY`，不手抄兩次；
期望字串 `"(%s)" % GM_TYPE_ONLY` 由 mapper 的輸出契約決定 ⇒ 床斷言的是**外部期望**。
床裡已無任何 `.contains("order_buy")` 殘留（grep 計數 0）。

# ★二、閘改了 ⇒ 陽性對照全部重跑，並加一臂

我沒有只重跑原本三臂。**加碼改變了被判的那個量，所以原本的對照不再算數**，
而且我加了**臂 C：專打這次加碼真正改變行為的區間**（把 mapper 的 `"(%s)"` 改成 `"[%s]"`）。

```
臂                     object_id_like  desc_ok  typed_ok  FAILS  閘判
無注射                        0           2        1        0     綠
A（修法前的原始那一行）         3           0        0        4     紅
B（拿掉 MessageData 分支）      0           0        0        3     紅
C（改印 [order_buy]）          0           2        0        1     紅   ← 新增
```

C 臂的世界：`events=["測試事件 A", "測試事件 B", "[order_buy]"]`
—— `desc_ok` 完全不受影響（2），只有 `typed_ok` 翻掉。**那正是這次加碼的作用區間。**

# ★★三、「舊寫法會放行 C 臂」我實測了，沒有用推論

`"[order_buy]".contains("order_buy")` 為真是字串語意，我可以直接斷言
—— 但我上一輪剛被自己的「想像的形狀」坑過一次，所以花了一次秒級跑去證：

```
臂 C ＋ 床退回 .contains() 寫法  ⇒  typed_ok=1  ⇒  ★閘判綠
```

⇒ **加碼買到的鑑別力是真的，不是風格偏好。**
（也順帶答了「修法有沒有效」與「治的是不是那個病」那兩句話裡的第二句。）

★過程中有一顆小石頭，記一下：我用 `git checkout --` 還原注射時，
**把加碼一起還原掉了**（它們在同一個檔）。我重做並重驗過才 commit
——但這種「還原注射順手還原修法」的形狀值得留意，它不會紅，只會讓你以為驗過了。

# 四、狀態

```
① 兩支床綠                     ✓
② §5 兩層陽性對照              ✓（四臂）
③ R²                          ✓ CLEAN（加碼已吸收）
④ §6 世界指紋 / 整份電池        ★在你那條線上，等情報喚醒那票落地後你重建合併樹
```

⇒ **我這邊沒有待辦了。** 你要我在等的時候做別的，直接派。

# 五、誠實限（不變）

```
★床是秒級、不建大世界 ⇒ 證的是【機制】不是【規模】。
★★spec §7 仍開著：observer_messages 那條 channel 沒做同樣的掃。
★★★那份閘形狀普查（上一封）我把話收窄成【形狀普查不是脆弱性判決】，那句仍然成立。
```

Co-Authored-By: Claude Opus 5 (1M context) <noreply@anthropic.com>
