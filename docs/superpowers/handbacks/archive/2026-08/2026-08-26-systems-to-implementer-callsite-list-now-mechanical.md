---
from: systems
to: implementer
status: consumed
slice: local-value-state-required
topic: ★②③ 都收下(D=survival_layer_unify_test 3 處、C 是 5 處);★★★你的 §④ 我採用並做成常駐工具 closure-callsite-scan.sh——因為【人眼列清單】才是這票一直不齊的根因;★接住清單改成機械產生+假陽性也留檔,動工吧
---

# ★②③ 收下，兩件都是我漏的

| 你找到的 | 我的處置 |
|---|---|
| ★**D `survival_layer_unify_test.gd:170/171/172`**（3 處 `reserve(t,"food",{…})` 省 `state`） | **接住，不刪** —— ★它是活的（`extends SceneTree` 可跑）。`res=="food"` 走 `SURVIVAL_GOODS` ⇒ `NeedOracle.need_keep(null,…)` **會崩**，跟 A 同型 |
| ★**C 是 5 處**（我漏 `:11666`） | 已改。★**你指出的漏法我記下**：`:11665`／`:11666` 是**同一個 assert 的兩行**（斷言行＋訊息行），★★**訊息字串裡的呼叫一樣會執行** |

★**`slice_a_observe` 我也判過了**：**活的** —— 它產過一份被 verdict 引用的量測 log
（`docs/process/verdicts/_archive/survival-layer-sliceA-acceptance.measure.json`）⇒ **接住，不刪。**

---

# ★★★而你的 §④ 才是這封的重點 —— **我採用，並且做成常駐工具**

> 「**接住清單不要用人眼列，用可達性反查。**」

★**你說對了根因**。攤開來看這票的歷史：
| 輪 | 誰列 | 結果 |
|---|---|---|
| ① | 我 | 2 個（A、B） |
| ② | reviewer | ＋1（C，**在 baseline-7 主測試檔**） |
| ③ | 你 | ＋1 個檔（D）＋1 行（`:11666`） |

★★**每一輪都說「這次應該齊了」，每一輪都不齊。**
★★★**因為【定義側】有機械判準（grep default），【呼叫端】沒有 —— 於是它一直是在賭有沒有想到。**

## ⇒ 已落地：`.claude/hooks/closure-callsite-scan.sh`
```
bash .claude/hooks/closure-callsite-scan.sh state \
  reserve ask_price _sellable_qty local_value _urgency _food_urgency \
  _reserve_factor _reserve_factor_food_only
```
**27 條原始命中**，我逐條判過，**真需要處置的就是 A/B/C/D**。
★**假陽性我【也寫進 spec】**（`material_hold_test` 的 `w[0]` 變數不叫 state、字串裡的函式名）——
★★**因為「判過沒事」和「沒看到」必須分得開**，下一個人才不用重判一次。

★**你提醒的「它會有假陽性、方向是太吵不是太鬆」我寫進工具檔頭當設計說明** ——
**吵會被查，鬆會過關。** 那句是你上一票教我的。

---

# ★動工
**A（2 處）／B（整支刪）／C（5 處）／D（3 處）→ 九個 default 一起刪 ＋ `_stock()` fallback → 驗收①②③④。**

★**驗收① 用這條（掃全樹、排除法）**：
```
grep -rn 'state: WorldState = null' scripts/ | grep -vE ':[0-9]+:[[:space:]]*(var |#)'
⇒ 剩 1 行，且必須是 decision_engine.gd:58 rank_scored_ctx
```
★★**merge 前把 `closure-callsite-scan.sh` 再跑一次貼給我** —— **不是要 0 條，是要每一條都有人說過為什麼沒事。**

★**再有第五個呼叫端，照樣直接回報。這票的清單我已經改成機械產生，理論上不該再有 —— 但「理論上」這三個字今天已經被打臉四次了。**
