---
from: blueprint
to: systems
status: consumed
topic: workflow改(用戶定案):①QA加回=故事性判官(全量trace判motive→action→outcome)②全量暫態可觀測性=不變量(code改不准留盲點)——本session thrash+tap-gap血證
---

# workflow 改：故事性 QA + 全量暫態可觀測性（用戶定案 2026-07-14）

用戶親定兩件。藍圖定 WHAT + 血證，系統 owner 落地（改 owner docs + memory）。**不動已 merged 的 Slice A（a630f2ab）；本 workflow 對後續 slice 生效，thrash-fix slice 當首個試驗。**

---

## 決策 1：QA 加回工作流 = 故事性判官（非第六角色）

**QA 擴充職能，非新開角色**（用戶明選 QA）。maker 外獨立腦判故事性 = 其 adversarial 判決自然延伸。

**流程位置**：量測完成後 → QA 讀**全量 specimen trace** → 判故事性合不合理 → 餵藍圖。

**故事性 = 好戲關做成可稽核閘**（[[project_playable_priority]] 四關之首「好戲」）。**聚合 metric 過 ≠ 好戲過**——需人讀全量 trace 判。

### 故事性定義（藍圖定，QA 據以判）
一條命/一個大事件過關 = **motive → action → outcome 鏈完整**：
- **動機看得到**：為何做此決策（decision trace：候選/winner/理由）
- **行動配動機**：真去追了（非想做卻做不成）
- **結局配行動**：死/贏得合理

### 反例表（本 session 抓到的不合理故事）
| 死法 | 合理? | 判準 |
|---|---|---|
| thrash 餓死（想買糧 122 次被打回 idle） | ❌ | 手不聽腦 bug，像自殺實為控制層打架 |
| 有錢餓死（coin=47 沒買糧） | ⚠ | 看資源+想法才判：賭徒好戲 or 引擎失靈 |
| idle 餓死（從沒嘗試） | ❌ | 躺平，用戶已否決 |
| 窮死（用盡覓食/乞食/掠奪/併入才死） | ✅ | 合法悲劇 |

**願景錨**：餓死可以，但**沒有隊伍能坐著/掙扎落空地餓死**。死前必須奮力求生（絕境階梯：覓食→乞食→掠奪→併入），用盡才准死。零被動/thrash 餓死。

### memory 更新（系統單寫者）
[[feedback_qa_inversion]] 需修：2026-07-09「QA release-gate 砍、pass 權→藍圖」仍成立，但 **2026-07-14 QA 以「故事性判官」身分加回**（非 release-gate，是量測後故事稽核餵藍圖）。user-in-loop 下 release-pass 仍藍圖。

---

## 決策 2：全量暫態可觀測性 = 不變量（用戶定）

**code 不管怎麼改，所有暫態都要量得出。任何改動不准製造量測盲點。**

**「暫態」= 故事判斷可能依賴的一切瞬時狀態**：
- **想法**：decision trace（候選/winner/理由）、控制流轉換（如 `idle↔貿易` thrash）
- **狀態**：pop/food_days/威脅/意圖/子隊關係
- **資源**：coin/food/weapons/庫存

**規則**：新增任何決策層/資源/狀態機 → 必須同步接進量測 tap。**新增盲點 = 違規**（與憲法閘同級，該被閘擋）。

### 血證（本 session，強制觸發此原則）
- **SpecimenTracer tap 沒接 order 系統** → `decision_count=0` 假象 → **差點誤判「架構絕症」**（第一次量測結論，第二次同世界 reeval 才推翻）。
- **thrash 抓得到純因 `[Survival]` 轉換有 log**；沒 log = 永久盲點，故事崩在哪永遠看不出。
- 盲點會**捏造假故事 + 誤導判決** → 這是不變量而非 nice-to-have 的理由。

### 現實校準（藍圖給，免落地做歪）
「所有暫態每 tick 全 dump」爆 perf（fullprobe 已重）。可實作版：
- **tap 必須存在、零盲點**（可觀測性=不變量，不打折）。
- **dump 可 scope**（specimen 鎖隊全量 / probe 抽樣），不必全世界每 tick 全記。
- 原則不稀釋（不准有量不到的暫態），**perf 平衡 = 系統 HOW**。

### 落地建議（系統定 HOW）
- 寫 `invariants.md`：全量暫態可觀測性不變量 + 定義 + 血證。
- 觀測盲點閘（憲法閘同精神）：新增 decision/resource/state 未接 tap → FAIL。可行性系統評。
- `03b_measurer.md`：量測員標準床升級為**逐 specimen 全量 dump**（想法+狀態+資源時序），非只聚合計數。
- `04_qa.md`：QA 故事性判官職能 + 判準表。
- `00_roles.md`：QA 五角色回歸（故事性判官身分）+ 接力流向加「量測→QA 故事稽核→藍圖」。

---

## 溯源（本 session 血證檔）
- thrash 實錄：`docs/measurements/2026-07-14-sliceA-reeval-attribution-branch-67d4a47.log` line 4242-4425（Team14 subteam `貿易↔idle` 抖 122 次，days_left 2.7→0 餓死；期間 line 4348 urgent 還 buy weapon×6）
- tap-gap 假象：`docs/measurements/2026-07-14-samewrld-team14-deathcause-67d4a47-dirty.log`（decision_count=0 但死時 coin=47/weapons=3/food=0）
- 同型 Team10 thrash：`docs/measurements/2026-07-13-roach-scan-team10-thrash-1337.log`（早於 slice A → thrash 是舊病非本 slice regression）

## 不擋什麼
- Slice A 已 merged（a630f2ab），本 workflow 不回改它。
- tuning follow-up backlog（歸藍圖）待用戶 greenlight；開 slice 時**「層5 餓時食物壓過軍備」方向已被本 session 推翻**，真活=thrash-fix（求生 fire 後鎖執行到買糧單下成，別每 tick 被底層任務打回 idle）。走 patch-gate-first 查誰在跟求生控制器搶。
