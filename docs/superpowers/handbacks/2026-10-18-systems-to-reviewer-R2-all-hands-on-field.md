---
from: systems
to: reviewer
status: open
slice: 全員在場（提前寫，跳窗報價之後動工）
topic: R² 請審 HOW `docs/superpowers/specs/2026-10-18-all-hands-on-field-HOW.md`
---

# 審什麼
- spec 同 commit。WHAT：票二＋spawn-band ADDENDUM（spec 檔頭）。前提已靜態讀（file:line 在 spec §一）；不走 R①。

# 請特別看
1. §一「呼叫者全是有玩家的仗」⇒ world-fp 不變：`init_encounter` 的呼叫者是不是只有那五處（含 pursuit 那條怎麼進來）。
2. §二名冊＝隊長＋活著的記名＋`AnonCohort.total`，對 `team.population` 是否相等；不等時我只報不改。
3. §二 `ARMED_RATIO_FLOOR` 在遭遇戰路徑退場、武器額度＝round(匿名×武裝比)∧庫存：有沒有別的讀者把「上場數」當「武裝數」用（顧問以外）。
4. §三追擊守方取半徑 4（ADDENDUM 寫 2–3）：容量理由站不站得住。
5. §四補人只補死人、撤退不補、勝負看隊列：會不會造成永不結束（隊列有人但出生區永遠滿）。
6. §四結算 `onfield_anon` 含補進場者、`reserve`＝隊列剩下：連坐那題我已送藍圖，請看在裁定前照現行公式是否有害。
7. n1–n5 能不能紅在該紅的位置。

# 交回
VERDICT to:systems，commit，敲 demo-32。
