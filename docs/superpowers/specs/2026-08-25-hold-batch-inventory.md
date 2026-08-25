# HOLD 批素材【盤點】——★不是提案、不排序、只列出處

`from: systems` ｜ **狀態：盤點。★本檔不改變任何規則，也不建議先做哪個。**

## §0 ★為什麼需要這張表
**批範圍已從「四件」擴大到「桌上全清」（用戶原話：「專案停工的話就全做了吧」）。**
★**而素材散在今天十幾封信裡** ⇒ ★★**窗口一開，沒有人手上有完整清單。**
★★★**這正是我草案在講的病：東西住錯地方，就等於不存在。★所以我先把它們集中，不做別的。**

---

## §1 原四件（`dde2f68b` ／ `docs/notes/2026-08-25-four-fixes.md`）
| # | 改哪 | 治什麼 |
|---|---|---|
| ★**1** | `inbox-watch.sh`：刪「同 session 安靜退出」改一律搶佔 | **同代殭屍**（★**唯一急件**） |
| 2 | `watchdog.sh`：`UNRESPONSIVE` 移出 `RUNNING` | RUNNING 遮蔽 |
| 3 | `watchdog.sh` 頂端：明寫豁免清單 | 下次加分類不會又被默默吞 |
| 4 | doc 瘦身：`invariants 824→150`／`game-design 1658→1030`／`00_roles 387→80`／`status/` 刪 | 六角色開場 CTX −57~78% |

## §2 批外追加（blueprint 轉用戶裁）
| # | 項 | 出處 |
|---|---|---|
| 5 | **`assert` 實例掛 `01_architect`** | 用戶裁（批範圍擴大那封） |
| 6 | **零產出偵測：Stop-hook `warn-only`** | 同上（★**我的唯讀診斷是它的依據**） |
| 7 | ★**裁決請求類信必須得到回信，`consume` 不算回應** | `ruling-one-action-one-value` §4 |
| 8 | ★**信件 `re:` 欄位**（回信指回它在回哪一封） | 我的弱綠自檢；blueprint 收進批素材 |
| 9 | ★**`memory` 積壓提煉** | 用戶裁；★**我認領** |

## §3 ★★★`memory` 積壓的實際內容（**我認領那項的清單**）
| # | 條目 | 出處／血證 |
|---|---|---|
| ★a | **`MERGE_HEAD` 存在時不要 commit** —— **任何 commit 都會完成別人的 merge，路徑限定的 `add` 擋不住** | 我用 `git add docs/` 仍收尾了 implementer 的 convoy merge（`b992a286` 兩個 parent）；★**而我事前自己 `ls` 過 `MERGE_HEAD`** |
| ★b | **觀測儀器改變被觀測物** 第 4 例 | tap 把 `out.append` 推出 `if` ⇒ 空字典進候選池 ⇒ `emitted 380→2116` |
| ★c | ★**`class` 快取陷阱第三次，且偽裝成災難** | 「`payoff` 改動造成 means-end 完全停擺」實為未 `--import`；★**`CLAUDE.md` 寫了也沒擋住三次** |
| ★d | **落地 ≠ 通知**（★**血證歸因已訂正**：implementer 發了三次沒送到，不是忘了發） | `feedback_landed_needs_notify.md` 已含訂正段 |
| ★e | **共 main dir：git 作者欄記「誰按了 commit」，不是「誰做了工作」** | 今天雙向各一次（我的信被掃入／我收尾他的 merge） |

## §4 ★我今天寫進流程 doc、但可能該降級／搬家的
★**這一格【不是提案】，是提醒 ④ 的人：這些是今天新增的，密度最高，最可能重疊。**
| 檔 | 今日新增 | 現有 | 占比 |
|---|---|---|---|
| `01_architect.md` | +480 | 673 | **71%** |
| `05_acceptance.md` | +276 | 361 | ★**76%** |
| `03b_measurer.md` | +241 | 596 | 40% |
| `00_roles.md` | +121 | 414 | 29% |
| `07_mailbox_trigger.md` | +106 | 294 | 36% |
| `invariants.md` | +61 | 824 | 7% |

★**方法論在 `2026-08-25-rule-consolidation-DRAFT.md`（三母題 ＋ 化身表 ＋ §7「住錯地方」反例）。**

## §5 ★已經在窗口外做掉的（**列出來免得被重做**）
| 項 | 狀態 |
|---|---|
| ★**蟑螂地板②入 `mechanism-intents.md`** | ★**blueprint 已做**（WHAT 帳 ＝ 專案 doc，不在凍改內） |
| ★**`a3e0b4af` watchdog `COMMIT-NO-LETTER` 提序** | ★**已落地，待用戶追認或退回** ｜★★**且【尚未被真實 fire 驗證過】** |
| **convoy 兩個 hook 進 main** | ★**已隨 merge 落地**（`commitment-field-scan` ／ `decision-entry-scan`，★**兩個都在凍改令前完成**） |
