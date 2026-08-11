---
from: qa
to: measurer
status: consumed
topic: "[統一派遣specimen稽核verdict]①manufacture main0→branch15:非純RNG巧合(有真architecture-level divergence佐證:anon 4→0 vs穩4/幽靈團殘留2個/team count 6→4/scout 4→2,commit 285bca8f坐實)但Team1自己從未scout/care/rescue過→直接因果鏈未可溯,判『可信但非直接可溯,建議多seed』②Team0 44/45天空巢:ticket假說(重複觸發無throttle)證偽——throttle(_has_inflight_info)正常運作+scout.dispatched全程僅2次非loop;真因=285bca8f把scout/care/rescue改named-led(借最低統領記名,無spare不派=genuine『領主少做』設計),Team0幾乎沒有spare記名→僅有的1個被長途scout任務占用未歸,非bug非迴圈;反而BEFORE(main現HEAD)才有真bug(784 succession safety net誤升anon→named→幽靈團),已被這次fix修掉"
---

# 統一派遣 re-measure 雙 specimen 稽核 verdict

## Q1：manufacture.fired main=0→branch=15，真因果還是 RNG 巧合？

**讀 specimen 先發現一個岔路**：AFTER-branch specimen 的「想什麼.candidates」裡 `build_apothecary:location:delegate` 全程 `nd:true`（不可選，util=0.98 是假象上限，從未真的贏過），BEFORE 也一樣。查 code（`goal_resolver.gd:375`）：**owner 在場（Team1 一直站自家 outpost）→ GoalResolver 直接 defer 給另一條「infra path」（`_pick_facility`/`_evaluate_infrastructure`，`faction_ai_system.gd:4026`），不生這個 candidate**。所以你我一開始盯的這份 candidate 清單根本不是真決策路徑（跟 scout/herald 側動作一樣，是 specimen 主 tap 照不到的側路）。

真決策路徑 `_pick_facility`：score = 地利 × (1+缺口) × 人格，**純算術零 randf**（我讀了 `_facility_score`/`_facility_deficit` 全文，沒有任何 random 呼叫）。缺口 = `NeedOracle.need_keep`（藥品 need_keep，隨人口/存量算）。這代表：**picker 本身不隨機**，AFTER 蓋成 apothecary 純粹是因為 Team1 在 AFTER 的人口/物資軌跡先跨過門檻，不是 picker 那一刻擲骰擲到不同結果。

15 次 manufacture 全部同一隊同一設施同一產品（`[Manufacture] Team1 medicine worker_rate=0.16` ×15），前面接一條乾淨的 `[Outpost] Team1 設施施工 apothecary→Lv1 at (17,26)`——**不是散落多隊多產品的雜訊，是單一 build→produce 因果串**，這點支持「不是純巧合」。

但我進一步查了為什麼世界軌跡會岔開——**找到真正的分岔源**：unified-dispatch commit `285bca8f` 把 scout/care/rescue 從 `dispatch_anon_messenger`（生 leaderless 孤匿名子隊）改成 named-led `dispatch()`。查 daily_log 硬數字（不是我猜）：
- BEFORE：Team0 `anon_t0` 4 天內 3→0（耗盡）、`named_t0` 1→4（暴增）、`final_team_count=6`（比 AFTER 多 2，幽靈團殘留）。
- AFTER：`anon_t0` 全程穩定=4（零耗損）、`named_t0` 44/45 天=0、`final_team_count=4`（無殘留）。
- `scout.dispatched`：BEFORE=4、AFTER=2。

這組數字跟 commit message 自己記錄的 fp 證據（`anon 池 4→0→4→4`、`團數 peak7/end6→peak5/end4`、`scout.dispatched 4→2`）**完全對得上**——這不是隨機位移的噪音，是一個被驗過 17/17 單元測試 + determinism 的**真實、大幅度架構行為改動**。所以「code 分岔」這件事本身是真的、幅度不小，不是「巧合落在不同結果」那種淺層 RNG 位移。

**但**——我查了 BEFORE-main 的 raw log：**Team1 自己整場從未親自做過 scout/care/rescue**（grep 全無命中）。所以「不再頻繁失去記名成員」這條 measurer 假說的具體機制，**沒有直接證據落在 Team1 自己身上**——Team1 的人口/物資軌跡差異（BEFORE day36.75 pop10、AFTER day29 pop12）比較像是這個大幅度世界分岔的**間接下游效應**（faction 層級的連鎖position/資源位移），而非「Team1 自己少失去人→多勞力去蓋」這條字面因果鏈。

**判定**：相關、且有真實非平凡的架構級分岔佐證（不是我不敢排除的那種淺層巧合）——但 Team1 自己這條因果鏈**讀不出直接 motive→action→outcome**（它沒有自己的 scout/care/rescue 記錄可查）。報「可信但非直接可溯，建議多 seed 確認幅度/方向是否穩定」，不建議直接拿 15 這個數字當這次 fix 的量化證據。

## Q2：Team0 named roster 44/45 天空巢，故事合理嗎？

**ticket 假說先證偽**：查了 `_try_scout_side`（目前 main HEAD 版本，你 AFTER 用的是 285bca8f 之後版本，行為不同，見下）跟 `_has_inflight_info` throttle（`faction_ai_system.gd:2071`，一隊一 in-flight scout，機制正常）。更關鍵：**AFTER-branch 的 `scout.dispatched` 全程只 2 次**（daily_log counts 最終值）——不是「每次記名成員一回歸就立刻重派」那種高頻迴圈，2 次的量級跟「重複觸發無 throttle」的故事對不上。

**真因（讀 285bca8f commit diff 坐實）**：這次架構改動把 scout/care/rescue 改成 named-led——新函式 `_pick_dispatch_runner` 借「named_members 中統領最低者」當跑腿（留親信辦要事），**無 spare 記名 → 直接不派**（commit message 原話：「§2 named-scarcity genuine 戰略約束=領主少做、非 crank、非孤匿名頂替」）。

Team0 的 `named_t0`（`t.named_members.size()`，不含領主）daily_log 顯示：AFTER 全程幾乎=0（僅 day19 曇花一現=1，隔天打回 0）；BEFORE 反而 day1-5 就從 1 衝到 4 且穩住到底。**這個 BEFORE 的高 named 數，不是「正常成長」——是 commit message 自己標的 bug**：leaderless 匿名子隊 → `faction_ai:784` 的 succession 安全網每 tick 誤判它是「真領隊死亡」而誤升 anon→named（幽靈 named 團），也解釋了 BEFORE `final_team_count=6`（2 個幽靈團殘留到結尾）vs AFTER `=4`（乾淨）。

所以 Team0 在 AFTER「44/45 天空巢」= **genuine 設計行為**：Team0 手上記名人力本來就緊（沒有多的可以留守+外派兩全），唯一/僅有的 spare 記名被派去執行一趟耗時的偵察任務（單趟含移動+timeout，2 次派遣吃掉 44 天不算離譜），任務沒完成前母隊就是沒有 bench——這不是重複觸發 bug，也不是 throttle 失效，是這次架構改動刻意選擇的「寧可少做事、不拿匿名頂替」設計後果。是否要調整（太嚴格/難度曲線）是用戶/blueprint 的裁決範圍，不是 QA 這關要判的 bug。

★這條完全對得上 systems 你們自己 commit `70ff16eb` 訊息裡寫的「named-scarcity 真+strict(Team0 無 bench)=待用戶判」——我這輪 specimen+code 稽核是獨立驗證，沒有新矛盾，等於幫這條下了 QA 背書。

## 總結

兩題都不是「random 巧合」，也都不是「重複觸發/throttle 失效」這類 bug 故事。Q1 是真架構分岔但 Team1 自身因果鏈非直接可溯（可信但需多 seed）；Q2 是 genuine 設計行為（named-scarcity 真+strict），throttle 正常，無迴圈。

---
*QA 驗收官 · 2026-08-11*
