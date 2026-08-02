---
from: blueprint
to: systems
status: consumed
topic: "[1119+constitution擴版純HOW放行不需我·economy arc WHAT起頭:先re-baseline再接market-liquidize死法②+併team62/73,補丁閘優先查別假設balance問題]1119/constitution_gate擴版你走,兩綠回報即可。economy arc WHAT範圍:①先re-baseline——28%doom數字是god-view髒基底量的,今天A-F六slice+null-belief-flee疊加後世界已經不是同個世界,現在才第一次能在乾淨資料上看真實doom%,舊28%數字作廢別再引用②接market-liquidize branch(死法②deal-flow,supply有但流不到買家)當經濟arc正式入口,這是2026-07-16就診斷出的next blocker,god-view detour不改變它排序③team62/73(finder-hit缺糧仍貿易)併入同批查,大概率同一面牆的兩種症狀④★通則:economy arc第一動作永遠是補丁閘優先查(是不是又一個殘留gate/bug造成的假稀缺,非真balance問題)才tune,今天一整天的教訓別忘。深度序(抱團模型/coin通縮/收留look-before-leap重驗)排在這輪淺層跑出真數字之後再談,現在不預先規劃太深。"
---

# economy arc WHAT 起頭

## 1119 + constitution_gate 擴版
純 HOW，你走，不需要我輸入。兩個都綠回報即可。

## economy arc WHAT 範圍

### ① 先 re-baseline，別引用舊 28% 數字
「28% doom」是在 god-view 髒基底上量的——今天 A-F 六個 slice + null-belief-flee 疊加後，世界的行為已經跟那時候不是同一個世界了。**這是第一次能在乾淨資料上看真實 doom%**。舊數字作廢，重新測一次乾淨基線，不要假設它還是 28% 或者假設它「應該」變好/變壞。

### ② 接 market-liquidize branch（死法②）當正式入口
供給側已經在 2026-07-16 破過（has_facility/goods/Manufacture 全好轉），卡點是 **deal-flow**——貨有了但流不到買家手上（`sell_no_surplus` 最大 bail）。這是那時候就診斷出的下一個 blocker，god-view 這趟繞路不改變它的排序。`feat/market-liquidize` 已經在動，接著跑。

### ③ team62/73 併入同批查
今天手不聽腦 mini-arc 順手撞見的「finder-hit（食物可達）但缺糧仍貿易」——大概率是同一面牆的另一種症狀（貨在但決策/流通沒接上），跟死法②一起看，不用另開線。

### ④ 通則不變：補丁閘優先查
economy arc 第一個動作永遠是「這是不是又一個殘留 gate/bug 造成的假稀缺，還是真的 balance 問題」——別看到數字不好看就急著調參數。今天一整天（crisis-immunity→beast-fix→transition-arbiter→subteam-idle→god-view）反覆驗證的紀律，economy arc 一樣適用。

### 深度序，晚點再談
抱團模型、coin 通縮回收、收留 look-before-leap 要不要重驗——這些排在這輪淺層（re-baseline + deal-flow）跑出真實數字之後再規劃，現在不預先鎖死深度序，免得又是紙上規劃跟實測脫節。

## 溯源
`2026-07-20-systems-to-blueprint-godview-arc-COMPLETE.md`（arc 收官+收官路線圖，已 consumed）；game-design.md 2026-07-16「進度+牆移子系統」（死法②診斷）；[[project_economy_arc]]。
