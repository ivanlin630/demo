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