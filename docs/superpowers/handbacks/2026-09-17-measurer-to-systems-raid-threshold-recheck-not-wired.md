---
from: measurer
to: systems
status: consumed
slice: 掠奪門檻複查 ｜ 交件——三種預寫都不完全對，真相是「根本沒接」不是「接了沒通電」
topic: ★三格數字：f=1500尾部仍不搶(0.0779<紮營0.1921,gap 2.47x，比你舊值2.38x還寬一點不是變小)｜f=1500中庸仍不搶(0.0272)｜f=8000尾部仍會搶(0.2175>0.1921,無退步)；★★我沒有停在數字對不上就交件——查過因果鏈全部10個檔案(terms/decision_context/options/decision_engine/task_arbiter/path_system/faction_ai_system/discounted_flow/threat_assessment/npc_combat_system)跨5ac91a6fa..b647643fc全零diff⇒恩怨帳Slice A沒有碰到這條路徑一個字；★★★[TREE] HEAD=b647643fc(clean)｜床commit=1e77f4631
---

# ① 三格數字(逐字，同一組fixture跑兩次驗過determinism)

```
f=1500 尾部(好戰/貪婪.9)：掠奪=0.0779｜紮營=0.1921｜首選=紮營｜比值(紮營/掠奪)=2.467
f=1500 中庸(.5/.5)      ：掠奪=0.0272｜紮營=0.1921｜首選=紮營
f=8000 尾部(好戰/貪婪.9)：掠奪=0.2175｜紮營=0.1921｜首選=掠奪(無退步)
完整rank表、food_days、絕境門檻都印在raw裡：docs/measurements/2026-09-17-raid-threshold-recheck-raw.txt
```

# ② 對照你先寫死的三種結果——三個都不精確符合

```
「尾部在1500翻成會搶」    ⇒ 沒發生(仍紮營>掠奪)
「尾部在1500仍不搶但差距縮小」⇒ 沒發生——★差距反而從你舊值的2.38x寬到2.467x（方向是變差不是變好）
「完全沒動」            ⇒ 數字上不是逐字沒動(0.0779≠你舊值0.0833)，但下一段會解釋這不是恩怨帳的效果
```

# ③ ★★為什麼我敢說「這不是恩怨帳的效果」——查過不是猜

```
git diff --stat 5ac91a6fa..b647643fc 逐查：
  terms.gd／decision_context.gd／options.gd／decision_engine.gd／task_arbiter.gd／
  path_system.gd／faction_ai_system.gd／discounted_flow.gd／threat_assessment.gd／
  npc_combat_system.gd  —— 全部空diff
⇒ loot_drive/subjective_cost/w_wealth 用到的每一個檔案，字節不變
⇒ 恩怨帳Slice A(改的是trade_valuation.gd／npc_ai_system.gd／interaction_system.gd等)
   根本不在這條因果路徑上 —— ★是「沒接」不是「接了沒通電」，這句要更精確
```

# ④ ★誠實限：舊值0.0833與我這次0.0779的落差，我沒有追到底

```
兩次都用同一組fixture(逐字照headless_test.gd _test_solo_seek_home)跑，本身determinism驗過(跑兩次逐字相同)。
但我沒有拉一個 7b07e3800(舊merge commit)的worktree去重跑舊碼核對0.0833是不是能重現——
★因為因果鏈的10個檔案已證字節不變⇒理論上同輸入必同輸出，這落差不太可能是Slice A造成的，
但我也沒有100%排除「文件裡的0.0833本身是另一種fixture量出來的」這個可能。
若這個落差你認為重要，我可以拉worktree去核；若不重要（因為主結論「沒接上」已經夠硬），這裡先擱。
```

# ⑤ 結論(我不下WHAT，只報事實)

```
掠奪門檻複查的答案：f=1500這一檔仍然不搶，且Slice A沒有碰過這條因果鏈的任何一個字。
你信裡預期「這次應該會動」的理由(名聲/記恨接上了)沒有兌現——因為grudge/gratitude只接進了
trade_valuation.gd的ask_price，沒有接進loot_drive的subjective_cost或take。
這條線要不要收案/要不要真的把grudge接進掠奪的因果鏈，是HOW層的事，回你判。
```
