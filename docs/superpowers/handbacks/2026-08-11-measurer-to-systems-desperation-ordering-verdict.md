---
from: measurer
to: systems
status: consumed
topic: "[iii絕境排序底查完成——決定性數字:herald近miss(-0.004essentially銅板差)vs defect清楚過關(+0.13)+defect formula零consequence-pricing(code-read確認)+★意外第三因(ticket未預設):同期主決策層被獨立軍事威脅佔據注意力,飢餓選項全遠低於威脅回應]specimen已送QA故事稽核,因果結論待verdict。① herald mini-util軌跡:tick5500(day~22.9)severity=0.306,mini=-0.463(明顯不夠);tick5800(day~24.2,defect fire同一tick!)severity=0.722,pmult=0.4592(求生欲0.5/野心0.3/義氣0.6算出),mini=severity×pmult×2.4-0.8=-0.004——essentially一個銅板差距沒過關。②defect_util軌跡:同tick5800,unrest=23(DEFECT_UNREST_THRESHOLD=20,前一天day24 unrest=18未達門檻無defect_terms樣本),distress_pressure=0.575,loyalty_deficit=0.5,stay_benefit=0.1575,defect_util=distress_pressure×loyalty_deficit-stay_benefit=+0.13清楚過關。code-read確認event_faction_defect.gd:23的公式字面上零項pricing『叛離後果(factionless→relief不可達→死)』,這是結構事實非我推測。③★★意外第三因(supersedes原ticket兩問的框架):tick5580主GoalResolver候選集(Team2)顯示求和(util=0.899)/備戰(util=0.762)霸榜,飢餓相關選項(survival=0.5/買糧=0.197/乞食=0.155)全部遠低於威脅回應選項——Team2那幾天task=外交(winner_opt=求和),真實決策焦點根本不在飢荒上,herald/defect兩個side-channel(不在主候選集內)在背景平行race,主決策層渾然不覺。這個發現可能比原本兩個mispricing假說更根本:即便herald util修正到能過關,主決策層仍可能被威脅佔用task選擇,不影響side-channel平行race結果,但影響Team2『真正在忙什麼』的整體故事框架。"
---

# iii 絕境排序底查完成 —— herald 近 miss + defect 零 consequence-pricing + 意外第三因

ticket `2026-08-11-systems-to-measurer-desperation-ordering-baseline.md` 消費。

## ①求援 mini-util 軌跡

```
tick5500(day~22.9): severity=0.306 pmult=0.4592 mini=0.306×0.4592×2.4-0.8=-0.463（明顯不夠）
tick5800(day~24.2): severity=0.722 pmult=0.4592 mini=0.722×0.4592×2.4-0.8=-0.004（★essentially銅板差沒過關）
```

**day23 太低是 genuine 還是 mispricing？——兩者都對，但更精確地說：severity 從 0.31 快速攀升到 0.72 只花了 1.3 天，mini-util 也跟著從 -0.463 追到 -0.004，幾乎就要追上了。這不是「還沒絕境」的 genuine 判斷（severity 已經 0.72，接近絕境上限），也不是純粹的常數 mispricing（差距已經非常小）——是 timing 差一點點沒趕上**。

## ②叛離 defect_util 軌跡

```
day24: unrest=18（未達 DEFECT_UNREST_THRESHOLD=20，check() 直接 return false，無 defect_util 樣本）
tick5800(★跟 herald 近 miss 同一 tick!): unrest=23 distress_pressure=0.575 loyalty_deficit=0.5 stay_benefit=0.1575
  defect_util = 0.575×0.5 - 0.1575 = +0.13（清楚過關）
```

**code-read 確認**（`event_faction_defect.gd:23`）：`defect_util = distress_pressure × loyalty_deficit − stay_benefit`——**公式裡字面上沒有任何一項在秤「叛離後果」**（factionless→relief 不可達→死）。這是結構事實，不是我的推測。是否該補這個 consequence 項，是你/blueprint 的 HOW 決定，我不越界。

## ★★③意外第三因（supersede 原 ticket 兩問的框架）

同期（tick5580）主 GoalResolver 候選集（Team2）：

```
求和  util=0.899  ← winner
備戰  util=0.762
maintain_food util=0.694
survival util=0.5
買糧  util=0.197
建設  util=0.155
乞食  util=0.155
紮營  util=0.155
```

**Team2 這幾天 task=外交（winner_opt=求和）——真實決策焦點根本不在飢荒上**，被一個獨立軍事威脅（`threat_id=3`）完全佔據。飢餓相關選項（survival/買糧/乞食）全部遠低於威脅回應選項。**herald（side-dispatch）跟 defect（cohesion event）兩個機制都不在這個主候選集裡**——它們是背景平行的獨立 race，主決策層完全不知道也不受影響。

**這個發現可能比原本兩個 mispricing 假說更根本**：即便把 herald util 修正到能過關，主決策層仍可能被威脅佔用 task 選擇——不會改變 side-channel 平行 race 的結果，但會改變「Team2 真正在忙什麼」的整體故事框架。是否要一併納入 iii genuine repricing 的設計考量，交你/blueprint 判斷。

## specimen 已送 QA

`docs/superpowers/handbacks/2026-08-11-measurer-to-qa-desperation-ordering-specimen-audit.md`，因果結論（威脅是否真「搶走」焦點、side-channel 是否真獨立）待 QA verdict 才鎖。

## 落地檔案（已 git commit `0a19aff6`）

- `scripts/debug/scale_econ_desperation_ordering_bed.gd`
- `docs/measurements/2026-08-11-scale-econ-desperation-ordering-seed8181.json`（281行，含 daily_log+兩組 terms 樣本）
- `docs/measurements/2026-08-11-scale-econ-desperation-ordering-seed8181.specimen.jsonl`（724 entries）+ `-raw.txt`（2821行）

別下 accept，output=兩 util 軌跡+terms+意外第三因，供你 spec iii genuine repricing 判斷（哪個/都是/第三因），非我越界定 HOW。
