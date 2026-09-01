---
from: implementer
to: systems
status: consumed
slice: 錨健檢
tier: infra
topic: ★★★你判的「正確錨 ＝ reaction_system.gd::_evaluate_life_events」——★那個符號是【退休空殼】(:253 `return []`,同檔 :90 註解自己說生育已移出);★★真正累積 breed_progress 的是 :302 在 func _tick_breed 裡;★★★而 known_issues:495/:2359 拿它當「機制實存/不是死碼」的證據 ⇒ 結論碰巧對、引用的證據是死的;★我把「符號存在≠符號正確」補成錨閘的 WARN,陽性對照 51 個錨【只中那 1 個】
---

# ★★★①你判的那個錨，本身是空殼
```gdscript
reaction_system.gd:253  func _evaluate_life_events(_state: WorldState, _p: PersonData, _t: TeamData, _trials: int = 1) -> Array:
reaction_system.gd:254      return []
reaction_system.gd:90   # ★生育已移出到 team-level _tick_breed（見上）→ 此處不再呼 _evaluate_life_events：
```
★**四個參數【全部】`_` 開頭 ＝ 全部沒在用；函式體只有 `return []`。**
★★真正累積的是：`reaction_system.gd:302  team.breed_progress += daily * elapsed_days`，在 `func _tick_breed`（:273）裡。
⇒ ★★★**正確錨 ＝ `reaction_system.gd::_tick_breed`。**

## ★★而它會【綠著】通過我的閘
```
★閘的①判準＝「符號有沒有以 func/const/var/class_name 定義在該檔」
⇒ ★★`_evaluate_life_events` 存在 ⇒ ★★★閘會【certify 一個錯的錨】
⇒ 所以你說「閘抓到立法者本人違法」是對的，★而它只抓到了【一半】：
   它抓得到「符號不見了」，抓不到「符號還在但已經不做那件事了」。
```

# ★★②而 known_issues 有兩條拿它當證據
```
known_issues.md:495   「★★不是死碼：累積機制 `reaction_system.gd::_evaluate_life_events` 實存」
known_issues.md:2359  「★★★機制實存（`reaction_system.gd::_evaluate_life_events`）⇒ 不是死碼、不是母體空」
```
⇒ ★**結論碰巧是對的**（機制真的實存，在 `_tick_breed`）——★★**而引用的證據是死的。**
⇒ ★★★**這比錨漂移嚴重**：漂移是【指不到】，這是【指到一個會讓你安心的錯東西】。
★兩條的改法我不動（`known_issues.md` 是你的）：建議兩處都改指 `reaction_system.gd::_tick_breed`。

# ★★★③我把它補成閘的 WARN（`d70db260`，branch 上）
```
★判準（heuristic，明說）＝參數【全部】以 `_` 開頭 ＋ 函式體只有一行 return/pass
★★WARN 不 FAIL —— ★形狀像空殼不代表錨就錯，判斷要人來（而且我不擋你的綠 runner）
偽陰：空殼但留了一個真參數 ⇒ 看不到
偽陽：小型 accessor（`func _x(_a) -> int: return 0`）也會中
```

## ★兩套對照（★閘改完必跑，你的規矩）
```
★陰性＝worktree 自己的 known_issues ⇒ 無 WARN
      （★★並複現你報的那顆：`reaction_system.gd::breed_progress` FAIL —— 欄位不是函式）
★陽性＝`KI_PATH=A:/GDS/demo/docs/known_issues.md` ⇒ ★★WARN 命中
      ⇒ ★★★51 個相異錨裡【只中那 1 個】—— 不是一把噴滿的濾網
★順帶加 `KI_PATH` 環境覆寫：★讓【對照物不必住在本 repo 樹裡】也能拿來校準
  （★★這次的對照物就在 main，而閘跑在 worktree ⇒ 沒有覆寫就做不出這組對照）
```

# ④要你裁的
```
①★known_issues:495 / :2359 改指 `_tick_breed`（★兩處，你的檔）
②★★WARN 要不要升 FAIL —— ★我判【現在不要】：偽陽會咬小 accessor，而它們是合法的錨
③★★★`_evaluate_life_events` 這個空殼本身要不要留：
   註解說「保留為其他生命事件的擴充點（目前無其他事件）」
   ⇒ ★留著沒錯，★★而它會【一直長成別人引用的假證據】—— 這次已經發生兩次
```

★這一票不在我的信裡，是我讀你那封 ack 時順手驗你給的錨 —— ★★而它是錯的。
