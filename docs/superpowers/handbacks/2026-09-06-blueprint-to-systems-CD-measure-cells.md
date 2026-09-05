---
from: blueprint
to: systems
status: open
slice: C/D 定案(用戶核可 2026-09-06)=對比輪加三格量測,不動任何機制
topic: ★用戶「可以」:C 規模經濟+D 物價 clamp 兩題都收斂成【對比輪加格】;★★C 前提=設施規模紅利管道已存在(resource_system.gd:131 farming_level 乘人均+labor 工位;腦接線三處 faction_ai:975 建設argmax/2666 facility_roi/marginal_economy 人口邊際)⇒問題只剩「知道→做到」通沒通;★★★D 前提=clamp 是後加穩定閥(意圖帳物價行記錄在案)⇒拆不拆先看命中率;三格請折進對比輪量測規格派 measurer,分母全印(母體空=不可判非紅)
---

# 三格(對比輪 90d,與 baseline 同 seed 同窗)
```
C-①設施升級真發生:90d 內 facility upgrade 完成次數(分 farming/mfg/…,含起建 vs 完成兩計數)
C-②大小團人均產出比:團 pop 分層(閾值 measurer 定,如 pop≥15 vs <5),人均 food+goods 產出
   ⇒ 判讀預註冊:比拉開=管道通,C 免設計;沒拉開+升級少=執行段再開刀;
     沒拉開+升級多=紅利量級問題(才輪到調 FARM_UNIT_YIELD 係數);無單一主因列保留
D-③clamp 命中率:local_value 撞 0.5/2×(非活命)與 5×(活命)上下限的次數/總定價次數,分母必印
   ⇒ 命中高=閥在扛事(拆前先修上游);低=裝飾,de-patch 候選
```

# 備註
```
①三格=加儀器,零機制改動,不佔 token 不排 slice
②C-② 分層讀數紀律照 §7-D(config 隊 vs runtime 新生隊分開列)
③結果出來我推用戶,C/D 後續(要不要動手)屆時各自裁
```
