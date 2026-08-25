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

## 3 層流程（依規模選，主 session 第一句需求即判層級）

| 層 | 規模 | 流程 | 主 session 可否直接動 code |
|---|---|---|---|
| **L1 大功能** | 跨多系統 / 新概念 | brainstorm → spec → plan → 子 session | ❌ 禁止 |
| **L2 fix 群** | 5–10 個關聯 small fix | 跳 spec，root cause investigation → plan → 子 session | ❌ 禁止 |

> ★血證／案例 → `detail/01_architect-cases.md`（同標題節）

## ★兩道對抗閘（reviewer，spec 前後各一——不可省，2026-07-10 釘死）

**無斷點自動鏈 ≠ 跳站**：reviewer 是鏈上的站。**R② 每 slice 必過；R① 只新概念大框才啟用**。

| 閘 | 何時啟用 | 位置 | 我(系統)做什麼 |
|---|---|---|---|

> ★血證／案例 → `detail/01_architect-cases.md`（同標題節）

## 設計 checklist（spec 前必過）

- **judge 盤點（藍圖裁定 2026-07-02，R2 desync 教訓）**：統一/新增一個概念的判斷器時，**必須盤點並退役/收編所有既存 judge，不並存**。新系統上線前問：「這概念已有 judge 嗎？」（首燒統一 intent 菜單只加新 judge 沒退役 `derive_archetype` → 兩判斷器讀同 values 48% 分類矛盾。矩陣抓結構 fork、抓不到語意重複——兩公式判同概念要 runtime measure 才現形。）
- **敘述性 regime ≠ 實作 classifier**：藍圖給的「帶/階段/類型」敘述模型，實作全用**既有連續信號**進 util，嚴禁新 band 判斷器/enum。淨判斷器數只降不升。
- **凡 in-flight latch 必配 timeout/release（藍圖 2026-07-03,found_ally 凍結教訓）**：spec 含任何「dispatch 後不重評」guard 時,必同時給 timeout（按距離/移速估,非死常數）。scout/FLEE/TRADE 有、found_ally 漏=家族病。
- **身分=權重非路徑切換（藍圖 2026-07-03）**：spec 禁「按身分(fid/tag/階級)切換決策路徑」——個人戰略層永遠跑,身分只能是 util term/context 權重。

## ★spec/plan 鎖後直接 dispatch，別問用戶（2026-07-09 定死）

spec 鎖定（reviewer CLEAN）後，**dispatch = 直接寫 `to:implementer status:open` handback 到 main mailbox**——armed implementer session 主動撿，這**就是** dispatch 本體，不需 live 終端、不需人肉轉述。

**禁止**：問用戶「要 spawn agent 還是開終端還是跑 LG」。dispatch 方式是技術微決策（memory `feedback_no_tech_microdecisions`），系統自決：
- **預設 = 寄 implementer 信箱**（多終端 relay 主軌；worktree implementer session 收信做）。

> ★血證／案例 → `detail/01_architect-cases.md`（同標題節）

## ★★spec 鎖在長跑因果 = QA-verdict 機械閘（2026-08-04 用戶定，治 QA-hook 連漏）

**病 root（結構、非個站失職）**：`.claude/hooks/longrun-qa-gate.sh`（7/22）提醒**打在跑床站（量測）**，但因果結論在**下游鎖**（systems verdict→spec-lock / blueprint 鎖 WHAT），**鎖點零 gate**＝提醒與執行點錯位；advisory 靠記憶+compact 洗 context 必漏（血證 §5/饑荒-flee/anomaly 三因果沒過 QA 就鎖 spec）。**通則：hook 提醒 ≠ gate；gate 要裝在執行點（鎖/merge），advisory 在上游必漏**（memory `feedback_self_approve_gate` 2026-08-04）。

**機械閘（裝在「鎖」的位置、不靠記憶）**：
1. **含因果結論的 handback 必帶 `QA: <ref 或 PENDING>` 欄**（因果結論＝「X 造成/卡住 Y」「Z 是根因」「這門檻擋那行為」等——同 R① §判準的 gating/因果宣稱）。

> ★血證／案例 → `detail/01_architect-cases.md`（同標題節）

## ★裁定：`plans/` 停用，HOW spec 就是唯一產物（systems 裁 2026-08-21）

**背景**：blueprint 在 P9 工單裡把「`plans/` 空目錄＝plan 還欠不欠」交給 systems 前置定。

**實測**（負斷言協議：窮盡、不用 `head`）：
- `docs/superpowers/plans/` **頂層 0 個 md**；遞迴 **52 個全在 `_archive/`**，最新一份 **2026-07-13**。

> ★血證／案例 → `detail/01_architect-cases.md`（同標題節）

## ★P9 交接縫：派工單必帶 `slice:` 與 `tier:`（2026-08-21 用戶核）

**背景**：前作那八項 harness 是「**漏了會被發現**」，不是「**不會漏**」——
寫一封空信所有警報就閉嘴、`to:` 寫錯零紅燈、而且全部只是「1h 後告訴 blueprint」。
用戶 2026-08-04 立的法（`00_roles:30`）：**hook 提醒 ≠ gate；gate 裝執行點（鎖／merge），非 advisory 上游。**
`seam-gate.sh` 就是那條裝在 merge 上的閘。

> ★血證／案例 → `detail/01_architect-cases.md`（同標題節）

## ★★`tier` 的判準：**「會不會改變世界行為」，不是「工程大小」**（systems 自糾 2026-08-25）

**事故**：我把 `build-eta-single-source` 標成 `tier: probe`，
但它**改了六處估值、五個門檻的鬆緊、`det fp` 也變了** ⇒ ★**那是 `full`，不是 `probe`。**
我當時是用「工程不大／是接線不是設計」在判 —— **判錯的維度。**


> ★血證／案例 → `detail/01_architect-cases.md`（同標題節）

## ★★「假設不靜默」的完整形狀 ＝ **偵測 ＋ 主動告知**（reviewer 指出，systems 立 2026-08-25）

**背景**：`build-eta-single-source` 的分母依賴一個假設 ——
「`outpost_tick` 掛在 `LOD_NEAR`」。implementer 做了
`_outpost_tick_runs_in_near_pass()` **讀 registry**（不手抄）＋ 失效時 `Probe.bump(...stale)`。


> ★血證／案例 → `detail/01_architect-cases.md`（同標題節）

## ★★前置量測 vs 事後驗收欄：**有資格否決一張票的量測，必須擋在動工前**（reviewer 指正，systems 立 2026-08-25）

**我犯的錯**：把「**exact-pair 命中率**」寫在 spec **§5 驗收**裡當一欄死水檢查。
**reviewer 指正**：那顆數字**有資格否決整張票的語意** ——
若 target 幾乎每次不同，exact-pair 的命中率趨近 0 ⇒ **折價形同不存在** ⇒
★**我們會做出第二個「恆 1.0」的機制**（第一個是 `OPTION_FAIL_KEY` 只接 2 個 option）。

> ★血證／案例 → `detail/01_architect-cases.md`（同標題節）

## ★★★決策層與仲裁層是**兩個互不相通的閘**（reviewer 親驗，systems 立 2026-08-25）

**我差點根據「它們相通」做出一個設計裁定** —— reviewer 逐行讀 `try_set` 擋下來了。

| 層 | 誰 | 它決定什麼 | 它讀什麼 |
|---|---|---|---|

> ★血證／案例 → `detail/01_architect-cases.md`（同標題節）

## ★★被推翻的猜測要**明確作廢**，否則它會變成下一輪的隱性前提（2026-08-25）

**血證**：我猜「decision entry 缺的那一個是 **subteam**」（理由：子隊一路上都是那個唯一沒被涵蓋的角色）。
**implementer 實測後挑明**：★**缺的不是 subteam，是 survival 路** ——
**「我挑明講，免得下次照那個方向找錯。」**


> ★血證／案例 → `detail/01_architect-cases.md`（同標題節）

## ★★引用站點用**語意錨**，不用行號（implementer 補正 2026-08-25）

**我立過「母體元素定義要對齊」，implementer 補正另一半**：★**行號本身跨輪就不可靠。**

**本 session 已至少三次**：
| # | 我引的 | 實際 |

> ★血證／案例 → `detail/01_architect-cases.md`（同標題節）

## ★★`seam-gate` 綠 **≠** acceptance 過（2026-08-25 第一次咬到）

**血證**：`failure-memory-structural-identity` 的 `seam-gate` **rc=0 交接縫齊全**
（`spec 1 / handback 25 / R²verdict 2 / measure 4 / QA 1`）——
★**但那 4 筆 measure 量的是【三分流與記錄側擴之前】的版本。**


> ★血證／案例 → `detail/01_architect-cases.md`（同標題節）

## ★★★造一個新機制時，**先問「它會 fire 嗎」** —— 死水兩欄要【前移】（2026-08-25，一天內第三次）

**同一個形狀，一天內出現三次**：
| # | 機制 | 造好之後 |
|---|---|---|
| 1 | `OPTION_FAIL_KEY`（查詢側） | ★**只認得 2 個 option**，其餘恆 1.0 |

> ★血證／案例 → `detail/01_architect-cases.md`（同標題節）

## ★★修 bug 後 `652 → 0`：**擺動太大要當心修過頭**

implementer 自抓 detector 兩顆 bug（**無進度事實卻判停滯**／**開火不重置 baseline**），修後 **652 → 0**。
★**自抓與修都對**，但：
> ★**從「大量誤報」直接到「完全不報」，中間沒有【合理的少量】** —— **那本身是一個訊號。**


> ★血證／案例 → `detail/01_architect-cases.md`（同標題節）

## ★★★事件的身分要在**事件開始時凍結**，不能在**偵測到時反查**（2026-08-25，一天內第 4 個同形）

★**根因一句話**：**偵測總是【晚於】發生，而當下值早就往前走了。**
⇒ **用「偵測到的那一刻的當下值」去描述「一個過去的事件」，必然記到別人頭上。**

### 今天的四個實例（**同一個病，四張不同的臉**）

> ★血證／案例 → `detail/01_architect-cases.md`（同標題節）

## ★★★不只結論會建立在錯誤前提上，**「問題怎麼問」也會**（2026-08-25）

**血證**：measurer 觀察到 `dispatch_fail` **「全部 `tick = 10`」**，我複述並據此把第二半的問題框成：
> ★**「`_dispatch_goal_delegate` 之後【為什麼不再產生】build 委派？」**

★**implementer 拒絕沿用那個前提**：**那份樣本是 `bump_sample`（first-N），天生只顯示最早那批。**

> ★血證／案例 → `detail/01_architect-cases.md`（同標題節）

## ★★另記：一條**被完整交叉驗證**的儀器鏈（罕見，值得標）
今天多次遇到「儀器說謊」（分母污染／量排版／觀測器有副作用／first-N 假象）。
★**但這一條鏈是乾淨的**：
```
cand_build_emitted 28 = branch.build 28 = build_fail 28
                      = dispatch_fail.資源不足 28 = blocked_no_identity 28（修前）

> ★血證／案例 → `detail/01_architect-cases.md`（同標題節）

## ★★證據的**維度**要對上主張的**維度**（implementer 自糾 2026-08-25）

**血證**：他用 **`cand_build_emitted = branch.build = build_fail = 28`**（**一組不含時間資訊的等式**）
去否定一個**時間主張**（「**只在 `tick 10`**」）。
★**他自己指出前後不一致**：**同一封信裡他才剛寫「不能用樣本推時間」。**


> ★血證／案例 → `detail/01_architect-cases.md`（同標題節）

## ★★★而這次驗證的價值：**不在推翻，在於【知道】**

我上一輪立了「**問題的框架也可能建立在未經驗證的觀察上**」。
★**這次去驗了，結果是【框架本來就對】。**

⇒ ★**那條規則【不因此削弱】** —— **它要求的是「驗」，不是「預設框架是錯的」。**

> ★血證／案例 → `detail/01_architect-cases.md`（同標題節）

## ★★★「窮盡」保證覆蓋率，**不保證判準正確**（2026-08-25，我自己最貴的一次）

**我掃了 29 個 config，宣告「26/29 沒有 `factions`」** —— **看起來很窮盡。**
★**但我掃的是 top-level `factions` key，而 faction 的實際表達是 `teams[].faction_id`。**
**用正確讀法重掃：多數 config 都有 faction。**


> ★血證／案例 → `detail/01_architect-cases.md`（同標題節）

## ★★「移除一個過嚴的閘」**不是零風險操作**（2026-08-25）

**血證**：A 型修法把手工表 `RES_HARVEST_TERRAIN` 刪掉、改從真相源導出。
★**表刪掉之後，下游的 `satisfied` 判定變【太寬】** ⇒ `material` 的卡點 **28 → 0**
—— ★**不是修好了，是判定鬆掉了。**（implementer 自己抓到並修成同一個比較。）


> ★血證／案例 → `detail/01_architect-cases.md`（同標題節）

## ★★★問真相源要問「它涵蓋哪個【物理】」，不是「它是不是【權威】」（2026-08-25 血證）

**A 型我把 `REGEN_RATE` 當成「資源從哪來」的真相源。**
★**錯 —— 它是【再生率】的真相源。** 「資源從哪來」在這個世界至少有 **6 條路、散在 5 個檔**：

| # | 手段 | 真相源 | ★**物理形狀** |

> ★血證／案例 → `detail/01_architect-cases.md`（同標題節）

## ★★★手工分類表無法避免時：**允許表，但必須配【機械 falsifier】**（2026-08-25）

**判準不是「這是不是一張表」，是**：
> ★★**「這張表變錯的時候，誰會發現？」——有機械答案才准留表。**

| | 手工對照表（列管病） | ★**配 falsifier 的分類表** |

> ★血證／案例 → `detail/01_architect-cases.md`（同標題節）

## ★★★訂正我自己：**出處分類消滅【碰撞】，但取代不了【語意判斷】**（2026-08-25，falsifier 第一次跑就打臉）

**我說過「用【出處】分類，不用【字面】分類 —— 字面會碰撞，出處不會」。**
★**前半對，後半講得太滿。**

**實證**：falsifier 上線第一次跑就抓到未分類項 —— ★**`predator_density`**。

> ★血證／案例 → `detail/01_architect-cases.md`（同標題節）

## ★★★恆假式：**永遠紅的閘 ＝ 沒有閘**（2026-08-25，我自己做了一個）

**我做的 `test-ran-floor.sh` 檔頭寫「回答【有沒有跑完】，不是【有沒有失敗】」，
實作卻在任何 `Assertion failed` 非零時 FAIL。★而 baseline 就有 8 個已知失敗 ⇒ 這個閘【永遠紅】。**

★★**恆假式跟恆真式一樣沒有資訊量** ——

> ★血證／案例 → `detail/01_architect-cases.md`（同標題節）

## ★★★列舉要挑【收斂】的那一類（2026-08-25，同型第四次）

**我的 `test-ran-floor` 第一版只 grep `Assertion failed`。實測失敗有【三類共 16 行】，閘只看到 5。**
（另兩類：**非-assert 的 `SCRIPT ERROR` 8 行**、**`[FAIL]` print 3 行**。）

★**病根跟前面三次同型**：`REGEN_RATE` 只蓋再生／`reason` 字面分類／出處取代不了語意 ——

> ★血證／案例 → `detail/01_architect-cases.md`（同標題節）

## ★★觀測路徑與決策路徑的**失敗處置相反**（2026-08-25）
**兩條規矩看起來矛盾，其實是鏡像 —— 並列寫清楚免得互相誤用**：
| 路徑 | 失敗時 | 理由 |
|---|---|---|
| ★**決策**（means-end「無手段終止」） | ★**不得靜默，必須發 tap** | **最容易誤判的分支，症狀卻是「什麼都沒發生」** |
| ★**觀測**（`specimen_tracer` 讀 intent 炸掉） | ★★**不得吵，必須靜默降級＋記 tap** | ★★★**觀測器產生錯誤行 ＝ 污染被觀測物的輸出**，它讓「綠的定義」更難建立 |

> ★血證／案例 → `detail/01_architect-cases.md`（同標題節）

## ★★★spec 紀律三條（2026-08-25 從 `invariants.md` 搬入並壓縮）
**原本 176 行躲在一個叫「寫 spec 掛上決策層前…」的標題底下，★而那個標題只講了其中第一條。**
★**搬家理由**：**它們是【我們怎麼做事】，不是【世界怎麼運作】** —— ★★**放在 `invariants.md` 等於沒人在對的時機讀到。**

### ①★掛「決策層」之前，先驗那個動作真的經過決策層
**共同形狀 ＝ ★機械層旁路決策層。** 寫 spec 時預設「這當然會經過引擎／仲裁／util」，**而它其實是機械層直接寫。**

> ★血證／案例 → `detail/01_architect-cases.md`（同標題節）
