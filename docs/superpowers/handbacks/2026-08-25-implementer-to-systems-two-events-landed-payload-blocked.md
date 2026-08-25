---
from: implementer
to: systems
status: consumed
slice: convoy-return-task-authority
branch: feat/convoy-return-task-authority @ 051aaa28 +WIP
topic: ★三裁全落地(兩事件/latch+累計waited/三分含「蓋完≠失敗」);★★③做不到而非忘了做——WorldEvents.emit 沒有 payload 通道,要你裁走哪條;★★★順手拆雷:舊 STALLED 分支會清 corvee_site=偵測器自己在卸工地,先前每輪數字裡的「放棄」有一部分是觀測器造的
---

# 三裁落地 ＋ 一個真卡點

## §1 ①②已落地

| 事件 | 條件 | 進記憶 |
|---|---|---|
| `construction_stalled` | 零進度持續 ≥ 耐性窗 | ⛔ 不進 |
| `construction_abandoned` | ★承諾真的消失 | ✅ 執行型 |

`_check_commitment_abandoned` 做**三分**（不是二分）：
- `construction_ticks_left <= 0` ⇒ ★**蓋完了 —— 這不是失敗**，只記 `commit.site_completed`，**不發事件**
- `construction_team_id != team_id` ⇒ `abandoned(reason=taken_over)`
- 否則 ⇒ `abandoned(reason=dropped)`

★**它不清任何欄位**：世界已經自己變了，**偵測器不補刀**。

②latch：`commit_stall_latched`，★**只有進度真的動過才解**；
`commit_stall_episode_tick` **不被 latch 重置** ⇒ 事件/樣本帶 `waited_total`。
★**次數不膨脹、時長不遺失**，照你要的形狀。

## §2 ★★★順手拆掉一顆我自己種的雷（比上面三件都重要）

舊 STALLED 分支最後一行是：
```gdscript
team.corvee_site = Vector2i(-1, -1)   # 「放棄 ＝ 卸下這個工地」
```
★**偵測器在【卸工地】——那不是觀測，那是動世界。**
⇒ ★**先前每一輪報給你的「放棄」數字裡，有一部分是【觀測器自己造出來的】。**
（那 3 個工地後來還是蓋完了，是因為 `build_tile()` 會退到腳下 ——
★**一個 bug 被另一個 fallback 蓋住，所以它從來沒炸給我看。**）
已移除，理由寫進 code 註解。★**這與「觀測儀器禁耗 global RNG」是同一條**：**量測不得改變被量測物。**

## §3 ★★③做不到，不是忘了做 —— 要你裁

你裁「**事件帶 `action`，消費端過濾**」。★**但事件匯流排沒有 payload 通道**：
```gdscript
static func emit(state: WorldState, kind: String, subjects: Array) -> void   # 只有 kind + subjects
```
`pending_rethink` 是**單 tick 喚醒旗標**，檔頭寫明「★禁分批消費（跨 tick 存活＝determinism 盲點）」
且**刻意不入 `state_fingerprint`**。⇒ ★**掛 payload 會動到那個正當性基礎，那是你的地界，我不自己開。**

三條路（我不選）：
| | 做法 | 代價 |
|---|---|---|
| (A) | `emit` 加 optional `payload`，存 `state` 上單 tick 生命週期的 dict | 動事件匯流排契約＋要重新論證 fingerprint 豁免 |
| (B) | ★**消費端自己讀事實**：收到 `construction_abandoned` 就去讀該隊的工地 tile 拿 `construction_target.action` | 零新 seam，**但消費端要拿得到 site**（隊已丟下時 `corvee_site` 已清 ⇒ 讀不到） |
| (C) | 拆成 `construction_abandoned.<action>` 多個 kind | kind 集合爆炸，且 `all_kinds()` 守衛要跟著改 |

★**我的傾向：(B) 但需要一個「最後工地」的事實欄**（隊身上留 `last_site`）——
**不過那等於加狀態，還是你的地界。**
⇒ ★**在你裁定前，`action` 只進 Probe 樣本（觀測），不進事件（契約）。**
**觀測我可以自己加，契約不行。**

## §4 另一個我自己抓到的不一致
`recover-restarve` 那個 stale 分支**自稱「重置視為新 episode」，實際只重置 baseline** ——
沒解 latch、沒挪 episode 起點。★**宣稱與行為不一致**，已改走單一入口 `_reset_stall_episode()`。
★**理由寫進 code**：分散寫會出現「重置了 baseline 卻忘了解 latch」這種**只在長跑才看得見的洞**。

## §5 閘況（誠實標時點）
| 閘 | 結果 |
|---|---|
| headless | **8 ＝ baseline，0-new** ✅（3 `[FAIL]` ＋ 5 `Assertion failed`）—— ★跑的是 `051aaa28`，**偵測器改寫在其後，要重跑** |
| 憲法 | PASS(74) —— 同上，`051aaa28` |
| det×3 | `c1e3f7c5db444fc06c6a826efa77b146` ×3 穩定 —— ★**同樣是 `051aaa28` 的**，★**改寫後必重跑才算數** |
| `commitment-field-scan` | 17/17 PASS（★已寫明它的候選是**名字形狀**不是語意 ⇒ 不等於窮盡） |
| `decision-entry-scan` | 4/4 PASS |
| 床 | 重跑中（新增 `abandon_fire` / `site_completed` / `latched_suppressed` 三欄） |

★**閘的時點我標出來，是因為「綠」如果指的是改寫前的版本，那個綠就是假的。**
