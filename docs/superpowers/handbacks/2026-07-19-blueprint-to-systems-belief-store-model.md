---
from: blueprint
to: systems
status: consumed
topic: "[belief/知識 store 模型·brainstorm 定案] awareness arc 地基。8 點:兩store統一/三級volatility/不evict留全部+決策filter/★monotonic-id硬前置(修確認bug _next_team_id max+1回收)/恩仇掛人vs團/世界特徵belief/message→belief橋/隊數有界+安全閥。全落 game-design 資訊系統章。HOW+byte-identical驗=你。"
---

# belief/知識 store 模型（一場藍圖×用戶 brainstorm 定案 2026-07-19）

全文已落 `game-design.md` 資訊系統章「★★ belief/知識 store 模型」節（承「永遠要傳播」+ 感知鐵律）。此 handback＝交你做 HOW 的摘要 + 前置 + R①。

## 8 點模型（WHAT，game-design 為準）
1. **兩 store 泛化統一**：`team_known`（事件流）+ `team_intel`（對隊估計）→ 一個統一知識 store，鍵 entity（隊/世界特徵/…），擴充性優先（用戶 #1）。
2. **三級 volatility**（decay 配被記物變多快）：永久（存在/身份/恩仇/市場位置，免衰減、只矛盾事件翻）/ 低頻（leader/派系/據點，事件更新、不衰減）/ 高頻（位置/戰力/情緒，時效衰減→過期未知）。
3. **不做硬 eviction，留全部 + 決策時 filter**：拆「記憶體 bound」vs「決策相關性」；相關性＝決策 filter（fresh OR 重要納入；過期+不重要＝記得但不判別），不刪。高頻層古老無用可丟（省記憶非忘身份）。
4. **★★monotonic id（硬前置 + 修確認 bug）**：`_next_team_id`＝`max(live)+1`（6 份重複：game_setup:416/subteam:237/manpower:228/population:77/reaction:330/recruit_tutorial:29）→ **回收死 id → belief 冒名頂替**（team100 死→重用）。修＝持久遞增單一源 counter，死 id 永久退休。`_next_person_id` 同病。**belief key 前提，優先做。**
5. **恩仇掛人 vs 掛團 雙 key**：人仇隨人（RelationGraph 孤兒/未接）、團仇留團。key 支援兩種，真接 RelationGraph＝維度5 後續。
6. **世界特徵 belief（gap A）**：市場/據點/資源＝entity，存在永久/存貨高頻，發現/聽說才進 → 修 `has_food_market`/`_nearest_market_outpost` 讀 belief。
7. **message→belief 橋（gap B）**：事件到達更新 entity belief（成長→實力估計↑→威脅判斷看得到，接 Slice D 威脅讀 belief）。現兩 channel 脫節要接。
8. **隊數有界 + 安全閥**：隊數 bound＝belief/perf 共用前提（一人隊非 viable+anon-cohort+named 率）；belief 安全閥（高水位只砍垃圾＝無關係+早死+瞥一次，永不砍恩仇/大勢力）＝縱深優雅降級。

## 前置序（你調 HOW 切法）
- **monotonic id ＝硬前置**（belief key 前提 + 乾淨 unification 6→1，可能 byte-identical 驗如 Arc1 mode）。**先做。**
- 其餘接 awareness/god-view 殲滅 arc（現在飛 slice2 → F/E/D）。belief-store 泛化是較大結構工，排在 god-view 後門殲滅之後或並行，你定。

## R①（spec 前驗，別憑舊 memory）
- monotonic id migrate 對現有 save/測床影響（id 值變）；6 份 `_next_team_id` 收單一源真無回歸（byte-identical?）。
- message→belief 橋現況：事件訊息到底有沒有 record_claim 更新 belief，還是純進 team_known（gap B 真缺?）。
- 世界特徵有沒有既存 belief store 或全 god-view（gap A 確認）。
- 三級 volatility 落地：現 belief claim 全同 decay，分級要不要拆 claim 結構。

## 注意
- **byte-identical refactor 驗**（統一/遷移類，遷了不變＝無回歸最強證據，接 Arc1 模式）。
- 稽核 over-count 前科（R① 屢打臉 + 你 grep bug）→ 列缺口每項先 verify。
- 每 slice R②。

## 溯源
本 session brainstorm（訊息+記憶架構 → volatility 三級 → id 回收 bug grep 坐實 → 不 evict 留全部 → 極端 case 安全閥）;game-design 資訊系統章 belief 模型節（本輪落）;belief_system.gd/message_system.gd/game_setup:416 `_next_team_id`;[[project_anon_cohort_refactor]]（隊數 bound）;[[project_unification_matrix]]。
