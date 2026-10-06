---
from: systems
to: measurer
status: consumed
slice: 「玩家死後 N 天」specimen（給 QA 故事稽核）
topic: ★藍圖裁（2026-10-06）：故事結束票 merge 後世界不再停 ⇒ 請 QA 讀「玩家死後 N 天」世界有沒有繼續合理地動 ⇒ **你產 specimen、QA 讀**｜★並行、不擋用戶（他已經在玩）｜★交件必標【已落地 exact path】並開檔驗它存在
---

# 一、為什麼要這一份

```
故事結束（票 #2，merge `d415a5791`）把 `sim_runner.gd` 那個 early return 拿掉 ⇒ 玩家絕後之後世界照跑
⇒ 這一輪只驗了**機械性質**（tick 推進、旗標照設、fp 床結構上不受影響）
⇒ ★**沒有人讀過「玩家死後世界繼續跑」那段故事** ⇒ 工作流規矩：行為結論要 QA 讀 specimen
```

# 二、佈置（★照既有先例，不要發明）

```
·樹：`origin/main` ≥ `78e42f776`（★sha 印在輸出第一行 —— 主詞跟著數字走）
·世界：正常 worldgen，先跑到「有一點歷史」再殺玩家（★建議先推 3 天：tick 0 就殺的話，
  母體太年輕、什麼都還沒發生，QA 讀到的「沒事」分不出是世界停了還是本來就沒事）
·殺玩家：照 `scripts/debug/story_end_not_physics_bed.gd:67-73` 那條（★真的寫入者）
  ⇒ 抹掉玩家（`persons.erase`）＋ `EventSystem.new().handle_player_succession(ws, pt)`
  ⇒ ★斷言 `state.game_over == true` 真的成立再往下（母體地板：否則讀到的是一個沒死的世界）
·然後推 **N ＝ 7 天**（★理由：要涵蓋幾個決策週期與至少一次日界的經濟結算；跑法細節你定）
·specimen：`SpecimenDumpHelper`（`scripts/debug/specimen_dump_helper.gd`）
  ★要 motive → action → outcome（QA 要的是**故事**，不是聚合數字）
  ★抽樣：**原玩家隊**（它在玩家死後變成什麼？還在嗎？誰接手？）＋ **2-3 支鄰近 NPC 隊**
```

# 三、交件

```
·★【已落地 exact path】（開檔驗它存在）＋ 樹 sha ＋ 種子
·一行「這一份能答什麼／不能答什麼」（母體邊界：幾支隊、幾天、哪個種子）
·★你不下故事結論（那是 QA 的格）—— 但你看到**機械異常**（錯誤、tick 不動、某隊所有欄位凍結）要寫出來
⇒ 交給 QA（`2026-10-06-systems-to-qa-read-world-after-player-death.md` 已預告他），副本 to: systems
```
