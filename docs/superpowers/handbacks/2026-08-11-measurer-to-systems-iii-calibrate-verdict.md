---
from: measurer
to: systems
status: open
topic: "[iii④順序gate+校準+flag(B)逐隊判完成——★★razor-thin margin真的被fix翻轉(tick級決定性數字)但Team2最終trajectory-shift非簡單變好變壞,需blueprint WHAT裁]seed8181 dispersed逐隊45天,temp tap(已revert)+determinism二跑byte-identical。★①tick5800(day~24.2)Team2同一tick:herald mini=+0.1717(過關會fire)/defect_util=-0.00056(consequence 0.1306把原+0.13壓成負、擋下)——QA上輪標註的razor-thin margin確實被hedge+consequence聯手翻轉,tick級證據decisive。Team3同款(defect tick5800被consequence壓到-0.0144擋下,herald稍晚tick5900轉正+0.466)。②聚合面改善:attrition20.8%→8.3%(顯著降)/help.letter_dispatched1→2(herald確實多fire)/defect_fire5→7逐隊拆解後分散多隊(anon-promoted旁支隊6/7/8各1+Team0/3各1+Team2兩次)非單隊惡化。③★★flag(B)確認且更精確:Team2雖day24那次defect真被擋,但food_days此後持續掛0、unrest飆到233→308,最終day37完全消失(pop=-99)——比baseline『永遠卡pop=1殭屍』更早死透。這是真trajectory-shift,非簡單變好或變壞,需你/blueprint WHAT層判斷『團隊徹底死亡』vs『永久殭屍態』何者更合理敘事(這題超出我measure-first範圍)。Team3則明顯改善(day45存活pop=4、food_days回升4.58,無二次defect)。④餓叛vs野心叛區分:Team1(食物健康food_days4.9→3.6穩定)day42仍defect一次,符合『野心叛不變』設計意圖(consequence≈0不壓)。⑤specimen已送QA(970 entries)故事稽核,因果結論待verdict。"
---

# iii④順序 emergent gate + 校準 + flag(B) 逐隊判完成

ticket `2026-08-11-systems-to-measurer-iii-calibrate-emergent.md` 消費。

## ①★★razor-thin margin 真的被 fix 翻轉——tick 級決定性證據

seed8181 dispersed，temp tap（`event_faction_defect.gd`/`faction_ai_system.gd`，已 `git checkout --` 復原確認乾淨），determinism 二跑 byte-identical。

**Team2，tick5800（QA 上輪標註的那個 razor-thin 時刻）**：

```
herald: mini_util = +0.1717  （severity=0.722 × pmult=0.4592 × 2.4 - 0.8 + hedge=0.1757 = 過關）
defect: defect_util = -0.00056（distress_pressure=0.575 × loyalty_deficit=0.5 - stay_benefit=0.1575 - consequence=0.1306 = 剛好被壓過負值）
```

**QA 上輪標註的「差 -0.004 就能翻轉」的假說被證實了**——hedge 把 herald 從 -0.004 推到 +0.172，consequence 把 defect 從原本的 +0.13（無 consequence 時）壓到 -0.0006，**同一 tick、兩個新項聯手真的翻轉了這場 race**。

**Team3 同款**：defect 在 tick5800 被 consequence 壓到 -0.0144（擋下），herald 稍晚 tick5900 轉正 +0.466。

## ②聚合面確實改善

```
attrition: 20.8% → 8.3%（顯著降）
help.letter_dispatched: 1 → 2（herald 確實多 fire 救人）
cohesion.defect_fire: 5 → 7（看似升，但見③拆解）
```

## ③★★flag(B) 逐隊拆解 —— defect_fire 5→7 非單隊惡化，但 Team2 出現真 trajectory-shift

7 次 defect_fire 分布：Team2×2、Team0×1、Team3×1、Team6×1、Team7×1、Team8×1（6/7/8 是 population-overflow spin-off 出來的旁支隊，非原本 4 隊核心故事）——**不是單一隊惡化，是分散在多隊**。

**但 Team2 本身出現一個需要你判斷的真實 trajectory-shift**：day24 那次 defect 確實被擋下了，**但 Team2 此後 food_days 持續掛 0、unrest 一路飆到 233→308，最終 day37 完全消失（pop=-99，team 徹底沒了）**——這比 baseline「永遠卡在 pop=1 殭屍態」**更早、更徹底地死了**。

這不是簡單的「變好」或「變壞」：
- 如果衡量標準是「有沒有活到最後」：baseline 的 pop=1 殭屍態技術上「活著」，fix branch 的 Team2 徹底消失了，看起來更差。
- 如果衡量標準是「敘事合理性」：一個永遠卡在 pop=1、food=0、unrest 累加到天文數字卻打不死的殭屍態，本身可能才是更不合理的既有病灶（跟這個 session 反覆撞到的其他「卡死不動」故事同款）；team 徹底消亡至少是個完整的敘事終點。

**這題超出我 measure-first 範圍**，需要你/blueprint 做 WHAT 層判斷。

**Team3 則是明確改善**：day45 存活、pop=4、food_days 回升到 4.58，此後沒再 defect 過。

## ④餓叛 ≠ 野心叛，state-emergent 確認

Team1：food_days 全程健康（4.9→3.6，從未逼近 0），day42 仍 defect 一次——`consequence` 在食物充足時趨近 0，不壓這種「野心叛」，跟設計意圖（餓叛通往死該壓、野心叛後果非死不壓）一致。

## ⑤specimen 已送 QA

`docs/superpowers/handbacks/2026-08-11-measurer-to-qa-iii-calibrate-specimen-audit.md`（970 entries），因果結論（Team2 消亡是否真的是 consequence-term 副作用 vs 獨立巧合）待 QA verdict 才鎖。

## 落地檔案（已 git commit `a7a1adb4`）

- `scripts/debug/scale_econ_iii_calibrate_bed.gd`
- `docs/measurements/2026-08-11-scale-econ-iii-calibrate-seed8181-fixbranch.json`（1395行，含逐隊 daily_log+完整 help/defect terms 樣本）+ `.specimen.jsonl`（970 entries）+ `-raw.txt`（3746行）

## 序

別下 accept。①②③④供你/blueprint 判斷 iii 最終定案；Team2 trajectory-shift（消亡 vs 殭屍）是本輪最需要 WHAT 裁的一題，交你/blueprint。
