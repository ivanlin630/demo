---
from: systems
to: implementer
status: consumed
slice: #5 確認 tap（★純觀測、不修）
topic: ★成因我查到結構那半了(tick 序 move→faction_ia、release 無排程 ⇒ 不是延遲,是【上游每 tick 重造】);★★而要坐實「哪一處、哪一條路」需要 tap,那是 measurer 明說跨他 scope 的地方;★★★這一票【只加 tap 不改行為】,修法等 blueprint 裁「怕但不知道往哪逃該做什麼」
---

# ★①要 tap 的三個點（★純觀測，`fp` 必須逐位元不變）
```
①faction_ai_system.gd:2973  `if _set_ok and td["task"]==FLEE: flee_from_pos = _flee_threat_pos(...)`
②faction_ai_system.gd:3539  `if td["task"]==FLEE: flee_from_pos = _flee_threat_pos(...)`
   ⇒ ★兩處各記：設進去的值【是不是 (-1,-1)】
③movement_system.gd:88-90 backstop：`TaskArbiter.release(team)` 被走到幾次
```
★★**而 `_flee_threat_pos` 有【兩條路】回 (-1,-1)，要分開記**：
```
★best_id == -1（找不到威脅）        → 桶 A
★★belief_pos() 回 (-1,-1)（positionless／過期） → 桶 B
⇒ ★★★兩者的意思完全不同：A ＝「沒有威脅卻在逃」；B ＝「有威脅但不知道在哪」
   —— 而修法方向會因為哪個佔多數而不同
```

# ★★②要能回答的一句話
> **「backstop release 了幾次」與「上游重新設成 (-1,-1) 幾次」，這兩個數的關係是什麼？**
★**若後者 ≈ 前者** ⇒ 坐實【每 tick 重造】。★★**若後者 ≪ 前者** ⇒ 我的結構推論錯了，**停下來報我**。

# ★★★③這一票【不要修】
```
★修法方向取決於 blueprint 裁「怕、但不知道往哪逃的隊該做什麼」(不選 FLEE／原地戒備／盲逃)
⇒ ★★三種是不同的世界，★★★而在他裁之前加任何 guard 都等於替他選
★而 fp 逐位元不變是硬條件 —— 這一票若 fp 變了，就是你動到了行為
```
