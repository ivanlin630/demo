---
from: blueprint
to: systems
status: consumed
slice: A1 建設 —— 收量測員窮盡（0fd9d1562）：Team0／Team3 30 天每天都是「腳下沒工地」
topic: ★裁：「建設」是【綁地點的動詞】。兩個根因兩條出口：①Team3 無家（home_count=0）⇒ 建設不可選（列的條件＝做的條件），它的立業驅力要落到「紮根／建據點」那條路，不是在原地喊建設 29 天；②Team0 有 4 個據點但人不在家 ⇒ 建設這個選項必須【帶目標格】——commit 的是「回自己據點蓋」（to_task 給 target＝自己的據點格，像領取帶著市集格一樣），人到了才開工；人不在家且不願回家 ⇒ 不可選。★禁：加一行「不在家就 skip」的盲閘——那會讓 Team0 永遠不蓋；正解是讓選項自己帶路。★順帶：Team0 的 why 字串「備戰籌餉(建材枯)」在 material=80、4 個據點時仍成立＝理由句沒讀真值，一併修（C′ 同族：給人讀的句子引用的量要是當下真值）。床：佈置「有據點、人不在家、committed 建設」⇒ N tick 內 move_target＝自己據點格且抵達後 construction_team_id≠-1；佈置「無家、committed 建設」⇒ 建設不在可選清單（或帶 ineligible 原因「無據點」）。這張可以動 HOW 了（量已窮盡：30 天 Σ(i..iv) 每日對帳成功、P4 陽性對照過）。
---

# 一、事實（量測員 a1_build_never_started＋construction_funnel_bed 兩支獨立床同結論）

```
Team3：home_count=0；30 天每天 (iii) no_site；resolver.empty_no_own_outpost 100%。
Team0：home_count=4；30 天每天 (iii)；因為 TASK_BUILD 的「建設」commit 的是腳下 tile_pos 施工，而它站的格不是自己 4 個據點之一；它那 4 個據點的升級路另外卡在 wrong_outpost_type／pop_below_min（另一條路，不在這張）。
```

# 二、裁（WHAT）

```
①建設綁地點：沒有工地就沒有建設。工地＝自己據點的格（或已核准的新址）。
②選項要帶路：「建設」的 to_task 回 {task, target＝自己最近／最需要的據點格}；人不在那格 ⇒ 先走過去（與領取同款：動詞含路程）。抵達才進 TASK_BUILD 的施工態。
③無家：建設不可選；同一股立業驅力改列「紮根／建據點」（既有選項），讓 Team3 這種隊去找地方落腳，而不是原地 29 天。
④理由句讀真值：why 不得印與當下狀態矛盾的量。
⑤票 A 出口對照：這是出口 (a)「列的條件＝做的條件」加一條——條件不足時若【動詞自己能補足前提】（走過去）就帶路，不能補足（沒有家）才不列。
```

# 三、HOW 邊界

不准用「不在家就跳過」把 Team0 永久關掉；不准替 Team3 憑空生一個據點；升級既有據點那條（wrong_outpost_type／pop_below_min）是另一張，先登 defer 不混。

# 四、消費

measurer→blueprint 2026-10-06 a1-build-never-started：consumed。
