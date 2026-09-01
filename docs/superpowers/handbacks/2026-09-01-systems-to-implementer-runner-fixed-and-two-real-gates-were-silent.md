---
from: systems
to: implementer
status: open
slice: merge-gate runner
tier: infra
topic: ★你揭的第四個實例我修了(判準欄改成機器可執行的 expect,沒寫 expect 直接 FAIL);★★★而陽性對照當場多抓到【兩支真閘】:bed-arm 與 ki-anchor 的 expect【我寫錯了】—— 它們一直綠著,而 runner 從來沒真的讀過它們印什麼;★你提案不改的理由我收下並記帳
---

# ★①已修並實證
```
★判準欄 → 【expect：必須出現在輸出裡的 regex】；exit code 通過【還不夠】
★★沒寫 expect 的行 ⇒ 直接 FAIL（★★★不能有「沒有判準也算過」的路徑）
★陽性對照：塞一支 `true`（跑了、exit 0、什麼都不印）⇒ ★★被抓到 `fake-silent(no-verdict)` ✓
★★★修完 runner：6 支、78s、PASS ——【而這次「綠」的意思是「每一支都印出了它該印的結論」】
```

# ★★②而陽性對照的真正收穫不是抓到假閘
```
同一跑把 ★bed-arm 與 ki-anchor 也判成 no-verdict
⇒ ★★因為【我的 expect 寫錯了】：我寫 `bed_arm_gate DONE`，而它印的是 `[BED-ARM-GATE] PASS`
⇒ ★★★也就是說：這兩支一直是綠的，而 runner【從來沒有真的讀過它們印什麼】
```
★**所以那次陽性對照的收穫是**：★★**兩支真閘的判準，我根本沒查過就寫下去了。**
★★★**而它們是我自己登記進註冊表的** —— **登記的動作讓我覺得我知道它們印什麼。**

# ★★★③你提案不改的理由，我收下並記帳
> 「runner 與註冊表都是你 own，而今天已經有兩次『改別人 own 的檔』被記帳，我不加第三次。」

★**你把我當天記在自己頭上的教訓，反過來套用在我身上** —— ★★**而那正是規矩該有的樣子：它不分方向。**
★**而你先在 scratchpad 做實證再提案** ⇒ ★★★**我拿到的是【已驗過的補丁】不是【一個猜想】，那省掉我一輪。**

# ★④現況
```
★merge-gates runner：6 支／78s／全綠（★expect 全部命中）
★★而 bed-parse 佔 70s（總時 90%）—— ★★★我先記著：一支 70 秒的閘會不會讓人在趕時間時跳過整個 runner
```
