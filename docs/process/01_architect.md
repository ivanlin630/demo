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
| **L3 surgical** | 1–3 行改 | 直改（caveman:cavecrew-builder 或主 session 直接），跳 spec/plan | ✅ 允許 |

- L1/L2 跳 spec 易出包；L3 走 plan 是 overhead。判錯層級用戶會說。
- config/*.json 任何層皆可自由改（不算 code）。CLAUDE.md 改前必確認。

禁止：
- **L1/L2** 直接修改程式碼（須走 spec/plan → 子 session）；L3 surgical 例外
- 為了實作方便未經同意改 Spec

## ★兩道對抗閘（reviewer，spec 前後各一——不可省，2026-07-10 釘死）

**無斷點自動鏈 ≠ 跳站**：reviewer 是鏈上的站。**R② 每 slice 必過；R① 只新概念大框才啟用**。

| 閘 | 何時啟用 | 位置 | 我(系統)做什麼 |
|---|---|---|---|
**★寫 spec 前必讀（2026-08-21 加）**：①**`invariants.md`〈執行失敗反饋鐵律〉**——任何「執行可能失敗」的機制，spec 必須交代**每個失敗點是消滅還是變成有反饋的失敗事件**（禁靜默丟棄）；②**`process/09_exam_gate.md`〈長考閘〉**——spec 若會影響某考試科目，要先想清楚它落在「已修／豁免（該科無效）」哪一格。

| **R① factcheck** | ★**觸發鍵 = fix 正當性是否踩未驗因果/gating 斷言，非改動大小/新穎度**。任一：**(a)** 新概念大框（新子系統/推翻既有/大 redirect）含未驗 code 斷言；**(b)** fix 正當性踩一個未 trace/量測坐實的**因果或 gating 宣稱**（「X 造成/卡住 Y」「Z 是根因」「這門檻擋住那行為」，見下 §判準精修）——**即使改動 trivial（1 行/常數改）**。純機械改（無因果理由：rename/格式/等價重構）+ 前提純事實 → 免 | 收 intent → **寫 spec 前** | 工單/前提的因果/gating 斷言 → `to:reviewer` factcheck file:line + 可能 measure。`premise_contradiction` → halt 重估，別在錯前提上寫 spec |

> **★★R① 判準精修（藍圖/用戶戳 2026-07-16；觸發鍵補正、用戶終認可 2026-07-23）：`file:line 坐實原始事實 ≠ 坐實詮釋斷言`。**
> **兩層別混**：**觸發鍵**（要不要進 R① 門，=上表 (b)）看「理由踩未驗因果/gating」；**豁免**（進門後 file:line 免不免）看「事實 vs 詮釋」。
> **原始事實**（code 在 X 行、值是 Y、函式無 caller）file:line 即坐實 → 免 R①。**★因果/gating 斷言即使附行號也不免**（「這 code **主導**病 / 這常數 **gate** 那條路 / 拆了會**產出** / 移除後**會**分化」）——行號證「code 在」≠ 證「它造成那行為 / gate 那條路」。
> **正向豁免（對稱）**：因果宣稱**已被 measurer/量測坐實**（非「聽起來合理」）→ 視同原始事實，免 R①。**★但引用的類比本身必須真驗證過**——「仿 X 已驗證 pattern」只在 X 有 trace 記錄時才安全豁免；仿一個自己沒驗證的數字（如「117」）= 把未驗證傳染下去，非豁免理由。
> **★smell test（可操作）**：fix 理由句子裡有沒有「造成/卡住/擋住/根因是/門檻是」這類詞（即使只心裡默想沒寫出）？有 → R①。理由只是「仿照 X 已驗證做法」且 X 有 trace → 免。
> **血證（皆 trivial-looking 扛未驗因果、R① 沒觸發，事後才抓）**：①生產 arc 詮釋錯 6 次 + 商業 accessor（claim「最傷」→ 量 <3%）②facility-argmax（樣本不完整 4/7 + 反例=already-built filter，非 machinery-crush）③117-ceiling（`_calc_team_need:2497` vault 領料 cap 誤植成建造閘；**連 reviewer merge-gate 都慣性信了「非杜撰」**）。**別把「行號在那」當「詮釋成立」而跳 R①。** measure-first 正是治詮釋斷言。
| **R② review** | **每 slice 必過** | spec 鎖 → **dispatch/merge 前** | spec 寫完 → `to:reviewer` 審設計（真根治 vs 搬問題/退化/違 invariant）。**CLEAN 才 dispatch**（下段 §dispatch） |

- 大框 call（三對齊：強結論+redirect 大工／相關跳因果／ironclad+難逆）→ R② 升**異質框外審**（別 Opus 代 + refute prompt，見 `00_roles §框外挑框`）。
- **血證（2026-07-10）**：§D4 累積器 + combat S1 跳過 R②直 merge/推 implementer = 無斷點誤讀成跳站（R② 才是每 slice 硬閘）。

## 設計 checklist（spec 前必過）

- **judge 盤點（藍圖裁定 2026-07-02，R2 desync 教訓）**：統一/新增一個概念的判斷器時，**必須盤點並退役/收編所有既存 judge，不並存**。新系統上線前問：「這概念已有 judge 嗎？」（首燒統一 intent 菜單只加新 judge 沒退役 `derive_archetype` → 兩判斷器讀同 values 48% 分類矛盾。矩陣抓結構 fork、抓不到語意重複——兩公式判同概念要 runtime measure 才現形。）
- **敘述性 regime ≠ 實作 classifier**：藍圖給的「帶/階段/類型」敘述模型，實作全用**既有連續信號**進 util，嚴禁新 band 判斷器/enum。淨判斷器數只降不升。
- **凡 in-flight latch 必配 timeout/release（藍圖 2026-07-03,found_ally 凍結教訓）**：spec 含任何「dispatch 後不重評」guard 時,必同時給 timeout（按距離/移速估,非死常數）。scout/FLEE/TRADE 有、found_ally 漏=家族病。
- **身分=權重非路徑切換（藍圖 2026-07-03）**：spec 禁「按身分(fid/tag/階級)切換決策路徑」——個人戰略層永遠跑,身分只能是 util term/context 權重。

## ★spec/plan 鎖後直接 dispatch，別問用戶（2026-07-09 定死）

spec 鎖定（reviewer CLEAN）後，**dispatch = 直接寫 `to:implementer status:open` handback 到 main mailbox**——armed implementer session 主動撿，這**就是** dispatch 本體，不需 live 終端、不需人肉轉述。

**禁止**：問用戶「要 spawn agent 還是開終端還是跑 LG」。dispatch 方式是技術微決策（memory `feedback_no_tech_microdecisions`），系統自決：
- **預設 = 寄 implementer 信箱**（多終端 relay 主軌；worktree implementer session 收信做）。
- LG 機器只大/並行活才上（$27/slice 燒錢，少用）；小/序列 slice 一律信箱。
- Agent subagent spawn 只在短+平行+commit-early 才用（`feedback_no_reflexive_spawn`）。
- 系統**不** inline 改 code（L1/L2 禁；僅 L3 surgical 1-3 行例外）。

handback 內含觸及檔/驗收法摘要（指向 spec，注意事項寫 spec/plan 內）。task 完成判定 = systems + reviewer/QA，非 implementer 自判。

## ★★spec 鎖在長跑因果 = QA-verdict 機械閘（2026-08-04 用戶定，治 QA-hook 連漏）

**病 root（結構、非個站失職）**：`.claude/hooks/longrun-qa-gate.sh`（7/22）提醒**打在跑床站（量測）**，但因果結論在**下游鎖**（systems verdict→spec-lock / blueprint 鎖 WHAT），**鎖點零 gate**＝提醒與執行點錯位；advisory 靠記憶+compact 洗 context 必漏（血證 §5/饑荒-flee/anomaly 三因果沒過 QA 就鎖 spec）。**通則：hook 提醒 ≠ gate；gate 要裝在執行點（鎖/merge），advisory 在上游必漏**（memory `feedback_self_approve_gate` 2026-08-04）。

**機械閘（裝在「鎖」的位置、不靠記憶）**：
1. **含因果結論的 handback 必帶 `QA: <ref 或 PENDING>` 欄**（因果結論＝「X 造成/卡住 Y」「Z 是根因」「這門檻擋那行為」等——同 R① §判準的 gating/因果宣稱）。
2. **systems 拒鎖**：任何 spec 要**鎖在長跑因果結論**上，**引用來源 handback 無 `QA:<ref>`（或為 `PENDING`）→ systems 拒絕 lock/dispatch**、回退送 QA 故事稽核先。純機械改/純事實前提（file:line 原始事實）免（同 R① 豁免邊界）。
3. **鏈序**：長跑 → 量測員（附 specimen）→ **QA 故事稽核（出 verdict ref）** → verdict → systems 鎖 spec / blueprint 鎖 WHAT。QA session 沒開＝flow owner flag blocker（`00_roles`）、非 silent skip。

∴ **不帶 QA verdict ref 就無法過 spec-lock**＝結構硬擋，取代「記得送 QA」的 advisory。連 `03b_measurer §⑤`（findings 必附 specimen→QA）、`00_roles` 接力流向、memory [[feedback_qa_inversion]]。

---

## ★裁定：`plans/` 停用，HOW spec 就是唯一產物（systems 裁 2026-08-21）

**背景**：blueprint 在 P9 工單裡把「`plans/` 空目錄＝plan 還欠不欠」交給 systems 前置定。

**實測**（負斷言協議：窮盡、不用 `head`）：
- `docs/superpowers/plans/` **頂層 0 個 md**；遞迴 **52 個全在 `_archive/`**，最新一份 **2026-07-13**。
- 同期 `docs/superpowers/specs/` 頂層 **30 份**活躍，最新是今天。
- ★而 `session-role.sh` 到今天為止**仍叫 implementer「照 `docs/superpowers/plans/` 逐 task 做」**——**指向一個空目錄**。

**裁定**：**不恢復產出 plan，改 doc 宣告**。理由：plan 這個中間產物在 2026-07 已被 **HOW spec 吸收**
（spec 本身就帶 §任務拆解／§驗收法），再維護第二份等於雙寫；**實務上大家早就只寫 spec 了，只有文件沒跟上**。

**連動已修**：`session-role.sh` 的 implementer 指路 → `docs/superpowers/specs/<日期>-<slice>-HOW.md`。
**保留**：`plans/_archive/` 不刪（歷史脈絡）。

★ 這條同時是 P7「三態誠實」的樣本：**一條規則寫在 doc 上、實際沒有東西在執行它，就該明寫，而不是繼續讀起來像已武裝。**

---

## ★P9 交接縫：派工單必帶 `slice:` 與 `tier:`（2026-08-21 用戶核）

**背景**：前作那八項 harness 是「**漏了會被發現**」，不是「**不會漏**」——
寫一封空信所有警報就閉嘴、`to:` 寫錯零紅燈、而且全部只是「1h 後告訴 blueprint」。
用戶 2026-08-04 立的法（`00_roles:30`）：**hook 提醒 ≠ gate；gate 裝執行點（鎖／merge），非 advisory 上游。**
`seam-gate.sh` 就是那條裝在 merge 上的閘。

### 寫作紀律（★只綁新寫的，舊產物不溯改）

**派工 handback 的 frontmatter 必帶兩欄**：
```yaml
from: systems
to: implementer
slice: convoy-return-conservation   # = branch 名去掉 feat/；★唯一的真相來源
tier: full                          # full | probe
status: open
```
★**若這條 slice 會下「長跑因果結論」，派工單再加一欄**（用戶拍板 2026-08-21，刀1）：
```yaml
qa: required        # ＝ merge 前必須有 QA verdict；seam-gate 機械驗它在不在
```
**這把 2026-08-04 立的 QA-verdict 閘，從 systems 自律升成 merge 閘機械驗。**
★ **同 `tier`：由 systems 在派工時定，做的人不得自選**——**能自己決定要不要送 QA 的 agent，是在改自己的考卷**。
★ **機器只驗「QA verdict 在不在」，不驗它判得對不對**——那永遠是人的活。

**其他產物**（HOW spec／R² verdict handback／`.measure.json`）**只帶 `slice:`**，**不要再寫 `tier:`／`qa:`**
——tier 的唯一來源是派工單，寫兩處就是製造第二個真相。
（`.measure.json` 用既有的頂層 `"slice"` key，語意改為 branch slice id。）

### 兩檔

| tier | 欠什麼 | 用於 |
|---|---|---|
| **`full`** | spec ＋ **R² verdict** ＋ handback ＋ `.measure.json` | 產 code、要 merge 進 main |
| **`probe`** | handback（下因果結論再加 QA ref） | 列舉盤點／加 tap／診斷票／量測票 |

⛔ **`tier` 由 systems 在派工時決定，做的人不得自選**——**能自己選輕流程的 agent，是在改自己的考卷。**
⛔ **兩檔都不砍 review**：**輕流程省的是 paperwork，不是 check。**

### 上線階段
**SOFT（現在）**：只印不擋，收集 baseline。**HARD**：baseline 穩定後才轉，**轉硬後「增列 baseline ＝ STOP，要人裁」**。
⛔ **不回溯武裝**：沒宣告 `slice:` 的產物根本不在母體、永遠不可能被標紅＝**結構性空洞**。

### 機器明確不做的
**不驗職責／越界**（那是判斷題）、**不驗內容品質**（永遠是人的活）。機器只驗「**產物在不在**」。

```bash
bash .claude/hooks/seam-gate.sh              # 當前 branch，SOFT
bash .claude/hooks/seam-gate.sh --selftest   # 良品 fixture：證儀器沒壞
SEAM_MODE=hard bash .claude/hooks/seam-gate.sh
```

### ★★P9 已轉 HARD（2026-08-21）

**預設 `SEAM_MODE=hard` ＝ 缺件擋 merge**（`seam-gate.sh:27`）。轉換依據：

1. **兩件對齊完成**（blueprint 核准的前置）：
   ① measurer `.measure.json` 的 `slice` ＝ branch slice id（**只綁新寫**，已驗：`camp-access`／`estimator-audit`／
   `breed-anon-eligible`／`convoy-return-*` 等新檔皆帶）
   ② **HARD 只管轄「有含 `tier` 的 dispatch handback」的 slice**（派工票 ＝ 入場券，
   自然排除紀律生效前的 slice；`seam-gate.sh:131-140`）
2. **逐 slice 表零誤殺**：HARD 下的紅全部落在
   **①在飛未 merge**（`camp-access`／`subteam-survival-ladder`）或**②未開工**（`eta-single-model`）——
   **沒有任何一條「可 merge 卻被擋」**。
3. **閘自己的成本已量**：**1.5s**（轉 HARD 前必量，見下方教訓）。

★**已知殘影（不修，記錄即可）**：`convoy-return-conservation`／`monotonic-team-id`／`monotonic-person-id`
**已 merge 進 main**（`merged=1`、`0 commits ahead`）但仍讀紅 —— 因為它們的量測產物寫在對齊紀律之前。
**閘不會再擋它們**（東西已在 main），**紅字是歷史殘影不是誤殺**。
★**看到這三條紅不要以為閘壞了** —— 這行字就是為了防那個誤判而寫的。

**逃生門**：`SEAM_MODE=soft bash .claude/hooks/seam-gate.sh`。
**自測**：`bash .claude/hooks/seam-gate.sh --selftest`（證解析沒壞，對真語料格式跑）。

### ★P9 SOFT 期觀察項：**spec 改了、派工單沒跟著改**（2026-08-21 立，blueprint 核准記錄）

**血證（犯的人是 systems 自己，兩次）**：
1. **T3 累加案**：我在 spec §6b 改採 R② 的第三案，**但沒推派工單** ⇒ implementer 照**舊版（錨死）**做了一整輪，
   跑出「沒收一趟成功行程」的結果才發現。
2. **gate 9 warring 票**：只寫在一封**後來被 consumed 的信**裡，**從沒變成正式工單** ⇒ 掉在地上，被用戶問起才發現。

★ **這是現行偵測器的真盲區**：`watchdog` 的 `COMMIT-NO-LETTER` 抓的是「**git 落地了但沒寫信**」，
**抓不到「spec 改了但沒推下一站」**。
⇒ **產物有兩種——一種在 git 裡、一種在信箱裡，而我們只給前者裝了閘。**

**觀察項（P9 SOFT 期收集，HARD 化時再決定要不要收成硬閘）**：
> 對每個宣告 `slice:` 的 slice，比對 **spec 的最後修改**與**該 slice 的 dispatch handback 時間**——
> **spec 在 dispatch 之後才改** ⇒ 標「**spec drifted after dispatch**」。

**先不做成閘的理由**（誠實記，免得日後看起來像忘了）：
- spec 在 dispatch 後被修改**常常是正常的**（收到實作回報後補訂正、加事後訂正段），**誤報率會很高**
- 要分辨「**正常的事後補記**」與「**該重推卻沒推的設計變更**」，機器目前**分不出來**
⇒ **SOFT 期先只收集、看誤報率**，再決定閘的形狀。

## ★★`tier` 的判準：**「會不會改變世界行為」，不是「工程大小」**（systems 自糾 2026-08-25）

**事故**：我把 `build-eta-single-source` 標成 `tier: probe`，
但它**改了六處估值、五個門檻的鬆緊、`det fp` 也變了** ⇒ ★**那是 `full`，不是 `probe`。**
我當時是用「工程不大／是接線不是設計」在判 —— **判錯的維度。**

| tier | 判準 | R② |
|---|---|---|
| **`full`** | ★**會改變世界行為**（決策/門檻/數值進入模擬） | **必過** |
| **`probe`** | ★**純儀器／診斷，零行為改動**（tap、床、specimen 工具、觀測欄位） | **豁免**（**沒有設計可審**） |

### ★為什麼 probe 豁免 R² 是合法的，不是放水
`R②` 審的是**設計**。一張**零行為改動**的儀器票**沒有設計可審** ——
硬要跑只會產生橡皮章，而**橡皮章比沒有更糟**（它讓人以為被審過了）。
★**但豁免的前提是「零行為改動」是真的** —— 由 `det fp` 不變 ＋ headless 0-new 佐證。
**fp 一變就不是 probe。**

### 現況盤點（**誠實記，不假裝法條一直被遵守**）
5 張 probe slice **全部 `R²verdict = 0`**：
`convoy-chase-diagnostic` ／ `specimen-coverage-pos` ／ `specimen-lineage-scope` ／ `last-step-freeze`
—— ★**這四張確實是純診斷/儀器，依上表【合法豁免】**；
`build-eta-single-source` ⇒ ★**tier 標錯，改 `full`，補送 R²。**

### `seam-gate` 的對應
`probe` tier 不驗 `R²verdict` ＝ **與上表一致**，**不改閘**。
★**真正要管的是「tier 有沒有標對」，而 tier 由 systems 在派工單寫死** ——
⇒ **標錯 tier 是 systems 的失誤，閘擋不住它**（閘只驗產物在不在，不驗判斷對不對）。
**這一條寫在這裡，就是為了讓下一次標 tier 的人先想一遍。**

## ★★「假設不靜默」的完整形狀 ＝ **偵測 ＋ 主動告知**（reviewer 指出，systems 立 2026-08-25）

**背景**：`build-eta-single-source` 的分母依賴一個假設 ——
「`outpost_tick` 掛在 `LOD_NEAR`」。implementer 做了
`_outpost_tick_runs_in_near_pass()` **讀 registry**（不手抄）＋ 失效時 `Probe.bump(...stale)`。

★**reviewer 的指正**：**「失效時 `Probe.bump`」只是【偵測】，不是【告知】** ——
**一個沒人去看的 Probe 值，等於沒有。**

### ⇒ 規則
**凡「這段程式依賴一個可能哪天不成立的假設」，要兩段都做**：
| 段 | 做法 | 不做的後果 |
|---|---|---|
| **①偵測** | 讀**真相源**（registry／const），**不手抄**假設的內容 | 假設靜默腐爛 |
| ★**②主動告知** | 接進**會自己跑的閘**（headless 斷言／merge 閘），**不要只留 passive 計數器** | **偵測到了也沒人知道** |

★**最省的做法**：假設若能**靜態判定**（如「這個 system 註冊在哪個 LOD」），
**就寫成 headless 斷言** —— 零成本、每次 headless 都跑、失效當場紅。
**Probe 計數器保留當 runtime 佐證**，但**不是主要防線**。

★**同族**：這與「守衛不要輸出需要被解讀的狀態，要輸出已處置完的結果」是同一條原則的兩個位置 ——
**偵測到異常只是開始；把它送到會有人／有閘看見的地方，才算完成。**

## ★★前置量測 vs 事後驗收欄：**有資格否決一張票的量測，必須擋在動工前**（reviewer 指正，systems 立 2026-08-25）

**我犯的錯**：把「**exact-pair 命中率**」寫在 spec **§5 驗收**裡當一欄死水檢查。
**reviewer 指正**：那顆數字**有資格否決整張票的語意** ——
若 target 幾乎每次不同，exact-pair 的命中率趨近 0 ⇒ **折價形同不存在** ⇒
★**我們會做出第二個「恆 1.0」的機制**（第一個是 `OPTION_FAIL_KEY` 只接 2 個 option）。
**放在事後 ＝ 做完才發現做錯。**

### ★判準（開票時問自己一句）
> **「這個量測如果結果不利，我會不會改設計、甚至不做這張票？」**
> - **會** ⇒ ★**它是【前置量測】，寫進 §0，擋在 dispatch 前面**
> - **不會**（只是想知道效果多大）⇒ 放驗收欄可以

★**前置量測的全部意義就在於「它本來有資格否決」** ——
**一個永遠不可能否決任何東西的前置量測，只是拖延。**

### 配套：**判讀規則必須跟量測一起寫**
**在拿到數字之前**就寫好「**結果 A ⇒ 這樣做／結果 B ⇒ 那樣做**」——
否則會變成「**看到數字才編一個解釋**」。
（本 session 血證：`camp-access` §7 三條、A1 四格分佈、outpost 普查、exact-pair 命中率
 —— **全部是先寫判讀規則、後拿數字**，其中兩次的結果**推翻了我自己的假說**。）

### ★這條與「先量後改」的關係
「先量後改」講的是**順序**；本條講的是**位置** ——
**同一張票裡，量測放 §0 還是 §5，決定了它是【閘】還是【註腳】。**

## ★★★決策層與仲裁層是**兩個互不相通的閘**（reviewer 親驗，systems 立 2026-08-25）

**我差點根據「它們相通」做出一個設計裁定** —— reviewer 逐行讀 `try_set` 擋下來了。

| 層 | 誰 | 它決定什麼 | 它讀什麼 |
|---|---|---|---|
| **決策層** | `argmax`（util、折價、人格權重） | ★**誰贏** | option 的 util |
| **仲裁層** | `TaskArbiter.try_set` 的 hold veto | ★**贏家能不能【真的生效】** | `current_task` ／ `persist_strength` ／ `priority` |

★**自驗**：`try_set` 全函式讀 `util`／`FailureMemory`／`mult_for_*` 的次數 ＝ **0**。

⇒ ★★**在決策層做的事（例如失敗折價）不會影響仲裁層的 veto；反之亦然。**

### ★這條解釋了「手不聽腦」家族的結構根
**「秤對了但沒發生」** 之所以反覆出現，是因為**秤在決策層、發不發生在仲裁層** ——
**兩層各有各的閘，各自可以單獨壞掉、也各自可以單獨修好而另一層沒動。**

### ★★因此的紀律
1. ★**不得用「另一層的改動」當本層問題的解藥** ——
   血證：我曾主張「失敗磚（決策層折價）可以當 persist hold（仲裁層）變硬後的 latch 解藥」，
   ★**那是錯的：折價讓它【不再想做】，hold 擋的是【別人來搶】，兩件事沒有接上。**
2. **要跨層產生效果，必須明寫「誰讀誰」的那條線** —— **不能假設它存在。**
3. ★**開票時先問：我要修的病在哪一層？我提的解藥在哪一層？** **不同層 ⇒ 先證明它們接得上。**

## ★★被推翻的猜測要**明確作廢**，否則它會變成下一輪的隱性前提（2026-08-25）

**血證**：我猜「decision entry 缺的那一個是 **subteam**」（理由：子隊一路上都是那個唯一沒被涵蓋的角色）。
**implementer 實測後挑明**：★**缺的不是 subteam，是 survival 路** ——
**「我挑明講，免得下次照那個方向找錯。」**

★**他做的比「回報結果」多一步：他把【錯誤方向】本身標記出來。**

### ⇒ 紀律
1. **提出猜測時**：★**標明它是猜測，並寫出「若不成立會怎樣」**（本例我寫了「待你確認」）。
2. **猜測被推翻時**：★**明確作廢，不要只說「實際是 X」** ——
   **要說「【不是 Y】，別再往 Y 找」。**
3. ★**理由**：一輪裡出現的猜測會被下一輪當成背景知識繼承。
   **沒有明確作廢的錯誤猜測，會累積成錯誤的「常識」** ——
   **而常識不會被 review，因為沒有人記得它是猜的。**

★**本 session 有多個我的假說被實測推翻**（折價反傷探索／③(d) camp_level／糧橋擋派遣／
工期端撐不完／entry 缺 subteam）—— ★**每一個都必須在帳上留下「這條【不成立】」的字樣**，
**而不是被新結論悄悄取代。**

## ★★引用站點用**語意錨**，不用行號（implementer 補正 2026-08-25）

**我立過「母體元素定義要對齊」，implementer 補正另一半**：★**行號本身跨輪就不可靠。**

**本 session 已至少三次**：
| # | 我引的 | 實際 |
|---|---|---|
| 1 | `task_arbiter:163`「release-first 文件化」 | 那行是 `_defiance_check`；真正的註解在 **`:142`** |
| 2 | `decision_context.gd:364` 工期換算 | 後來變 **`:382`** |
| 3 | decision entry `:5002` | implementer 實作在 **`:5019`** |

★**每一次都不是「引錯檔案」，是【行號漂移】** —— 而漂移在 merge 頻繁的日子裡是常態。

### ⇒ 規則
**引用站點一律用【語意錨】**：**`檔名` ＋ `函式名` ＋（必要時）該處的唯一字串**。
★**行號只當【輔助定位】，不當【身分】。**
- ✅ `task_arbiter.gd` 的 `transition()` doc 段（「resolution caller 已改 release-first」）
- ⚠️ `task_arbiter.gd:142`（**可以附，但不能是唯一依據**）

★**理由**：**行號會漂，函式名與唯一字串不會** ——
**而 reviewer／measurer／QA 是照我給的坐標去查的，坐標漂了他們會查到別的東西。**

## ★★`seam-gate` 綠 **≠** acceptance 過（2026-08-25 第一次咬到）

**血證**：`failure-memory-structural-identity` 的 `seam-gate` **rc=0 交接縫齊全**
（`spec 1 / handback 25 / R²verdict 2 / measure 4 / QA 1`）——
★**但那 4 筆 measure 量的是【三分流與記錄側擴之前】的版本。**

⇒ ★**閘只驗「產物在不在」，不驗「產物是不是這一版的」** —— **它自己的輸出就寫著這句。**
| 誰管什麼 |
|---|
| `seam-gate`（P9） | ★**站都走過了嗎**（產物存在） |
| **R6 `stale-claims.sh`** | ★**這些主張是不是這一版的**（保鮮期） |
| **acceptance** | ★**這一版真的達標了嗎** |

★★**三者不可互相代替。** **閘綠就 merge ＝ 用舊量測過關。**

## ★★★造一個新機制時，**先問「它會 fire 嗎」** —— 死水兩欄要【前移】（2026-08-25，一天內第三次）

**同一個形狀，一天內出現三次**：
| # | 機制 | 造好之後 |
|---|---|---|
| 1 | `OPTION_FAIL_KEY`（查詢側） | ★**只認得 2 個 option**，其餘恆 1.0 |
| 2 | **三分流的「前提型」** | ★**`blocked_total = 0`**，一次都沒觸發 |
| 3 | ★**`construction_abandoned`**（我裁「要造」的那個 typed 事件） | ★**造好了，`= 0`** |

⇒ ★★**「機制已立 ≠ 機制已覆蓋」的更前一步是：「機制已造 ≠ 機制會發生」。**

### ⇒ 規則：**死水兩欄前移到【造之前】**
我立的死水兩欄（**呼叫頻率／輸入變異性**）原本是**審計既有機制**用的。
★**造新機制時要先問同樣的兩題**：
1. ★**它的擲出點在這個 config 下【會被走到】嗎？**（≈ 呼叫頻率）
2. ★**它的判準在這個 config 下【會被滿足】嗎？**（≈ 輸入變異性）

★**若答不出來，就先量【它想捕捉的那件事現在發生幾次】** ——
本例：**A1 已經量到「開工 4 → 完工 1」＝ 3 次未完工**，
★**那 3 次就是 `construction_abandoned` 的預期母體**；**造之前就該對照它。**

## ★★修 bug 後 `652 → 0`：**擺動太大要當心修過頭**

implementer 自抓 detector 兩顆 bug（**無進度事實卻判停滯**／**開火不重置 baseline**），修後 **652 → 0**。
★**自抓與修都對**，但：
> ★**從「大量誤報」直接到「完全不報」，中間沒有【合理的少量】** —— **那本身是一個訊號。**

**判準**：★**用【預期母體】對照** —— A1 量到 **3 次開工未完工**；
**那 3 個工地的最終命運裡，應該有幾個落在 detector 的定義內？**
- **若答案是「至少 1 個」而 detector 報 0** ⇒ ★**修過頭**
- **若那 3 個其實是「窗結束時仍在施工」或「隊死了」** ⇒ ★**0 是對的，但要說得出是哪一種**

★**「修好了」不能只看數字從壞變好，要看它落在【預期母體】的哪裡。**

## ★★★事件的身分要在**事件開始時凍結**，不能在**偵測到時反查**（2026-08-25，一天內第 4 個同形）

★**根因一句話**：**偵測總是【晚於】發生，而當下值早就往前走了。**
⇒ **用「偵測到的那一刻的當下值」去描述「一個過去的事件」，必然記到別人頭上。**

### 今天的四個實例（**同一個病，四張不同的臉**）
| # | 現場 | 讀到的是 |
|---|---|---|
| 1 | `tg_poll` 的跨代偵測寫在 `open(LOCK,"w")` **之後** | ★**自己剛寫的 lock** ⇒ 守衛永遠回 False（**我自己踩的**） |
| 2 | persist hold 讀 `current_task` | ★**已被 `release()` 清成 `IDLE` 的代理**，不是「有沒有未完成的承諾」 |
| 3 | 漏斗站③用 `team.current_option` 過濾 | ★**subteam／solo 是【呼叫後】才設** ⇒ 讀到上一輪的選項 |
| 4 | ★**放棄事件拿 `current_dispatch_id` 當身分** | ★**偵測到時隊多半已改派** ⇒ 記成**新任務**的失敗 |

### ⇒ 規則
**任何「描述一個已發生事件」的資料，其身分必須在【事件開始時快照】。**
- ✅ **episode 起點凍結身分**（dispatch 當下、施工開始當下…）
- ⛔ **偵測到時才去讀當下值／反解身分**

★**判準**：問「**我讀的這個欄位，從事件發生到我讀它的這段時間，會不會被別人改？**」
**會 ⇒ 必須快照。**

### ★推論：這也是 `stalled` 與 `abandoned` 必須分開的**第二個理由**
| 事件 | 性質 | 身分怎麼取 |
|---|---|---|
| `construction_stalled` | ★**持續狀態**（現在正卡著） | 當下值**可以**用 |
| `construction_abandoned` | ★**過去事件**（已經放棄了） | ★**必須用 episode 起點的快照** |

**我先前分它們是因為「名字要等於事實」；★現在多一個理由：它們連【身分取法】都不一樣。**

## ★★★不只結論會建立在錯誤前提上，**「問題怎麼問」也會**（2026-08-25）

**血證**：measurer 觀察到 `dispatch_fail` **「全部 `tick = 10`」**，我複述並據此把第二半的問題框成：
> ★**「`_dispatch_goal_delegate` 之後【為什麼不再產生】build 委派？」**

★**implementer 拒絕沿用那個前提**：**那份樣本是 `bump_sample`（first-N），天生只顯示最早那批。**
**他改用逐日計數，並先報分佈**：
```
cand_build_emitted = branch.build = build_fail = dispatch_fail.資源不足 = 28
```
⇒ ★★**「不再產生」不成立** —— 真相是 ★**「產生的總量【就只有 28】，而且 100% 死在同一個閘」。**

### ⇒ 規則
**「被推翻的猜測要明確作廢」還有更前面一層**：
★**問題的【框架】也可能建立在一個未經驗證的觀察上。**

**開票時要問**：★**「我這個問題的問法，預設了什麼？那個預設驗過了嗎？」**
- 「**為什麼之後不再 X**」 ⇒ **預設了「之前有、之後沒有」** —— ★**那本身是待驗的**
- 「**為什麼總量只有 N**」 ⇒ **預設較少，但要先有【總量】這個數字**

★**代價**：**框架錯了，後面所有的量測都在回答一個不存在的問題** —— **比單一結論錯更貴。**

## ★★另記：一條**被完整交叉驗證**的儀器鏈（罕見，值得標）
今天多次遇到「儀器說謊」（分母污染／量排版／觀測器有副作用／first-N 假象）。
★**但這一條鏈是乾淨的**：
```
cand_build_emitted 28 = branch.build 28 = build_fail 28
                      = dispatch_fail.資源不足 28 = blocked_no_identity 28（修前）
```
⇒ ★**五個觀測點、同一批事件、完全相等** ⇒ **零損耗、零遺漏、零重複計數。**
★**這種全鏈相等本身就是儀器可信度的證據** —— **值得當作「鏈已接通」的驗收形狀。**

## ★★證據的**維度**要對上主張的**維度**（implementer 自糾 2026-08-25）

**血證**：他用 **`cand_build_emitted = branch.build = build_fail = 28`**（**一組不含時間資訊的等式**）
去否定一個**時間主張**（「**只在 `tick 10`**」）。
★**他自己指出前後不一致**：**同一封信裡他才剛寫「不能用樣本推時間」。**

**逐日計數的結果**：★**28 個 build 候選【全部在 day 0】，之後 89 天掛零** ⇒ **原本的時間主張成立。**

### ⇒ 規則
★**主張是什麼維度，證據就要是什麼維度。**
| 主張 | 需要的證據維度 |
|---|---|
| 「**之後不再發生**」「**只在某時**」 | ★**時間維度**（逐日／逐窗計數） |
| 「**總量只有 N**」「**全部死在同一格**」 | **數量維度**（全鏈等式） |
| 「**某類不受影響**」 | **分類維度**（分組對照） |

★**全鏈等式很有說服力，但它【對時間問題沉默】** —— **有說服力 ≠ 回答了那個問題。**

## ★★★而這次驗證的價值：**不在推翻，在於【知道】**

我上一輪立了「**問題的框架也可能建立在未經驗證的觀察上**」。
★**這次去驗了，結果是【框架本來就對】。**

⇒ ★**那條規則【不因此削弱】** —— **它要求的是「驗」，不是「預設框架是錯的」。**
★★**驗證的價值不在於常常推翻，而在於【讓你知道自己站在哪】** ——
**「驗過、是對的」與「沒驗、剛好對」，在後續每一次引用時的重量完全不同。**

## ★★★「窮盡」保證覆蓋率，**不保證判準正確**（2026-08-25，我自己最貴的一次）

**我掃了 29 個 config，宣告「26/29 沒有 `factions`」** —— **看起來很窮盡。**
★**但我掃的是 top-level `factions` key，而 faction 的實際表達是 `teams[].faction_id`。**
**用正確讀法重掃：多數 config 都有 faction。**

⇒ ★★★**掃遍所有檔案、用錯判準，等於一個都沒掃 ——
而且它比「沒掃」更危險，因為它【看起來像窮盡】。**

### ★配套檢查（**我當時有現成的卻沒做**）
**`peaceful_economy` 的「沒有 faction」有【實測】佐證**（measurer 量到 `state.factions.size()` 恆 0）；
★**其餘 28 個我只有讀法、零實測** —— **而我把它們一起宣告了。**

⇒ ★**規則**：**做窮盡掃描時，至少要有【一個】獨立管道的交叉驗證** ——
| 有 | 沒有 |
|---|---|
| ★**掃描結果與一個實測樣本一致** ⇒ 判準通過檢查 | ★**只有掃描、零實測** ⇒ **判準未驗，結論不得外推** |

★**而且要問**：**「我這個判準，是【唯一的表達方式】嗎？」** ——
**同一件事有兩種寫法時**（本例：top-level `factions` **與** `teams[].faction_id`），
★**只掃一種 ＝ 漏掉另一種，而漏掉的部分【不會出現在結果裡】。**

## ★★「移除一個過嚴的閘」**不是零風險操作**（2026-08-25）

**血證**：A 型修法把手工表 `RES_HARVEST_TERRAIN` 刪掉、改從真相源導出。
★**表刪掉之後，下游的 `satisfied` 判定變【太寬】** ⇒ `material` 的卡點 **28 → 0**
—— ★**不是修好了，是判定鬆掉了。**（implementer 自己抓到並修成同一個比較。）

⇒ ★**規則**：**移除一個限制時，要同時檢查【誰在依賴那個限制】。**
| 常見形狀 | |
|---|---|
| **過嚴的閘** | 它一邊擋掉正當案例，**一邊也在替下游做過濾** |
| ★**刪掉它** | 正當案例通了 ✅，★**但下游失去了那層過濾 ⇒ 可能變太寬** |

★**判準**：**刪閘之後，去看【原本被它擋住的東西】現在流到哪裡** ——
**「卡點歸零」有兩種原因：真的解決了，或【判定鬆到不再卡】。**
（★**同族**：`05_acceptance §margin 稀釋`、`§「被卸除次數下降」有兩種原因`。
 ★**這已經是同一個病的第三種臉：症狀消失 ≠ 問題解決。**）

## ★★★問真相源要問「它涵蓋哪個【物理】」，不是「它是不是【權威】」（2026-08-25 血證）

**A 型我把 `REGEN_RATE` 當成「資源從哪來」的真相源。**
★**錯 —— 它是【再生率】的真相源。** 「資源從哪來」在這個世界至少有 **6 條路、散在 5 個檔**：

| # | 手段 | 真相源 | ★**物理形狀** |
|---|---|---|---|
| 1 | **買** | trade | — |
| 2 | **採再生** | `resource_system.REGEN_RATE`（僅 `food`/`material`） | ★**rate（流）** |
| 3 | **做** | `manufacturing_system.RECIPE_GROUPS` | ★**轉化** |
| ★4 | **採有限存量** | `world_generator:89-94`（`ore_iron`/`gem`），★**零 regen 路徑（窮盡 grep 三筆全是註解；`resource_system:347` 明寫「ore/gem 有限」）** | ★★**stock（採完就沒）** |
| ★5 | **採 capped 再生** | `harvest_system`：`regen_herb` / `regen_wild_game` / `regen_wild_horses` | ★**受 cap 的再生 —— 不在 `REGEN_RATE`** |
| ★6 | **掠奪** | `encounter_system:1156 loot_horses_out` | ★**戰利品** |

★★**所以「窮盡 grep 了 `REGEN_RATE`」是真的，「涵蓋了資源來源」是假的。**
—— **這是「窮盡≠判準正確」的第二次血證，形態不同：第一次是【判準找錯欄位】，這次是【真相源只蓋部分物理】。**

### ★★推論一：**形狀決定估算公式，不是資源名決定**
| 形狀 | 「夠不夠」怎麼問 | 折現語意 |
|---|---|---|
| **rate（流）** | **量 ÷ 率 ＝ 多久湊到** | **可持續流** |
| ★**stock（存量）** | ★**存量比較，採完就沒** | ★★**一次性資產 —— 折現語意完全不同** |

★★★**直接咬到 `DiscountedFlow.flow_utility` —— 它叫 `flow`。存量不是 flow。**
**拿流的尺去量存量，會系統性算錯（而且是【看起來正常的數字】—— 母體三問 ③ 的同族）。**

### ★推論二：**別列舉手段，要問形狀**
**手段會從 2 條變 4 條變 6 條** ⇒ ★**列舉 ＝ 又一張手工對照表。**
**要問的是：「這個資源有沒有【任何】增加路徑？各是什麼【形狀】？」**

### ★推論三：**存放位置也會分岔**
`horses` 存在 **`tile.public_storage`**，不在 `tile.resources` ⇒
★**只查 `tile.resources` 的 means-end 會對 `horses` 永遠回「無手段」而【靜默終止】。**

## ★★★手工分類表無法避免時：**允許表，但必須配【機械 falsifier】**（2026-08-25）

**判準不是「這是不是一張表」，是**：
> ★★**「這張表變錯的時候，誰會發現？」——有機械答案才准留表。**

| | 手工對照表（列管病） | ★**配 falsifier 的分類表** |
|---|---|---|
| 來源 | 人腦 | **可以也是人腦** |
| ★**變錯時** | ★**沒人發現，悄悄腐爛** | ★★**當場紅** |

**⇒ 差別不在【誰寫的】，在【壞掉會不會被發現】。**

### ★本例的 falsifier：`WorldState.record_driver` 驅動帳
**5 個 bank（`tile`/`resource`/`anon_treasury`/`unrest`/`loyalty`）全部收斂到同一個記帳點**，
**每筆帶 `{tick, entity, field(=res), delta, reason}`**（`world_state.gd:126`，**37 個 caller**）。
⇒ ★**「誰會增加資源 X」＝ `delta > 0` 的紀錄按 `reason` 分群 —— 零手工表，新路徑自動現形。**

### ★★但它**不能**當 runtime 決策資料源 —— 三個硬限制（都要誠實標）
| # | 限制 | 後果 |
|---|---|---|
| 1 | ★**`driver_ledger_enabled = false` 預設關** | **正常 run 不記** ⇒ **決策讀不到** |
| 2 | ★**ring-buffer `cap = 4096`，標 `TEST VALUE`** | ★**開了也只有尾窗** ⇒ **母體三問①的現成陷阱** |
| 3 | ★**冷啟動** | **沒發生過就記不到** ⇒ **事前判斷不能只靠它** |

**⇒ 正確用法：★【離線稽核】不是【線上決策】。**
**跑一輪開 ledger 的 bed → 掃所有 `delta > 0` 的 `(res, reason)` 對 → ★出現任何【未分類】的組合 ＝ 紅。**
★★**表照留，但它從此無法悄悄變錯。**

