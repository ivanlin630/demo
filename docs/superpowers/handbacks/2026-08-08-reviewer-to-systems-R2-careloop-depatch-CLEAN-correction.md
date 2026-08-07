---
from: reviewer
to: systems
status: consumed
topic: "[R②判決=CLEAN+1輕量必查項(HOW-binding文字跟code snippet有落差,非阻塞但需訂正措辭)] care-loop scout de-patch——premise親驗坐實:親讀_dispatch_care_scout現況(faction_ai_system.gd:5110-5123)逐字對得上spec引述,:5114-5116 vpos==(-1,-1) silent-return死鎖真實存在,R①免成立;①感知鐵律:親讀_faction_roster_pos完整body(:4664-4677)確認這不是這輪新寫的函式,是既有已gate-ok標記的組織常識accessor(:4671行內註解legit intra-faction結構),5道邊界(①只tile_pos零live-state②只固定outpost③同faction gate④當下faction_id snapshot known-gap⑤隱匿據點旗)逐條讀code坐實,scout仍走dispatch_anon_messenger物理送+founding_timeout延遲,roster只解『村在哪』不洩漏『村怎樣』,無god-view偷渡;②③own-faction/throttle保:親讀:5111throttle guard(pop<2/_has_inflight_info)跟:4665-4669 own-faction gate皆現有code、這輪fix完全沒碰,保序成立;④零crank:_pick_care_reaction(:5126-5129)care/ignore util formula這輪零改,坐實;⑤staged scope:'care-loop第一刀+量death-spiral破否再定要不要follow-up'的階段化做法正確對應feedback_patch_gate_first(找到執行斷點=de-patch非補償補丁)+避免feedback_whole_system_first講的piecemeal症狀打地鼠(這輪不是症狀補丁,是抓到真execution-break後的定範圍de-patch,非同一種病);★但★發現一處HOW-binding文字表述跟真code snippet有落差:spec§1明講『belief優先、roster僅fallback...不覆蓋既有belief-based行為』,但親讀§修的code snippet(第22-27行)發現新版直接把原本三層fallback(belief.tile_pos→entry.get(last_known_pos)→(-1,-1))砍成兩層(belief.tile_pos→roster→(-1,-1)),中間那層entry.last_known_pos(:5114現況確認存在、來自_ledger_record:5107存的belief快照)被整層拿掉換成roster,非單純『補一個缺口』——親查_ledger_record生產holding entry只服務is_resident_static目標(:5103守衛)這件事讓兩者實務上幾乎收斂(resident村位不太會變、roster讀當下outpost位比舊belief快照更新鮮,遷村後roster甚至更準確非更差),判斷這個落差對行為影響低,但HOW-binding的文字宣稱('不覆蓋既有belief-based行為')技術上不精確,應該訂正措辭講清楚entry.last_known_pos這層被roster取代的理由(非只是補洞、是刻意换成更新鮮的同語意來源),非阻塞但要求訂正文字避免未來誤讀;判決=CLEAN+1輕量必查項(訂正§1措辭,非要求code變更)→鎖→build(scout真fire驗)→量(death-spiral破否)→QA specimen→merge"
---

# R②判決：care-loop scout de-patch HOW — CLEAN + 1輕量必查項

## premise 親驗坐實（R①免成立）
親讀 `_dispatch_care_scout` 現況（`faction_ai_system.gd:5110-5123`）逐字對得上 spec 引述——`:5114` 的 `vpos = BeliefSystem.best_estimate(...).get("tile_pos", entry.get("last_known_pos", Vector2i(-1,-1)))`、`:5115-5116` 的 `if vpos == Vector2i(-1,-1): return` 這個 silent-return 死鎖真實存在。measurer 標的「30+ 次 care 決定全零 dispatch」、「Team2 從沒 belief（7-8hex 超觸及）」是這個 gate 造成的具體後果，因果鏈成立。R①免（premise 已 file:line 坐實）正確。

## ①感知鐵律——roster fallback 不是新寫的、是既有 sanctioned 組織常識，位置零洩漏
親讀 `_faction_roster_pos` 完整 body（`:4664-4677`）——**這不是這輪新寫的函式**，是既有、已經帶 `gate-ok` 行內標記（`:4671`）的組織常識 accessor。5 道守界逐條讀 code 坐實：
1. 只回 `tile.tile_pos`，零讀 runway/resources/pop 等 live-state（`:4676`）
2. 只固定 outpost（迭代 `outpost_level>0 and outpost_owner==target_id`，移動隊/無據點隊自然落 -1）
3. 同 faction gate（`:4665-4669`，非自家 faction / factionless target → -1）
4. 當下 `faction_id` snapshot（known gap，非用戶要求的 frozen-snapshot，non-blocking）
5. 隱匿據點旗（`:4674-4675`，`outpost_hidden` → 不上名冊）

scout 拿到 `vpos` 後仍走 `SubteamSystem.dispatch_anon_messenger`（`:5118-5120`）物理派出、`founding_timeout(dist)` 延遲抵達——領主**不**因 roster 就知道村餓/狀態，那要 scout 真的抵達才觸發 firsthand 觀察（`_tick_info_scout` 走的路徑，這 session 領主照護 loop 那輪已審過的機制）。roster 只解「村在哪」，不洩漏「村怎樣」——沒有偷渡 god-view。

## ②③own-faction / throttle 保序 — 坐實
親讀 `:5111` throttle guard（`team.population < 2 or _has_inflight_info(...)`）跟 `_faction_roster_pos` 內的 own-faction gate（`:4665-4669`）——這輪 fix 完全沒有碰這兩處，都是既有 code 原地不動，保序成立。

## ④零 crank / 零死常數 — 坐實
`_pick_care_reaction`（`:5126-5129`）的 care/ignore 競爭 util 公式這輪零改，spec 沒有夾帶任何新常數，純粹是位置解析邏輯的 de-patch。

## ⑤staged scope — 合理，非 piecemeal 症狀補丁
「care-loop 第一刀 + 量 death-spiral 破否 + 求援-ordering/propagation 待量後定」這個階段化做法對應 [[feedback_patch_gate_first]]（找到真執行斷點=de-patch、非補償補丁）——這輪抓到的是一個具體、已用 measurer tap 坐實的 execution-break（scout 從未 fire），修的是這個斷點本身，不是在症狀層面加補償邏輯，跟 [[feedback_whole_system_first]] 警告的「piecemeal 症狀打地鼠」不是同一種病。iii factionless-death-spiral 深根明確標記為「cohesion territory、用戶 WHAT 裁、本批不動」——邊界守得住，沒有把 blueprint 的願景決定權吃掉。

## ★（輕量必查項，非阻塞）HOW-binding §1 措辭跟真 code snippet 有落差
spec §1 明講「belief 優先、roster 僅 fallback...**不覆蓋既有 belief-based 行為**」，但親讀 §修 的 code snippet（第 22-27 行）發現新版把原本**三層** fallback（`belief.tile_pos` → `entry.get("last_known_pos",...)` → `(-1,-1)`）砍成**兩層**（`belief.tile_pos` → `roster` → `(-1,-1)`）——中間那層 `entry.last_known_pos`（`:5114` 現況確認存在，來源是 `_ledger_record:5107` 存的 belief 快照）**整層被拿掉**，換成 roster，不是單純「補一個缺口」。

親查 `_ledger_record` 的 `"holding"` 種類 entry 只服務 `is_resident_static` 目標（`:5103` 守衛）——這代表兩者實務上幾乎收斂：resident 村的位置不太會變，roster 讀的是「當下 outpost 位」，比舊的 belief 快照更新鮮；就算遇到遷村令改了 outpost 位，roster 甚至比舊快照更準確、非更差。判斷這個落差對實際行為的影響很低，但 HOW-binding 的文字宣稱（「不覆蓋既有 belief-based 行為」）技術上不精確——它確實**替換**了一層，只是替換成同語意但更新鮮的來源。

**要求**：訂正 §1 措辭，講清楚「`entry.last_known_pos` 這層舊 belief 快照被 roster（更新鮮的同語意組織常識）取代，非單純補洞」，並簡短記下理由（holding entry 只服務 resident、位置穩定、roster 讀更即時）。這不需要改 code，只是要 HOW 文件對自己實際做的事講精確，避免未來有人對著這段文字誤以為三層 fallback 全保留。

## 判決
**CLEAN + 1輕量必查項（訂正 §1 措辭，非要求 code 變更）→ 鎖 → build（scout 真 fire 驗）→ 量（death-spiral 破否 + care-loop 單修是否足）→ QA specimen（scout→親見→relief→Team2 defect 前得救）→ merge → re-measure scale。**
