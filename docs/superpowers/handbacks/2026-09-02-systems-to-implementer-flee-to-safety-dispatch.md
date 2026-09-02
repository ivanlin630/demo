---
from: systems
to: implementer
status: open
slice: flee-to-safety（#5 修法）
topic: ★R② 過(issues 皆解,兩條都併進 spec);★★形狀:選步加「要有 believed 目的地」+移動改三層優先序+退化走既有 TASK_PREPARE(不必新建);★★★方向源我盤點過:①己方據點 ②同 faction 成員位置【兩個現成】,③記憶安全處【不存在,本刀不建】;★而有一個【既有】窄 band 我判 benign 但要你加計數撐它
---

# ★①形狀（★spec 全文見 `docs/superpowers/handbacks/2026-09-02-systems-to-reviewer-R2-flee-to-safety.md`）
```
★選步：FLEE 的 applicable 加上【存在一個 believed 目的地】
   ①`faction_ai_system.gd:6075 _find_own_outpost`（self-knowledge，零 god-view）
   ②`faction_data.gd:33 known_member_states`（★已被 belief_system.gd:129 當同-faction 位置通道，含 staleness gate）
   ★★③【記憶安全處】掃過 `scripts/data/*.gd`：**沒有這個欄位** ⇒ ★★★本刀【不建】，用①②就夠
★★移動：★★★三層優先序【寫死】（reviewer 給的 staleness race 防禦，我採納）
   ①目的地可解 → 朝目的地
   ②目的地過期/無，而威脅座標仍在 → away-tile（既有 `_flee_away_tile` 保留）
   ③兩者皆無 → backstop release（`movement_system.gd:88` 保留為【冗餘】）
★退化：無 believed 目的地且真恐懼 ⇒ 引擎自然 rank 到「備戰」
   —— ★★`TASK_PREPARE` 是既有 option（`options.gd:400`），★★★不必新建 task
```

# ★★②恐懼不會被吞掉（reviewer 查實，我複驗）
`備戰` 的 applicable 只要 `threat_react >= threshold`、**不需 destination** ⇒ **真恐懼（過門檻）保證有出口。**

## ★★★而中間有一個【既有】窄 band，我判 benign —— **但要你用數字撐它**
```
options.gd:76-81 "逃跑" applicable【不檢查 threshold】，只檢查 threat_pos != -1
⇒ ★兩道閘問【不同種類的問題】：FLEE 問「有沒有座標」、備戰問「怕不怕」
⇒ band ＝ threat_pos != -1 且 threat_react < threshold ⇒ 加 destination 後可能兩者皆不 applicable
★★我判 benign：低於反應門檻 ＝ 沒怕到需要出口，隊會去 rank 正常選項
⇒ ★★★驗收加一格：**落進該 band 幾次** —— 恆 0 代表 band 不存在；數字大 ⇒ 我判的 benign 要重判
（★這 band 是【既有】結構落差，不是本刀新造；已另立 known_issues 條目）
```

# ★③驗收（★第②條是防自欺的，注意）
```
①`fp` 會變（行為修正）⇒ 差在哪要說得出來
②★★★沿用 #5 量測：續卡隊數【應趨近 0】，而【機會母體不該塌】
   ⇒ ★若 FLEE 隊數也掉到 0，那是【把恐懼擋掉了】不是修好了
③★退化路計數：「因無目的地而改派備戰」幾次 —— ★★恆 0 表示退化路沒被走到，要查
④★backstop release 次數應【下降】（從主要收尾降級成冗餘）
⑤★★band 計數（見②）
```

# ④不動的
★`_flee_away_tile` **保留**（三層的第②層）。★★`movement_system.gd:88` backstop **保留**（第③層）。
★★★**不要因為「有了新機制」就把舊的拔掉** —— **它們現在是不同層的接住點。**
