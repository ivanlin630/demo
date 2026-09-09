---
from: systems
to: implementer
status: open
slice: fp 的「本尺排除：…」由 code 導出 —— ★DISPATCH
topic: ★派工：`specs/2026-09-10-fp-excludes-must-be-derived-HOW.md`（R² 判 CLEAN）｜★★而 R² 把我原本的措辭訂正了，這件事會影響你怎麼做：我寫「退而求其次」，★★★而他判【①在此架構下不可行（compute() 全檔零反射，逐欄手選是編輯判斷）／②不是退路，是頂層欄位這個粒度的【完整解】】——因為②信任的是【整份原始碼的文字搜尋】，不是 EXCLUDES 字串
---

# ① 派工

```
spec  docs/superpowers/specs/2026-09-10-fp-excludes-must-be-derived-HOW.md（★措辭已依 R² 訂正）
R²    ★CLEAN，直接 dispatch
```

# ② ★★做法（★別照我原本那個「退而求其次」的心情做）

```
母體 ＝ WorldState 的全部 var 欄位（★get_property_list 抽，不手抄）
判準 ＝ 該欄位名【有沒有出現在 state_fingerprint.gd 的原始碼任何地方】
        （進 _emit_* ＝ 被算進去；出現在 EXCLUDES ＝ 被明示排除）
  ⇒ ★兩者皆無 ⇒ 具名紅：「WorldState.<欄位> 既不在 fp 裡、也沒被宣告排除」
★★它【不是】在信任 EXCLUDES 字串 —— 信任的是【整份原始碼的文字搜尋】，
   EXCLUDES 只是其中一個可能被找到的位置。
★★★blind_note() 印的那一行改由【母體 − 有出現的】算出來 ⇒ 它從此是【導出值】。
```

★**R² 給的那個「為什麼①不可行」的理由，你動手前先讀一次**：

```
compute()（:23 起）呼叫 6 支手寫的 _emit_*，每一支【逐欄手選】
（例：_emit_world:143 直接寫 state.world.current_tick／state.in_transit_letters…）
⇒ 全檔【沒有任何一層用反射】——而「這個物件的哪些欄位算進 canon」本身就是【編輯判斷】。
⇒ ★要做到①等於把 compute() 重寫成反射驅動 ＝ 換掉 hash 的計算方式
  ⇒ ★★那是範圍擴張，**不要順手做**。
```

# ③ 驗收（★三格是成對的，別只做會紅那半）

```
①`player_pending_targets` 必須在第一版就被抓到（★它是本票的觸發樣本）
②★成對對照：在 WorldState 加一個假欄位（不進 fp、不進 EXCLUDES）⇒ 必須具名紅；移除後回綠
③★★不得亂紅：一個【真的在 fp 裡】的欄位（例如 `teams`）不得出現在排除清單裡
④★★★fp 值本身【必須完全相同】—— 本票只改自我描述、不改 hash 內容
   （R² 特別要求不鬆這條：★它的價值正是逼出「順手動到走訪順序」這種隱藏改動要單獨拿出來談，
     不能夾帶在一張「只改自我描述」的票裡）
⑤所有印 blind_note() 的地方（★grep 逐一列）輸出都跟著變 —— 單一來源的意義就在這裡
```

# ④ 不做

```
①★不擴大 fp 的涵蓋範圍（不把 player_* 加進 hash）——那是 blueprint 的裁定
②不改 EphemeralStateHash
③★★本票只保證【那一行說的是真的】，不保證【排除的東西不重要】
④★★★它檢不到【子層級】（例如 _emit_teams 漏掉 TeamData 某個新欄位）——
   那是另一個問題，★交件時請把這一句寫進誠實限，不要讓下一個人以為 fp 全檢過了
```
