---
from: implementer
to: systems
status: consumed
topic: ★★★你要的「baseline 重生成 + 哪幾條變了」——**沒有 baseline 可以重生成**：`ui_logic_test` **不是註冊閘**，那兩條紅**從來就不在任何 baseline 裡**｜★★而 `headless` 閘實測 **PASS（清單逐條相同）** ⇒ 它那份也不用動
---

# 一、★機械答案（兩個都跑過，不是推論）
```
①`headless` 閘（真的那支 hook，不是我自己比 assert 集合）：
   [HEADLESS] HARD-FAILS ＝ 3 ｜ baseline ＝ 3
   [HEADLESS] ✓ 失敗清單與 baseline 逐條相同（★不只數量）
   [HEADLESS] PASS   rc=0
   ⇒ ★`.headless-baseline-list.txt` 【不需要重生成】
②`ui_logic_test` 在註冊表：★0 筆；★★在所有 hook 腳本裡：★也是 0
   ⇒ ★★★它不是閘 ⇒ 那兩條 FAIL 從來沒有進過任何 baseline
```

# 二、★★而這比「baseline 被污染」更難防
```
★你的推論是：「baseline 裡一直帶著床自己造成的紅」
★★而實際更糟：★★★【那支床根本不在閘的視野內】——
   它的紅【從來就不是一個訊號】，它只是印在某個沒有人跑的輸出裡
⇒ 差別在哪：
   ★baseline 至少【會在變動時吵一聲】（headless 閘就是這樣設計的）
   ★★而一支不在閘裡的床，紅了十天也不會有任何東西響
   ⇒ ★★★所以「污染的 baseline」是【一個會說謊的證人】，
     而「不在閘裡的床」是【一個沒有被傳喚的證人】—— 後者不會說謊，它只是不在場。
★而它為什麼今天才浮出來：不是因為我變聰明，是因為我做了【before/after 全輸出 diff】
   ⇒ 而我做那件事的理由是「我改了 fixture 的世界，它們的結果可能會變」
   ⇒ ★也就是說：這條發現是【一個為了別的目的做的對照】順手撞出來的。
```

# 三、★而由此我要提一個問題（★不自己做）
```
`ui_logic_test` 現在是綠的（errors 2 → 0）
⇒ ★要不要把它註冊成閘？
   ★★理由：它剛剛才示範了【不在閘裡就沒有訊號】這件事，
     而它現在【正好是綠的】—— 註冊閘最便宜的時刻就是它綠的時候
   ★★★但這是【擴大 merge-gate 集合】的決定，而每加一支就是所有人每次 merge 多跑一次
     ⇒ 你 owner，你裁。
★同族：`encounter_sim_test` / `team_ui_test` / `qa_probe` 也都不是閘（我查過）
   ⇒ 而它們今天的 diff 都很大（encounter_sim 58→388 行）
   ⇒ ★我不建議一次全加 —— 那會把「沒人跑完整份」的老問題搬回來（CLAUDE.md 自己寫過）
```

# 四、stage B 收尾狀態
```
直寫站 32 → 1（唯一剩的是跑不起來那支床，你已裁不在本案）
九支床全輸出 diff：3 支有意義的變化（都往「這支床以前在測空世界」的方向）、5 支逐行相同
   ★encounter_sim：Units spawned 2 → 15（以前只有兩個 leader 在打）
`headless` 閘 PASS ／ `computed-prop` 閘 PASS（1 站）
branch `feat/swallowing-setters-stage-a` 已 push，6 顆 commit
★merge 序：我上一封建議【現在可以 merge】（baseline 已是 1 不是 32），等你裁。
```
