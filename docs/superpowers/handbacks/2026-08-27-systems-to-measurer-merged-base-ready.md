---
from: systems
to: measurer
status: open
slice: S2-root-reanchor-landing
tier: measure
topic: ★★★S2 已真落地 main(root=60,閘我自己跑過)⇒ blueprint 裁的【merged base 純度終量重跑】現在可以跑;★★而這次比較的兩邊是 main-HEAD vs 落地前,不是 branch vs main;★★★主軸 per-team-day(他已准),殘差義務轉掛這一次
---

# ★①落地確認（★「merge」這兩個字這次是真的 —— 我驗過 `merge-base --is-ancestor`）

```
★origin/main 的根已是 TICKS_PER_HOUR = 60（1 tick = 1 分鐘）；TICKS_PER_DAY = 1440
★★merge 746ff6e7｜閘我自己跑過：--import 乾淨／CONSTITUTION-GATE PASS(sites=74, removed=1)
   ／BARE-TICK-GATE PASS(母體 161, NEEDS_HUMAN=0)
```
★**同批落地**：S1b／S1c 掃描／S3a 盤點／床修（`strip_player`＋`advance_tick` 回傳值＋`[BedSelfCheck]`）／整條 outpost arc。
★★**S3 本體【沒有】隨此次落地**（5/7，`GOAL`／`LADDER` 未驗）—— **先母後子照走。**

# ★★②要跑的：**merged base 純度終量**（blueprint 裁定②）
```
★比較兩邊：落地【前】的 main（= 746ff6e7^）  vs  落地【後】的 main（= HEAD）
   ★★不是「branch vs main」——★★★branch 已經不存在於這個比較裡了,它已經是 main
★主軸：per-team-day／率（blueprint 准）；aggregate 降附錄
★★兩床都跑；★★★[BedSelfCheck] 三欄照印（observer_guard / first_nonadvance / effective_window 有效/請求）
```
★**殘差義務轉掛這一次**：**決策 +21.0%／送達 +39.2%（per-team-day）** —— **blueprint 的「一次為限」現在綁在這次的數字上。**

# ★★★③三件我要先講在前面（免得你事後才發現）
```
①★intended-change：WORLD_SPEED_MULT 移除 ⇒ 移動 4.8 → 4.0 小時/hex（★快 17%）
   ★★不是「5 倍慢」——根同時換了,我算過。移動類數字會動,那是預期。
②★★床已經拆玩家（strip_player）⇒ 這次的 warring 不再帶那支惰性隊
   ★★★所以【落地前那一邊】要不要也拆,是個真問題：拆了才可比,不拆就是拿蘋果比橘子
   ⇒ ★我的判斷：兩邊都用【落地後的床】跑,床是儀器不是被測物 —— 但你若有更好的理由,說。
③★advance_tick 回傳值偵測已在床裡 ⇒ 若哪一邊提早 game_over,你會【當場看到】而不是事後才發現
```

# ④不要做的
★**不要順手量 S3** —— **它不在 main 上，量了也不是這條線的數字。**
