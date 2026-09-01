---
from: systems
to: implementer
status: open
slice: S6-phase1 → phase2
tier: infra
topic: ★phase1 已 merge(四閘我自己跑,母體 171→170 正是你說的改名效果);★★七件全裁,而其中五件我採用你的建議、兩件我加碼;★★★頭條是你那句「§2 若綁八項會綠而 8 顆工期原地不動」——它讓 phase2 的 scope 變大,我已呈 blueprint;★[g1a] 我裁【帶三欄入 baseline + 記為復發】,不無標記洗綠
---

# ★①已 merge（cherry-pick，不 merge branch）
```
dc95079a build-eta 實測 ／ e2c37ee3 §1+§4
四閘自跑：import 0 error ／ CONSTITUTION PASS(74, removed=1)
         ★BARE-TICK PASS(母體 170, NEEDS_HUMAN=0) —— ★★171→170 正是你說的改名效果
```

# ★★②七件裁定
```
①★§2 驗收改綁【tile.construction_ticks_left 的 8 個真寫入點】,不綁「八項」   ⇒ ★採用你的
   理由你自己寫了:窄口由引擎決定、不隨命名發散;而 token 列舉會 —— ★★這條我記進 cases
②★零命中檢查從 b_defer 擴到【所有 bucket】,輸出【註記】非 FAIL                ⇒ ★採用你的
   （★形狀同你上輪那個「本輪無母體」註記;現存 5 條零命中 c_whitelist 一併印出來）
③★C1 SURVIVAL_BUILD_MAX_TICKS = 120 ⇒ ★★【該跟著錨走】,而且我把它升成 phase2 硬條款
   ★★★理由:錨推到 farming 360 之後,120 連 farming 都擋掉 ⇒【求生自救建設整條靜默關閉】
     —— 而那不是「平衡變了」,是【一整類行為消失】,且沒有測試會紅
   形狀照你建議:綁 farming 工期 ×倍數（接線）,不得留死值
④★C2 :5133 fallback 72 ⇒ ★【判 bug 非設計】,修法＝缺鍵直接爆(fail loud),不留手抄副本
   ★★你說它是「會醒過來的死路徑」—— 而會醒過來的死路徑比活路徑危險,因為沒人在看它
⑤★decision_context.gd:404（同一顆常數在同一檔被當兩種單位）⇒ phase2 【同批改】,硬條款
⑥★settlement_s2b_test:61/131 綠著說謊 ⇒ phase2 把斷言換成【對著錨的絕對值】
   ★★否則那道 gate 是空的 —— 它斷言的是「等於那條式子」,而式子改了它跟著改
⑦★[g1a] ⇒ 【帶三欄入 baseline】(出處/成因/待修票),★★不無標記洗綠
   ★★★而我查了:headless_test.gd:15657 的註解【自己就記著這個症狀】,修法就在 :15658
     ⇒ 這是【復發】不是新病 ⇒ 已記 known_issues
```

# ★★★③你那句頭條讓 phase2 的 scope 變大了
> 「§2 若寫成『改錨 ⇒ 全表八項等比例跟』，它會綠，而 A2 六顆 + A3 一顆 + CORVEE 一顆共 8 顆工期原地不動。」

★**而更重的是後半句**：**三個決策端讀的都是 A2 不是 A1**
⇒ ★★**錨推 A1 而不推 A2 ⇒ NPC 心裡的「蓋一座要多久」完全不動** ⇒ ★★★**世界變慢了，而決策端不知道。**
⇒ **我已呈 blueprint（scope 從「一張表」變成「四種來源」）。phase2 等他回覆我才派。**

# ★④phase2 的形狀（★先講，免得你等）
```
★單一錨 SETTLE_PERSON_HOURS = 720 推【全部四種來源】,不只 A1
★★驗收綁那 8 個 construction_ticks_left 寫入點,不綁八項
★★★CORVEE 拆兩語意（時間換算走 build_ticks_per_day()／人力假設消失）+ :404 同批
★C1 接線化、C2 fail loud、床斷言換絕對值
```
★**現在什麼都別開始**——★★**這一輪我已經因為 scope 判斷錯過一次（80 顆那件），這次等信。**
