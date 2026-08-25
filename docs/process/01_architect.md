**主 session職責**：

brainstorm → spec → plan 設計，不實作。

主 session 職責：
- 設計 Spec
- 審核 Plan
- 確保跨系統一致性
- Merge 管理
- 更新docs文件

必須先閱讀：
- docs/invariants.md

## ★★★觸發式必讀（開場【不】讀，★做到那件事的當下【必】讀）

| 你要做這件事 | ★**動手前必讀** |
|---|---|
| ★**開驗收考／診斷考** | ★**`docs/process/09_exam_gate.md`**（★半成品禁跑驗收考） |
| ★**動信箱／Monitor／watchdog** | ★**`docs/process/07_mailbox_trigger.md`** |
| **動機器軌（orchestrator）** | `docs/process/08_machine_workflow_v2.md` |
| ★**改既有機制** | ★★**`docs/mechanism-intents.md`**（WHAT 權威帳：★code 服從表、表服從用戶） |
| **要引用某條被搬走的規則** | `docs/process/detail/*-cases.md`（同標題節） |
> ★★**這張表本身要短** —— **它的用途是「知道有這個入口」，不是取代那些檔。**

> ★★**本節【不得被切】** —— 它的用途是「在動手的那一刻看見入口」，移到 `detail` 等於廢掉它。

## 3 層流程（依規模選，主 session 第一句需求即判層級）

| 層 | 規模 | 流程 | 主 session 可否直接動 code |

> ★詳 → `detail/01_architect-cases.md`

## ★兩道對抗閘（reviewer，spec 前後各一——不可省，2026-07-10 釘死）

**無斷點自動鏈 ≠ 跳站**：reviewer 是鏈上的站。**R② 每 slice 必過；R① 只新概念大框才啟用**。

> ★詳 → `detail/01_architect-cases.md`

## 設計 checklist（spec 前必過）

- **judge 盤點（藍圖裁定 2026-07-02，R2 desync 教訓）**：統一/新增一個概念的判斷器時，**必須盤點並退役/收編所有既存 judge，不並存**。新系統上線前問：「這概念已有 judge 嗎？」（首燒統一 intent 菜單只加新 judge 沒退役 `derive_archetype` → 兩判斷器讀同 values 48% 分類矛盾。矩陣抓結構 fork、抓不到語意重複——兩公式判同概念要 runtime measure 才現形。）

> ★詳 → `detail/01_architect-cases.md`

## ★spec/plan 鎖後直接 dispatch，別問用戶（2026-07-09 定死）

spec 鎖定（reviewer CLEAN）後，**dispatch = 直接寫 `to:implementer status:open` handback 到 main mailbox**——armed implementer session 主動撿，這**就是** dispatch 本體，不需 live 終端、不需人肉轉述。

> ★詳 → `detail/01_architect-cases.md`

## ★★spec 鎖在長跑因果 = QA-verdict 機械閘（2026-08-04 用戶定，治 QA-hook 連漏）

**病 root（結構、非個站失職）**：`.claude/hooks/longrun-qa-gate.sh`（7/22）提醒**打在跑床站（量測）**，但因果結論在**下游鎖**（systems verdict→spec-lock / blueprint 鎖 WHAT），**鎖點零 gate**＝提醒與執行點錯位；advisory 靠記憶+compact 洗 context 必漏（血證 §5/饑荒-flee/anomaly 三因果沒過 QA 就鎖 spec）。**通則：hook 提醒 ≠ gate；gate 要裝在執行點（鎖/merge），advisory 在上游必漏**（memory `feedback_self_approve_gate` 2026-08-04）。

> ★詳 → `detail/01_architect-cases.md`

## ★裁定：`plans/` 停用，HOW spec 就是唯一產物（systems 裁 2026-08-21）

**背景**：blueprint 在 P9 工單裡把「`plans/` 空目錄＝plan 還欠不欠」交給 systems 前置定。

> ★詳 → `detail/01_architect-cases.md`

## ★P9 交接縫：派工單必帶 `slice:` 與 `tier:`（2026-08-21 用戶核）

**背景**：前作那八項 harness 是「**漏了會被發現**」，不是「**不會漏**」——

> ★詳 → `detail/01_architect-cases.md`

## ★★`tier` 的判準：**「會不會改變世界行為」，不是「工程大小」**（systems 自糾 2026-08-25）

**事故**：我把 `build-eta-single-source` 標成 `tier: probe`，

> ★詳 → `detail/01_architect-cases.md`

## ★★「假設不靜默」的完整形狀 ＝ **偵測 ＋ 主動告知**（reviewer 指出，systems 立 2026-08-25）

**背景**：`build-eta-single-source` 的分母依賴一個假設 ——

> ★詳 → `detail/01_architect-cases.md`

## ★★前置量測 vs 事後驗收欄：**有資格否決一張票的量測，必須擋在動工前**（reviewer 指正，systems 立 2026-08-25）

**我犯的錯**：把「**exact-pair 命中率**」寫在 spec **§5 驗收**裡當一欄死水檢查。

> ★詳 → `detail/01_architect-cases.md`

## ★★★決策層與仲裁層是**兩個互不相通的閘**（reviewer 親驗，systems 立 2026-08-25）

**我差點根據「它們相通」做出一個設計裁定** —— reviewer 逐行讀 `try_set` 擋下來了。

> ★詳 → `detail/01_architect-cases.md`

## ★★被推翻的猜測要**明確作廢**，否則它會變成下一輪的隱性前提（2026-08-25）

**血證**：我猜「decision entry 缺的那一個是 **subteam**」（理由：子隊一路上都是那個唯一沒被涵蓋的角色）。

> ★詳 → `detail/01_architect-cases.md`

## ★★引用站點用**語意錨**，不用行號（implementer 補正 2026-08-25）

**我立過「母體元素定義要對齊」，implementer 補正另一半**：★**行號本身跨輪就不可靠。**

> ★詳 → `detail/01_architect-cases.md`

## ★★`seam-gate` 綠 **≠** acceptance 過（2026-08-25 第一次咬到）

**血證**：`failure-memory-structural-identity` 的 `seam-gate` **rc=0 交接縫齊全**

> ★詳 → `detail/01_architect-cases.md`

## ★★★造一個新機制時，**先問「它會 fire 嗎」** —— 死水兩欄要【前移】（2026-08-25，一天內第三次）

**同一個形狀，一天內出現三次**：

> ★詳 → `detail/01_architect-cases.md`

## ★★修 bug 後 `652 → 0`：**擺動太大要當心修過頭**

implementer 自抓 detector 兩顆 bug（**無進度事實卻判停滯**／**開火不重置 baseline**），修後 **652 → 0**。

> ★詳 → `detail/01_architect-cases.md`

## ★★★事件的身分要在**事件開始時凍結**，不能在**偵測到時反查**（2026-08-25，一天內第 4 個同形）

★**根因一句話**：**偵測總是【晚於】發生，而當下值早就往前走了。**

> ★詳 → `detail/01_architect-cases.md`

## ★★★不只結論會建立在錯誤前提上，**「問題怎麼問」也會**（2026-08-25）

**血證**：measurer 觀察到 `dispatch_fail` **「全部 `tick = 10`」**，我複述並據此把第二半的問題框成：

> ★詳 → `detail/01_architect-cases.md`

## ★★另記：一條**被完整交叉驗證**的儀器鏈（罕見，值得標）
今天多次遇到「儀器說謊」（分母污染／量排版／觀測器有副作用／first-N 假象）。
★**但這一條鏈是乾淨的**：

> ★詳 → `detail/01_architect-cases.md`

## ★★證據的**維度**要對上主張的**維度**（implementer 自糾 2026-08-25）

**血證**：他用 **`cand_build_emitted = branch.build = build_fail = 28`**（**一組不含時間資訊的等式**）

> ★詳 → `detail/01_architect-cases.md`

## ★★★而這次驗證的價值：**不在推翻，在於【知道】**

我上一輪立了「**問題的框架也可能建立在未經驗證的觀察上**」。

> ★詳 → `detail/01_architect-cases.md`

## ★★★「窮盡」保證覆蓋率，**不保證判準正確**（2026-08-25，我自己最貴的一次）

**我掃了 29 個 config，宣告「26/29 沒有 `factions`」** —— **看起來很窮盡。**

> ★詳 → `detail/01_architect-cases.md`

## ★★「移除一個過嚴的閘」**不是零風險操作**（2026-08-25）

**血證**：A 型修法把手工表 `RES_HARVEST_TERRAIN` 刪掉、改從真相源導出。

> ★詳 → `detail/01_architect-cases.md`

## ★★★問真相源要問「它涵蓋哪個【物理】」，不是「它是不是【權威】」（2026-08-25 血證）

**A 型我把 `REGEN_RATE` 當成「資源從哪來」的真相源。**

> ★詳 → `detail/01_architect-cases.md`

## ★★★手工分類表無法避免時：**允許表，但必須配【機械 falsifier】**（2026-08-25）

**判準不是「這是不是一張表」，是**：

> ★詳 → `detail/01_architect-cases.md`

## ★★★訂正我自己：**出處分類消滅【碰撞】，但取代不了【語意判斷】**（2026-08-25，falsifier 第一次跑就打臉）

**我說過「用【出處】分類，不用【字面】分類 —— 字面會碰撞，出處不會」。**

> ★詳 → `detail/01_architect-cases.md`

## ★★★恆假式：**永遠紅的閘 ＝ 沒有閘**（2026-08-25，我自己做了一個）

**我做的 `test-ran-floor.sh` 檔頭寫「回答【有沒有跑完】，不是【有沒有失敗】」，

> ★詳 → `detail/01_architect-cases.md`

## ★★★列舉要挑【收斂】的那一類（2026-08-25，同型第四次）

**我的 `test-ran-floor` 第一版只 grep `Assertion failed`。實測失敗有【三類共 16 行】，閘只看到 5。**

> ★詳 → `detail/01_architect-cases.md`

## ★★觀測路徑與決策路徑的**失敗處置相反**（2026-08-25）
**兩條規矩看起來矛盾，其實是鏡像 —— 並列寫清楚免得互相誤用**：
| 路徑 | 失敗時 | 理由 |

> ★詳 → `detail/01_architect-cases.md`

## ★★★spec 紀律三條（2026-08-25 從 `invariants.md` 搬入並壓縮）
**原本 176 行躲在一個叫「寫 spec 掛上決策層前…」的標題底下，★而那個標題只講了其中第一條。**
★**搬家理由**：**它們是【我們怎麼做事】，不是【世界怎麼運作】** —— ★★**放在 `invariants.md` 等於沒人在對的時機讀到。**

> ★詳 → `detail/01_architect-cases.md`

## ★★★互斥證據 ＝ 框架訊號（2026-08-25，`assert` 案）
**兩邊各有證據且互斥時，★先懷疑【問題問錯了】，不是先判誰的證據假。**
**血證**：「`assert` 會不會中止？」—— 我有「6 條共存」的輸出，他有「撞第一個就停」的觀測。

> ★詳 → `detail/01_architect-cases.md`
