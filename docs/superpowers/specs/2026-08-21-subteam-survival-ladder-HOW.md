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

### ③ ~~血證：porter 案卷~~ ⇒ ★★**撤回（implementer 動工前實測否決，2026-08-21）**

**原文**：~~瀕死 porter 有 `coin 296`、母隊方向可行，卻只會投靠 ⇒ 階梯只有末端那一階。~~

**實測**（peaceful / seed 1337 / 90 天，tap 在 `rank_survival` 內、只記 `parent_team_id != -1`）：

| spec 說 | 實際 |
|---|---|
| 在途子隊**不走**求生尺 | ★**有走**（`faction_ai:850` `_evaluate_survival` 對每隊呼叫） |
| 階梯**只有末端一階** | ★**2–3 階**（team13 `n=3`：`[併入, 買糧, 紮營]`） |
| 買糧**不在**候選 | ★**在**（team13 `coin 347.4`、`has_buyable_food=true`） |
| team21 沒買糧 ＝ 階梯被砍 | ★**`has_food_market=false`**（那一帶沒市場），**機制正常** |

★**真問題換了：不是「階梯只有一階」，是「90 天只被問 4 次」——是【入口頻率】，不是【候選數量】。**

⇒ **§2 的設計（「把子隊也送進去問」）連帶失效**：機制已經在，
**照原 spec 再加一層求生評估 ＝ 第二個入口 ＝ 違反本 spec 自己寫的單一源鐵律。**
**本刀 HELD**，等頻率診斷（見 §1④）定位「沒被呼叫」還是「呼叫了被 entry gate 擋」。

### ④ 待答（診斷票已派 measurer）
`_evaluate_survival` 對**在途子隊**的 **呼叫次數 vs 放行次數**。
★ 依 `patch_gate_first` 追加判準：**「gate 沒擋」≠「gate 沒執行」**——
只回「沒擋」會讓我把 entry gate 錯記成誠實。

### ⑤ 順手記下的架構味道（**非本刀**）
implementer 指出：`:4796` 對 `uses_unified` 或非子隊 early-return
⇒ **子隊反而是唯一還走 legacy body 的角色**。
與統一矩陣的 `uses_unified` 承重牆同一條線，**記在案，不在本刀動**。

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
3. **承諾仍受保護** —— ★**T1 的兩個方向要拆開講，不得含糊成「T1 活了」**（R² 必查項，我送審時也自己懷疑過）：
   - ★**survival-override 方向：真的活了**。子隊被送進求生尺後，
     `≥PRIO_THREAT` 的求生選項**真的會走 `try_set`**，而 hold **依設計讓行** ⇒ **這條路徑第一次有東西經過**。
   - ★**routine-block 方向：仍然結構性打不到**。本刀**只加求生評估、不開放 routine 決策**
     ⇒ **routine 本來就沒人嘗試對子隊搶班** ⇒ **hold 沒有東西可擋** ⇒ **那一半仍是 inert**。
   ⇒ **帳上要寫「T1 半活」**，**不得寫「T1 活了」** —— 否則就是**重演 convoy 那輪的 over-claim**。
   （對應 tap：`persist.hold` 對子隊 task **預期仍為 0**；若非 0 反而要查是誰在對子隊丟 routine。）
4. **不只 convoy**：**移民／建設子隊**同樣走得到求生尺（**至少一個非-convoy 族有樣本**）。
5. **留帳可觀測**：`convoy.entrusted.delta` 有值；母隊 belief **真的變**（**不是只寫進 log**）。
6. **det×3 穩定**；`fp` **會變 ＝ intended-change**（子隊行為改變）；憲法 ≤74；headless 0-new。
7. ★**perf**：子隊多跑一次求生評估的成本 —— **報 per-tick delta**，
   **若超過 5% 要先講**（`faction_ai` 已是 93.7% 熱點，見 memory `project_size_matter_arc`）。

## §5 不做
- **不開放子隊做 routine 決策**（貿易／外交／野心）——**用戶裁的是「求生尺」，不是「完整決策權」**。
- **不改 `PROGRESSIVE_HOLD_TASKS` 的內容**（它已經對）。
- **不新造評價／懲罰系統**（留帳走既有 belief）。
