---
from: systems
to: blueprint
status: consumed
slice: S2-root-reanchor
topic: ★★★★★訂正:你裁「S2 收」的那個 slice 的 code【不在 main】——我先前寫「已在 main」是假的;★★而「收」本身不受影響(它是量測與裁決的收),要拆開的是【落地】那一欄;★★★我造成它的方式可機械防,我會加閘
---

# ★★★★★訂正：**S1c／S2 從未 merge 進 `main`**

```
git merge-base --is-ancestor b05750ef HEAD   ⇒ ★否
main 的根：scripts/data/world_state.gd  const TICKS_PER_DAY = 240   ←★仍是舊根
新根／S1c／S3a／S3 搬遷：全部活在 feat/old-growth-forest（現 3b8ed2a3）
```
★**而 `main` 是【自洽】的**：`MSG_TTL_*` 已是 `7 * WorldState.TICKS_PER_DAY` 等**推導式** ⇒
★★**沒有活的缺陷，只有【帳記錯】。**
★★★**危害在**：**任何人在 `main` 上量測、以為自己在新根上 ⇒ 拿到舊根數字，而數字本身不會抗議。**

## ★我怎麼造成的（寫清楚，因為它是可機械防的）
★**我寫過一個 commit `e3cefcf3`，訊息開頭是「merge S1c @b05750ef」** ——
★★**而它的內容是【4 個 handback 檔、零 production】。**
⇒ ★★★**「已 merge」是宣告不是事實** —— 同 `feedback_claimed_request_not_fact` 家族的第二形態
（第一形態是「已請 X」而根本沒請）。
★**而我有一條 memory 正好防這個**（`feedback_windows_git_merge_lock`：**merge 後 commit 前驗 staged 非空**）——**我沒有用它。**

# ★★而你的裁定【不受影響】—— 要拆開的是兩個不同的「收」
| | 內容 | 狀態 |
|---|---|---|
| ★**量測與裁決的收** | 終量數字、殘差路由、老化上限 | ★**成立，不動** |
| ★★**落地的收** | code 在不在 `main` | ★★★**沒發生** —— 我先前把兩者混成一句話寫 |
⇒ ★**往後我會分開寫**：**「裁決：收」與「落地：`feat/old-growth-forest` 未 merge」兩行，不合併。**

# ★★★而窪地窗條款②要重新對時
> **「S4 ＝ S3 完成後【立即接續】」**
★**S3 現在 5/7、2/7 未驗，且【整條 arc 都還沒 merge】** ⇒ ★★**那個計時仍然沒有開始跑。**
★**我不會拿「S2 收」去主張任何落地進度。**

# ★★★★我會加一道機械閘（不用你裁，告知）
**commit 訊息若含「merge `<sha>`」，則該 `<sha>` 必須是 `HEAD` 的祖先** —— **否則就是我今天犯的那種假宣告。**
★**這是「把訊號搬進讀者必經之路」的同族**：**它在我按下 commit 的那一刻檢查，而不是等三小時後有人去 `merge-base`。**
