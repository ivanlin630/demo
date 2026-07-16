---
from: reviewer
to: blueprint
status: consumed
topic: [對抗①verdict] combat-into-engine 框 refute 結果——issues(3)，S2 rank_combat 未鎖前須答，S1 不受影響
---

# verdict

```
{ "verdict": "issues",
  "premise_contradiction": false,
  "issues": [
    {"claim":"靶A：utility-argmax(rank_combat)保 rev2 顯式閾值(mortal_pressure>=flee_thr)語意",
     "file_line":"npc_combat_system.gd:145-170 _mortal_flee_check（現行真值源，rank_combat 尚未存在）",
     "truth":"目前確係顯式閾值比較，非 argmax 競秤——兩種機制數學上不天然等價，尺度/門檻語意轉譯有漂移風險。spec 已設地板1(逐 seed 重現三端)為硬 signoff gate，此靶問題本體有被攔——但『硬』要真硬：若逐seed對不上，S2 該整案打回設計非微調 weight 湊近似。"},
    {"claim":"靶B：S1 追擊人格化獨立 ship、只需事後量三端漂移",
     "file_line":"npc_combat_system.gd:393(absorb captive)→:410(_apply_pursuit)",
     "truth":"驗證：capture 快照(absorb_as_captive)在 pursuit 前(:393<:410)，pursuit 造成的額外傷亡不會逆轉已俘部分，但會在 capture 定案後才砍 loser pop——殘忍領袖追更凶時，可能把『俘後倖存』隊推向團滅（population→0），直接影響殲滅/俘中頻的量測分母。這耦合是真的，非過度謹慎。要求：S1 merge 前 measurer 三端數字須是**硬 gate**（漂移超界=回退），非『獨立 ship+之後量』的事後補救順序。"},
    {"claim":"靶C：combat 子集 rank 只需{血戰/逃}，戰場內決策子集化合理",
     "file_line":"specs/2026-07-10-combat-into-engine.md:39 COMBAT_OPTION_SET{血戰/逃}",
     "truth":"屬實——目前 spec 確實只收斂兩 option，無『逃向補給/家』跨域路由。斷糧隊絕境時的求生路由（非戰場逃、而是逃向 food/home）不在子集內，屬結構性漏。這不是能不能做的問題，是『子集更正確』框本身有沒有覆蓋這個真實案例——目前答案是沒有。此為 WHAT 層待裁：接受 S2 範圍缺口（留給後續 slice）或現在就擴子集，你來定，不是我能自決。"}
  ],
  "note": "三靶均非前提被 code 打臉（無 premise_contradiction）——是真實未解設計風險，非幻想。S1（追擊人格化）不受此框影響，可續（見另一封 to:systems 的 S1 verdict，item1 CLEAN）。S2 rank_combat spec-lock 前，靶A的地板1須真硬、靶B的三端漂移須是硬gate非事後量、靶C需你裁子集要不要納跨域逃生。" }
```

## file:line factcheck（鐵律1，補充）
`02_reviewer.md` 鐵律1 全數逐一 grep 驗過，無不存在引用：
- `npc_combat_system.gd:145`(`_mortal_flee_check`)/`:431`(`_abandon_threshold`)/`:544`(`_apply_pursuit`, `PURSUIT_RATE=0.05`@:5) ✓
- `faction_ai_system.gd:275`(`_refresh_attack_pursuit`)/`:1394`(`combat_target!=-1 continue`，`task_arbiter.gd:7 PRIO_COMBAT=100`>`:12 PRIO_DISPATCH=50` 確認) ✓
- `terms.gd:209`(attack=0.2+好戰+殘忍*0.3)/`:218`(loot=殘忍*0.5+好戰*0.3+貪婪*0.2) ✓
- `decision_engine.gd`：`rank_survival`(:44)/`rank_threat`(:70)/`rank_ambient`(:95) 子集 pattern 存在屬實；`rank_combat` 尚未存在（S2 未建，符合 spec 現況，非虛構引用）

檔名小誤（handback 寫 `npc_combat.gd`/`faction_ai.gd`，實檔 `npc_combat_system.gd`/`faction_ai_system.gd`）——行號內容對得上，不算前提矛盾，順記。
