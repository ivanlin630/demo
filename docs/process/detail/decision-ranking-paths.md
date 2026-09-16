# 決策排序：三條 rank 路 × 三個「名次」（systems，2026-09-16）

status: REFERENCE（按需讀）｜owner: systems
★**為什麼有這份**：2026-09-16 掠奪那條線繞了一整天的圈，**根因是沒有人（包括我）知道
「掠奪在哪一張表上跟誰比」** —— 而那個問題本來應該有一份查得到的答案。

---

## §1 三條 rank 路（term 集合**不同**，而差異從未被寫下）

| | `rank_scored_ctx` | `rank_survival` | `rank_threat` |
|---|---|---|---|
| 位置 | `decision_engine.gd:~300-360` | `:739-763` | `:809-825` |
| 候選集 | `applicable(ctx)` 全體 | `applicable ∩ sets.survival` | `applicable ∩ sets.threat` |
| `weight × eval` | ✅ | ✅ `:752` | ✅ `:820` |
| `consistency_coeff` | ✅ `:329` | ❌ | ❌ |
| `FailureMemory` | ✅ `:338` | ❌ | ❌ |
| survival break-top boost | ✅ `:346` | ❌（**它本身就是 survival 子集**） | ❌ |
| threat break-top boost | ✅ `:354` | ❌ | ❌ |
| 承諾慣性 | （走 `d`／persist 另計） | ✅ `_persist` `:748/757` | ❌（每 cadence idle 才重觸發） |

**★ 蓄意 / 待判**（★★這一欄是這份文件的重點）：
- `rank_survival` **不讀 `consistency_coeff`** ⇒ ★**我判【蓄意且正確】**：絕境時不該被
  「這個選項跟你當下的需求層不合」壓住 —— **生存本來就是最急的那一層**。★★**待 blueprint 認可後改標。**
- `rank_survival` / `rank_threat` **不讀 `FailureMemory`** ⇒ ★**待判**（失敗記憶在絕境該不該失效？**沒有理由被寫下來**）。
- `rank_threat` 的 `survival` option 走**特例公式**（`:812-816`）⇒ **已在原地寫明理由**（鏡射舊 dispatch）。

---

## §2 三個「名次」—— ★而它們之間各夾著一個機制

```
\u2460 **秤的第一名**      ＝ `rank_scored_ctx` 的 `scored[0]`（★`won_anyway` 數的是這個）
        ↓ `reorder_same_need_first`（`decision_engine.gd:717-728`；呼叫點 `faction_ai_system.gd:3391`／`:4434`）
          ★**把與 `ranked[0]` 【同需求類別】的全部搬到前面** —— 類別由 `main_layer_of(opt)` 決定
\u2461 **重排後的順序**
        ↓ 派工迴圈（沿著 ranked 走，`try_set` 失敗就 `continue`）
\u2062 **實際被派出去的那一個**（★`pos1`／dispatch 計數 數的是這個）
```
★★**所以「掠奪贏了」有三個互不等價的意思**，而它們在 dispatch 計數上長得一模一樣。
★★★**血證**：同一輪裡 `won_anyway ＝ 3` 與 `21 次全部第 1 順位` 併存 ——
**不是矛盾，是兩個不同的問題**（而發現這一點花了四封信）。

**★ 一個必然的連動（2026-09-16 撞到）**：
改 `affinity` 那一格 ⇒ 同時改了 **①`consistency_coeff` 的 alignment** 與 **②`main_layer_of` 的 argmax**
⇒ **②會改變 `reorder_same_need_first` 的分組** ⇒ ★★**一格數字，兩個機制**。
**改 affinity 之前先問：這個 option 的 `main_layer_of` 會不會換？**

**★★而這個危害【在掖奪這個 option 上實測為 0】**（2026-09-16）：
```
A 臂（affinity 0.70）：`main_layer_of(掖奪)` ═ L0；重排呼叫 6294、真的改了順序 4142
掖奪在場 3226 ⇒ 往前 512／往後 558／原位 2156／**`became_first` ═ 0**
```
⇒ ★**重排確實會動順序，而它【一次也沒有把掖奪搬到第一】** ⇒ **「重排造成 5→28」這個候選解釋【死了】。**
★★**危害本身仍然存在**（一格數字確實改兩個機制），**而它在這一個 option 上的實測值是 0** —— ★★★**兩件事都要寫，因為下一個改別的 option 的人還是會撞到它。**

---

## §3 引用紀律（★寫給下一個要引用這些數的人）
```
引用任何「某 option 贏了幾次」時，**必須同時說出**：
  ・**哪一條 rank 路**（統一／求生／威脅）
  ・**哪一個名次**（秤的第一名／重排後／實際派出）
  ・**母體是什麼**（rank 次數 vs 派工次數 —— ★一次 rank 未必一次派工，反之亦然）
★★缺任何一項 ⇒ **那個數不可引用**，因為它會被下一個人拿去跟另一個定義的數相比。
```
