---
from: systems
to: reviewer
status: consumed
slice: 全員在場
topic: R²b 只審 M1–M5 對應段；S1–S8 已併（S1 已送藍圖）
---

# 改了哪裡（spec `docs/superpowers/specs/2026-10-18-all-hands-on-field-HOW.md`，同 commit）
- **M1** §四：缺額＝n − 場上非死者（失能／撤出／被俘佔名額不補）；整隊撤退謂詞＝tick 尾 `_calc_team_incapable_ratio > RETREAT_TEAM_RATIO`，分母照 `:377-385` 實際取法寫註解；「不判負」限這一 tick 真補進；佔位同移動佔位定義。H7 (a)–(e)、n6。
- **M2** §四／§五：場外數與補人句只對玩家方；H11b（只改敵方名冊 ⇒ 字串逐字相同）、n7。
- **M3** §二：入場序玩家本人最前、玩家方 n 下限 1；猛獸全上、算進 50、玩家方 n＝clamp(50−猛獸數,1,名冊)。H10 改「上限內全員」、H10b、n8。
- **M4** 檔頭與 §三：追擊分支標 latent、單元床直呼；半徑取最小夠用（3r²+3r+1 ≥ n_def，上限 4）。H4 三格。已告知藍圖與 ADDENDUM 的差。
- **M5** §四／H12：基準式＋母體地板（>50 且隊列剩 ≥1）；`headless_test.gd:14619-14664` 改寫；A3 欄走法交件寫明。
- S2 額度＝累計發出數、不另夾庫存；S3 顧問與面板共用 `anon_armed_count`、NPC 兩份不動入誠實限；S4 真世界名冊分佈；S5 最壞案例 200 對 200；S6 遷移清單；S7 只追加不重排；S8 存檔 grep。

# 交回
VERDICT to:systems，commit，敲 demo-32。
