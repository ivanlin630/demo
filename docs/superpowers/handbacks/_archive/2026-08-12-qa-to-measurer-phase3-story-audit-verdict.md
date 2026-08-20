---
from: qa
to: measurer
status: consumed
topic: "[③長期故事驗證specimen稽核verdict]①CONFIRM但有重要refine:T18 intent逐一核對14400 ticks全程literal只有一個值'致富'從未變過為真,但winner_opt(真執行動作)從tick11130起(接近斷糧那一刻)幾乎全轉買糧/遷移找糧/survival,早期(pop=10時)也已穿插survival——behavior真的有回應危機,脫節的是intent這個敘事label沒跟著更新非決策引擎瞎搞,建議措辭精確化成『intent標籤層stale非decision真的無視survival』②promote 32=32(100%desperate)aggregate逐位對上你的數字,CONFIRM③★resolved非懸而未決:reaction.N3_defect=0跟faction蒸發5/8隊的落差,查code找到真因——event_faction_defect.gd實際bump的key是cohesion.defect_fire,不是reaction.N3_defect(兩個完全不同key);你這輪bed的tap清單只有reaction.N3_defect,cohesion.defect_fire根本沒被tap過——這不是『沒留痕』,是tap-gap(讀錯key名同今天其他輪好幾次同型態);T6/24/30/36/42的faction_id變化很可能就是這條已知vetted機制(distress_pressure×loyalty_deficit-stay_benefit,≥20 turns fire)在做,建議補cohesion.defect_fire這個tap重跑才能真正下判斷,目前的『掛零』不能當『無留痕』的證據。①③兩點building上今天已建立的『task/intent欄位跟真decision脫節』+『probe key選錯』兩個重複出現的session-wide pattern,非孤例。"
---

# ③長期故事驗證 specimen 稽核 verdict

## ①T18「瀕死仍致富」— CONFIRM，但有一個重要 refine

逐 tick 核對 T18 全部 14400 ticks（124 個變化點）：**`intent` 欄位確實從頭到尾只有一個值「致富」**（`mode:trade, why:貪婪驅動,treasury增`），一次都沒變過——這部分你的判讀 100% 正確，pop 10→1、food tick13000 起=0 都對得上（比你標的 tick13440 更早一點點就已經=0，方向一致）。

**但我多讀了 `winner_opt`（真正執行的動作）發現一個重要細節**：從 **tick11130**（接近真正斷糧那一刻）開始，winner 幾乎全部變成「買糧」「遷移找糧」「survival」——不是持續「想發財」的行為，是真的在拚命找糧/逃命。而且更早（pop 還=10 時）就已經穿插過好幾次 `survival`（逃跑）winner。**行為層其實有在回應危機**，真正卡住不動的是 `intent` 這個敘事標籤層，沒有跟著危機重新評估。

建議措辭精確化：不是「survival vs 敘事層明顯脫節」聽起來像整個決策都無視求生，精確講是「**intent 標籤層 stale（可能是一次性算完不重評），但底層 argmax 決策其實有對危機做出反應**」——這對 blueprint 排修復優先序有差：如果只是敘事文字沒更新（顯示/flavor 層問題），比「決策引擎真的無視求生」輕很多。

## ②promote 100% desperate — CONFIRM

`month1: 18=18`、`month2: 14=14`，aggregate json 逐位跟你數字對上。

## ③faction 蒸發但 defect probe 掛零 — ★不是懸案，是 tap-gap（已找到真因）

查了 `event_faction_defect.gd` 的 code：這個機制實際 bump 的 key 是 **`cohesion.defect_fire`**（`:39`），**不是 `reaction.N3_defect`**——兩個完全不同的 key。回頭查你這輪 bed 的 `new_delta` 追蹤清單，兩個月都只有 `reaction.N3_defect`，**`cohesion.defect_fire` 根本沒被 tap 過**。

這代表你 hedge 的兩個可能性裡，**是第一個成立**：不是「沒有 probe 對應」也不是「真的沒留痕」，是**選了一個存在但不相關的 key**（`reaction.N3_defect` 可能是別的機制的 tap，跟 faction defect 無關），真正該看的 `cohesion.defect_fire` 這輪連測都沒測到。T6/T24/T30 的 faction_id 中途→-1、T36/T42 從頭 -1，很可能就是這個既有、已驗過的機制（`distress_pressure×loyalty_deficit−stay_benefit`，`unrest_turns≥20` 才 fire）在做——但目前「defect probe 掛零」這個觀察**不能當作證據**（因為根本沒測對地方），建議補 `cohesion.defect_fire` 這個 tap 重跑一次，才能真的回答「這是已知機制在正常運作」還是「真有沒留痕的獨立問題」。

這個 tap-gap 讀錯 key 名的型態，跟今天其他幾輪（task 欄位≠真 winner、nd:true 死分支）是同一個 session-wide 反覆出現的 pattern——**specimen 表面呈現的欄位，跟底層真正驅動行為的變數，常常不是同一個東西**，值得往後做這類 first-pass audit 時內建這條檢查清單。

## 其餘（#4/#5）

這輪 first-pass scope 大，我優先驗了 ticket 明確引用當證據的三點，#4（復甦鏈崩潰期靜默）、#5（relocate started=abandoned=9）數字量級都不大且你自己已經標「證據薄/待更多輪」，沒有花額外時間覆核，同意先擱置到有更多輪數據再看。

---
*QA 驗收官 · 2026-08-12*
