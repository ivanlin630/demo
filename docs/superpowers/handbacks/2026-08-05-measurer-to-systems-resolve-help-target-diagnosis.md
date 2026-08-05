---
from: measurer
to: systems
status: open
topic: "★_resolve_help_target 89%『失敗』root查明=非code bug,是Probe計數桶混淆:temp-print逐次呼叫顯示——36次severity_positive中,32次是team已faction_id=-1(day44後,defect已使其獨立,正常無lord可問)、4次是team仍在faction內的真評估且100%成功resolve(accepted=1,H1/H2/H3三假說皆未發生過一次)。問題出在_try_herald_side的呼叫端只用`if tgt.id==-1: bump(target_unresolved)`一個bucket,沒區分『已非faction member』vs『仍是member但真找不到』兩種完全不同原因——production code本身邏輯正確,是我上一輪的tap粒度不夠精細誤導判讀。★真正卡點回到mini_util:4次成功resolve當中,help.mini_util峰值全部=0.0000(cost-benefit gate從未通過),letter從未dispatch。這才是relief鏈真正斷點,建議下一步查_help_pmult/severity×INFO_RELIEF_EXPECT-INFO_ANON_COST這個算式在此fixture參數下為何結構性≤0(非我越界猜HOW,誠實報告數字所在)。temp print已revert確認乾淨。"
---

# `_resolve_help_target` 89%失敗 root 查明：非 code bug，是量測 bucket 混淆

工單 `2026-08-05-systems-to-measurer-resolve-help-target-tempprint.md` 消費。

## temp-print 結果（已ls/wc驗證落地：`docs/measurements/2026-08-05-help-target-debug.txt`，1100行）

```
faction_id=-1→bail（H0，非H1/H2/H3任一假說）：32次
真評估（faction_id有效,走完整迴圈）：4次，全部 accepted=1（100%成功resolve）
  [HTDBG] team=1 結果best_pos=(16, 16) | 跳過分布: self=1(H2) owner_null=0(H1) faction_mismatch=2(H3) accepted=1
  [HTDBG] team=3 結果best_pos=(16, 24) | 跳過分布: self=1(H2) owner_null=0(H1) faction_mismatch=2(H3) accepted=1
  （T1/T3 各 2 次，數字皆相同——同一組tile掃描結果穩定重現）
```

**H1(owner==null)/H2(resident自己是唯一outpost)/H3(faction_id remap錯位)三個假說全部沒發生過一次**——32次「unresolved」全部是第4種、systems原本沒列進假說清單的**H0：team.faction_id已經是-1**（`faction_ai_system.gd:1739`最前面那個guard，team已經因defect退出faction，正常沒有lord可問）。

## ★誠實淨判：`_resolve_help_target` 本身零bug

- **成功率**：team仍在faction內時，target resolution **100%成功**（4/4）。
- **32次「失敗」的真正原因**：team已經因defect機制在day44退出faction（獨立team=faction_id=-1）——這之後每天still severity_positive fire（team還在餓，只是現在沒lord了），`_try_herald_side`正確地在faction_id==-1那關直接return，這是**完全正常、預期內的行為**，不是bug。
- **量測端的問題**：呼叫端只有一個`help.target_unresolved`計數桶，沒有區分「已非faction member」vs「仍是member但真找不到領主」——這兩種原因天差地遠，混在一起數才產生誤導性的89%數字。**這是我上一輪tap粒度不夠精細的問題，不是production code的bug**，在此更正。

## ★真正卡點：回到 `help.mini_util`

4次「仍在faction內的真評估」，**全部**在resolve成功後卡在下一關：`help.mini_util`峰值=0.0000（`faction_ai_system.gd:1684-1687`的`mini = severity * _help_pmult(lv) * INFO_RELIEF_EXPECT - INFO_ANON_COST`，`if mini<=0.0: return`），letter從未dispatch。**這才是relief鏈在這個fixture裡真正斷掉的環節**——不是找不到人問，是「問了但AI自己算出來不划算」。

**下一步建議（非我越界定HOW，只誠實報告數字所在）**：若要繼續深挖，下一個該查的是`_help_pmult(lv)`的公式和這個fixture的severity/population參數組合下，為什麼`mini`結構性算出≤0——可能是`INFO_RELIEF_EXPECT`（=DESPERATION_DAYS×FOOD_PER_PERSON_PER_DAY=2.4，固定值）相對`INFO_ANON_COST`（=0.8）+ `_help_pmult`的組合，在severity剛轉正（低severity值）時本來就很難超過門檻——這可能是**genuine「輕度餓不值得派信使」的by-design行為**（非bug），也可能是這個具體fixture的population/distance參數組合觸發了一個真正的calibration問題。我沒有把握判斷是哪種，交你們判。

## 對 cohesion ①分化的影響

這個發現**不改變①INCONCLUSIVE的結論**，但**精確化了故事**：relief鏈斷點不在「找不到求助對象」（那條路徑是好的），是在「找到了但AI自己決定不划算」這一步。這也**不是「純reactive太晚」的race-timing問題**（原本假說）——是在severity剛轉正、還有時間差的時候，AI就已經主動判定不值得，跟race timing無關。

## 清理

- temp print（`_resolve_help_target`內H1/H2/H3診斷）已 `git checkout --` revert確認乾淨（`git diff --stat`歸零）。

別下accept。mini_util結構性≤0是否要深挖，交你們判。
