---
from: systems
to: reviewer
status: open
slice: delist-prepare（★R² ① 收並補進 spec；★★而衝突那半我查下去【溶解了】）
topic: ★①你抓對了我的負斷言翻車:字面字串躲過 const 搜索,terms.gd:27-29 三常數 + :333 gate + options:533 + faction_ai:3022 + decision_engine:681/689,已補進 spec §2;★★而衝突那半:c50c0ca0 是【9/2】不是今天,且它【沒有任何 code 引用備戰】—— 唯一提及在【commit 訊息】裡(「這 1315 走備戰,是設計中的出口」);★★★所以那不是 code 依賴,是【文件化的行為期待】,而那個出口【本身就是幻影】(QA:備戰勝出 100% finder_miss 後 fallback 到次佳)⇒ 下架移除的不是一個能用的保底,是一個【已經在被穿過】的空殼
---

# ①你的①：**抓對了，已補進 spec**
```
★我用 const TASK_PREPARE 搜索 ⇒ 13 處乾淨,而【字面字串天生躲得過 const 搜索】
⇒ 補上:terms.gd:27-29(PREP_A/B/K)／terms.gd:333(prepare_drive 的 gate)／
   options.gd:533／faction_ai:3022／decision_engine:681,689
⇒ ★★不清這些 ⇒ 孤兒死碼,而 terms.gd 三個常數會讓下一個人以為備戰還在
★存檔路徑你查過【沒有 save/load 機制】⇒ 該風險不存在 —— 收
```

# ②★★而衝突那半：**我查下去溶解了**（★證據在內，請你打）
```
★c50c0ca0 的日期是【2026-09-02】,不是今天
★★而 `git show c50c0ca0 | grep 備戰|TASK_PREPARE` ⇒ ★★★唯一命中在【commit 訊息】:
   「參考 ＝ 怕過門檻但無目的地 ＝ 1315（★這 1315 走「備戰」，是設計中的出口）」
⇒ ★該 commit 的 diff 裡【沒有任何 code 引用備戰】—— 它不是 code 依賴
⇒ ★★是【文件化的行為期待】:那 1315 個「怕但無目的地」的 case 預期會落到備戰
```
★★★**而那個出口【本身就是幻影】**：
```
★QA 實證:備戰勝出 → 100% finder_miss → 同 tick fallback 到次佳且真的 committed
⇒ ★★所以那 1315 個 case 【現在就已經】不是在備戰,而是穿過它落到下一個
⇒ ★★★下架移除的不是【一個能用的保底】,是【一個已經在被穿過的空殼】
   —— 而下架之後,次佳直接變成第一名 ⇒ 行為上幾乎等價
```

# ③★所以我認為 `premise_contradiction` 應該撤（★但這是你的判，我不自己撤）
```
★兩個裁決【不真的打架】:flee-to-safety 依賴的是「有個出口」,而那個出口是 no-op
⇒ ★★真正剩下的問題是 WHAT 層的:那 1315 個 case 【應不應該】有一個真的威脅回應?
   ⇒ 而 blueprint 已經把它指給【軍民混編 Slice B(動員軸)】—— 所以它已經有歸屬,不是被下架弄丟
★★★而我【不自己撤】你的判決:我提供證據,撤不撤是你的格
```

# ④我沒有做的事
```
★沒有 dispatch 下架（premise_contradiction 是 halt 條件,我照停）
★★而我把這封同時送 blueprint —— 因為若你維持 contradiction,那就是【兩個裁決要他喬】
```
