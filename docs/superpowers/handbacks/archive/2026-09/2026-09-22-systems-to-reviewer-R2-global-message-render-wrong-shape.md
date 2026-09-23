---
from: systems
to: reviewer
status: consumed
topic: R² 審設計：事件流渲染讀錯形狀（玩家看得到的缺陷，現在就在 main 上）｜★spec 已落地，路徑在內文
---

# 請審

**spec（已落地）**：`docs/superpowers/specs/2026-09-22-global-message-render-reads-the-wrong-shape-HOW.md`

**開票**：blueprint 2026-09-22（從 `feat/walkthrough-v2` 拆出的 (乙)，不等那場尋找）

# 一句話

`player_api_mapper.gd:797` 只認 `Dictionary`，其餘走 `str(m)`；
而世界寫進 `global_messages` 的 **5／5 個 production 寫入點全是 `MessageData`**
⇒ 玩家看到的每一則事件都是 `<RefCounted#-922337…>`。

# ★R① 我判免，理由寫在這裡讓你反對

規矩：R① 只給【新概念大框 ＋ 前提含未驗 code 斷言】。
本票的每一條前提我都已經逐點坐實，spec §1 裡列著：

```
寫入端 5 個：各自的 `var msg := MessageData.new()` 行號 ＋ append 行號
讀取端 4 個：三個已用 MessageData 欄位（popup_layer:76／message_system:299／observer_bridge:63）
            一個假設 Dictionary（player_api_mapper:797）
床 2 支    ：各自 append Dictionary 字面量的行號（我開檔看過，不是照抄別人的註解）
```

⇒ 沒有「X 會經過 Y」這類未貼呼叫點的斷言。**若你認為有，請當 R① 打回。**

# ★★我自己知道的三個弱點（先講，省你挖）

```
① §7 誠實限寫著：我【只】掃了 global_messages 這一條流。
   observer_messages 那條 channel 沒掃 ⇒ 同型可能還有一處，而我沒有證據說沒有。
   ★這是「宣稱窮盡 vs 讓窮盡可被證偽」——我選擇標限，不選擇宣稱。
② 「保留 Dictionary 分支」是我的判斷，不是量出來的：
   現在 production 零個寫 Dictionary ⇒ 嚴格說它是死分支。
   我保留它的理由是【未來可能有人寫】，而那是推論。
   ★你若認為該刪（fail-loud），這是設計選擇，請裁。
③ §4 的判決行格式是我訂的，我【沒有】實際跑過它印出來長什麼樣
   ——那是實作端的事，但若格式本身有問題（例如操作元不自足），現在打回比事後便宜。
```

# ★★★我要你特別看的一格

blueprint 令「缺陷要變成對照」，spec §3-4 把它寫成：
**兩支床的餵料改成真型別，或新增一格餵 MessageData 的床**。

★我給了「擇一」，而擇一意味著**實作端可以選那個比較不痛的**。
⇒ 若你認為必須指定其中一條（例如「一定要把舊床改掉，否則盲點還在」），請直接改死它。
★★我傾向「改舊床」，因為新增一格會讓**舊那兩格繼續餵假形狀**——
  盲點沒被拆掉，只是旁邊多了一個對的。但我沒把它寫死，這是我留的洞，請你補。

# 落地路徑（審過之後）

```
R² CLEAN ⇒ 我派 implementer（新 worktree，不以 feat/walkthrough-v2 為 base）
⇒ 陽性對照兩層都要跑到（spec §5）
⇒ production 檔 ⇒ 落地走 merged result 上的整份電池，不是分支自檢
```

★現況備註：目前主線的合併電池卡在【不可判】（68／72 被機器記憶體壓力殺掉），
等用戶對重跑點頭。本票的**設計審不受那件事阻擋**，實作也不受——只有最後落地要排隊。
