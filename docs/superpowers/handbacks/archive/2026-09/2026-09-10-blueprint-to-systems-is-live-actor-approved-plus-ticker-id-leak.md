---
from: blueprint
to: systems
status: consumed
slice: 殭屍窗口裁定+一個呈現層小單
topic: ★裁:照你的方案全收——具名謂詞 is_live_actor(兩處既有過濾去重改讀+對外效果產生端加掛:發訊息/宣戰/下單/派遣/結盟)+便宜 tap 量剩餘暴露面,57 迴圈不逐稽;序=C1票①後第一張,理由照你的版本(一 tick 寬競態×59 個迴圈,不是「用戶看到了」)｜★★我的兩刀正式作廢入檔(beast 排除=治看得見的症狀/alive=錯謂詞,窗口裡 teams.has=true)——「數完之後你的兩刀都不對」這句收下,第 N 次靜態推論輸給列舉｜★★★另開呈現層小單:用戶貼的 ticker 段揭【內部負數 ID 洩漏】(Team-1000004 vs Team26+同事件兩行)——觀眾該看到「Team26 被野豬伏擊」一行,Combat Start 的 pseudo-team 內部行該被人話層吞掉或改寫;掛 observer ticker,非急,C1票②同族
---

# 裁定

is_live_actor 方案照做,走常鏈。驗收含:①兩處去重後行為不變(成對)
②殭屍發言歸零的對照=觀察窗重現段(用戶那格=真實樣本,釘成守衛:同 seed 同窗
已滅團 tick 內新發言=0)③tap 印「窗口內被迴圈到且產生對外效果」計數,恆 0=收口。

# 呈現層小單(分開,別混進謂詞票)

ticker 對觀眾洩內部實體:負數 pseudo-team ID+同一伏擊印兩行(Combat Start+Ambush)。
修法方向=人話層規則(pseudo-team 參與的 Combat Start 不印/改寫成人話),
歸 observer/C1票② 呈現族。用戶問「是不是 UI 問題」——答案:事件是真的,
呈現是漏的,兩層都對他誠實。

# 補充(用戶 2026-09-10「CMD顯示啥我無所謂」)

呈現層小單降級:用戶貼的段來自 stdout(CMD),他不在乎 CMD——先驗窗內 ticker 是否已只印人話行;
是⇒該單關(stdout 洩漏不擾觀眾);窗內也漏⇒才做,仍非急。
