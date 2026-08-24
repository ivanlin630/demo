---
slice: convoy-return-task-authority
tier: full
qa: required
from: systems
topic: ★scope 已升格(blueprint 2026-08-25)=「task 卸除單一門」—— release() 59 caller 旁路所有 guard;convoy RETURN 只是其中一個受害者
---

# convoy RETURN：**task 主導權沒鎖住**

**來源**：QA 故事稽核（`eta-single-model` 那輪）。
**`stranded 3→0` 是 margin 稀釋，不是修好**（見 `05_acceptance` 的 margin 稀釋條）。

## §1 QA 的觀測（故事層，counter 看不到）
逐隻掃 14 個 porter 的 RETURN 期間移動訊號：
**team123（及 86／162 較輕微）連續 20+ 個樣本 `convoy_phase = RETURN` 但 `task ≠ 運輸`、
`move_target` 與 home 完全無關** —— 被**掠奪／紮營／覓食**反覆劫走。
★**與 gate9 那輪抓到的「相鄰不動」不是同一件事**，這個更根本。

## §2 code-read（systems，**file:line 已坐實**，機制假說標待驗）
`task_arbiter.gd:70-75` 的 progressive hold 條件：
```
new_task != team.current_task
  and team.current_task in PROGRESSIVE_HOLD_TASKS     ← ★只看 current_task
  and priority < PRIO_THREAT and team.task_priority < PRIO_THREAT
  and priority != PRIO_PLAYER
  and team.persist_strength > PERSIST_HOLD_THRESHOLD
```
而 `convoy_phase` 存在 **extra-data**（`faction_ai_system.gd:2819/2846` `xd["convoy_phase"]="RETURN"`）
⇒ ★**arbiter 完全不看它。**

### ★★2026-08-25 更新：**先驗 `release()` 路徑，(a)(b) 都往後排**
`camp-construction-duration` 第一趟窮盡列舉 `current_task = ` **＝ 9 處**，發現：
| 路 | 過哪些 guard |
|---|---|
| `try_set` ×4 | combat／crisis／**persist hold**／優先序 |
| ★**`release()` ×1** | ★**一道都不過**（`TaskArbiter.release(` **59 個 caller**） |
| `transition()` ×1 | combat／crisis／emergency，**不過 persist hold** |

★**「持守 floor 守的是 `try_set` 那道門，而離開的隊是從旁邊那扇沒鎖的門走的。」**
⇒ **本票假說 (b)「一次被搶就永久解鎖」建立在「被 `try_set` 搶」的前提上 ——
若 porter 是被 `release()` 放掉的，(b) 根本還沒輪到。**
⇒ ★**第一趟改成：RETURN 期間 `current_task` 被改寫時，是走哪一條路？**
（`try_set` ／ ★`release` ／ `transition` ／ 其他）**這一格分佈定了才談 (a)(b)。**

### 兩個候選機制（**都待驗，且排在 release 路徑分佈之後**）
| # | 假說 | 性質 |
|---|---|---|
| **(a)** | **第一次被搶的原因**：porter 的 `persist_strength` ≤ 門檻 ⇒ **hold 從未生效** | 需量 `persist.hold` 對 porter 的觸發率 |
| **(b)** | **被搶之後為什麼一直被搶**：`current_task` 已非 `TASK_CONVOY` ⇒ **後續永遠不受 hold 保護** | ★**結構上必然**（條件讀 `current_task`）—— **一次成功搶班 ＝ 永久解鎖** |

★★**這是「同一件事有兩份真相」的又一例**：**「我正在送貨回家」** 這個事實
同時存在於 `convoy_phase`（extra-data）與 `current_task`（arbiter 唯一看的），
**兩者會脫鉤** —— 與〈估算器禁手抄物理〉、〈跨代縫〉**同族**（第二份拷貝必 drift）。

## §3 量測（★**開票就指定兩趟法**，見 `04_qa`）
1. **第一趟**：tap 記 **RETURN 期間 `task = 運輸` 的佔比**（★**margin 影響不到的量**）
   ＋ `persist.hold` 對 porter 的觸發率 ＋ **被搶走時的 new_task 分佈**
   ＋ dump **命中「RETURN 期間被搶」的 team id**
2. **第二趟**：同 seed ＋ `SPECIMEN_TEAM_ID=<那幾隊>` ⇒ QA 讀得到被搶當下那幾隊在想什麼

## §4 修法方向（**待分佈，先不定案**）
⛔ **不准**再放寬 margin／調 `RETURN_ABANDON_ETA_MULT`（那正是製造這個假象的東西）。
可能形狀（**不自選**）：讓 arbiter 看得到「convoy 未結案」這個事實（單一真相源），
而不是靠 `current_task` 這個**會被覆寫**的欄位當代理。

## §5 acceptance
★**主指標 ＝ RETURN 期間 `task = 運輸` 的佔比**（margin 轉不動它）。
`stranded` 計數**只當輔助**，★**不得單獨當通過依據**。

---

## §I ★★scope 升格：**「task 卸除單一門」**（blueprint 裁 2026-08-25）

本票原本只管 convoy RETURN。**升格後管的是整個「誰可以把一支隊從它的 task 上卸下來」。**

### 為什麼升格
`camp-construction-duration` 第一趟窮盡列舉 `current_task = ` **＝ 9 處**：
★**`release()` 一道 guard 都不過**，**59 個 caller**。
⇒ ★**convoy RETURN 被劫走只是這個結構的一個受害者，不是獨立的 bug。**
⇒ 且**清單 §B1 的「寫入側乾淨」是只查了 `try_set` 那道門的結論** —— 已回填訂正。

### 修法形狀（blueprint 指定）
1. ★**`release()` 也要過 arbiter／guard —— 讓「單一門」名實相符**
2. ★**59 個 caller 逐一歸類**：**合法卸除**（任務真的完成／目標消失／隊死）
   vs ★**旁路**（拿 release 當「我就是要換 task」的後門）
   —— **窮盡紀律，不得抽樣**
3. **若診斷顯示影響面超出本票 ⇒ 再升 arc**（blueprint 保留）

### ★量測順序（改寫本票第一趟）
**先報「RETURN 期間 `current_task` 被改寫時走哪一條路」的分佈**
（`try_set` ／ ★`release` ／ `transition` ／ 其他）——
**這一格定了，(a)(b) 兩個舊假說才輪得到。**

---

## §J ★★第一趟：**QA 的現象沒重現** —— 但**本票不因此結案**

**implementer 自己先抓到一個錯**：第一版分母掛在 `_tick_convoy` 裡 ⇒ **同語反覆**
（day25 量到 `886/886 ＝ 100%`）。**已修。**
**修後**：RETURN 期間 **task 全部是運輸、改寫路徑全 0** ⇒ ★**QA 的現象沒重現。**

### 對帳（照既有規矩：**無指紋不對帳**）
QA 的觀測是 **`@eta-single-model` 那輪**；其後 **`camp-access` 與 `build-eta` 兩次 merge** 已改了世界
（四端同秤動了 option 排序、工期估值修正動了持守）
⇒ ★**現象【可能真的消失了】，而不是誰量錯。**
★**但這是假說** —— **要 QA 的執行指紋（config／seed／窗／branch／工作區）才能定案。** 對帳令已發。

### ★★★無論對帳結果如何，**本票不結案**
| | |
|---|---|
| **現象**（RETURN 期間被劫走） | **可能已消失** ⇒ 對帳中 |
| ★**結構事實**（`release()` **59 caller、一道 guard 都不過**） | ★**與現象是否重現【無關】** —— code-read 坐實 |

★**「症狀不再出現」≠「結構問題已修」。**
本票 scope 已升格為「**task 卸除單一門**」（blueprint 裁）
⇒ ★**即使 convoy 症狀消失，`release()` 旁路 guard 這個結構仍要處理**
（否則下一個受害者只是換一個 task —— ★**事實上紮根那條走的就是同一扇門**）。

⇒ **第一趟結論改成**：★**「症狀未重現」＋「結構問題確認存在」，兩件分開記。**
**59 caller 逐一歸類（合法卸除 vs 旁路）照原計畫進行。**

### ✅ 對帳結案（QA 指紋回覆，2026-08-25）

| | QA 那輪 | implementer 這輪 |
|---|---|---|
| branch | ★**`feat/eta-single-model @3f8705ca`** | convoy branch（**在 `camp-access` ＋ `build-eta` 兩次 merge 之後**） |
| config／seed／窗 | `warring_states` / 1337 / 30 天 | **相同** |
| specimen | `eta-model.specimen.jsonl`（4238 entries、37 隊 strided、含 14 隻 porter） | — |

⇒ ★**口徑一致，差異只在 branch。** **兩次 merge 動了 option 排序與持守 ⇒ 世界已前進。**
**QA 同意此判讀。** ⇒ **對帳結案：不是誰量錯。**

### ★但歸因標 `declared-unverified` —— **我不重跑，理由是我自己剛立的規則**
「**現象因為那兩次 merge 而消失**」**目前是【合理推測】，不是【已驗證】**。
**要驗證只需一件事**：在 `feat/eta-single-model @3f8705ca` **原地重跑同床**，看現象是否重現。

★**我決定【不跑】**，理由是 `01_architect §前置量測`：
> **「這個量測如果結果不利，我會不會改設計、甚至不做這張票？」**
**不會。** 本票的工作（`release()` 單一門、59 caller 歸類）**不因這個因果成立與否而改變**。
⇒ ★**一個否決不了任何決策的量測，不該花錢跑** —— **標 `declared-unverified` 即可。**

**若日後需要**：`branch=feat/eta-single-model @3f8705ca` / `warring_states` / `seed=1337` / 30 天。

---

## §K ★★★裁定：**問題不是「有人偷繞」，是 `release()` 混了兩種語意**

implementer 窮盡歸類 59 caller，結論**比「旁路」更硬**：
★**`release-first` 是 arbiter【自己文件化】的通道**，**7 處帶這個 idiom**。
`task_arbiter.gd:142`（`transition` 的 doc）明寫：
> ★**emergency task 自身的正當退場走 release**（→re-rank/re-set）…
> resolution caller **已改 release-first**（現任＝IDLE@0 → **guard 不 fire** → 正常轉換）

**我已自驗，屬實。** ⇒ ★**不是漏洞，是設計，而且設計理由正當**（避免 guard 誤傷正當退場）。

### ★★真正的病：**一個函式承載兩種語意**
| 語意 | 例 | 該不該過 persist hold |
|---|---|---|
| **①正當退場** | task 真的完成／目標消失／隊死／timeout | ❌**不該擋**（擋了就是 latch） |
| ★**②我想換 task** | 還在施工，但想去做別的 | ✅**該過秤** |

★**兩者在 code 上是同一個 `release()`** ⇒ **persist hold 想擋 ② 卻擋不到**
—— **因為 ① 和 ② 長得一模一樣。**

### ★★★而這與 convoy／紮根是**同一個形狀**
> **「保護讀的狀態」與「事實」是兩份真相。**
- **事實**：這隊**有一個未完成的承諾**（`corvee_site != -1`／`construction_team_id == 自己`／convoy 未結案）
- **保護讀的**：`current_task` —— ★**而 `release()` 剛好把它清成 `IDLE`**

⇒ ★**hold 讀了一個【會被清掉的代理】，而不是【事實】。**

## §L 修法方向（**systems 裁；arbiter 契約 ＝ HOW ＝ 我 owner**）

★**persist hold 的判準改讀「有沒有未完成的承諾」這個【事實】，
不再只讀 `current_task` 這個【會被 release 清掉的代理】。**

- ⇒ **`release-first` 這個 idiom 可以保留**（正當退場照走），
  ★**但「先 release 再 set 別的」不再自動繞過持守** —— 因為 hold 看的是承諾，不是 task 欄位。
- ⛔ **不改 59 個 caller**（那是治症狀）；★**改判準，一處。**

### ⚠️★★訂正：**「失敗磚是 latch 解藥」——撤回**（R² ISSUES，2026-08-25）

**reviewer 逐行讀 `try_set` 確認【沒接上】**（我已自驗：該函式讀 `util`／`FailureMemory` 的次數 ＝ **0**）：
> ★**折價影響的是 argmax【選誰贏】；hold 擋的是贏家【能不能真的生效】。
> 決策層與仲裁層是兩個互不相通的閘。**

⇒ ★**我自己定的 halt 條件成立，「失敗磚順便解決 latch」這句【撤回】。**
（**「讀承諾非 `current_task`」這個改法本身仍然對** —— reviewer 明確保留它。）

### ★latch 解藥改用：**獨立 stall-detector**（reviewer 建議的既有已驗證模式）
**比照 `faction_ai_system._detect_survival_stall`**：
- **不依賴決策層折價**，★**直接觀測「承諾了很久但事實沒有進展」**
- **人格化耐性**（`stall_patience_factor` × `STALL_BASE_DAYS`），**不是死常數門檻**
- 有 **recover-restarve 邊界處理**（避免把「曾好轉又變糟」誤判成同一個 episode）

⇒ **本票的 latch 解藥 ＝ 同模式的建設版**：
★**判準讀【進度事實】**（`construction_ticks_left` 有沒有在減少／convoy 有沒有在接近終點），
**不是讀「有沒有被折價」。**

### ~~★latch 風險與它的解藥（**必須一起講**）~~
「讀承諾」比「讀 current_task」更黏 ⇒ **latch 風險上升**（memory 有血證：latch 凍世界）。
★**但解藥現在剛好到位**：**失敗記憶結構身分磚已落地**
（`(結構 id, target)`、覆蓋 19 個結構 id、760 次折價）
⇒ ★**撐不下去的承諾會【自己折價退出】，不需要靠「隨時可以 release 走人」當逃生門。**
**這兩張票是互補的，順序也對：失敗磚先落地，持守才敢變硬。**

**⇒ 送 R²。** ★**請 reviewer 特別打「latch 風險是否真的被失敗磚覆蓋」這一點。**

## §M ★三訊號白名單：**改用覆蓋率機械稽核**（R² ②，成立）

我原本列 `corvee_site` ／ `construction_team_id` ／ `convoy 未結案` 三個訊號當「未完成的承諾」判準。
★**reviewer 指出那又是一張手工白名單** —— **成立，而且我剛立法列管這個物種，卻自己犯。**

⇒ **比照 `T0` ／ `monotonic-id` 的做法：機械稽核覆蓋率。**
- **列舉「所有承載未完成承諾的狀態欄位」**（不是我想到的三個）
- ★**寫成掃描**（同 `estimator-lineage-scan.sh` 的形狀）：**新增承諾類欄位而 hold 沒讀 ⇒ 紅**
- ⇒ **覆蓋是【構造性】的，不是靠我記得列全**

★**這與失敗磚的「結構身分 key」是同一個解法** —— **能機械導出的，不要人工列。**

## §N ★★acceptance 設計：**「被卸除次數下降」有兩種原因，必須分開報**

hold 變硬之後，**「施工中隊被卸除的次數」一定會下降** —— **但下降有兩種原因**：
| 原因 | 是不是我們要的 |
|---|---|
| ★**②「我想換 task」被擋住了** | ✅ **正是本票要的** |
| ★**①正當退場也被誤擋** | ❌ **是回歸**（latch 的前兆） |

★**只看總數，這兩者長得一模一樣** ——
（**同族**：`05_acceptance §margin 稀釋`「症狀計數變 0 要問是機制修好還是容忍度變寬」。）

⇒ **acceptance 必須分兩欄報**：
1. **合法退場**（完成／目標消失／隊死／timeout）的次數 —— ★**這個【不該下降】**
2. **「想換 task」被 hold 擋下**的次數 —— **這個該上升**
★**若①也跟著掉 ⇒ 立刻紅燈，那是誤擋正當退場。**

### 主指標（**margin 轉不動的那種**）
- **convoy**：★**RETURN 期間 `task = 運輸` 的佔比**（`05_acceptance` 已立：**不得只看 `stranded` 計數**）
- **建設**：★**開工後「工地被自己隊放掉」的事件數**，**且與上面①分開**

### ★latch 監測（**假設不靜默**）
**stall-detector 的觸發率要當常設 tap**：
| 觀測 | 意義 |
|---|---|
| 有觸發、且觸發後隊真的換手 | ✅ **解藥在運作** |
| ★**長期零觸發，同時①合法退場也掉** | ★**latch 已發生而沒人知道** ⇒ **紅燈** |

★**「解藥有沒有在運作」本身要可觀測** —— 不能只寫在 spec 上假設它會動。

