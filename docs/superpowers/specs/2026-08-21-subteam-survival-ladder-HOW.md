# HOW spec：在途子隊入同一把求生尺

slice: subteam-survival-ladder
date: 2026-08-21 ／ owner: systems
**WHAT ＝ 用戶連兩問裁定**（授權真檔 `2026-08-21-blueprint-to-systems-five-rulings.md` §②）：
> 子隊入**同一把求生尺 ＝ 完整絕境階梯**（趕路歸隊／動用資產買糧／覓食遷移／乞食／**投靠末端**），**非「瀕死→投靠」單招**。
> 依據 ＝ **survival 保序單一源不變量：「命運不看 dispatch 路」** ＋ T0 全突發全體適用。

## §1 前提（實測坐實）

### ①「決策真空」**不是 convoy 專屬**——所有在途子隊都是
`faction_ai:761-762`：`parent_team_id != -1` → 一律走 `_evaluate_subteam`，**不進 `_evaluate_solo`／`_decide_unified`**。
`_evaluate_subteam` 內對**移民**（`_tick_migrant` → `return`）、**`TASK_BUILD`**、
**`TASK_CONSTRUCT`／`UPGRADE`／`EXPAND`**、**`TASK_CONVOY`**（`:2753-2756`）**逐一早退**。
⇒ **在途子隊整趟不做任何決策**。specimen 坐實（convoy 追逐窗）：porter **decision 0**、reaction 10、heartbeat 10。

### ② 已存在的兩塊拼圖（**本刀不需要新造**）
- **`PROGRESSIVE_HOLD_TASKS`**（`task_arbiter:22`）**列的正好就是這些 task**
  （BUILD／CONSTRUCT／UPGRADE／EXPAND／SETTLE／MIGRATE ＋ 已加入的 **CONVOY**）。
- **hold 對 `≥PRIO_THREAT` 讓行**（`try_set:60-70`）＝ **求生本來就穿得過、routine 穿不過**。
⇒ **承諾保護的機制已經在位，缺的只是「子隊根本沒被問」。**

### ③ 血證：porter 案卷
瀕死 porter **身上有 `coin 296`（買糧 applicable）**、**母隊方向可行（趕路可行）**，
卻**只會投靠** ⇒ **它不是選了階梯末端，是階梯只有末端那一階**。

## §2 設計

**在途子隊每 tick 先跑一次「求生尺」評估**；**未觸發求生則維持現行早退**。

```
_evaluate_subteam(sub):
    if _in_transit(sub):                      # 移民/BUILD/CONSTRUCT/UPGRADE/EXPAND/CONVOY
        if _survival_ladder_tick(state, sub): # ★同一個 DecisionEngine 路徑、同一組 survival options
            return                            # 求生選項勝出 → 已 try_set（hold 對 ≥PRIO_THREAT 讓行）
        ...現行早退邏輯不動...
```

### ★★單一源鐵律（**本刀最重要的一條**）
**求生尺必須是「同一個來源」——不得為子隊複製一份 survival 邏輯／選項表／門檻。**
⇒ 走**既有的 survival option set 與既有 `DecisionEngine`**，**只是把子隊也送進去問**。

★ 理由：**今天已經因為「兩個理論上該同步、物理上分開」栽過四次**
（specimen 選樣清單凍結／fate 以隊伍消失推論／trip 以 id 為鍵／**七份 `_next_team_id`**）。
**複製一份求生邏輯 ＝ 主動製造第五次。**
（這也正是不變量「**命運不看 dispatch 路**」的機械形式：**同一把尺，不是兩把校準過的尺**。）

## §3 「挪用委託資產求生」：湧現允許 ＋ **留帳**
**用戶裁定**：**不硬禁、不魔法歸還**。允許瀕死子隊動用身上的委託資產（買糧等）。

**但要留帳**：
1. dispatch 當下記下**委託清單**（`task_extra_data` 內，不新增全域結構）
2. 歸建／併入時比對 → **差額 ＝ 挪用量**
3. **差額寫進母隊對該子隊 leader 的 belief** → **信任／聲譽後果**（走既有 belief／relation 管道，**不新增評價系統**）

⛔ **不做**：硬禁挪用、自動歸還、對挪用額外扣血或懲罰數值。
**後果應該是「別人怎麼看你」，不是「系統罰你」。**

## §4 gate
1. ★**階梯真的有多階**：合成床——瀕死子隊**身上有錢且市場可達** ⇒ **選「買糧」而非「投靠」**；
   **移除錢** ⇒ 才降到下一階。**逐階可證**（買糧／覓食／乞食／投靠）。
2. ★**單一源**：**`grep` 證明沒有第二份 survival 選項表／門檻**（**負斷言、窮盡、禁 `head`**）。
3. **承諾仍受保護**：routine（貿易／外交／野心）**仍被 hold 擋下**（`persist.hold` 對這些 task **真的 fire**）
   ⇒ ★**T1 從「死線」變成「活的」**——這是本刀的附帶產物，**要在帳上明寫**。
4. **不只 convoy**：**移民／建設子隊**同樣走得到求生尺（**至少一個非-convoy 族有樣本**）。
5. **留帳可觀測**：`convoy.entrusted.delta` 有值；母隊 belief **真的變**（**不是只寫進 log**）。
6. **det×3 穩定**；`fp` **會變 ＝ intended-change**（子隊行為改變）；憲法 ≤74；headless 0-new。
7. ★**perf**：子隊多跑一次求生評估的成本 —— **報 per-tick delta**，
   **若超過 5% 要先講**（`faction_ai` 已是 93.7% 熱點，見 memory `project_size_matter_arc`）。

## §5 不做
- **不開放子隊做 routine 決策**（貿易／外交／野心）——**用戶裁的是「求生尺」，不是「完整決策權」**。
- **不改 `PROGRESSIVE_HOLD_TASKS` 的內容**（它已經對）。
- **不新造評價／懲罰系統**（留帳走既有 belief）。
