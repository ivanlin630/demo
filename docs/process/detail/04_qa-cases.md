# 04_qa 詳（按需讀）


## 四職


**★機器自身也會錯（2026-07-05 V2 教訓）**：判「斷鏈=矛盾」前**先驗 feasible counter 量的是不是同族群**——V2「征服 1529→0」是 sufficiency_bed 探針配對錯（feasible=conq.intent=unified-only by construction 空），measure 交叉驗同世界真行為 counter（攻擊 2/捕俘 3/同化 2）即翻。**斷鏈判決前必交叉驗同世界下游真行為 counter**;feasible=0 也可能是探針瞎非世界斷。

| # | 職 | 內容 |
|---|---|---|
| 1 | **充足性稽核判決官** | 跑/讀全系統率表（帶分母,R3）、世界句子審計（R4）,判決三類 **可解釋（附解釋句）/矛盾/未知**,出判決表 |
| 2 | **戲感觀者（③ owner）** | 開 GUI/讀 ticker dump 當觀眾——「觀者看得下去嗎」。**三量測軸（blindspot-axes）**：**觀看節奏**（1×/4×/MAX 各檔每真實分鐘幾件觀者在意的事;沒事=無聊/洪水=噪音;pacing=產品品質獨立於模擬正確性）、**世界間多樣性**（跨 seed:十個故事 vs 同齣戲換演員——主導 archetype/興衰 pattern/事件分佈差異度）、**新鮮度衰減**（事件型覆蓋耗盡速度:看多久不再有沒見過的事）|
| 3 | **release gate + ledger** | **★2026-07-09 硬閘職暫停**（release-pass 權→藍圖，見頂 banner）；仍**管理 `docs/escaped_defects.md`**（每筆逃逸→回溯哪層該抓→開補機器工項）——ledger 續存 |
| 4 | **UI 落差掃描** | 下方三類落差章節（原 04_qa 本體,保留） |
| 5 | **★故事性判官（2026-07-14 加回,見下 §第五職）** | 量測後讀**全量 specimen trace**,判 motive→action→outcome 鏈完整＝好戲關可稽核閘,餵藍圖 |

**邊界**：只找不修、不裁 WHAT（藍圖）、不修 HOW（系統）、不寫 sim code。
**輸出**：判決表/落差清單 → handback 交藍圖裁修序、系統修。
**頻率**：wave 邊界 + 任何東西交用戶之前（非每 merge;CI 常駐回歸管 per-merge）。**消費現成產出**（率表/ticker dump/截圖/GUI）,不重建 harness。
**★★每長跑 sim → 必送 QA 故事讀（用戶定 2026-07-22,綁 hook 非記憶）**：任何**長跑 sim**（warring/game_sim/world_sim/specimen/economy/despladder/detach/大窗——長跑=成本所在）產出後，**在拿去下 behavior 因果結論 / 鎖 spec / 餵藍圖之前，必經 QA 讀全量 specimen trace 判故事**。**★必附 specimen trace（`SpecimenDumpHelper`）——光 aggregate branch/baseline JSON，QA 讀不了 motive→action→outcome=履不了職（血證 2026-07-22 d26ae644：只 aggregate → QA 索 trace 卡住）。長跑順手掛 dump（§⑤）。****禁跳 QA 自讀 metric/樣本自判**（血證 2026-07-22 一日 3 次翻案：食物聚合誤讀 / facility-argmax 因果 / GateA divert-metric，全因結論建在未經 QA 故事驗證的 metric 上——metric 會騙[聚合沒拆/trace 不完整/算錯]，QA 讀真實事件故事才是 behavior 因果地面真相）。**沒長跑=不需 QA**（快跑 gate/import/_test 豁免）。**純聚合 metric 非下 behavior 因果者**（determinism byte-identical/doom% release-gate）可免。**機械強制=`.claude/hooks/longrun-qa-gate.sh`（PostToolUse，偵測長跑 godot→注入硬規則提醒，session 記憶不可靠故綁 hook）**。連 [[feedback_fileline_vs_interpretation]]。
**驗收鏈規則本體**（R1-R6/三層機器）見 `05_acceptance.md`。

必須先閱讀：
- docs/invariants.md（對稱性、UI 邊界等不變量——查對稱/邊界落差的依據）
- docs/process/05_acceptance.md（三層驗收鏈+R1-R6——判決依據）

（不需讀 01_architect/03_implementer：QA 只找不修,分層/實作是交修後主/子 session 的事。）

---

# 第五職：故事性判官（用戶定案 2026-07-14）

**流程位置**：`implementer → 量測員（全量 dump）→ 【QA 故事性稽核】 → 藍圖判`。QA 讀量測員產的**全量 specimen trace**（想法+狀態+資源時序），判**故事性合不合理**，出稽核 → 餵藍圖（非 release-gate；藍圖持 release-pass 權）。

**為何需要**：故事性=**好戲關**（[[project_playable_priority]] 四關之首）做成可稽核閘。**聚合 metric 過 ≠ 好戲過**——attrition/pop 這類數字達標，個別命運可能仍是「手不聽腦」的假故事。需一顆非蓋房者的腦讀**全量 trace** 判，非只讀聚合計數。


## 故事性定義（藍圖定，QA 據以判）

- **行動配動機**：真去追了（非想做卻做不成、非每 tick 被打回 idle）。
- **結局配行動**：死/贏得合理（配得上前面的動機+行動）。


## 判準表（藍圖給的反例，QA 據以分類）

| **thrash 餓死**（想買糧 122 次被打回 idle） | ❌ | 手不聽腦 bug，像自殺實為控制層打架 |
| **有錢餓死**（coin=47 沒買糧） | ⚠ | 看資源+想法才判：賭徒好戲 or 引擎失靈 |
| **idle 餓死**（從沒嘗試求生） | ❌ | 躺平，用戶已否決 |
| **窮死**（用盡覓食/乞食/掠奪/併入才死） | ✅ | 合法悲劇 |

**願景錨（藍圖）**：餓死可以，但**沒有隊伍能坐著/掙扎落空地餓死**。死前必須奮力求生（絕境階梯：覓食→乞食→掠奪→併入），用盡才准死。**零被動/thrash 餓死。**


## 輸出

---

# 第四職：UI 落差掃描（原 04_qa 本體）


## 三類落差（都要查，不只可達性）

|---|---|---|
| **A 可達性** | registered action / capability 無 UI 路徑 | 對 `PlayerCommandSystem.get_registered_actions()` 逐項驗有 UI 入口；headless `_test_action_ui_coverage` 是基線 |
| **B 顯示正確** | 動作執行後 **state 變了但 UI 沒更新**，或顯示值與實際不符 | 動作後斷言 state 變 **且** 對應 DTO/label 反映（如「收留後 population 增」「裝備後武裝數變」）|
| **C 能力對稱** | NPC 會做、玩家無對應主動動作（破對稱性不變量）| 列 NPC 能力（reaction/faction_ai/survival：乞食/投靠/anon 升 tier/named 晉升/紮營/掠奪…），逐一查玩家有無對應 command + UI |


## 必做兩種測試

逐一比對每個現有功能,確認 **sim 功能 → API(DTO/command) → UI 入口** 整條鏈對齊、無斷點：
- sim 有的功能/欄位,API 有沒有暴露?
- API 暴露的,UI 有沒有顯示/可操作?
- 三層任一斷 = 落差。逐項列。

### 測試 2：系統性遍歷（動態 harness 驅動）
1. **每個 UI mode**（主/互動/成員/outpost/faction/subteam/storage/trade/encounter/forced）逐一進出 + 操作一輪。
2. **每個玩家動作端到端**：執行 → 斷言 **state 真的變 + 顯示真的更新**（抓「收留後 pop 沒增」這類 B 類）。
3. **NPC 能力 vs 玩家對稱**：列 NPC 會做的（乞食/投靠/anon 升 tier/named 晉升/紮營/掠奪…），逐一查玩家有無對應（抓「anon→named 無選項」這類 C 類缺功能）。
4. **一次出完整落差清單**。


## 輸出

- 落差類別（A/B/C）
- 重現（哪個 mode/動作/斷言失敗）
- root-cause hint（讀碼推測，不修）
- 嚴重度


## 禁止

- 發明 spec 沒有的規則
- 改世界模型 / config（除非為重現臨時注入，不提交）


## 跑測（wrapper，UTF-8）

```powershell
.\tools\godot.ps1 --headless --import          # 新 class_name 後必跑
.\tools\godot.ps1 --headless --script scripts/debug/ui_flow_test.gd
```

注意：godot 跑前殺孤兒進程（並發搶 import lock 會死鎖）；headless `assert` 失敗會擋在 `quit()` 前致 idle 卡死 → 寫測先 print 診斷再 assert。


## ★★specimen 故事稽核的**結構觀測邊界**（systems 立 2026-08-25，第 3 次被重新發現後）

★**背景反應式系統（scripted reaction，不過 AI 候選引擎）結構上不在它的觀測範圍內。**

**已知落在邊界外的族**（每次都被當成「specimen 漏抓」重新發現一遍）：

| 族 | 為什麼看不到 |
|---|---|
| **繁殖**（breed） | 背景系統直接改狀態，無候選決策 |
| **convoy porter 移動** | 同上 |
| ★**camp 棄置**（`camp_ticks_left` 衰減）／**施工進度**（`_tick_construction`） | 同上 |

⇒ ★**QA 對這些族「判不了」不是失職、也不是 specimen 壞了 —— 是【問錯層】。**
**要驗它們必須用 counter／專屬 tap，不是 specimen。**

### 判別法（一句話）
**問「這件事有沒有經過 argmax？」**
- **有** ⇒ specimen 讀得到，可做故事稽核
- **沒有**（背景系統直接改狀態）⇒ **只能用 tap／counter**，QA 應直接回報「本層判不了」並指出該用哪種儀器

### ★但「判不了」不等於「不用驗」
**funnel 的頭尾常分屬兩層**：例如紮根 ——
**「argmax 贏」在 specimen 內**（QA 判得了），**「commit → 施工 → 完工／棄置」在背景層**（判不了）。
⇒ **這種 funnel 一定要兩種儀器並用**，否則會出現「決策看起來很好、世界什麼都沒發生」而**無人能解釋**的狀態。
（血證：`camp-access` 的 `紮根贏 8 → 開工 1 → 完工 0`。）


## ★★覆蓋窗不足 ⇒ **兩趟法**（systems 立 2026-08-25，第 4 次同款之後）

- convoy porter 不在名單 ／ camp-access 的 host 不在名單 ／
- A1 的 `start=4` 有 **2 筆**不在名單 ／ team15 **掉出可見範圍**

### ★不需要新機制 —— 缺的不是抽樣能力，是「知道要抽誰」
`specimen_dump_helper.gd` **已經支援兩種選法**：
| 環境變數 | 行為 |
|---|---|
| `SPECIMEN_SAMPLE_N` | 從 sorted team_id **確定性等距**取樣（零 RNG） |
| ★`SPECIMEN_TEAM_ID="3,19,42"` | **明確指定**要追哪幾隊 |

**問題只是**：跑之前**沒人知道**哪幾隊會命中目標事件。

### ⇒ 標準做法：**兩趟，同 seed**
1. **第一趟**：只跑 counter／tap，**dump 出「命中目標事件的 team id」**
   （★前置：關鍵站的 tap 要**記 team id**，不能只記次數）
2. **第二趟**：**同 seed 重跑**，用 `SPECIMEN_TEAM_ID=<第一趟那幾隊>`
   ⇒ ★**specimen 精準覆蓋真正相關的隊，一個都不會漏。**

★**成立的前提是世界確定性**：同 seed ⇒ 第二趟逐位元重現第一趟 ⇒ **兩趟指的是同一批事件**。
（★這也是為什麼 determinism 不只是「reproducibility 的潔癖」——**它讓精準取樣成為可能**。）

### ★為什麼不選另外兩條路
- **調高 `SAMPLE_N`** ⇒ 成本線性上升，**而且仍然不保證命中**（命中是事件驅動、不是 id 分佈驅動）
- **做 event-driven 抽樣（跑到一半動態加入）** ⇒ **新機制、且有破壞 RNG-neutral 與確定性的風險**
  （`observer_no_global_rng` 家族）—— **不值得，因為兩趟法零新機制就解決了**

### 適用時機
**任何 `qa: required` 且要驗「少數隊身上發生的事」的票**，**開票時就該指定兩趟**。
★**下一張用得到的就是工期票**（要讀「哪些隊棄工」——那幾隊幾乎一定不在等距抽樣裡）。

### ★兩趟法的補充：**比較型主張需要【兩邊都有 specimen】**（systems 自糾 2026-08-25）

**血證**：`build-eta` 的主張是「**branch 比 main 多保住 1 個 outpost**」。
QA 判不了 —— **這輪 specimen 只有 branch、沒有 main 對照**，
且 branch 裡三隻有紮根活動的隊**全是本輪新 root 嘗試**，
**沒有一隻是「day0 既有 outpost 撐過近乎放棄關頭」的 profile** ⇒ ★**那正是要驗的 profile。**

⇒ **規則**：
1. ★**主張形如「A 比 B 好」⇒ 兩邊都要 specimen**，否則故事層只看得到一邊、**判不了因果**。
2. ★**主張形如「某類個體被保住了」⇒ 第一趟要先找出【屬於那一類】的 team id**
   （這裡是「day0 就有 outpost 且中途瀕臨放棄」），**不是隨便抓有相關活動的隊**。
3. ★**這是開票的人的責任** —— QA 回「判不了」時，先檢查**票有沒有把對照組寫進量測設計**。
   （`build-eta` 這張**我沒寫**，是我漏的。）

★**「數字有、因果未證」是一種合法狀態**：
measurer 可以拿到 `12 > 11`，QA 仍可能證不了「是同一個機制造成的」。
**兩者都照實記，不要讓數字自動升格成因果。**

