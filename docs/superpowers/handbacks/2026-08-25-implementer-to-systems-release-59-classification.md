---
from: implementer
to: systems
status: consumed
slice: convoy-return-task-authority
branch: feat/convoy-return-task-authority @ c34de246 (pushed)
topic: ★59 caller 窮盡歸類完成 — 但結論比「有人偷繞」更硬:`release-first` 是【arbiter 自己文件化的通道】(task_arbiter:163 明寫「guard 不 fire＝正常轉換」),7 處帶這個 idiom;⇒ persist hold 在結構上【對任何肯先 release 的 caller 無效】,不是漏洞是設計;要裁的是那個設計本身
---

# `release()` 59 caller：窮盡歸類

**方法**：`grep -rn "TaskArbiter.release(" --include=*.gd scripts/`
⇒ **65 筆**，其中 **6 筆在 `scripts/debug/`（測試）**、**59 筆 production**。**逐筆讀 context，不抽樣。**

---

## §1 ★★最重要的發現：**`release-first` 不是偷繞，是【文件化的通道】**

`task_arbiter.gd:162-163`（`transition()` 的註解，**arbiter 自己寫的**）：
> ★emergency task 自身的正當退場走 release（→re-rank/re-set），非靠 transition 降級：resolution caller
> **已改 release-first（現任=IDLE@0 → guard 不 fire → 正常轉換）**，故此 guard 只擋 (a) 外部 stomp、不誤傷 (b) 退場。

⇒ ★**「先 release 再 set」是被承認的正當轉換手法**，而且 **7 處 caller 的註解直接寫著 `release-first`**：

| 站點 | 註解原文（節錄） |
|---|---|
| `faction_ai:4006` | 「zombie 現任常 RETURN_HOME survival@80，**先 release→IDLE@0 過 transition guard**，再 set BUILD」 |
| `interaction:1330` | 「**先 release 過 transition guard**，再還原 previous_task」 |
| `interaction:1347` | 「流亡隊常在 survival@80，**先 release→IDLE@0 過 transition guard**，再 set 生產」 |
| `interaction:1374` | 「清 emergency→IDLE@0 **過 transition guard**，再 set 生產」 |
| `player_command:1019` | 「release-first + move_target 存/還」 |
| `sim_runner:276` | 「release-first + move_target 存/還」 |
| `task_arbiter:163` | ★**通道本身的說明** |

### ★這對 persist hold 的結構後果（code-read 坐實，非推測）
`try_set` 的 persist hold 條件是 `new_task != team.current_task and team.current_task in PROGRESSIVE_HOLD_TASKS and …`。
**`release()` 先把 `current_task` 設成 `IDLE`、`priority` 設成 0** ⇒ 下一個 `try_set` 走的是
`if team.current_task == TeamData.TASK_IDLE … → true`（**無條件通過**）。

⇒ ★★**persist hold 對「任何肯先呼 `release()` 的 caller」結構上無效** ——
**這不是漏洞，是上面那句註解描述的設計。**
⇒ ★**所以本票 scope 升格成「task 卸除單一門」是對的：門存在，而且有門牌。**

---

## §2 59 筆歸類（**三桶，不是兩桶**）

★**我沒有照票面的「合法 vs 旁路」二分**，因為實測有第三類：**設計內的 release-first 轉換**。
硬把它塞進「旁路」會誣賴一個被文件化的機制；塞進「合法卸除」又會讓它從視野消失。

### 桶 A：**任務真的結束**（≒ 無爭議合法）
| 類型 | 站點 |
|---|---|
| 目標／獵物消失 | `faction_ai:298, 312, 374, 2953`、`movement:53` |
| 逾時 | `faction_ai:378, 888, 910, 1332, 2780`、（founding/trade/station/scout/construct-transit） |
| 抵達／完工 | `faction_ai:4842, 4848`、`outpost:418, 445`、`interaction:723`、`sim_runner:404` |
| 實體消滅／併入 | `faction_ai:2914, 2975`、`interaction:1322`、`subteam:275` |
| 信使歸隊 | `interaction:483`、`subteam:29` |
| 被拒 ⇒ 計畫失效 | `interaction:507, 1287`、`faction_ai:5132` |
| 全部失敗 ⇒ 回 idle | `faction_ai:2098, 5061` |
| 玩家命令 | `player_command:516, 563` |
| 起義結算完成 | `faction_ai:395` |
| flee 無座標 backstop | `movement:89` |
| 外交/朝貢結束 | `interaction:419, 432` |

### 桶 B：★**設計內的 `release-first` 轉換**（＝ §1 那 7 處，門牌上有名字）
`faction_ai:4006`／`interaction:1330, 1347, 1374`／`player_command:1020`／`sim_runner:277`
**特徵**：`release()` 之後**緊接著** `try_set(...)` 換成另一個 task。
★**它們不是「濫用」——它們照著 arbiter 文件寫的做。**

### 桶 C：★**釋放【是為了讓別的東西設得進來】**（**灰色，我不自己判**）
| 站點 | 註解原文 | 我的疑慮 |
|---|---|---|
| `faction_ai:1413` | 「**讓位**日常 task（busy 已濾高優先；此處只剩 idle/日常 @≤DISPATCH）→ founding @PRIO_DISPATCH **設得進**」 | ★**明說目的是「設得進」** —— 這是優先序不夠就先卸貨，與 (B) 只差在沒有立刻 set 同一隊 |
| `faction_ai:1500` | 「母隊不再自己追（release 回日常，等結果）」 | 卸任務以避免重派，合理但仍是「主動卸」 |
| `faction_ai:2055` | village relocate：`release` 後設 `TASK_MIGRATE @PRIO_SURVIVAL` | 形同 (B)，但註解說明的是「轉 mobile」不是過 guard |
| `faction_ai:401-403` | crisis-override：`release` + 設免疫窗 | ★**這個相反** —— 它**故意**釋放並**擋自己**被立刻打回，是設計的一部分 |
| `faction_ai:347, 3152` | `_is_stuck` ⇒ release 讓同層重評 | 「卡住」的判準是啟發式；卡住≠任務結束 |
| `faction_ai:2115` | 清空 `task_reason`/`task_extra_data` 後 release | 手動清欄位再 release，語意接近重置 |
| `interaction:1333`／`player_command:1023`／`sim_runner:281` | beggar 無 previous_task ⇒ 直接 release | (B) 的 else 分支 |

---

## §3 ★要你裁的（我不自己選）

1. ★★**桶 B 這條通道要不要收？**
   收了 ⇒ `release()` 也要過 guard，那**七處 caller 全部要改**（它們現在的正確性依賴通道存在）。
   不收 ⇒ ★**persist hold 的語意要改寫成「只擋外部搶班，不擋自願卸任」** ——
   **那本來就是它現在的實際語意，只是沒人這樣寫在票面上。**
   ⇒ **兩條路我都能做，但這是設計決定。**

2. **桶 C 的 `faction_ai:1413`（「讓位…設得進」）算不算旁路？**
   ★**它的註解自己承認目的是讓某個東西設得進去** —— 但被讓位的是「idle/日常 @≤DISPATCH」，
   **不是 committed progressive**。**要不要算，取決於 (1) 的答案。**

3. **`_is_stuck` 那兩處（`347` / `3152`）**：卡住是**啟發式判準**，
   ★**「卡住」與「任務結束」不是同一件事** —— 若 (1) 收緊，這兩處要重新定性。

---

## §4 ★症狀與結構分開記（照你的裁定）
| | 狀態 |
|---|---|
| **現象**（QA 的 `RETURN 但 task≠運輸`） | ★**在我這輪沒有重現**（`warring/1337`，**PARTIAL day 25/30**）；對帳令你已發 QA |
| ★**結構事實**（`release()` 旁路 persist hold） | ★**確認存在，且是文件化的設計** —— **與現象是否重現無關** |

★**「症狀不再出現」≠「結構問題已修」** —— 你這句我照抄進票裡，
而且 §1 讓它更硬：**那扇門不只存在，還掛著門牌。**

## §5 下一步
等 (1) 的裁定。**在那之前我不動任何 caller** ——
★因為改任何一處都會踩到「通道是否存在」這個前提，**先定前提再動手**。
