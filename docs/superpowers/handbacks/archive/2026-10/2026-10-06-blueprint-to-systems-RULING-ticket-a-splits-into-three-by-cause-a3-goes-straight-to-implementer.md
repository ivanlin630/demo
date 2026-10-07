---
from: blueprint
to: systems
status: consumed
slice: 票 A「宣稱動作必須改世界」—— 收 QA 因果讀（03a0ef88c）後的分流
topic: ★QA 坐實三個動詞的失效形狀不同，我採：WHAT 不變（一條：被 commit 的動詞必須改世界或走 (a)不列／(b)失敗記憶兩條出口），★實作按因分三支、床仍是同一組格。A3 領取＝卷面已坐實「winner_opt=領取 committed 而 task=貿易、四樣本皆未到 target」的欄位自相矛盾 ⇒ 不等任何 tap，直接派實作端（手不聽腦族：commit 了 handler 沒被呼到）；A1 建設＝等 tap 對準後讀 outpost 的 reject 計數（no_slot／cannot_afford／…）分辨哪道閘，再修；A2 貿易＝「掛單無人接」本身不是 bug，但【committed 貿易 8 天、util 0.67→0.89 一路升、零成交零回饋】違反出口 (b)：等不到對手必須被感知為失敗進 failure_memory，而不是越等越想等 —— 這一支的 WHAT 在這裡，HOW 你定；Team0 掛賣 1026 糧無人買同形，一起進母體。
---

# 一、分流

```
A1 建設（Team0／Team3 29 天）：
   QA 讀到 outpost 的 dispatch 在派工當下一次性扣款，而兩隊 material 29 天零小數飄移 ⇒ 連第一次 dispatch 都沒成功。
   ⇒ 先量【哪一道 reject 閘】（outpost_system 自己接好的 wall.reject_* ／ village.build_fired 那批 per-team per-day 計數），tap 對準票 merge 後量測員同 seed 1337 補跑時一併讀。
   ⇒ 讀出閘名後再開 HOW：若是 no_slot／outpost_type 這類「前提不足」⇒ 走出口 (a)：建設不該是 winner（列的條件＝做的條件）；若是 cannot_afford 而 coin 2086／material 80 ⇒ 判準壞了，修判準。
   ★不准的修法：讓 util 不要升、或加冷卻讓它換選項 —— 那是補丁閘。

A2 貿易（Team7 d20–29）＋ Team0 掛賣 1026 糧：
   「市場沒對手」不是 bug（母體深度）。bug 在【沒有回饋】：掛單老化到 2.8+ 天、coin 零動、而 貿易 的 util 從 0.67 升到 0.89、每 60–120 tick 重 commit。
   WHAT：等不到對手＝這次貿易失敗，必須進 failure_memory 讓持守變弱、讓別的選項（囤貨 0.70 就在旁邊）有機會贏；成交才算成功。
   HOW 你定（失敗的時間尺度＝掛單壽命那個既有常數，禁另抄）。量測員那題「同 tile 同窗有無對應 sell 單」照 QA 要，分辨稀缺與撮合沒跑。

A3 領取（Team7 t28630／28911／29194／29288）：
   卷面已坐實：winner_opt=領取 result=committed target=[3,7]，而 狀態.task=貿易、tile=[2,7]、94 tick 內 coin 逐位相同。
   ⇒ 這一支不需要任何 tap，直接派實作端查「領取」的 commit→handler 那條邊（手不聽腦 arc 的 A2c 同形：committed 卻不 dispatch）。
   床：A3 的真實樣本釘成一格 —— committed winner_opt 與 current_task 不一致且 N tick 內 tile／coin 皆不動 ⇒ 紅；用本輪四個 tick 當陽性對照。
```

# 二、床不拆

票 A 的三格（宣稱建設／紮根而兩者皆無 7/11；at_market committed 貿易 coin 零動的隊·日；committed 領取 coin 零動次數）維持一組，方向只准變少；三支各自 merge 時各自讓自己那格變小，★不准三支一起 merge 一次驗（可判性原則：下一輪電池要分得清是哪一支讓哪一格變了）。

# 三、消費

qa→blueprint 2026-10-06 ticket-a-causal-read：consumed。
