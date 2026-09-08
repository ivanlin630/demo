---
from: systems
to: implementer
status: consumed
topic: ★★★**wagepen 交接（fresh session 接手）**——★WIP 我已固定成**可攜補丁**（未 commit 的半成品是最脆弱的形態）；★★**從檔案接，不從記憶接**；★★★第一動作＝**跑紅測看半到哪**，不是先動手
---

# 一、★接手物（★exact path，我開檔驗過，不是宣稱）
```
補丁：docs/handoff/2026-09-08-wagepen-WIP-salary_system.patch      （99 行；★git apply --check 在現 main 上通過）
床  ：docs/handoff/2026-09-08-wagepen-WIP-wage_penalty_test.gd.txt （86 行；★骨架，判準相關只有 3 行）
spec：docs/superpowers/specs/2026-09-08-wage-penalty-rework-HOW.md  （★含 §1b 訂正：unrest 確實有鉤）
原 worktree：.worktrees/wagepen（★舊 session 可能還持有 ⇒ 別搶 lock，用你自己的 copy）
```

# 二、★★半到哪（我讀過 diff，這是【現況】不是猜）
```
★production 改得【差不多】且照 spec 走：
   _can_pay = budget_ratio >= 1.0            ← §2② 的【付不出】判準
   _willful 計數                              ← 【不肯付】的人數（unrest 該跟它走）
   Probe.bump("salary.reason.paid_full")      ← ★我要的三格窮盡已經在做
   註解裡引了「地理被定罪」與「付不出不是惡意」
★★測試床【還是骨架】：86 行、判準相關 3 行
⇒ ★★★所以缺口在【驗收】那一半，不在修法那一半
```

# 三、★★★第一動作（blueprint 明裁）：**先跑紅測，不要先動手**
```
★檔案是半成品 ⇒ 先知道【半到哪】：跑那支床，看它現在紅在哪一格
⇒ ★★而不是從 spec 從頭做一遍 —— 那會把別人做完的部分再做一次
```

# 四、★驗收（spec §3，★成對，缺一半就分不出「修好」與「把功能關掉」）
```
①★仍要罰得到：【有錢卻不發】⇒ underpay 忠誠流失【必須發生】
②★★不得再罰無辜：【無幣村】⇒ 忠誠流失【必須為 0】
③離團導向：①那支隊 N 週後出現【離團】而非全隊 unrest 飆高
④anon 側懲罰 counter 歸 0、morale 側非零
⑤★守恆：coin 流出總量不變 —— ★★用 CoinAudit.total 六池，★★★不自寫子集普查
⑥unrest：salary_system.gd:210-211 的 UnrestBank.add 不得由「地方沒錢」觸發
```

# 五、★兩件我要先講的（免得重踩）
```
①★spec §1 我原本寫錯過一句（「沒有 unrest 寫入」）——★★已訂正見 §1b，
   而正確的是 :210-211 `if budget_ratio < 1.0: UnrestBank.add(team, 1, "salary")`
   ⇒ ★★★若你發現 spec 還有別的錯 —— **動手前回報**，前一位就是這樣救了我三次
②★別調 SALARY_LOYALTY_PENALTY 這個數值 —— 本票是【改接線】不是【改數值】
```
