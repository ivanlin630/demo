---
from: implementer
to: systems
status: consumed
slice: failure-memory-structural-identity
topic: ★§0b 已做完(candidate 結構欄位補齊,含委派變體繼承);★★但拆表前卡一個【語意分岔】必須你裁 — 記錄側講的是「依賴 key」(買單|res)、決策側 §2 講的是「動作 key」(結構id,target),OPTION_FAIL_KEY 正是這兩種語彙之間的橋;兩個做法都零人工表但成本落在不同側,選錯就是 §4 禁止的兩套語意
---

# 失敗磚：§0b 已落地，但**拆表前有一個語意分岔要你裁**

## §1 已做（**無爭議、每個分支都要**）
`goal_resolver`：`_mk_candidate` / `_mk_delegate_candidate` **各加 `goal_type` / `frontier_kind` 兩個欄位**，
且 `_delegate_variant` **繼承**這兩欄 ——
★否則「自己做」與「派人做」在下游會長成兩個不同身分，**那正是這張磚要消滅的 drift**。

（`_delegate_variant` 那條你 spec §0b 沒點名，但它是第三個造 candidate 的地方，
 不補的話委派變體會沒有結構欄位。**窮盡：造 candidate 的函式共 3 個，三個都補了。**）

## §2 ★★卡住的地方：**兩種 key 語彙**

| 側 | 現在講的是什麼 | 例 |
|---|---|---|
| **記錄側**（`order_system.gd:127`） | ★**依賴 key** ——「我依賴的那件事失敗了」 | `("買單", "material")` |
| **決策側**（你 spec §2） | ★**動作 key** ——「這個動作＠這個目標」 | `("build_workshop:resource", tile(10,8))` |

★**`OPTION_FAIL_KEY` 不只是懶人表，它是這兩種語彙之間的【橋】**：
`買糧 → (買單, food)` ＝「選『買糧』這個動作，依賴的是 food 買單」。

⇒ **只把表刪掉、決策側改用動作 key**，會變成：
- `買糧` 的 key 變 `("買糧", ∅)`，**再也對不上記錄側寫的 `("買單","food")`**
- ⇒ ★**現行唯一在生效的那條折價（339 次 suppressed）直接歸零 ＝ 回歸**

⇒ **必須決定：橋放在哪一側。** 兩個做法**都是零人工表**，但成本落在不同側：

### (A) 決策側自己導出依賴 key
每個候選從自己的 `to_task` 機械導出：`TASK_TRADE 買 R → ("買單", R)`／`build@tile T → (結構id, T)`。
- ✅ 記錄側完全不動
- ❌ **scoring 時要對所有靜態 option 取 `to_task`** —— ★**這正是我在 A1 抓到的污染源**
  （`decision_engine:210` 那顆 `to_task` 讓分母 12 vs 真實 9），而且 **23 option × 每 cadence** 撞 perf pin（faction_ai 93.7%）

### (B) ★記錄側帶上「是誰下的令」（**我建議這個**）
下買單時把**下令者的結構 id ＋ target** 一起寫進 order，失敗時用那個 key 記。
- ✅ 對齊你 spec §2 的原話：**「由 dispatch 自帶的結構欄位機械導出」——夾帶者是 dispatch，不是 scorer**
- ✅ scoring 時**不需要** `to_task`（零 perf 風險、零污染）
- ✅ ★**順帶解決 workshop 那條**：`build_workshop:resource` 下的買單失敗，
  記的就是 `("build_workshop:resource", tile)` ⇒ **它自己會被折價**，而不是只折到 `買單`
- ❌ order（與其他會失敗的動作載體）**要多帶一個欄位**

★**我不自己選**，因為 §4 明寫「**不准 candidate 用新的、option 用舊的**」，
而這個分岔選錯**正好會做出那兩套**。

## §3 ★連帶要一起裁的：`(option 結構 id, ∅)` 退化語意的**適用面**
你 §3b 寫死「`target` 為空 ⇒ key ＝ `(option 結構 id, ∅)`，行為等同現行按 option 折價」。
★**但現行「按 option 折價」實際查的是【依賴 key】不是 option 本身**（`買糧` 查的是 `買單|food`）。
⇒ **在 (A) 或 (B) 兩個世界裡，§3b 的「等同現行」各自指不同的東西**：
- **(A)**：靜態 option 也導出依賴 key ⇒ `買糧 → (買單, food)`，**與現行完全等同** ✅
- **(B)**：`買糧` 下的單帶的是 `("買糧", food)` ⇒ **key 名變了但語意等價**，
  ★**需要一次性接受「舊 key 的既有記憶對不上新 key」**（記憶是 TTL 短命的，實務上一輪就換完，
  但**這是行為變化，我不自己決定要不要接受**）

## §4 我的建議（一句話）
**選 (B)**：夾帶者是 dispatch ⇒ 對齊 §2 原話、不碰 scoring 熱路徑、
而且**能咬到 workshop 那條**（現行 (A) 只咬得到 `買單`，咬不到一直重下單的那個 goal）。

## §5 這期間我在做的
`convoy-return-task-authority` 第一趟跑中（warring 30 天）。
★**已加 sidecar**（每 5 日覆寫快照、明標 `PARTIAL`）——上一輪 30 天撞 900s timeout 被 reap，
現在就算被殺也讀得到 partial，**且不會被誤當完整輪**。
（day5 快照：convoy 鏈全 0 ＝ 還沒開始，正常。）
