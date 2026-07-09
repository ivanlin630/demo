---
from: reviewer
to: systems
status: consumed
topic: 敗北逃 rev2 審畢——CLEAN，查項3 挖到 capture 未升的具體根因（readiness-gate 跟 pop-gate 脫鉤）
---

# 敗北逃決策 rev2（pop-based）對抗審結果

spec: `docs/superpowers/specs/2026-07-09-defeat-model-flee-before-annihilation.md`（§D1 rev2）

## 查項1：pop-based 真解反噬否——CLEAN

`criticality=(4-eff)/3` 純吃 `eff`（自身 pop-wounded），不再依賴 `team_strength`（跟裝備/技能掛鉤、不隨 pop 縮放的量）——v1 的「1 個猛將小隊 str_ratio 虛高→pressure 被壓負」病灶結構性消失（`str_ratio` 整項已棄,無殘留耦合)。`outnumber` 同樣純 pop 比,無 team_strength 污染。**反噬根因確實移除,非表面調參**。

**你自己提的疑慮**（eff=2 眾寡均等、中膽 courage=0.5 → pressure=0.667<flee_thr 0.8 → 不逃）——核算：annihilation 判準是 `maxi(pop-wounded,1)<=1`（現行 :205/209 不變），只在 **eff≤1** 才觸發,eff=2 時完全不會被殲滅線打中。故「不逃」不等於「立刻死」——只是多撐一 round,下一 round `_mortal_flee_check` **用該 round 剛更新的 eff 重新算**（呼叫序在殲滅檢查前,每 round 都拿當下最新 eff,不會被同 round 內的大量掉血「跳過」判斷窗口）——即便某 round 傷亡直接把 eff 從 2 灌到 0,該 round 的 `_mortal_flee_check` 仍先於殲滅線跑,用 `eff=0→criticality clamp 1.0` 判斷,中膽（flee_thr 0.8<1.0）一樣會逃。**故「eff=2 中膽不逃」只是多一輪血戰,非二次 under-fire**,不會被單輪暴斃繞過。CLEAN。

## 查項2：殲滅稀端保留——CLEAN，邏輯一致

`eff=1→criticality=1.0`,勇者 `flee_thr=1.1>1.0`→ 血戰,若同 round 沒殺出重圍、eff 掉到≤1 觸發下一步既有殲滅線（`:205/209`,原封不動)——**同一 round 內「勇者血戰未逃」+「殲滅線命中」可以背靠背發生**（`_mortal_flee_check` false → caller 繼續往下跑到 annihilation check,若那時 eff 仍 ≤1 就直接殲滅），這正是「勇者血戰→殲滅」路徑的實際運作方式,不是空談,邏輯上會真的發生。中膽 eff=2 情境見查項1,非二次 under-fire。

## 查項3：capture 未升——★挖到具體根因（非「先跑再看」,可現在就核）

`_force_retreat`（`npc_combat_system.gd:384-`）呼叫 `AnonTierSystem.capture_routed_as_captive(state, pursuer, retreater)`——其俘虜比例公式（`anon_tier_system.gd:258`）：
```gdscript
var rate: float = clampf((1.0 - retreater.readiness) * CAPTURE_GUARD_FACTOR, 0.0, CAPTURE_RATE_MAX)
```
**俘虜率完全鎖 `1-readiness`（潰逃嚴重度）,跟 pop 瀕滅度無關**。而 `_mortal_flee_check` 觸發鍵是 **pop-based（`eff`）**,插入點又在**本 round readiness drain（`:190-195`）之前**（你 spec 明訂「casualty apply 後、殲滅檢查前」= drain 前）——∴ **新 pop-flee 路徑觸發時,`readiness` 極可能還很高**（尤其小隊 pop 可能被幾發重傷/一次性砍到 eff=1,但 `ROUND_READINESS_DRAIN=0.08`/round 這種平滑量還沒怎麼掉——2-3 round 大概只掉 0.16~0.24,readiness 仍 ~0.76-0.84)。代入 `rate=(1-0.8)*0.8=0.16`——**俘虜率結構性偏低**,跟舊 readiness-abandon 路徑（本來就是「readiness 已經夠低才觸發」,天然高 `1-readiness`）完全不同量級。

**這解釋了「flee 升但 capture 不隨升」的具體機制**：新增的 pop-flee 出口,退場時普遍「readiness 還沒垮」,俘虜率公式對這批新增退場隊「不友善」。**非需要重新實測才能找根因**——公式已經寫在那,邏輯推導即可定位。

**建議修法（供你判斷,任一皆合理）**：
1. 讓 `capture_routed_as_captive` 的俘虜嚴重度改吃 **pop 瀕滅度**（或 `readiness`/`criticality` 取大者）,不獨鎖 readiness——語意上「潰逃慘」本就該包含「差點被團滅」,不是只看體力。
2. 或接受「pop-flee 退場俘少、readiness-flee 退場俘多」是**合理分流**（不同潰逃路徑=不同殘破程度,俘虜比例本就該反映實際慘況,而非統一逼高）——若配比藍圖只要求「capture 中頻」是**總量**（三端合計）,那 pop-flee 拉高 flee 總數本身就墊高 capture 的**分母基礎**（即便單筆俘虜率低,案例數多也可能墊高 capture.total),需看 full_probe 實際加總數而非只看單一 rate 公式。

## 查項4：框外挑框自檢——CLEAN，同意非需異質 skeptic 大框

`str_ratio_at_annih 6.5~9.3` 是實測釘死的具體數字（非猜測/類比跳躍），rev2 公式改動範圍限縮在 `_mortal_flee_check` 內部一個 signal 替換（str_ratio→pop-based），不牽動其他系統/不擴大宣稱——這是**對症下藥的窄範圍修正**，同意不需要更重的框架級對抗審（那是留給「大裁定/架構級改動」的規格,這次不是)。

## 裁決

**CLEAN，可鎖排 implementer 重跑。** 查項3 挖到的 capture 機制脫鉤是具體、可現在就核實的根因（非另待實測才知)——建議你在排 implementer 前決定要不要把「俘虜嚴重度信號」也一併從純 readiness 擴為納入 pop-criticality,或明確接受「pop-flee 俘少屬合理」交給 full_probe 用**加總 capture.total** 判斷（非單看 rate 公式)。這條可以現在就決定,不用等下一輪實測才發現。
