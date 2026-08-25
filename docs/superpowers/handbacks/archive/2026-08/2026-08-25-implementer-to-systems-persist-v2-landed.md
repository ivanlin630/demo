---
from: implementer
to: systems
status: consumed
slice: convoy-return-task-authority
branch: feat/convoy-return-task-authority @ 12012b74 (pushed)
topic: ★v2 三件全落地(hold 讀承諾事實/機械稽核 16-16/建設版 stall-detector 發 construction_abandoned);★★但 det fp 又沒變 ⇒ 行為改動在 a4 床上量不到,分辨要靠 §N 兩欄;★我自己列一個覆蓋缺口:偵測器只掛 3 個 decision entry
---

# v2 落地

**branch**：`feat/convoy-return-task-authority` @ `12012b74`（已 push）

## §1 三件定案

### ①hold 讀【未完成的承諾】這個事實
```gdscript
var _commit: Dictionary = CommitmentFields.unfinished(state, team)
var _held_commit: bool = not _commit.is_empty() \
        and not CommitmentFields.serves(String(_commit.get("kind", "")), new_task)
if new_task != team.current_task \
        and (_held_commit or team.current_task in PROGRESSIVE_HOLD_TASKS) \
```
⛔ **59 caller 不改、`release-first` 保留**（正當退場照走）；
★**「先 release 再換去做別的」不再自動繞過持守。**

★**我自己加了一道 `serves()` 例外，理由必須講**：hold 護的是**承諾**不是 task 欄位，
所以「先 release 再 set **回同一件事**」是**復工**不是搶班。
**不放這條的話，`faction_ai:4006` 那條 zombie 復工路（release→IDLE 過 guard→set BUILD）會被自己擋死
⇒ zombie 工地永遠鎖在 zombie 狀態 —— 正好是要修的反面。**
（這就是你 §N「①正當退場被誤擋」在仲裁層的具體形狀。）

### ②承諾欄位＝**機械稽核**，不是白名單
`.claude/hooks/commitment-field-scan.sh`：候選欄位**從 `team_data.gd` 自動抽**（結構命名 pattern），
每個都必須在 `READS`（註明怎麼判）或 `NOT_COMMITMENT`（**附理由**）⇒ **沒分類就紅**。
```
-- commitment field coverage: 16/16 classified   PASS
```
★**它第一次跑就抓到我漏分類的兩個**，其中一個是 **`current_task` 自己** ——
它的分類理由正好是這張票的核心：**「它就是被 release 清掉的那個代理」**。
（順帶修掉掃描自己的 bug：原本從 `--git-common-dir` 推根 ⇒ **會跑去稽核 main 的檔案**。）

### ③latch 解藥＝**獨立 stall-detector**（不是失敗磚）
判準**讀進度事實**（工地 person-ticks 有沒有在減少／convoy 有沒有接近終點），
**不是**「有沒有被折價」—— ★你撤回的那條我沒有偷偷靠回去。
人格化耐性（`stall_patience_factor × STALL_BASE_DAYS`）＋ **recover-restarve 邊界**。
★**STALLED ⇒ `WorldEvents.emit("construction_abandoned")` ＋ 卸下工地**
（否則偵測器每輪重放同一個）。

★**`relief_min = 1.0` 不是我拍的**：真值那行每次扣 `maxi(pop,1) ≥ 1`
⇒ **1.0 ＝「至少推進過一個 person-tick」＝ 進度的最小單位**（同源推導）。

## §2 ★§N 兩欄（照你要的分開）
| 欄 | tap | 期望 |
|---|---|---|
| ①合法退場 | `commit.release_clean` vs `commit.release_with_commitment` | ★**①不該掉**（掉＝誤擋＝回歸）|
| ②被 hold 擋下 | `commit.hold_blocked`（+ per-kind） | ★**該升** |
| latch 解藥在跑嗎 | `commit.stall_fire`（+ per-kind + 樣本帶 `waited_ticks`/`progress`/`baseline`） | 長期零觸發 ＋ ①同時掉 ⇒ **紅燈** |

★`release()` 拿不到 `state` ⇒ ①用**欄位 proxy**判「身上有沒有丟下東西」，
**我在 code 註解標明它是 proxy**，不假裝是精確判準。

## §3 ★★又一次「fp 沒變」，我照實記
```
headless = 8 ＝ baseline，0-new ✅
憲法 PASS(74) ✅
det×3 = c1e3f7c5…（三跑穩定）★但與 base 相同 —— fp 沒變
```
★**hold 判準改了是【真的行為改動】，fp 卻沒動** ⇒ **a4 那 1000 tick 的床沒跑到這條路**
（那床裡大概沒有「帶著未完成工地／convoy 的隊被 routine 搶班」這種情形）。

⇒ ★**分辨「床沒覆蓋」與「沒生效」的是 §N 兩欄，不是 fp** ——
這已經是本輪第三次同形狀（eta / 磚 / 這裡），**建議 acceptance 一律別把 fp 當生效訊號**
（你已寫進 `03b §④g` 的反向，這裡是第三個實例）。

## §4 ★我自己列一個覆蓋缺口（不自己補，呈報）
`_detect_commitment_stall` 目前**只掛在三個 decision entry**
（`_decide_unified` / `_decide_subteam` / `_evaluate_solo`，比照 `_detect_survival_stall`）。
⇒ ★**不走這三條路的隊，身上的未完成工地不會被偵測到。**

**兩個選項**：
1. **擴到每 cadence 全隊掃**（成本：多一次全隊迭代；且要找一個 owner 位置）
2. **維持現狀**，理由是「不做決策的隊也不會去搶別的 task」⇒ latch 風險本來就低

★**我傾向 (2) 但沒有證據**，而且這正是「假設不靜默」該處理的東西 ——
**若選 (2)，建議加一顆「有未完成承諾但本輪沒被偵測到」的計數**，讓假設自己喊。
**你裁。**

## §5 相依關係（merge 順序要你定）
★**`construction_abandoned` 事件在【本 branch】；消費它的 `FailureMemory.record(執行型)` 在【磚 branch】。**
⇒ **事件要先進 main，磚的記錄側才接得到。**
兩張都動 arbiter 附近 —— **先後你定**（你上次已經提過要先告訴你）。
