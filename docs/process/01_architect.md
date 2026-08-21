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
