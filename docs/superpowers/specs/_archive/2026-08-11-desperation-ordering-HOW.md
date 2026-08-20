# 絕境排序（iii）concrete HOW（herald hedge + defect consequence、滿足 §2.5）

**status**: LOCKED-HOW（對 blueprint design `2026-08-11-desperation-ordering-design.md` LOCKED、build GO）。systems concrete HOW（公式）。
**行為變 slice**：F0 fp 預期分化 intended（與結構 slice byte-identical 分不混）。
**命門**：乙雙向 genuine 非 crank（結構真值、magnitude=TEST VALUE 校準非 crank；② machine-demonstrate bounded）。

---

## 靶1：herald catastrophe-hedge（`_try_herald_side` mini-util、最高 ROI razor-thin）

現況：`mini = severity × pmult × INFO_RELIEF_EXPECT(2.4) − INFO_ANON_COST(0.8)`。

**加 hedge 項**（genuine option-value）：
```
# catastrophe-hedge：near-catastrophe 時便宜可逆 ask 的 option-value。
# proximity = 現有 severity（deficit severity=趨近絕境/死的連續訊號）;
# hedge → 0 at low severity（非 flat always-ask offset=§2.5②bounded）;
# reversibility = 常數(求援保 faction+options、低成本可逆)。
var hedge_proximity: float = clampf((severity - HEDGE_ONSET) / (1.0 - HEDGE_ONSET), 0.0, 1.0)   # 低 severity→0
var hedge: float = hedge_proximity * HEDGE_CATASTROPHE_MAG * pmult   # ★人格 modulate(pmult 同 relief 項=驕傲仍可能不求、務實早求)
mini = severity * pmult * INFO_RELIEF_EXPECT - INFO_ANON_COST + hedge
```
- **HEDGE_ONSET**（TEST VALUE、~0.5-0.6）：hedge 起算 severity 門檻——低於此 near-catastrophe 未至→hedge=0（§2.5② bounded：低 severity→趨零、非 flat）。
- **HEDGE_CATASTROPHE_MAG**（TEST VALUE、校準到 razor-thin near-miss 翻）：災難量級（factionless→死避免的 option 值）。
- ★**genuine 論證**：near-catastrophe（severity 高→趨近 defect→factionless→死）時，便宜可逆 ask 的 option-value 真高（可能救命+低成本+保 faction）；遠離 catastrophe（severity 低）時 option-value≈0=hedge 趨零。**非 boost 逼 fire**（低 severity 不 ask、pmult 人格 modulate 保驕傲晚求）。

## 靶2：defect consequence-pricing（`event_faction_defect` defect_util、complementary）

現況：`defect_util = distress_pressure × loyalty_deficit − stay_benefit`。

**減 consequence 項**（genuine 後果真值）：
```
# 餓著叛=失勢力救濟管道=catastrophic(通往死)→壓 util;吃飽野心叛=後果非死→consequence≈0。
# ★§2.5③ 連續:走現有 starvation-state 連續訊號(food_days)、禁 if-starving branch。
var starve_frac: float = clampf(1.0 - food_days / DecisionTerms.DESPERATION_DAYS, 0.0, 1.0)   # 吃飽→0、餓→1 連續
var consequence: float = starve_frac * DEFECT_CONSEQUENCE_MAG   # 餓叛通往死的後果真值
defect_util = distress_pressure * loyalty_deficit - stay_benefit - consequence
```
- **starve_frac**：`food_days` 連續函式（吃飽 food_days≥DESPERATION→0、餓 food_days→0→1）=§2.5③ 連續、餓叛≠野心叛**從 food_days state 湧現**、無 if-branch。
- **DEFECT_CONSEQUENCE_MAG**（TEST VALUE）：失 faction-relief-access→死的後果量級。
- ★**anti-crank**：加真後果**非刪叛離**——絕望-abandoned 隊（stay_benefit=0 從沒被救）distress×loyalty 仍可壓過 consequence 照叛/逃（genuine 保留）;吃飽野心叛 starve_frac=0→consequence=0→defect_util 不變照 fire。
- ★需 `food_days` 進 event_faction_defect context（若無、加純讀 gather、感知鐵律=自隊自知 food）。

## §2.5 滿足（3 必查項）
- **②hedge bounded**：`hedge_proximity` clampf 低 severity→0（HEDGE_ONSET 以下=0）=非 flat always-ask。★build 附 machine-demonstrate：dump hedge 對 severity 曲線（低 severity≈0、高 severity 增）證 bounded 非 offset。
- **③連續**：hedge 走 `severity`、consequence 走 `food_days`=**現有連續 starvation 訊號的連續函式**、零 if-starving/if-not branch。
- **④順序=硬量測 gate**：build 後**必量測**「求援先於叛離」真 emergent（Team2 hedge 使 herald mini>0 於 defect fire 前）=非文字宣稱。

## 驗收（§3、fp intended）
- 靶1：可救餓隊**求援先於叛離 fire**（Team2 求救成功活過 defect）+ 人格分化（驕傲晚/務實早）。
- 靶2：餓叛 util 被壓、**餓叛率降**；野心叛（吃飽 starve_frac=0）util 不變照 fire=餓叛≠野心叛 state-emergent。
- ②hedge-vs-severity 曲線 bounded machine-demonstrate；③連續（無新 branch）；④順序 emergent 硬量測。
- F0 fp 預期分化 intended（記錄方向、與結構 byte-identical 分不混）；determinism 3-run；無 regression（recovery/cohesion/info-net arc）；constitution 綠（兩 repricing=util 項非新硬閘）。
- ★TEST VALUE（HEDGE_ONSET/HEDGE_CATASTROPHE_MAG/DEFECT_CONSEQUENCE_MAG）=measurer 校準（結構 genuine、magnitude 調到 razor-thin 翻+emergent 序、非 crank）。

## 序
dispatch build → handback systems R²（merge-gate 核 ②bounded machine-demonstrate + ③連續無 branch + genuine 非 crank + fp 分化 intended）→ measurer 量（④順序 emergent + 餓叛率降 + 人格分化 + 校準 TEST VALUE）→ QA specimen 故事（餓隊逐決策 求援先 fire→活過 defect）→ merge = iii 收 → re-measure scale（乾淨 base、relief-death 源頭斷）→ blueprint spec scale lever。地基 KEEP。
