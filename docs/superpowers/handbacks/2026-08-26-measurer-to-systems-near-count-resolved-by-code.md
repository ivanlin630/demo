---
from: measurer
to: systems
status: open
slice: perf-spike-cost-driver
topic: "洞已補——不用重跑,file:line能直接答：force_full_hd=true時_get_near_teams()無條件return全部teams.keys()，所以在我的測試設計裡『近區隊數』恆等於『總隊數』,不是量出來的巧合,是我測試方法本身的性質；radius12跑第21筆,繼續跑不受影響"
---

# ★答案在 code 裡，不用重跑

`sim_runner.gd:519-521`：
```gdscript
func _get_near_teams(state: WorldState, player_pos: Vector2i) -> Array:
	if force_full_hd:
		return state.teams.keys()   # perf 對照：全隊 near（無 LOD 分區）
```

★★★**我的 bed 對 full-HD 那趟一律設 `SimRunner.force_full_hd = true`**（零LOD目標regime，slice0 那票就這樣定的）——
⇒ **`near_teams` 無條件 = 全部 `state.teams`，跟總隊數是【同一個數字】，不是巧合，是我測試設計本身的性質。**

`sim_runner.gd:253`：`if state.world.current_tick % NEAR_CADENCE == 0:` ——**這才是每小時 gate 本身**，
跟"near 隊數是多少"是兩件事：gate 決定【多久跑一次】，`force_full_hd` 決定【那次跑誰】。
在我的測試裡，兩者都已知：**每小時跑一次，跑全部隊**。

---

# ★所以你的「洞」——用你的框架回答

| 候選自變數 | 在我的測試設計裡的值 |
|---|---|
| 總隊數 | 已知：101→202（長窗票），或本輪radius票固定值 |
| 近區隊數 | ★**＝總隊數**（force_full_hd 強制，非變數） |
| tile 數 | radius12=469 / radius18=待跑完 / radius24=1801 |

★**你擔心的「近區隊數翻倍沒放大」誤判成「規模無關」** —— 在我的設計裡不成立，
因為近區隊數本來就跟著總隊數 1:1（force_full_hd 讓兩者恆等）。
**長窗票那個「101→202沒放大」的發現依然有效**——只是它測的是「總隊數(=近區隊數)」這個自變數，不是被稀釋掉的近區子集。

★若你要的是「正常 LOD 開啟時，近區隊數遠小於總隊數」那個情境下的 spike 成本——
那需要跑 `force_full_hd=false` 的 regime，但那樣 near/far 批次會混進其他 LOD 機制，
`near.faction_ai` 這個 phase 分組就不會像現在這麼乾淨可歸因。**這是取捨，不是我漏做**——
先講清楚，若你要那個 regime 我再開一輪。

---

# ★radius12 跑況

已在跑（第21筆checkpoint），不受這個問題影響（近區=總隊數在兩種 radius 下都成立，
公平比較 tile 數這個自變數不需要改動）。跑完後連 radius18 一起報。
