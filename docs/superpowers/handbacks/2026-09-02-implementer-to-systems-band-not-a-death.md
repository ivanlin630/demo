---
from: implementer
to: systems
status: consumed
slice: flee-to-safety 30 日窗 —— ★最後一格補完
topic: ★那 1 隊消失【不是死】:真滅團=0／被吸納或收編=1 ⇒ 你的 benign 沒有被推翻;★★而兩跑的逐日 checkpoint 30 行【完全相同】⇒ extinct 桶沒動到行為、數字也不是浮動出來的;★★★量測全文已落地 docs/measurements/2026-09-02-flee-to-safety-warring_states-seed1337-30d.txt
---

# ★①那 1 隊消失 —— **不是死**

```
band 隊數（去重）= 27
消失 = 1  →  ★真滅團 = 0 ／ ★★被吸納或收編 = 1
位置最後 5 日未變 = 12 ／ 有移動 = 14
最終 task：掠奪5｜建設4｜覓食4｜貿易4｜迎戰4｜外交2｜逃跑2｜乞食1
```

★**你標的可證偽點是「若那些隊【因此死掉或凍住】，benign 就是錯的」** ——
★★**真滅團 = 0 ⇒ 沒有一隊死** ⇒ **benign 沒有被推翻。**

★★★**而我上一封沒有把那個 1 報成死，是對的**：它是【被吸納或收編】，
**在驗收上那是相反的結論**（隊併進別人不是壞事）。

## ★而「被吸納或收編」我【還是】沒分開
```
`extinct.team.<id>` 桶只認【真滅團】(`cleanup_extinct_teams`)
⇒ 沒進那個桶而不見了 ＝ 被吸納(`subteam_system.gd:212`)／encounter 收編(`encounter_system.gd:1460`)／野獸
⇒ ★★這三條我沒再分 —— ★★★而【對本問題不影響】：三條都不是「死」
   （若哪天要分，同樣加 per-team 桶就行，位置我標在上面）
```

# ★★②兩跑對照（★這是加桶那一刀的對照，不是新結果）
```
加 extinct 桶【前】的 30 日跑  vs  【後】的 30 日跑
⇒ ★逐日 checkpoint 30 行【完全相同】（flee 呼叫／設無效／backstop／退化／band／無目的地過門檻）
⇒ ★★那個桶沒動到行為；★★★而各項數字也【不是浮動出來的】——同 seed 同窗兩跑一致
（TickPerf 不同是時間，本來就浮動）
```

# ★★★③30 日全表（★量測全文已落地，路徑在下面）

| 驗收項 | 12 日 | **30 日** |
|---|---|---|
| ②機會母體（FLEE 派發） | 56 | **351** |
| ②續卡（桶 A／桶 B） | 0／0 | **0／0** |
| ④backstop release | 0 | **0** |
| ①朝目的地／②away-tile／③backstop | 48／6／0 | **45／43／0** |
| 派發時就有目的地（不必重解） | — | **480** |
| ③退化 total | 491 | **2108**（備戰 1569 ＝ 74%） |
| ⑤band 次數／隊數 | 49／16 | **163／27** |
| 四站：有設／沒設 | 34+22／0+0 | **274+77／8+0** |

★**驗收②④我仍然標成【答不了】**：backstop 與續卡在 30 日窗也都是 0
⇒ **不是「下降到 0」，是【這個 branch 的這個窗裡本來就沒有】。**
★★**而 30 日是自然跑完（無 timeout）、逐日 checkpoint 全程有值單調上升**
⇒ ★★★**這次的 0 至少【不是】「儀器沒跑到」那一種**。

# ④落地（★exact path）
```
量測全文  A:\GDS\demo\.worktrees\old-growth\docs\measurements\2026-09-02-flee-to-safety-warring_states-seed1337-30d.txt
          （repo 相對：docs/measurements/2026-09-02-flee-to-safety-warring_states-seed1337-30d.txt，commit bd8d86d7）
床        scripts/debug/flee_guard_tap_bed.gd（四段＋band 結局段）
          scripts/debug/flee_tap_fp_bed.gd（arm Probe 的 fp 對照）
commit    e7451a65 tap-only → 0bc0aa4e 修法 → 693dee78 ADDENDUM → 5885dd52 band 結局 → 2a09f7a4 消失≠死 → bd8d86d7 量測落地
merge-gate 10 支全綠（跑兩次：222s／176s，第二次涵蓋 2a09f7a4）
```

# ⑤還在你桌上的一件（★我沒自己決定）
★`_decide_subteam` 派的 FLEE **沒有第②層**（`flee_from_pos` 仍 (-1,-1)，因為你說不要補呼 `_flee_threat_pos`）
⇒ **目的地一旦跨 tick 過期，直接落第③層 release，中間沒有 away-tile 接。**
★★30 日窗裡沒發生（backstop=0），★★★**但那是「沒發生」不是「不會發生」** —— 要不要給它第②層，你判。
