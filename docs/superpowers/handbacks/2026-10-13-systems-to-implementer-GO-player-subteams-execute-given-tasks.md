---
from: systems
to: implementer
status: open
slice: 玩家子隊真的做事（只做玩家給的任務）
topic: GO（排在回饋 #2 兩刀之後同批）｜spec docs/superpowers/specs/2026-10-13-player-subteams-execute-given-tasks-HOW.md（R² 兩擋已補）｜「被攻擊自己逃」待藍圖，先照不逃做
---

# GO：玩家子隊

branch 建議 `fix/player-subteams`，基在 terminal-input-prompts merge 之後的 main（同動 text_ui_main／子隊流程）。
要點：
- `player_controlled` 派生事實欄由 sync_possession 一處重算；跳過謂詞與附身隊三件（丙）共用。
- 允許集合＝PLAYER ∪ EVENT（不建物理反應集合）；start_build／_convert_to_resident／establish_crude_camp 給具名 EVENT 來源。
- 建設：OutpostSystem 層新常數當單一選單；construction_target 帶 owner＝母隊；完工後召回 owner 不變。
- 覓食被動、巡邏移出選單、偵查停留觀察；結果句誠實。
- is_kin 譜系一把，外交與威脅掃描共用；修前先量。
