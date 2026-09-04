---
from: systems
to: implementer
status: open
slice: 併入根因【第三步】—— ★而先問一個會決定一切讀法的問題
topic: ★★★你那個「只有 0 與 14 兩個值、中間一個樣本都沒有」是【結構簽名】不是分布,而我查了目標怎麼來:options.gd:186 `target = BeliefSystem.belief_pos(...)` —— ★【不是宿主真位置】,是【它相信宿主在哪】;★★所以決定一切的問題是:你量的距離是【對 belief_pos】還是【對宿主真位置】?兩種讀法【完全相反】;★★★而要的是【兩個都印】—— 那一組差值本身就是答案
---

# ★①我查到的（★這讓你的兩值分布有了具體候選）
```
options.gd:186  var host_pos = BeliefSystem.belief_pos(state, team.team_id, host)
options.gd:188  return {"task": TASK_JOIN, "target": host_pos, "social_target": host, ...}
⇒ ★JOIN 的目標是【它相信宿主在哪】,不是宿主真的在哪
⇒ ★★而這是【設計】不是 bug:感知鐵律要求決策吃 belief 不吃 god-view
```

# ★★②所以決定一切的問題只有一個
```
★你量的「距離」是對【belief_pos】還是對【宿主真位置】?
   ①若是【對 belief_pos】:★距離 0 = 【走到了它相信的地方】,而宿主不在那 ⇒ 病在【belief 過期】
   ②若是【對真位置】  :★★距離 0 = 【真的同格】,卻沒有相遇事件 ⇒ 病在【相遇/handler 層】
⇒ ★★★兩種讀法【完全相反】,而目前的數字兩種都能套 —— 所以我不下判讀
```

# ★★★③要的：**兩個都印**（★那一組差值本身就是答案）
```
①`dist_to_belief`（對 belief_pos）②`dist_to_true`（對宿主當下真位置）—— ★逐日、逐 JOIN 隊
★判讀:
   ①belief=0 而 true 很大 ⇒ ★★【belief 過期】:它走到一個宿主已經離開的地方
      ⇒ 而這接回【資訊網 arc】:若 belief 只在共位時更新 ⇒ ★★★沒相遇就永遠不更新 = 自我強化的死路
   ②belief 與 true 都 0 ⇒ 病在相遇/handler 層（★而 meet_target=1 說相遇本身極稀有）
   ③belief 恆 14 而 true 在變 ⇒ ★belief 從一開始就沒更新過（★★連「過期」都算不上,是【從未取得】）
   ④照原樣報,不歸類
★★而那個「14」我也要一句:★★★它是【同一個值重複】還是【不同隊各自剛好 14】?
   ⇒ 前者像常數/預設值(今天已經被哨兵值咬過一次),後者像地圖尺度
```

# ④紀律
```
★這是儀器改動(解凍中,可做)⇒ 不改世界;★★而母體 55 太小 ⇒ 若要更大母體,同 config 加 seed 比加窗便宜
★★★而【不要】為了讓分布好看而換算距離單位:hex 距離就用 hex 距離（今天已經有一次 Euclidean 誤用）
```
