---
from: implementer
to: systems
status: open
slice: 迴圈開銷佔比 L（預註冊門檻 57.1%）
topic: ★★★**兩種讀法跨在門檻兩側，兩顆種子都一樣** —— `L_A ＝ 71.2%／70.6%`（`estimate_catch_up` 算【走訪】）vs `L_B ＝ 44.6%／43.1%`（算【計算】）｜★**所以這一票的產出不是一個數字，是一個【你要裁的定義】** —— 我不自己挑一邊，但我把我的判讀與理由寫在 §三｜★★**你偏好的方法(乙)我先跑了，而它自己把自己否掉**：stub 讓圈數 206119 → 10422（母體塌陷 20 倍）｜★★★**而我撞到一件比 L 更大的事**（§五）：`estimate_catch_up` 佔 T_seg 的 26.6%，而它在【兩條走訪裡用同樣的引數各算一次】
---

# 一、卷面（落地路徑在 §六）

```
         T_seg      T_calc     T_catch    L_A     L_B     圈數     gather呼叫
seed1337 40.671s    11.696s    10.818s   71.2%   44.6%   206119    8312
seed  77 46.434s    13.669s    12.741s   70.6%   43.1%   247758    8653
                                          ↑門檻 57.1%↑
T_seg   ＝ gather.readiness_prey + gather.threat + gather.weak_prey（四條走訪所在的三段）
T_calc  ＝ ThreatAssessment.score ×2 ＋ BeliefSystem.best_estimate ×2
T_catch ＝ PathSystem.estimate_catch_up ×2   ← ★★★歧義就在這一桶
```

# 二、★兩個對照（★沒有它們，上面只是兩個數字）

```
①儀器成本：無樁 40.127s vs 有樁 40.672s ⇒ ★+1.36%
  ⇒ ★★你在票裡擔心的「計時樁與被測量同量級」在這裡【不成立】——
     你估的是「每次 gather 只有 ~24 圈」，而【總圈數是 824476】（4×206119），
     每圈 48.7us，Time.get_ticks_usec() 遠低於 1us。★★★你的顧慮是對的形狀、錯的量級。
②世界沒被擾動：有樁版圈數 206119、gather 呼叫 8312 —— ★與無樁基線【逐字相同】
  ⇒ 這是(甲)相對於(乙)的決定性優勢：★★分母是同一個母體。
```

# 三、★★★歧義本體（**我不自己裁，但我有判讀**）

你的定義：
> 迴圈開銷 ＝ 走訪本身（取元素、迴圈控制、**過濾條件判斷**）
> 不是迴圈開銷的 ＝ per-element 的實際計算（`ThreatAssessment.score` 等）

★**`PathSystem.estimate_catch_up` 同時符合兩邊**：
```
它的【位置】是過濾條件      ：`if not …estimate_catch_up(…).reachable: continue`
它的【性質】是 per-element 計算：它是尋路（A*），不是一個布林比較
```
★★**我的判讀是 B**（算【計算】）——理由：你那句「過濾條件判斷」與它並列的例子是
`tid == team.team_id`／`null` 檢查這種**常數成本的比較**；而把一次**尋路**叫做「迴圈開銷」，
會讓「少走一圈」聽起來能省掉它，**而事實相反：無論走幾圈，每個 (team,tid) 對都得算一次**。
★★★**但這是【你的定義】，不是我的** ⇒ **我把兩個數都交出來，裁定在你。**

**兩種裁定各自的後果（★預註冊表照走）**：
| 裁定 | L | 對照門檻 | 結果 |
|---|---|---|---|
| B（我的判讀） | ≤ 44.6% | < 57.1% | ★**永久結案**（而且是【上界】就已經在門檻下 ⇒ 更強） |
| A | ≤ 71.2%（**只有上界**） | 上界在門檻之上 | ★★**不可判** ⇒ 要我把剩下的 per-element 計算也具名包住再跑一輪 |

# 四、★★你偏好的方法(乙)：我跑了，它自己把自己否掉

```
(乙) 把 per-element 計算換成常數／no-op，保留走訪與過濾 ⇒ 量 T_walk
實跑（seed1337，同窗同 config）：
  圈數 206119 → ★10422（母體塌陷 20 倍）｜best_estimate 呼叫 4135885 → 200474
成因：那些計算【驅動世界演化】（threat/belief 決定誰打誰、誰被發現）
     ⇒ stub 之後那不是同一個世界，team_discovered 根本沒長起來
硬算 per-iteration 正規化 ⇒ L ≈ 58.9% ——★★而它【剛好壓在門檻上方 1.8 個百分點】
⇒ ★★★拿兩個差 20 倍的世界算出來的 58.9% 去推翻一個永久結案，我不做。
```
★**我改用(甲)，而(甲)在這一題上剛好沒有你擔心的病**（見 §二①）。**raw 我留著，你要複核有檔。**

# 五、★★★順帶撞到的一件事，它比 L 本身大

```
T_catch ＝ 10.8s ＝ ★T_seg 的 26.6%
而 estimate_catch_up(state, team, tid, true) 在【同一次 gather】裡被呼叫兩次：
  faction_ai_system.gd:attack_scan      （:295 附近）
  faction_ai_system.gd:_find_weakest_prey（:7404 附近）
★兩處的引數逐字相同（同 state／同 team／同 tid／同 trusted=true）
```
★**若它沒有快取命中 ⇒ 那 26.6% 裡有接近一半是【對同一個問題算兩次】。**
★★**而這不是「迴圈開銷」也不是「等價剪枝」，是【重複子呼叫】** —— 與 `best_estimate`
那顆已經有樁的（`gseg.sub.best_estimate`，本輪 413 萬次）同一族。
★★★**我沒有驗證它有沒有快取命中**（`PathSystem._path_cache` 存在，但我沒有量命中率）
⇒ **標【待驗】，不進帳**。**要我量就說一聲**（加一顆命中率計數，一輪 6 分鐘）。

# 六、落地（exact path）

```
卷面：docs/measurements/2026-09-22-L-loop-overhead-HW2-2seeds-8d.txt
raw ：docs/measurements/2026-09-22-L-loop-overhead-HW2-seed1337-8d-RAW.log.gz
      docs/measurements/2026-09-22-L-loop-overhead-HW2-seed77-8d-RAW.log.gz
      docs/measurements/2026-09-22-L-baseline-noinstr-HW2-seed1337-8d-RAW.log.gz   ← 對照①的無樁那半
      docs/measurements/2026-09-22-L-methodB-abandoned-HW2-seed1337-8d-RAW.log.gz  ← ★(乙)被否掉的那一輪，我留著
四要素：窗 8 天（真天，TICKS_PER_DAY=1440）｜種子 1337+77｜warring_states｜樹 1a5560fe0＋計時樁（樁不進 main）
硬體  ：HW-2 AMD Ryzen 7 5800X3D　★L 是比例 ⇒ 跨機有效
```

# 七、下一步

**你**：裁 §三 的定義（A 還是 B）。**B ⇒ 這一票照預註冊【永久結案】，我不必再跑。**
**A ⇒ 我再跑一輪**（把 `has_belief`／`belief_pos`／`estimate_armed`／評分算式也具名包住，讓 L_A 從上界變成真值）。
**另外**：§五 那件要不要開票（我標待驗，沒有算進任何結論）。
**我手上同時在做**：你派的「手抄一天」那票（`feat/day-length-single-source`），母體 25 行/15 檔已改完、守衛床已寫、正要跑閘。
