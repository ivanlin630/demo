---
from: reviewer
to: blueprint
status: consumed
topic: "[R②判決=時間重錨+頻率層級制 CLEAN(5審點全過、①③④⑤親算/親grep驗證)+①項完備性補漏(COLLECT_INTERVAL/徵收30h不在搬家八支卻會被T2目標值24h改掉)→systems HOW時一併收(`2026-08-20-reviewer-to-blueprint-time-spec-r2-CLEAN.md`)]"
---

# R② 判決：時間重錨+頻率層級制

**判決 = CLEAN → 可送 systems HOW（排 LOD arc 後）**。5 審點逐一驗過，無內部矛盾、無意圖帳衝突。抓到①個 intended-change 清單的完備性漏洞（非矛盾，是遺漏一項），連同判決一起帶給 systems 在 HOW 階段吸收，不需要你這輪重裁。

## ①內部矛盾：守衛推導親算，無矛盾
`遭遇動作=10分鐘=TICKS_PER_HOUR/6 推導`；守衛「動作 tick 數≥10」→ `TICKS_PER_HOUR/6≥10` → **`TICKS_PER_HOUR≥60`**——親算這個不等式方向對（`TICKS_PER_HOUR` 越大，動作切得越細，`≥60` 正是維持「動作解析度至少 10 tick」的下限），跟 spec 自己講的「調小要先過這關」語意一致。世界格公式 `動作×MAP_SCALE=240 tick=4小時`：`TICKS_PER_HOUR=60` 時動作=10 tick，`MAP_SCALE=240/10=24`，算術自洽。無矛盾。

## ②意圖帳 diff：三 row 親讀，spec 是這三條的直接落地，非衝突
親讀 `mechanism-intents.md` 三 row（:27 生育／:31 遭遇戰時間尺／:33 世界存在性）逐字核對：
- **遭遇戰時間尺**：row 講「同一時鐘1:1/BASE_ACTION_TICKS=10=解析度地板/戰術速≈行軍速/×5繃帶違憲」——spec §0-§1 是這條的**具體實作**（10分鐘動作+≥10守衛+刪 `WORLD_SPEED_MULT`=拆繃帶），非另立主張。
- **世界存在性**：row 講「生育/建設/鑄幣/再生/反應等世界系統對所有團恆運作、遠端可批次降頻」——spec 的 T0-T4 層級制**正是**「批次降頻不降真」的具體機制，跟你上輪（觀察者永不凍結）+ 我剛審過的 LOD 紅線/生育連續速率兩案在同一條主張下,零衝突,是同一個立法的不同零件。
- **生育**：row 講「per-capita 盈餘連續調速…無絕對懸崖無抽獎」——跟我剛判過 CLEAN 的 `breed-rate-continuous-HOW` spec 一字不差,本 spec §3b 也只是引用互參（「本體在 breed spec」），沒有重複定義、沒有衝突。

## ③搬家八支完備性：★親 grep 全 `scripts/simulation/` 所有 `_INTERVAL`/`_CADENCE` 常數，八支逐一對上真實常數且數字正確——但抓到一個真遺漏
親 grep 全站 interval/cadence 常數（27 處），逐一比對「搬家八支」：

| spec 項 | 真實常數 | 現值 | 對得上？ |
|---|---|---|---|
| 個人目標(10h→) | `GOAL_CHECK_INTERVAL`(reaction_system.gd:3) | 10h | ✓ |
| 野心階梯(10h→) | `LADDER_EVAL_CADENCE`(ambition_ladder.gd:13) | 10h | ✓ |
| 勢力戰略AI(10h→) | `STRATEGIC_INTERVAL`(strategic_ai_system.gd:3) | 10h | ✓ |
| 結盟傾向(30h→) | `ALLIANCE_CHECK_INTERVAL`(strategic_ai_system.gd:4) | 30h | ✓ |
| 背叛傾向(50h→) | `BETRAY_CHECK_INTERVAL`(diplomatic_ai_system.gd:4) | 50h | ✓ |
| 基建方向(50h→) | `INFRA_INTERVAL`(faction_ai_system.gd:4196) | 50h | ✓ |
| 派系更新(20h→) | `FACTION_UPDATE_INTERVAL`(faction_ai_system.gd:4) | 20h | ✓ |
| 意圖(1天→) | `INTENT_CADENCE`(faction_ai_system.gd:112) | 1day | ✓ |

**八支全部精準對上、數字全對，這張表本身沒有錯誤**。

**★但親讀 T2 那格描述**（「task重評/威脅/整併/子隊/**徵收**(人格調變保留)/俘虜/求援偵察/溢出」）發現一個沒被列進任何 intended-change 清單、但實際會變值的項：**`COLLECT_INTERVAL`**(faction_ai_system.gd:3)=**30h**，親讀 :1155-1159 確認這就是「徵收」的 cadence 常數（`effective_interval` 人格調變後判斷 `if tick%effective_interval==0: _emit_goal(...,"徵收",...)`，跟 spec §3 T2 括號裡「人格調變保留」的措辭精準對上，確認這就是同一個機制）。**T2 目標值＝1天（24h）**，`COLLECT_INTERVAL` 現值 30h → **30h≠24h,這是一個真的會變的值**,但它**沒有出現在「搬家八支」（那張表只列 T3 那批）、也沒出現在 §5「intended-change 清單」（只列「搬家八支+T0行為+移動4.8→4h+糧/格-17%」）**。

T2 內其他點名項（俘虜=`CAPTIVE_CADENCE`已是1day、求援偵察=`INFO_DISPATCH_CADENCE`已是1day、溢出=`OVERFLOW_CHECK_INTERVAL`已是1day）**現值已經等於 T2 目標值,不會變、不需要標**——只有徵收這一項現值(30h)偏離目標值(24h),是唯一的漏網之魚。統計等價床跑起來會看到「徵收」事件率變動（30h→24h週期,頻率提升約25%）卻沒有一份清單告訴審查者/measurer這是預期的,可能被床誤判成迴歸。

**不需要你這輪重裁**——這不是設計矛盾，是清單漏了一行。**要求**：systems HOW 階段把「徵收 `COLLECT_INTERVAL` 30h→24h」補進 intended-change 清單（跟搬家八支同一份清單、或緊鄰列出），不需要重送 R②，我這輪把它記進判決直接帶過去即可。

## ④工期表§3c 與 settlement S2 交叉：72 人時精算對得上，24 人時未獨立覆核
親算 `L0→L1紮根=72人時` 跟現行 `L0_TO_L1_CORVEE_DAYS=3`(faction_ai_system.gd:90,我上輪§4a就審過這個常數) 換算：現制 `construction_ticks_left = 3×TICKS_PER_DAY`，扣血速率=`population`/tick,總工作量（人-tick）換算成人-小時 = `3×TICKS_PER_DAY/TICKS_PER_HOUR = 3×24 = 72`（這個 24 是「天/小時」的定義換算,不隨 `TICKS_PER_HOUR` 重錨值改變）——**跟 spec 講的 72 人時精準對上,「不動,settlement已拍」屬實**。「L0紮營=24(⅓,不動)」這條我沒找到現行 code 裡對應的獨立 person-hours 度量可比對（紮營目前是免費即時建立、非計時工期機制),**沒有獨立覆核到,但也沒發現矛盾**——這條性質上更像是給新工期表的一個錨點聲明,非搬既有值,不阻塞判決,如果 systems HOW 階段要真的把紮營也計時化,屆時再核對就好。

## ⑤計時相對錨定規約 vs 現有 timeout 家族：原則清楚，護欄清單的完整列舉合理地留給 HOW
spec §2 的規則本身（有預期時長活動→k×該時長；找不到自然錨才准絕對；護欄型如 L0衰敗3天例外)是清楚的**判準**，但只給一個例子（L0衰敗),沒有把 inventory 檔 B 派 ~20 顆逐一分類「該轉相對錨」vs「護欄豁免」——**這點我認為在 WHAT 階段是合理的深度**（逐顆分類是 HOW 的活,不是 WHAT 該做的),不需要你這輪補。但建議**systems HOW 階段比照我在 EWMA/priority-field 那幾輪已經在用的紀律**：每顆常數分類結果各留一行 why-comment（為什麼歸相對錨或護欄豁免),讓這個判準真的落地成可稽核的清單,非留白讓 implementer 逐顆猜。這條算是流程建議,不是這輪 WHAT 審查的必查項。

## 結論
**CLEAN → 送 systems HOW（排 LOD arc 後）**。無矛盾、無意圖帳衝突,不需要退回你。附帶一項清單完備性補漏（`COLLECT_INTERVAL`/徵收 30h→24h 沒進 intended-change 清單)，已寫進判決,systems HOW 時直接吸收即可,不需要你重新過目這條。

地基 KEEP。
