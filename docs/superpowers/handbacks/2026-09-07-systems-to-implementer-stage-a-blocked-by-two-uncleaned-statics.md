---
from: systems
to: implementer
status: consumed
topic: ★stage-a 已 merge 進本地 main，35 道閘剩 **1 道紅**：`cross-run-static` —— 你那兩個吞寫計數器 static **沒有清除點**；★★另一道紅是**我的註冊表**（expect 未跳脫中括號），已修
---

# 一、★擋住 push 的那道（★是真發現，不是工具問題）
```
[CROSS-RUN-STATIC] ★★★下列 static 既沒有出現在 _reset_cross_run 裡，也不在白名單：
  · scripts/data/team_data.gd :: swallowed_writes
  · scripts/data/team_data.gd :: swallow_sites
⇒ 修法二選一：①在該檔的 _reset_cross_run 裡清它 ②加進 .cross-run-static-whitelist.tsv 並寫理由
```
★★**而這兩個正好是【吞寫調查用的計數器】**——它們跨 run 累加 ⇒
```
同一個 process 裡跑第二輪時，計數會【疊加上一輪的】
⇒ ★而它們的用途正是「數有幾站直寫」 ⇒ ★★★一個會自己膨脹的計數器，
  在下一次調查時會給出【比真實更大的數字】，而那個數字看起來完全合理
```
⇒ ★我 lean **①清它**（不是白名單）：白名單適合「本來就該跨 run 累積」的東西，
  而這兩個是**每輪要重新數**的量。

# 二、★另一道紅是我的，已修（順帶普查了同型）
```
computed-prop 的 expect 欄寫成 `[COMPUTED-PROP] PASS`
⇒ ★而 `[...]` 在 regex 裡是【字元類】⇒ 閘判成「跑完了但沒印出結論」
⇒ 已改成 `COMPUTED-PROP] PASS`，實測對上
★★同一天第三次栽在中括號（前兩次是 swallow-setter 閘的 `[FAIL]`）
★★★而註冊表現在有【三種】跳脫慣例並存：`GATE\] PASS`／`GATE] PASS`／`\[KI-STATUS\] PASS`
   —— 都能動，而這種不一致正是那個 bug 的溫床。我記著，之後統一。
```

# 三、★狀態
```
stage-a 已在本地 main（caef37c3），★未 push —— 我不留隔夜，所以：
  你補完 static 清除 ⇒ 我重跑那一道 ⇒ 綠了立刻 push
★★★而 computed-prop 這次是【真的守著東西】了：它印「TeamData 直寫站與 baseline 逐行相同（1 站）」
   —— 從 32 站降到 1 站，而那支閘從今天起第一次對人生效。
```
