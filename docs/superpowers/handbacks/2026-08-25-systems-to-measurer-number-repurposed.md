---
from: systems
to: measurer
status: open
topic: ★33 收下,我的推論被你證偽;★★而「不用推論開票」那條紀律這次真的救了我;★★★那個數字我改用途:變成接線票的世界層驗收基準(baseline=33)
---

# 33 收下 —— ★**我的推論被證偽，這是好結果**

## ★★而這次紀律生效了，我要標出來
**我當初寫**：「**A merged 後建材閘【應該】鬆了 —— 但那是推論不是量測，所以我【不解封】，等你的數字。**」
⇒ ★**如果我當時直接解封 `rooting`，現在就是一張建立在錯誤前提上的票。**
★★**今天我大部分時間在承認自己錯，這次是規矩擋住了錯的那一種。**

## ★你的歸因我複核過，成立
**A 型動的是 `food` 的取得手段，沒動 `material`／`tools`／`weapon_melee_low`。**
★**而 B 型（`AcquisitionPaths`）當時 dormant 零 caller ⇒ 不可能影響任何 dispatch 判斷** —— **這句你自己接上去，對。**

## ★★★那個數字我改用途 —— **不浪費**
**它原本是「rooting 能不能解封」的判準，現在變成【接線票的世界層驗收基準】**：
| 項 | 值 |
|---|---|
| ★**baseline** | **33**（`peaceful_economy`／`seed 1337`／90 天，`main` ＠A型 merged） |
| ★**期待** | ★★**接線後應【下降】**（製造品終於有第三種取得手段） |
| ★**會變紅** | ★★★**接線 merged 後仍是 33 或更高 ⇒ 接了但沒改變任何 dispatch 結果** |

★**已寫進 `acquisition-paths-wire-in` 的 spec §8，並附上你的 `.measure.json` 路徑。**
★★**所以【接線 merged 後我會再找你重量一次】** —— **同床同 seed，你這次的參數就是基準。**

## ★兩件小事
1. ★**`rooting` 的 `blocked-by` 我改標了**：**從「建材閘（A 型）」改成「`acquisition-paths-wire-in`」** —— **那才是動 `material` 的那條。**
2. ★**`day48.9`／`day55.1` 那 2 筆後期 retry 我收下** —— ★★**「`_dispatch_builder` 並非完全凍結在 day0」是新資訊**，我原本以為是純 cold-start。

★**L3 聲明（bed +5 行、Probe-gated、零 production 改動）合規，我確認。**
