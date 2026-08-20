# docs 瘦身總掃：systems 格刪改清單（**不動刀**、待用戶勾）

date: 2026-08-21 ／ owner: systems ／ 判準六條見 blueprint 工單 v2
★**界線（blueprint 已認可）**：**只標「規範語句與新法牴觸」者**；**歷史紀錄保留**，必要時加一行「後續由 X 取代」指標——**不見 LOD 就殺**。

## 規模
`process/` 13 檔 1193 行｜`invariants.md`｜`progress.md`｜`known_issues.md`｜`CLAUDE.md` 91 行｜domain 6 檔 1108 行。

---

## 【改指標】① 與新法牴觸（規範語句；**現在仍正確、落地後失效** → 加指標不刪）
| 位置 | 現況 | 建議 |
|---|---|---|
| `world.md:86` **「## LOD 分區模擬」** 整節 | 描述 near/far 分區 ＝ **現行實作**（零 LOD 尚未落地） | ★加一行：「**效能 arc〈事件比例計算〉落地後本節作廢、由該 arc 重寫**（模擬層零 LOD、計算跟隨事件密度）」 |
| `invariants` 〈LOD 降頻補償紀律〉(:458) | **G（零 LOD）之前完全有效** | 加一行適用範圍：「**零 LOD 落地後，本節僅適用於仍存在的降頻機制**」（效能 plan §4 已寫，同步標在條文上） |
| `invariants:420` 優化兩道分類 | 仍有效（安全道/行為影響道） | **不動** |
| `invariants:183/184` nearby-scan LOD landmine｜`last_tick` 語意 | ★**與零 LOD 無關**（講的是 belief last-seen vs live god-view） | **不動**（避免誤殺） |

## 【瘦】④ domain docs 死常數（glance-aid B 判準：**不寫死常數/公式、改指 code**）
裸數字命中：`world.md` **7**／`person.md` **13**／`team.md` **6**／`event.md` **2**／`message.md` **1** ＝ **29 處**。
★建議：**逐處改成「見 `<file>.<CONST>`」**，保留**意圖敘述**、刪掉**數值**。
★**特別注意**：時間包落地後全常數改小時制宣告 → **現在寫死的數字會集體過期** → **這批的優先級應排在時間包 S1 之後**（否則改兩次）。

## 【改狀態】⑥ `known_issues` 今日已修/已翻案（**不是刪、是標結案 + 指向根修**）
| 條 | 現標 | 建議 |
|---|---|---|
| `:84` specimen 非中立性 | ⛔ | ✅ **根修已 merged**（EWMA advance/gather 解耦；oracle 1200t 零分岔）→ 標結案、指向該 slice |
| `:162` 無玩家 headless ＝個體反應層從不執行 | ★★★擋考級 | ✅ **已 merged**（LOD 紅線修；rate-equivalence 1.00） |
| `:154` 舊 warring 長跑靜默凍結 | 🧊 | ⚠ **機制已修**（觀察者永不凍結）**但歷史資料仍受污染** → 改標「**修法已落地；舊檔案的結論仍需按 signature 自查**」 |
| `:185` 人口不成長 | 👶 待分解 | ⚠ **機制已修**（生育連續速率）**效果待量**（AT_CAP 短跑）→ 改標「已修、待驗」 |
| `:202` `gather` 有寫副作用 | 🔬 | ⚠ **部分修**（`need_urgency`/`plan_phase` 已移出；**cache 群仍在**）→ 標「部分修、餘項另案」 |
| `:74` SurvivalMergeIn churn | ✅ 已標 | **不動**（示範格式） |

## 【改狀態】② `progress` 已完成 arc 的過程殘留
「在飛／HOLD／待 merge」**14 處**，其中今日已 merge：§4a/§4b/§4c／繼承-lite／EWMA 解耦／LOD 紅線修／生育／命令戳記／owner-outpost 索引／大考 harness。
★建議：**逐條改為已完成 + 保留結論**（**過程敘事可瘦**，但**推翻/自糾的紀錄一律保留**——它們是判斷力的證據，刪了會重犯）。

## 【待確認】③ SUPERSEDED 標記 16 處
需**逐條確認是否真的死**（有些是「被取代但仍是唯一紀錄」）→ ★**本輪只列出、不建議動**，避免把唯一紀錄殺掉。

## 【不動】⑤ 重複描述
`process/` 各角色檔與 `00_roles` 有必要的重複（**角色檔要能單獨讀**）→ ★**不建議去重**；真正該去重的是**同一事實在 invariants 與 domain docs 兩處各寫一遍**（本輪未發現明確案例）。

## ★CLAUDE.md
本輪**未提任何改動**——它 91 行、且**任何改動需用戶核可**；目前內容與新法**無牴觸**（它講的是工作流與指令，不含被推翻的機制描述）。


---

## 【補掃】`process/` 12 檔（2026-08-21 續掃）

### ★最重要的一項不是「牴觸」而是「**找不到**」——新法沒有入口指標
**除新立的 `09_exam_gate.md` 外，沒有任何 process 檔／`CLAUDE.md` 提到今日新法**：
- **執行失敗反饋鐵律**（住在 `invariants.md`）
- **長考閘**（住在 `process/09_exam_gate.md`）
- **事件比例計算**（取代「LOD/重要性」；住在 spec + `progress`）
→ **下一個 session 開場讀 `00_roles` 時，找不到今天立的法**。
**建議【改指標】**：
| 檔 | 加什麼 | 備註 |
|---|---|---|
| `00_roles.md` | 文檔導覽表加三行：失敗律（invariants）／長考閘（09）／事件比例計算（取代 LOD 語彙） | systems owner、**可直接改** |
| `01_architect.md` | 「寫 spec 前必讀」清單加：失敗律 + 長考閘 | systems owner |
| `CLAUDE.md` | 文件位置表加 `09_exam_gate.md` 一行 | ★**需用戶核可**、只列不動 |

### 其餘 process 檔：**體質良好，本輪不建議動**
- `04_qa.md`：release-gate 暫停**有完整 banner + 可逆條件**（「轉自動交付則硬閘回歸」）＝**不是 stale**、標註方式正確。
- `06_pipeline_orchestration.md`（5 行）＝ **標準 tombstone**（作廢宣告 + 現行權威 + 「勿依本 doc 操作」）→ ★**判準③「SUPERSEDED 沒標死」的範本**，其餘該標死的可照抄此格式。
- `07_orchestrator_machine.md`(98)＋`08_machine_workflow_v2.md`(85)＝機器軌 183 行，而 `CLAUDE.md:72` 定位為**少用**（只大/並行活才上）→ **【瘦】候選**：留「何時該上機器軌 + 入口 + 成本警語」，細節壓縮；**但不刪**（軌仍可用）。

### 歸檔項：**已由 blueprint 完成**（specs 112 檔 + handbacks 1080 封 → `_archive/`、`commit 56463a14`、全 `git mv` 可逆）→ 本清單不重複列。
★`2026-08-20-faction-succession-lite-HOW.md`：**確認可歸檔**——slice 已 merge（`d11550a4`）、§5 必查項已接線、產出的契約已入 `invariants`〈死亡窗口（走屍隊）決策紀律〉，**spec 本身無殘留未落地內容**。
