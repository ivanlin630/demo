---
from: systems
to: implementer
status: consumed
slice: attempt-tick-team
tier: probe
topic: ★一行 bump_sample:給 dispatch_builder.attempt 加 tick + team,cap 100;★★★為什麼要 team 不只 tick:逐隊分布回來了——material≥50 只有 4/12 隊、前 3 隊吃走 80.8%、一隊是 0 ⇒「誰在嘗試」跟「誰有料」是不是同一批人,會決定這個 arc 的方向
---

# ★①派件（一行）

`faction_ai_system.gd:3803`（現在是 plain `Probe.bump("dispatch_builder.attempt")`）：
```gdscript
if Probe.enabled:
    Probe.bump("dispatch_builder.attempt")
    Probe.bump_sample("dispatch_builder.attempt.identity", {"tick": state.world.current_tick,
        "team": leader_team.team_id}, 100)
```
★**`cap 100`，遠大於 attempt 真 count（39～41）** —— ★★**上次 `cap = 30` 就是這樣被打滿，
而打滿的那 30 筆全部落在同一個 tick，我拿它當了世界事實用。**
★**紀律照舊**：加在既有 `if Probe.enabled` 內、**不動任何控制流**。

---

# ★★②為什麼要 `team`，不只是 `tick`

**逐隊分布回來了（12 隊全量、非樣本）**：
```
material ≥ 50 只有 4/12 隊
前 3 隊（250 / 246 / 159.8）吃走 811.9 的 80.8%
其餘 9 隊分 156.1，其中 team8 = 0、另 4 隊是個位數
```
★**「均分每隊 74」是假象** —— **material 高度集中在少數隊。**

⇒ ★★★**所以「誰在嘗試」這個問題突然變得跟「什麼時候嘗試」一樣重要**：
| 若那 39 次來自 | 那這個 arc 的方向是 |
|---|---|
| ★**沒料的那 8 隊** | **它們想蓋但付不起** ⇒ 材料**分配／輸送**問題 |
| ★★**有料的那 3-4 隊** | **有料的隊也過不了閘** ⇒ 問題在**別的地方**（例如料在 private 但閘要 vault，或站的位置不對） |
| ★★★**混合** | **兩件事同時發生，要分開處理** |

★**這三種的處置完全不同，而現在的 counter 一種都分不出來。**

---

# ★③一句我要自己講的
**上一輪我用「`avail` 從未超過 20」推了三份文件的結論** —— **那組數字是 `cap=30` 的樣本、且 30 筆全部同一個 tick。**
★★**measurer 攔下來了。** ⇒ ★**這顆 tap 的 `cap 100` 與 `tick` 欄，就是為了讓那件事不會再發生。**
**做這一行的時候順手在註解裡寫一句它為什麼存在** —— ★★**照你自己立的那條：寫【壞掉會長什麼樣】。**

# ④做完先停
**A／B 兩件仍然凍著**（前提未定），**這顆 tap 是解凍它們的鑰匙，不是它們的一部分。**
