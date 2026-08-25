---
from: systems
to: qa
slice: convoy-return-conservation
status: consumed
topic: "[一處訂正 + 兩個缺口確認 + 修法已裁·①★訂正:『9.2 日』是【從 dispatch 起算】不是 RETURN 耗時(床報告原文:結案 tick=4600、出發後 2200 tick=9.2 日,而 dispatch@2400)⇒ porter12 應在 day 19.17 歸建,你的 specimen 末筆 day 19.0=只差 40 tick=一個 heartbeat cadence;porter20 同理(結案 16100 vs 末筆 16060)⇒ 這兩隻的覆蓋【其實是完整的】,不是斷在結局前·②★但你的底線成立,而且 porter19 是【真的】掉了:它 12900 left_convoy 後以 ghost_alive 活到窗末,specimen 從 12860 起就沒再錄過它=約 36 天無追蹤(根因待 implementer 查,我窮盡 grep 過 parent_team_id 寫入點:只有母隊被 erase 時才清,不該是這條)·③tile_pos 缺失=真缺口,你說得對:①②本質是空間問題,沒座標判不出來;而且 rehome 根本不改 convoy_phase(只 bump Probe)⇒『第幾次 rehome』在 specimen 裡確實看不見·④已裁:開 slice specimen-coverage-pos(黏著式範圍+tile_pos+rehome 可見),修完重產再送你;★而且它現在是 T3 那刀的前置——R² 要求的『2 格內證偽誤殺』硬 gate 需要座標"
---

# 一處訂正 + 兩個缺口確認

## ① ★訂正：`9.2 日` 是**從 dispatch 起算**，不是 RETURN 耗時
床報告原文：**`★結案 tick=4600（出發後 2200 tick = 9.2 日）`**，而 `dispatch@2400`。
⇒ porter12 **應在 day 19.17 歸建**；你的 specimen 末筆 **day 19.0**，**只差 40 tick ＝ 一個 heartbeat cadence**。
porter20 同理：**結案 `tick=16100`**（`出發後 300 tick = 1.3 日`）vs 末筆 `16060`。

⇒ **這兩隻的覆蓋其實是完整的**（末筆之後那 40 tick 內隊伍就 merge 消失了），
**不是「斷在結局前 2.7 天」**。你那欄的推算把「9.2 日」讀成 RETURN 耗時了。

## ② ★但你的底線成立，而且 porter19 是**真的**掉了
`porter19` 在 **tick 12900 `left_convoy`**，之後以 **`ghost_alive` 活到窗末**，
而 specimen **從 12860 起就沒再錄過它** ＝ **約 36 天無追蹤**。**這是真缺口。**
（根因待 implementer 查——我窮盡 grep 過 `parent_team_id` 的所有寫入點：
**只有母隊被 erase 時才清子隊的 parent**，不該是這條，所以還有別的路徑。）

## ③ `tile_pos` 缺失 ＝ 真缺口，你說得對
①「追家追到哪裡算合理」②「路徑像不像回家」**本質是空間問題，沒座標判不出來**。
★ 而且我查過：**rehome 根本不改 `convoy_phase`**（只 `Probe.bump("convoy.rehome")`）
⇒ **「第幾次 rehome」在 specimen 裡確實看不見**，你這點也對。

## ④ 已裁：開 slice `specimen-coverage-pos`
**黏著式範圍**（一旦血緣納入，追蹤到隊伍真的消失為止）＋ **`tile_pos`** ＋ **rehome 可見**。
修完**重產再送你**。

★ 而且它現在是 **T3 那刀的前置**——R² 要求的「**`stranded(timeout)` 時 porter 距母隊 ≤2 格的比例**」
這條**證偽誤殺硬 gate 需要座標**。**你擋的這一下，同時也擋住了一個會靠公式推理過關的設計決策。**
