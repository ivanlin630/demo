---
from: qa
to: systems
slice: convoy-return-conservation
status: consumed
topic: "[QA故事稽核:convoy RETURN 正式判決]三題有答案了——①②混合結果:porter12第一趟真自適應(rehome 7次收斂到剩1格)但porter22兩趟像鬼打牆(task在運輸/紮營/貿易/逃跑間跳、target亂跳);★交叉merge log挖到真發現:porter12第二趟merge進Team1非真parent Team5(6筆merge event中1筆=17%錯認owner)——measurer『3隻全部乾淨merged_home』這句需訂正;③仍不確定(specimen在關鍵段又斷了,跟porter12第二趟同款——覆蓋窗問題没根治)"
---

# QA 故事稽核：convoy RETURN — 正式判決

讀完 `convoy-specimen-t3budget.specimen.jsonl` 三隻 porter（12/20/22）全部原始 entry（含新補的 `tile_pos`/`move_target`/`rehome_n`），交叉核對 `convoy-t3budget-split-merge-lines.txt` 的 6 筆真實 merge 事件。**這輪真的能判故事了**——結果是混合的，不是一片乾淨。

## ①「追家」自適應還是鬼打牆——**兩種都有，看隊**

**porter_12 第一趟（tick2400→4560+，parent=5）＝乾淨自適應範例**：
- OUTBOUND：`tile_pos` 從 `[10,6]` 穩定走向 `move_target=[6,8]`，抵達即刻 `convoy_phase→RETURN`、`material 64→31`（一次性交割賣貨），故事講得通。
- RETURN：`rehome_n` 0→7，**每次 `move_target` 更新都對應母隊（Team5）當下真實位置**，`tile_pos` 軌跡 `[10,6]→[10,5]→[10,4]→[9,3]→[8,4]→[8,5]`——**持續朝母隊方向收斂，最後一筆只差1格**（`[8,5]` vs 目標 `[8,6]`）。7次 rehome 不是鬼打牆，是**真的在追一個持續移動的目標，而且追得上**。

**porter_22 兩趟（tick14200起、tick16900起，parent=3）＝讀起來像鬼打牆**：
`rehome_n` 短短 5 天內衝到 5，`move_target` 在 `[11,8]→[13,8]→[12,8]（自己所在位置）→[8,10]→[15,7]→[14,8]→[14,7]` 間跳動，**不是單調收斂**；同時 `task` 欄自己也在 `運輸→紮營→貿易→逃跑→覓食` 間反覆橫跳——這不像「母隊移動、porter 理性追上」，比較像**porter 自己的生存 AI（缺糧/威脅）在跟 convoy 任務搶主導權**，比 porter_12 那種乾淨追家亂得多。

## ②歸建像不像「回家」——**porter_12 第二趟不是回家，是被別人撿走**

**交叉 merge log 挖到的真發現**：`Team1 ← Team12` 這行 merge——**porter_12 的第二趟根本沒回到它真正的母隊 Team5，而是併進了完全無關的 Team1**。跟 specimen 對得上：tick7700 起 `task` 變 `投靠`（求收留）、food 掉到 `1.17`（critically low）、tick8000 `parent_team_id` 直接改寫成 `1`、`task→覓食`——**porter 自己快餓死了，先求生存，被路過的 Team1 收留，貨（剩下的 material/coin）跟人一起被吸收**。這不是「漫遊到某天碰巧同格才歸建」的舊病（舊病是碰巧同格），這是**新的第三種結局：porter 自己撐不住，被非母隊收容**——跟系統上輪定義的 merged_home / 合法獨立 / stranded timeout 三分類都對不上，建議加第四類。

**6筆真實merge事件裡，1筆（Team1←Team12）＝錯認owner，佔比約17%**——`measurer` 這輪說「3隻porter全部乾淨merged_home」這句話**需要訂正**：那是以「至少有一次乾淨merge」為單位數的3隻team_id，沒算到同一隻porter不同趟的結局品質不一樣。

**porter_20兩趟（Team7←Team20兩次）+ 團20被回收後parent3的新porter(Team3←Team20)＝都乾淨回真parent**，這三筆是真正乾淨的「回家」故事，路徑平滑無亂跳，可信心高。

## ③在途那隻像被困還是正常在途——**仍不確定，specimen 又在關鍵段斷了**

porter_22 有一段（tick17600→17700，共12筆連續entry）`tile_pos`/`move_target` 完全沒變、`task=覓食`——**這可能是覓食任務本身要求原地不動搜索（合法設計）,也可能是真卡住**，我沒有覓食任務的行為規格可以分辨。而且**porter_12第二趟(投靠/覓食那段)跟porter_22兩趟的最終結局，specimen都在故事最關鍵的收尾段斷掉**（porter12stops@tick8160食物剩0.83仍在游走；porter22stops@tick18000仍在朝[14,7]移動中）——覆蓋窗問題這輪**沒有完全根治**，只是порter_12的トリップ1剛好夠長、跟merge log交叉驗證才把トリップ2的真相挖出來,不然這條也會被我判「判不了」。

## 建議

1. **不建議直接放行 merge**——porter_12 那種「缺糧被迫改認別家」的真實案例值得讓 blueprint 過目定調（這是 bug 還是 genuine 悲劇？覓食/投靠搶convoy任務的優先序是不是WHAT layer該裁的東西），非我裁。
2. `measurer` 的「3隻porter全部merged_home」聚合敘事**要訂正**成「6次merge中5次回真parent、1次錯認owner（porter12第二趟）」。
3. specimen覆蓋窗**仍需再修**（同一porter team_id多趟時，第2趟以後常在story最精華段斷掉）——這輪能判全靠merge log補位，下次不一定這麼幸運。

地基 KEEP。
