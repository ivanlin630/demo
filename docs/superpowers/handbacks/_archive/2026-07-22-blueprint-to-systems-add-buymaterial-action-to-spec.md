---
from: blueprint
to: systems
status: consumed
topic: "[QA故事判補一塊·means-end need修法必須連帶新增buy-material動作(仿buy-food),否則需求接了也沒動作可選·非新WHAT是spec範圍要含這塊]QA讀8隊mil jsonl坐實:決策候選集裡有『買糧』動作fire 305次(仿coin低也買),但完全沒有對應的『買material』動作存在——就算你means-end提案把facility慾望接進material need_keep,需求有了但候選集沒有『買material』這個action可選,還是轉不成實際購買。這是結構性缺口(food有專屬買路徑material沒有),QA判為broken機制非coherent世界。★我先前點頭的means-end修法仍成立,但spec範圍要補這塊:仿現有buy-food動作,新增對應的buy-material(或更通用的buy-resource參數化,你HOW判斷)動作進候選集,否則need-generation修好也是空的。mil coin貧困(次要,影響大額購買如material120)維持你原本的分開處理,不變。"
---

# 補一塊：means-end 修法必須連帶新增 buy-material 動作

## QA 補的關鍵一塊
QA 讀 8 隊軍事隊的 jsonl，坐實：決策候選集裡有「買糧」動作，fire 305 次（連 coin 低也買）——但**完全沒有對應的「買 material」動作存在**於候選集。就算你 means-end 提案把 facility 慾望接進 material `need_keep`，需求有了，但候選集裡沒有「買 material」這個 action 可選，argmax 還是選不到它，需求轉不成實際購買。

這是**結構性缺口**（food 有專屬買路徑，material 沒有）——QA 判為 broken 機制，非「世界本該如此」的 coherent 敘事。

## 我先前的點頭仍成立，但 spec 範圍要補這塊
means-end（facility 慾望→material need）修法方向不變，我已經點頭。但 spec 範圍必須連帶：**仿現有 buy-food 動作，新增對應的 buy-material 動作**（或做成更通用的參數化 buy-resource，你 HOW 判斷哪個實作起來乾淨）進候選集——否則 need-generation 修好也是空的，需求接了但沒有動作可執行。

## mil coin 貧困維持分開處理
次要因素（影響大額購買如 material 120），維持你原本的分開處理，不變。

## 溯源
`2026-07-22-qa-to-blueprint-material-trade-flow-verdict.md`（故事判決，已 consumed）；`2026-07-22-blueprint-to-systems-meansend-material-approved.md`（means-end 原點頭）。
