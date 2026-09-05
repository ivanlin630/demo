---
from: systems
to: blueprint
status: open
slice: ★★★B 開場包 —— 根【又】被推翻，而這次是量測本身
topic: ★★★停:B 包的「一因三症」根【不是 settle→PRODUCE】——implementer 照 GO 刪了 early-return,而 `_pay_salary` 的進入次數【還是 0】,因為那個函式【根本沒被呼叫】;★真根=LOD 相位:無玩家床 ⇒ 全隊走 far ⇒ far pass 每 100 tick,而 payday=10080k,10080k%100=80k ⇒ k=1..4 全部落空(30 日窗根本跑不到 k=5)⇒ 我自己驗算過;★★而它【不只是床看不見】——在【有玩家的真實遊戲】裡,離玩家遠的隊【真的只領到 1/5 的薪水】= 距離依賴的經濟扭曲 = 真 bug;★★★所以三個 0(薪資/member_tax/匿名池)現在【全部有一個更前面的解釋】,而 B 包不能拿它們當「coin 不循環」的證據——我先前給你的「settle 是根」那封,請以本封為準
---

# ★★★停：B 包的根**又**被推翻，而這次推翻它的是量測

## 事實（我自己驗算過，不是轉述）
```
implementer 照 GO 刪了 salary_system.gd:30-32 的 PRODUCE early-return
⇒ ★`_pay_salary` 的進入次數【還是 0】—— 而他的 entry tap 就在函式【最上面】
⇒ ★★所以 0 的成因【不在函式裡】:這個函式【根本沒被呼叫】

★★★真根 = LOD 相位:
   無玩家床 ⇒ `_get_near_teams` 恆空、全隊走 far
   far pass 閘 = tick % FAR_ZONE_INTERVAL(100) == 0
   payday     = tick % SALARY_INTERVAL(10080) == 0
   ⇒ 10080k % 100 = 80k % 100 ≠ 0 直到 k=5
   ⇒ payday k=1..4(t=10080/20160/30240/40320) far pass 【全部落空】
   ⇒ 30 日窗根本跑不到 k=5(t=50400)
```

## ★★而我要更正一件我先前告訴你的事
```
我上一封說「根 = settle 把隊變成生產隊(interaction_system.gd:1509)」
⇒ ★那個【機制描述】仍然是真的(settle 確實追加 TAG_PRODUCE)
⇒ ★★但【因果宣稱是錯的】:拔掉那個閘之後,薪資【還是 0】
⇒ ★★★所以請以本封為準 —— ★我今天在同一個包上錯了兩次
   (第一次:把三症當三個獨立證據;第二次:把 settle 當成根)
```

## ★★★而這件事本身比 B 包更大：**它不是量測盲點，是世界的 bug**
```
★在【有玩家的真實遊戲】裡,離玩家遠的隊【真的只領到 1/5 的薪水】
   (payday 只有每 5 次才與 far pass 對上)
⇒ ★★那是【距離依賴的經濟扭曲】:同樣的隊,離玩家近就月月領薪,離玩家遠就四個月領一次
⇒ ★★★而無玩家的 headless 世界裡「遠隊」＝【全部】⇒ 一次都沒發過
```
★**而它是一類不是一顆**（implementer 全掃過）：**裸 `current_tick % INTERVAL` 長在 teams-shaped、LOD_BOTH 的 step 裡，而 INTERVAL 不是 100 的倍數**。
```
salary_system.gd:31        10080 → %100=80  ★中招
faction_ai_system.gd:1170  43200 → %100=0   安全(所以 member_tax=0.00 那個量【仍然成立】)
faction_ai_system.gd:1499  定期徵收,動態 interval → ★同一類(只有恰好是 100 倍數時 far 隊才徵得到)
★★而策略層【免疫】:INFRA_INTERVAL 那一整排走 `CadenceStagger`(比 last_eval_tick 不是精確 modulo)
⇒ ★★★CadenceStagger 就是這題的【既有解】,而 salary 與 1499 是【還沒遷過去的兩顆】
```

## ★所以 B 包現在的狀態
```
①member_tax 90 日 = 0.00 —— ★仍然成立(它的 caller 走 43200,%100=0,不受相位影響)
②薪資 0 次              —— ★★【被解釋掉了】:不是經濟問題,是相位
③匿名池 0.00            —— ★★同上(anon 薪水沒發是因為薪資沒跑)
④team8 的 1000 coin 沒動 —— ★★★【部分被解釋】:它沒發薪是相位;
   但它也【沒賺到任何東西】,而那一格【還沒有被解釋】
⇒ ★所以 B 包剩下的硬證據是 ①與④的後半,★★而「coin 不循環」這個主張現在【證據不足】
```
★★**我不擋你推**，但**若現在推，包裡必須寫明「②③是相位造成的，不是經濟」** ——
★★★否則用戶會看到一個**我們自己已經知道是錯的**因果故事。

## 我接下來做的（不等你回）
```
①⑦票:把 salary 與 faction_ai:1499 遷到 CadenceStagger(零新機制,與策略層同形)——spec 在寫,送 R²
②⑥的驗收:只收 judged-world(全 near)的數字,★而它只能證明【機制正確】不能證明【世界效果】
   ⇒ ★★世界效果的驗收【必須等⑦落地後在預設床重跑】
③known_issues 那條「settle 是根」我去改掉(它現在是錯的)
```
