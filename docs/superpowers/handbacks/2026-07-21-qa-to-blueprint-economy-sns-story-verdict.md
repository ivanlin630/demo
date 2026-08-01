---
from: qa
to: blueprint
status: consumed
topic: "[sell_no_surplus 故事稽核·CONFIRM 真稀缺非 machinery 誤判] 讀完 60 筆 specimen:coherent 真武器稀缺,無 machinery 味。res-type 一致(weapon reserve↔weapon holding,無混層)、holding 真被讀到(team63=0.6/team68=0.2 非零→證明不是某層把 holding 歸零的 bug)、reserve 隨 pop 縮放合理。~54/60 真 holding=0(世界沒產武器)+~6 筆 holding<reserve(有幾把留防身)=兩者都真無 surplus 可賣。→ 強化 measurer『weapons under-produced 生產側』verdict,市場撮合機制本身沒壞(正確報無貨)。★小訂正:measurer 說『全部 holding=0.0』不精確(6 筆非零),但不改結論。scope 提醒:我判的是 machinery-vs-稀缺=稀缺;武器 buy-demand 3573 合不合理/reserve 政策對不對=WHAT 你判。"
measured_at_head: 9c084d3a
---

# sell_no_surplus 60 事件故事稽核判決（QA）

**源**：`2026-07-21-measurer-to-qa-economy-sns-specimen.md`
**讀**：`docs/measurements/2026-07-21-economy-sns-specimen-9c084d3a-1337.txt`（60 筆逐事件，seed1337 8mo，全 res=weapon_melee/ranged_low）

## 判決：**COHERENT 真武器稀缺，非 machinery 誤判** ✓

逐項查 machinery 味（你今天糾正「聚合詮釋成因果前先讀故事」，我照做逐筆讀）：

| 查 machinery 的點 | 結果 | 判 |
|---|---|---|
| **res-type 對錯**（今天抓的 food/goods 混淆類） | 全 60 筆 weapon reserve ↔ weapon holding **同型配對**，無混層 | **無誤判** ✓ |
| **holding 被某層吃成 0?** | 反證：**team63 holding=0.6、team68 holding=0.2 被正常讀到**（tick 3300/4300/4900/5000/5100）→ 儀器**讀得到非零 holding**，故其餘 holding=0 是**真 0** 非「某層歸零 bug」 | **無誤判** ✓ |
| **reserve 算錯 res-type/量級** | reserve 隨 pop 縮放：pop=10→reserve 2.0-2.4、pop=3→0.7-0.9、pop=1→0.1-0.3 = 合理防身量 | **無誤判** ✓ |
| **賣方是不是餓死亂賣** | 賣方 task=貿易、food 多數足（17-176），是想賺錢的商隊非絕境隊 | coherent |

**故事**：buyer 掛武器買單（你聚合的 buy-demand 3573）→ 撮合檢查賣方 surplus → 賣方**手上 ~0 武器**（54/60）**或有幾把但 < 防身 reserve**（6/60，如 team63 有 0.6 但要留 1.2）→ 兩種都=**無 surplus 可賣** → sell_no_surplus **正確 fire**。market 撮合機制**沒壞**（誠實報「你沒多的可賣」），根因在**世界根本沒產出足夠武器**（生產側）。

→ **強化 measurer 的「weapons under-produced 生產側」verdict**。這批不是 machinery 假象，是真稀缺，你可據此往生產側行動。

## ★小事實訂正（不改結論，但量測可溯源鐵律要精確）
measurer 初判寫「**全部 holding=0.0**」——**不精確**：60 筆中 **6 筆 holding 非零**（team63 melee=0.6 ×3、team68 melee=0.2 ×3，surplus 仍 <0 因 <reserve）。**結論不變**（holding<reserve 一樣是無 surplus），但「全部 0.0」的措辭會讓人以為「零武器」，實際是「零 surplus（含有幾把但要留防身的）」。sell_no_surplus 語意=**無 surplus 非 holding=0**，兩者差別在 reserve 政策，別混。

## scope 提醒（我判的邊界）
- **我判的**：machinery-vs-真稀缺 = **真稀缺**（撮合機制正確、儀器沒讀錯層）。
- **我沒判、歸你（WHAT）**：武器 buy-demand=3573 這個需求量合不合理？reserve 防身政策（留 0.1-2.4）是不是你要的？「世界不產武器」是設計意圖還是缺生產鏈？——這些是願景/平衡，非 machinery，你裁。
- **我沒判、歸 systems（若你要深挖）**：確認「weapons under-produced」需生產側 trace（誰能產武器、產率），此 specimen 只證「賣方沒貨」不證「全世界產率」——但與 under-production 一致。

## 下一站
你（blueprint）：故事判 CONFIRM 真稀缺 + measurer 生產側 verdict 合流 → 若要治，往武器生產鏈（WHAT 定要不要、systems 定怎麼架）。**這輪無 machinery bug 翻案**（跟今天死隊系列不同，這個 economy 聚合的詮釋是**對的**——真稀缺）。

（QA 只找不修不裁；machinery-check 過關 = 聚合詮釋可信。教訓自留：economy 聚合這次故事稽核 CONFIRM 而非翻案，證明「先讀故事」不是每次都翻案——是驗證詮釋真偽，真的就放行。走 handback 交 systems 提煉 memory。）
