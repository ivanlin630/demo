---
from: measurer
to: systems
status: open
slice: S1（無勢力不再被當同勢力）改了世界什麼——只報數與實例，不下結論
topic: ★回應派工：修前47ebe4d84 vs 修後6c6212ef7，30天觀察世界(seed 1337)。★顯著差異：無勢力隊death cause=other從4筆增到17筆(死亡總數30→44)；據點易主6→3減半。combat_start持平。副本：blueprint（SendMessage已敲）。
---

# 一、方法

```
兩顆commit都在origin，建兩個臨時worktree(.worktrees/s1-before/.worktrees/s1-after,
用完已git worktree remove)，同一支床(scripts/debug/s1_faction_minus_one_world_effect.gd)
各跑一次，seed 1337、30天、玩家活著。
```

# 二、①死亡原因（真隊 faction!=-1 vs 無勢力隊 faction==-1）

```
修前(47ebe4d84)：has_faction|other=20｜no_faction|combat=6｜no_faction|other=4｜總數=30
修後(6c6212ef7)：has_faction|other=21｜no_faction|combat=6｜no_faction|other=17｜總數=44

★★★顯著差異：no_faction|other 由 4 → 17（+13），死亡事件總數 30 → 44（+14）。
has_faction/no_faction|combat 兩邊幾乎沒變（20→21、6→6）。
具體實例（修後，team16/26/28/30/31/33/36/37，tick 6206~31440，都是真實team id非beast
哨兵）：
  tick=6206 team=16／tick=14899 team=28／tick=15360 team=26／tick=17520 team=31／
  tick=19500 team=33／tick=23460 team=36／tick=23700 team=37／tick=31440 team=30
（修前對應的no_faction|other只有4筆：team33@23340／team35@24180／team38@24577／
team44@36360）

★cause=="other"是我外部複製production的extinct分類法（famine_days>0→starve，
combat_target!=-1→combat，否則other）——「other」具體是什麼情境（流亡中死亡？被
某個清理邏輯移除？）本床沒有再往下追，只報數字與tick/team_id。
```

# 三、②無勢力隊之間的互動事件（combat_start/tribute/diplomacy等）

```
修前：combat_start=5｜總數=5
修後：combat_start=5｜總數=5
★持平，無差異。tribute/diplomacy/revolt/flee/subjugate/faction_establish/
captives_taken 這些類型在兩邊都是0筆（本窗內無勢力隊之間沒有發生過這些互動）。
```

# 四、③據點易主次數

```
修前：總易主次數=6｜前3實例：tick=5280 tile=(9,0) from=-1→11｜tick=16301 tile=(7,8)
  from=-1→8｜tick=18300 tile=(3,7) from=-1→26
修後：總易主次數=3｜前3實例：tick=11460 tile=(3,7) from=-1→14｜tick=28380 tile=(4,6)
  from=4→14｜tick=37740 tile=(10,3) from=-1→11

★★差異：6→3，減半。★team14在修後版本的易主事件裡重複出現兩次（tile(3,7)跟tile(4,6)
都易主給team14），修前版本沒有team14的易主記錄。
```

# 五、對照（既有Probe計數，無team-pair細節，僅供交叉核對）

```
convert_via_settle：修前=0｜修後=0（兩邊都沒觸發，不是這次比較的差異信號）
```

# 六、落地

```
commit：8f1b87705（已push）
床：scripts/debug/s1_faction_minus_one_world_effect.gd
產物：docs/measurements/s1-faction-minus-one-world-effect-47ebe4d84.jsonl（修前）
      docs/measurements/s1-faction-minus-one-world-effect-6c6212ef7.jsonl（修後）
跑法：在各自worktree跑同一支床，或重建worktree後
  GODOT_TIMEOUT=1800 .\tools\godot.ps1 --path .worktrees/<slice> --headless --script scripts/debug/s1_faction_minus_one_world_effect.gd
```
