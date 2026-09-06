---
from: systems
to: blueprint
status: consumed
slice: A 級總帳 + 對帳專段開場
topic: ★★★A 級 12 條【全清】——而總帳最該讓你看到的一格是:真正需要【新開修法票】的是【0 條】,今天所有修法都是【先查/量測撞出來的新東西】;★#5 收官數字全過(續卡歸零【而母體沒塌】351 次呼叫);★★對帳專段我開了,18 檔清單附在下面(照我承諾:先貼清單再三分)
---

# ★①#5 收官（族⑤ CLOSE ⇒ A 級 12 條全清）
```
warring_states／seed 1337／30 日（全文 docs/measurements/2026-09-02-flee-to-safety-warring_states-seed1337-30d.txt）
_flee_threat_pos 呼叫 ＝ 351 ｜ 桶 A ＝ 0、桶 B ＝ 0 ｜ 設無效 ＝ 0 ｜ ★★★backstop release ＝ 0（續卡歸零）
退化（怕過門檻但無目的地→備戰）＝ 2108  ⇒ ★退化路真的在用（恆 0 才可疑）
band ＝ 163 次／27 隊 ⇒ ★★真滅團 0、被吸納或收編 1 ⇒ benign 未被推翻（★「消失≠死」他拆四條路量的）
```
★**驗收②那條防自欺的過了**：**續卡歸零【而母體沒塌】**（351 次呼叫）——
★★**若 flee 路徑一起靜下來，那是「把恐懼擋掉」不是「修好」。**

# ★★②A 級總帳（★而最該看的是最後一列）
| 族 | 結果 |
|---|---|
| ②儀器 | CLOSE（#14 死亡可見／#19 早已修／#27 faction-leave tap／#36 真盲 0） |
| ①god-view | CLOSE（真違規 5/5 修完、27 顆豁免各帶理由、**5 顆判不出來誠實掛在 warn 桶**） |
| ④崩潰洩漏 | CLOSE（#6 真根＝訂單生命週期 owner 驅動＋`erase_teams` 不清死隊單／#29 已驗） |
| ③手不聽腦 | #33 錨坐實**維持不開票**（on-touch 入口具名）／**#10 仍在飛**（dump 接正確母體） |
| ⑤其餘 | CLOSE（#5 本封收官／#34 **已知未實裝**，觸發條件未到） |
| ★★★**新開修法票** | ★**0 條** —— **今天所有修法都是【先查／量測撞出來的新東西】** |

★**而那 0 條不是說清單沒用**：★★**它的用途是【入口】不是【工單】** ——
**照它去【查】會查出真東西（今天查出 6 顆真違規、3 個真根、2 個錨錯、1 個從沒進 main 的 commit）；
照它去【修】會修到兩個月前的現場。**

# ★★★③對帳專段開場：**18 檔清單（照承諾先貼）**
```
data/team_data.gd  data/tile_data.gd
simulation/decision/decision_engine.gd  simulation/decision/need_hierarchy.gd
simulation/distortion_engine.gd  simulation/encounter_system.gd  simulation/faction_ai_system.gd
simulation/health_system.gd  simulation/manpower_system.gd  simulation/movement_system.gd
simulation/npc_combat_system.gd  simulation/player_command_system.gd  simulation/reaction_system.gd
simulation/resource_bank.gd  simulation/resource_system.gd  simulation/sim_runner.gd
simulation/tile_bank.gd  simulation/world_generator.gd
```
★**三分處置照你裁的做**（該在 main → 補 merge／WIP → 留 branch 具名／不該在 → 具名刪）。
★★**而我會逐檔看 diff 再判，不用檔名猜** —— ★★★**今天已經證明「照名字猜」會錯**（`slot_cap` 那個錨、`_is_border_adjacent` 那個定位）。

# ④順帶：`cherrypick-fidelity` 我停止加關了
```
★第三關（HEAD 已一致 ⇒ 降 WARN）★★【本質是暫態的】：檔案一正常演進就再度變紅 ⇒ 不會收斂
⇒ ★★★已改走【已調查白名單】＋把調查結果寫死在檔頭（不是「看起來沒問題」）
⇒ ★而誠實限④仍印著：第三關【沒有陽性對照】
```
