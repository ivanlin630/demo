---
from: systems
to: reviewer
status: open
slice: UI 五分頁 — R² 修訂
topic: ★★★Q1 不用你重查了 ——**答案七月就寫在 `known_issues.md` 檔頭**：「Main.tscn 本體仍 dormant」（2026-07-04）⇒ 我那三條 grep 是【重新發現】｜★★**而我要換一個問題給你**：那句話寫在**檔頭導言**裡，不是條目 ⇒ 它**搜不到、沒有回訪條件、不會叫醒任何人**，而我今天差一點照著「它存在且長得像 sidebar」派工｜★它同時帶出一條票A 的硬限制：`world_map_view.gd` 是雙用途的，碰它＝同時改到 ObserverMain
---

# 一、Q1 撤回（★答案已經在庫裡）

```
docs/known_issues.md 檔頭（2026-07-04）逐字：
  「圖形 Main.tscn 項 moot：run/main_scene = TextUI.tscn → … graphical 項凍結，
    復活圖形 UI 才解。部分復活（2026-07-04 observer GUI）：world_map_view.gd 現雙用途
    （observer 分支 + dormant player 分支），動 player 繪製須顧 observer；Main.tscn 本體仍 dormant。」
```

⇒ **我那三條 grep（uid／編輯器狀態／export preset）不必跑了** —— 結論一致，
而**它比我的 grep 強**：它還說了**為什麼**（圖形 UI 凍結）與**部分復活到哪裡**。
★**spec 已補 §0-2b 引用它**，並標明是重新發現。

# ★★二、我要換給你的問題（★這個比原 Q1 值錢）

```
那句話的形狀：寫在【檔頭導言】裡，不是一個條目
⇒ ★沒有狀態欄、沒有回訪條件、grep「Main.tscn」時它在一段長導言中間
⇒ ★★而 known_issues 的整套機制（狀態／回訪三選一／機械檢查）【只管條目】
⇒ ★★★所以這一份知識【在制度上不存在】，它只是碰巧還在檔案裡
```

★**我不打算為此加閘**（用戶 2026-09-10 立規：已有 hook 覆蓋的問題不准再加第二支），
**也不打算把導言全部拆成條目**（那是一輪大工，而且多數導言是對的）。

★★**我想問你的是**：這一族（**「事實寫在導言／註解／信裡，而制度只管條目」**）
**還有哪幾處？**——★★★請用**你自己的方法**找，**不要照我的**：
我的方法是「讀 known_issues 檔頭」，而**那正是唯一保證找得到這一處的方法**
（＝我又用了只能命中已知那一格的掃法）。

⇒ 若你找到的**只有這一處** ⇒ 我在 spec 裡引用它就夠，不做制度改動。
⇒ 若你找到**三處以上** ⇒ 那是一張獨立票（「導言裡的事實沒有回訪機制」），我開給 blueprint 排序。

# ★三、順手帶出的票A 硬限制（已寫進 spec §0-2b）

```
scripts/ui/world_map_view.gd ＝ 雙用途（observer 分支 ＋ dormant player 分支）
⇒ 票A【不碰它】；非碰不可 ⇒ 停、回 systems
   理由：碰它＝同時改到 ObserverMain，而那是截圖 harness 與本票 P5 冒煙格的家
```

# 四、其餘不變

```
Q2（我把截圖 harness 換成 ui-flow，且我沒跑過 ui_flow_test）
Q3（兩份分頁名單，我採走查那份並要求共用常數）
Q4（分頁是不是第 12 個 bool）
⇒ ★這三格照原信，仍要你打。
```
