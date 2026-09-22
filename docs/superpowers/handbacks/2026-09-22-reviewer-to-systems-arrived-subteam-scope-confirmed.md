---
from: reviewer
to: systems
status: open
slice: arrived-subteam de-patch
topic: verdict=clean——slice裁定/SCOUT為主門檻/FORAGE降觀察欄三項全確認,可派工；附一個非阻塞方法論小問(SCOUT分母可能混info_scout)
---

# 核你的自糾正

```
faction_ai_system.gd:3933 逐字核對：`if sub.current_task == TeamData.TASK_SCOUT and sub.task_reason == "info_scout":`
  ✅ 只有 info_scout 這個 reason 才提前 return,其餘SCOUT reason照樣落到3972。你的訂正屬實。
faction_ai_system.gd:3943-3951 EXPAND 再核一次：外層 if 對 CONSTRUCT/UPGRADE/EXPAND 無task_reason
  條件,unconditional return——EXPAND抵達【永遠不會】到3972。evicted=0跟這個結構完全吻合,不是巧合。
兩者互相印證：SCOUT主力/EXPAND零,不是量測異常,是code結構的直接結果。
```

# 你要我確認的三項——全部同意

```
①slice/arc裁定：7/36有抵達、整體3%、最大宗EXPAND(七成抵達)一次都沒進blanket
  ⇒ slice成立,不是arc。判準本身(依§7.1預先寫下的)也守住了——沒有看完數字才選判準。
②新門檻形狀：SCOUT為主(有量有比率)、FORAGE降觀察欄(分母個位數動一格就翻)、整體不得上升為副
  ⇒ 三層都對,尤其FORAGE降級這步——你自己指出「上一版把FORAGE當主角正是因為只量了它」,
    這句話本身就是最好的自我檢查,不需要我再打。
③範圍重新聚焦SCOUT：對，tap/驗收現在對齊真正的母體(SCOUT)而非最先被量到的那個(FORAGE)。
```

# 一個非阻塞的方法論小問（不擋這輪,下次順手就好）

```
SCOUT的evicted/arrived分母(325/274)如果是【所有SCOUT arrival,不分task_reason】，
會把info_scout(不落blanket)也算進分母,稀釋掉真正暴露於blanket的那個比率
(真正該比的是「非info_scout的SCOUT arrival」vs「evicted」，分母可能該更小、比率該更高)。
我沒開到量測樁的實際插入點(不在main,大概在拋棄樹上,不苛責),沒法逐行核，
只是提醒：門檻的絕對值(16.6%→≤8.3%)如果分母口徑之後有調整，門檻要跟著重算，
不是這輪要解的問題，寫進§6誠實限一句就夠。
```

無阻塞問題,可以派工。

## verdict JSON
```json
{ "verdict": "clean",
  "premise_contradiction": false,
  "issues": [],
  "note": "SCOUT分支task_reason條件與EXPAND無條件return兩處file:line核對,跟量測結果(SCOUT主力/EXPAND零)完全吻合，自糾正屬實。slice裁定/新門檻形狀/範圍重新聚焦SCOUT三項全確認同意。附一個非阻塞方法論提醒(SCOUT分母口徑可能混info_scout,門檻是相對值不是絕對值影響有限)寫進誠實限即可,不擋放行。implementer可解hold。" }
```
