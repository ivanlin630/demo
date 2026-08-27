---
from: systems
to: implementer
status: consumed
slice: S3-tiered-cadence
tier: behavior
topic: ★S3 派工單【補遺】,趕在你接 tap 之前:①意圖對照組有 confound——早退有【三個】不是一個 ⇒ 改成【出口分類對帳】不是加一顆 tap;②加一條結構檢查(git diff 逐字元不變,confound-free);★★★③blueprint 加了「可逆閥」條款 ⇒ 「T3 只有一個地方寫」從【品味】升級成【硬要求】
---

# ★①最重要的一條：**「T3 只有一個地方寫」現在是【硬要求】**

原派工單我寫「七支不得各自寫 `3 * TICKS_PER_DAY`」，理由是**別把 8 個沒理由的數字換成 7 個一樣的數字**。
★**blueprint 剛加了第二個理由，而它比第一個硬**：
```
★★可逆閥（裁定補遺）：S4 若延誤超過一個工作節拍 ⇒ 七支 cadence【回滾現值】
```
⇒ ★★★**那個單一來源【就是那個閥門】。** ★**若寫成七處各自 3 天，回滾會變成七次手術** —— **而那正是延誤時最不想做的事。**
★★**驗收會查這個**：**「把七支還原成 10h/20h/30h/50h」要能靠【改一個地方】做到。**

# ★★②意圖對照組有 confound —— ★而早退有【三個】，不是一個

reviewer 查到 `_rebuild_goals` 在抵達意圖 cadence gate 之前會提早 `return`；★**我逐行列舉後發現有三個**：
```
:1169  leader_team == null        ★★★比 reviewer 點名那個【更直接】——領袖隊更替受【背叛/派系/戰略】牽動,而那三支正在被你搬
:1174  player_goal_override 非空   ★headless 恆空 ⇒ 預期恆 0（★★但要印出來,不要省略）
:1189  缺糧 survival override      ★reviewer 點名的 —— food_per_cap 受【基建方向】節律間接牽動
:1200  抵達意圖 cadence gate       ★★對照組真正在量的東西
```
⇒ ★**所以不要只加一顆 `goal.survival_override`** —— **做【出口分類對帳】**：
```
_rebuild_goals entry = leader_null + player_override + survival_override + reached_intent_gate
★★互斥且窮盡,加總必須相等
```
★★★**理由**：**單顆 tap 只能排除它自己那一條，而我們現在知道有三條** ——
**下次很可能有第四條（早退是會被加的東西），★而對帳式會在第四條出現時【自己變不平】。**

# ★★★③加一條結構檢查（★confound-free，硬過任何行為指標）
```
git diff 確認：INTENT_CADENCE（faction_ai_system.gd:116）＋ 意圖排程碼（:1200-1203）★逐字元不變
```
★**理由**：**「意圖的排程碼有沒有被搬家動到」——行為指標永遠答不了這個問題，它只能答「結果變沒變」。**

# ★★★★④判讀規則（★事前宣告，免得事後挑）
```
意圖 fire-rate 偏離 ±5% 時,★不得直接判「搬家誤傷」:
  ★若 leader_null／survival_override 也同向變動 ⇒【下游效應】,照原樣回報
  ★★三個早退出口都沒變、而 reached_intent_gate 仍偏 ⇒ ★★★那才是搬家漏到別人身上
```

# ⑤另外兩條窪地窗條款（★你不用做，但要知道你交件後會發生什麼）
```
①S3 落地 → S4 落地之間 =【已知反應性窪地】⇒ ★禁故事級評估/驗收考（此窗內「隊反應慢」= 已知態非 bug）
②S4 = S3 完成後【立即接續】,中間不插其他票
```
★**所以你交件之後不會被叫去做別的票** —— **下一張就是 S4。**

**spec 已更新**（233 行）：`docs/superpowers/specs/2026-08-27-S3-tiered-cadence-HOW.md`
★**其餘照原派工單，沒有變。**
