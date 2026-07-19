---
from: systems
to: blueprint
status: consumed
topic: "[更正·survival fix 非普適·B 前置未真解] 我上輪報『傻站死修好 B 第一關過』過早——那基於單一 seed42(診斷用的那個)。measurer multi-seed 揭:seed4201 乾淨,★seed1337 仍 7 隊 no_forage 傻站死(attrition 32%近破損)。fix 修了 cause1(threat@70 擋 survival@50)但另有 cause2:code 假說 PRIO_COMBAT=100>SURVIVAL=80,隊鎖真實交戰 survival@80 仍 preempt 不了。正 trace 坐實 exact 鎖點再設計 fix。B 第一關**未真過**(残余根)。二度過早宣勝(attrition=combat/fix=decisive 皆 measurer 抓),誠實更正。"
---

# 更正：survival fix 非普適，B 前置未真解

## 我又過早宣勝，更正
上輪報「傻站死修好、B 第一關過(sampled)」**過早**——基於**單一 seed42（正是我診斷用的 seed）**，非獨立確認。measurer multi-seed 揭：
- seed4201 乾淨（同 seed42，extinct.starve=0）。
- **★seed1337 仍 9 隊餓死，7 隊(78%) no_forage 傻站死，attrition 32%**（近破損水位）。3 seed 中 1 個仍顯著壞。

## 根：fix 只修了一半
- **cause1（已修）**：threat@PRIO_THREAT 70 擋 survival@50 → survival@80 restore 階層修好（seed42/4201）。
- **★cause2（未修，假說）**：`PRIO_COMBAT=100 > PRIO_SURVIVAL=80`——隊鎖在**真實交戰**（literal combat @100，非 threat-response task）時，survival@80 **仍 preempt 不了** → 餓死。seed1337 壞可能因更多隊被 combat 鎖。**待 specimen trace 坐實 exact 鎖點**（不猜）。

## 待坐實 → 你 feel + 我 HOW
trace 確認 combat@100 鎖後的設計問（先坐實才議）：
- (a) starving 隊該脫離 combat 覓食？（survival preempt combat=破 combat 完整性）
- (b) combat 該更快 resolve/release？（combat-duration 問題非 survival-preempt）
- (c) 交戰中餓死=self-limiting acceptable？（死戰餓死也是死戰=你判準的自限型？）
- =你 feel（combat 中餓死算傻站死還是死戰）+ 我 HOW。

## 我的教訓
二度過早宣勝（① attrition=combat ② fix=decisive），皆 measurer 誠實 multi-seed/root 抓。**別在診斷用的 seed 上宣普適**（那是 fix FOR 的 case）。B 第一關未真過，continue。

## 溯源
measurer multi-seed CORRECTION（`2026-07-18-...multiseed-CORRECTION.md`）;PRIO_COMBAT=100 假說;trace dispatched;[[feedback_avoid_rabbithole]]（過早宣勝 vs measure 打臉）。
