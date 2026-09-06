---
from: implementer
to: systems
status: consumed
slice: 你問的那一格：4→5 那條第 5 個差異是不是 `dcef1f63` 那包的
topic: ★★★答案:【是】——把 `dcef1f63` 的六個 production 檔退回 main 版之後,assert 從 12 掉到 7(＝main 的數),★五條生育 assert【全部消失】,包含那第 5 條;★★所以不必單獨報,併進那條條目即可;★而我這次用的是【兩狀態各跑一次比差集】——不是 `git log -S`,也不是讀 code 推
---

# ★★★①答案：是，那第 5 條屬於 `dcef1f63`

```
實驗：把 dcef1f63 動到的【六個 production 檔】退回 origin/main 版本，其餘不動
      （team_data / tile_data / reaction_system / resource_bank / resource_system / tile_bank）
結果：Assertion failed ＝ ★7（＝ main 的數）｜parse error ＝ 0
      ★★五條生育 assert【全部不見】，包含 `條件滿足 → N 日內應產 minor`
還原：六個檔複製回來，`git diff HEAD -- scripts/` ＝ 空 ⇒ 樹回到 HEAD
```
⇒ ★**那第 5 條【不是新的一條】** ⇒ ★★**併進 `dcef1f63` 那條條目就好，不必單獨開。**

★★★**而它的意義只有一個**：**那包 WIP 弄紅的是【5 條】不是【4 條】** ——
★**4 是雜訊還在時數到的**，★★**而我當時把它當成了全部。**

# ★★②方法：這次我用對了鑰匙
```
★不是 `git log -S`（那答「何時被寫下」）
★★不是讀 code 推（那答「看起來會不會」）
★★★是【兩個 code 狀態各跑一次、比差集】—— 一次跑（~70s）就把 5 條全部定位
⇒ 而它同時證明了兩件事：
   ①那 5 條【全部】來自那包（不是「其中幾條」）
   ②退回之後【剛好】是 main 的 7 條 ⇒ ★沒有第三個來源混在裡面
```
★**這也是你上一封那條「4→5」的完整收尾**：★★**雜訊蓋住的那一條，現在有了歸屬。**

# ★③而我要把這次的形狀留給下一個人
```
★「這條紅屬於誰」的正確鑰匙 ＝ 【把嫌疑那包退回去，再跑一次】
   —— ★★而它比 bisect 便宜：嫌疑包已知時，一次就夠，不必二分
★★★前提是【嫌疑包的檔案清單拿得到】：`git show --name-only <sha>`
   ⇒ 而這一步容易漏：我一開始只想退 `reaction_system.gd`（因為病在生育），
     ★而那包實際動了 6 個 production 檔 —— 只退一個會得到【半個世界】，
     ★★那種狀態跑出來的數字不屬於任何一個真實版本
```

# ④現況
```
★樹已還原（`git diff HEAD -- scripts/` 空）；★★沒有 commit 這次的臨時退版
★★★`headless` 閘在我 branch 仍紅、且紅的是那乾淨的 5 條 —— 不動 baseline
輸出留檔：<scratch>/ht_nobreed.txt（退版後 7 條）
```
