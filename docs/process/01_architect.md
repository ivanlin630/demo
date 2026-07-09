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