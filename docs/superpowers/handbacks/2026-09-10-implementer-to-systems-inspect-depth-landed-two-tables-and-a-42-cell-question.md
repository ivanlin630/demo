---
from: implementer
to: systems
status: open
slice: 觀察窗 inspect 深化
topic: ★五欄掏好＋覆蓋率閘上線（`df01410a`）：閘的**腐爛判定照 R² 的反方向寫**（豁免欄位不得出現在任何玩家可見查詢面），四格成對對照全過｜★★**兩張表都在**：ctx 119（已接 2／待接 117／豁免 0）＋補充母體 2 項（事件流已接、關係圖全貌待接）｜★★★而我要交回兩個【不該由我決定】的東西：**42 欄「未分頁」**、以及**「待接 117」這個桶本身**
---

# ① 五欄（★掏欄位，不造機制）

```
query_team    target{move_pos, combat_team_id, social_team_id}   ★三個 target 各有語意，不合併成一句
              goal_state（引擎自己存的結構；★不加解釋層＝票②）
              work_morale（★team 層唯一的士氣量）
              threat{snapshot:false, note:"…"}   ← ★見 ③
query_outpost residents_here_now[]（★位置謂詞：此刻在這裡，不是屬於這裡）
```
床 `observer_inspect_depth_bed`（acceptance，4 段全綠），★成對對照兩處：
**有目標 vs 沒目標看得出差別**；**隊走了 ⇒ 居民清單變空**（證明印的是位置不是歸屬）。

# ② ★★威脅感：我選了【印未快照】而不是重算（照 spec §3②）

```
threat_react / threat_id 只活在 DecisionContext，而 ctx 是每 tick 重算 ⇒ ★沒有快照可讀。
我【不】在查詢時 gather：那等於「觀察一次就跑一次引擎」，
★而「觀測改變被觀測物」今天已經有血證。
⇒ 面板印 { snapshot:false, note:"未快照：…每 tick 重算" }
⇒ ★★而它【說了為什麼】：讀的人不必去猜 0 是什麼意思。
```
⇒ ★★★**這一格【沒有交付「玩家看得到威脅感」】** —— 它交付的是「玩家知道自己看不到，以及為什麼」。
**要真的看到，需要一張「存威脅快照」的票**（spec 自己也把它留給下一張）。

# ③ 覆蓋率閘（`.claude/hooks/ctx-coverage-gate.sh`）

```
母體＝decision_context 的 var 欄位（119）；每一欄必須【剛好】在 ctx-exposure.tsv 一次
狀態三選一：exposed(要寫 who) / exempt(要寫理由) / todo(要指【存在的】票)
★★★腐爛判定照 R² 的【反方向】另外寫（不是照抄 _dead_equivalents）：
   對每個 exempt 欄位 F，反查三個玩家可見查詢面；★命中 ＝ 這格豁免已腐爛 ⇒ 具名紅
成對對照四格（每輪先跑，不過就 ABORT）：
   乾淨⇒綠｜新欄位⇒具名紅｜同欄兩列⇒紅｜★把一個【真的被查詢面讀到】的欄位標 exempt ⇒ 紅
```
★**而對照樣本我犯了一次**：第一版用中文假欄位名，而抽取器只認 ASCII ⇒ **對照本身沒被偵測器看見**。
★★**那不是閘壞了，是我的樣本不像真的** —— 已改成 ASCII 並把理由寫在對照旁邊。

# ④ 兩張表（★兩張都綠才算完成，照 R²）

```
docs/process/ctx-exposure.tsv     119 列：exposed 2 ／ exempt 0 ／ todo 117
docs/process/ctx-supplement.tsv   2 項：事件流【已接】(C1 票① 的 wrapper) ／ 關係圖全貌【待接】
```
★**我沒有勾掉任何一格豁免**（照裁：豁免要呈用戶簽，沉默不是豁免）⇒ **exempt = 0**。

# ⑤ ★★★兩個我交回去、不自己決定的東西

**(1) 42 欄「未分頁」**
```
我用關鍵字自動分了 77 欄（生存/經濟/威脅/社交/記憶），★剩 42 欄關鍵字答不出來。
⇒ 我標成 `未分頁` 而【不是】塞進「其他」——★其他會是一個【不會變成 0 的垃圾桶】。
⇒ ★★分頁是 WHAT（玩家在哪一頁找得到它）⇒ 交 blueprint 裁；
   ★★★而我連那 77 欄的自動分類也【只是建議】：關鍵字猜出來的分頁，錯了不會有人發現。
```

**(2)「待接 117」這個桶本身**
```
閘現在容得下 todo，而 blueprint 裁的是【全要】⇒ ★todo 是一個【應該要清空】的桶。
⇒ 而清空它 ＝ 把 117 欄真的端到查詢面上，那【不在本票的五欄裡】。
⇒ ★★我沒有偷偷把它做掉，也沒有把它標成豁免充數。
⇒ ★★★要不要開一張「ctx 逐頁端出」的票、還是併進票②（人話層），由你/blueprint 裁。
```

# ⑥ 回歸與一件事故

```
observer_inspect_depth_bed 4/4｜observer_inspect_test ALL PASS｜headless-regression PASS
bed-kind PASS｜ctx-coverage-gate PASS（4 格對照）
```
★**事故（今天第二次）**：`ctx-exposure.tsv` / `ctx-supplement.tsv` 這兩個新檔
**被 `f5f84c56`（你的 01_architect 瘦身 commit）掃走了** —— 內容與我的工作樹一致，我不重寫 history。
★★**第一次是 blueprint 的 `e848dfef`** ⇒ **同一天、兩個不同的人、同一個成因（共用 main dir ＋ `git add -A`）**。
★★★你信裡說要做機械擋 —— **這是第二個樣本，而它證明那個擋是必要的**：
兩次都不是誰不小心，是**這個工作方式在有並行寫入時必然發生**。
