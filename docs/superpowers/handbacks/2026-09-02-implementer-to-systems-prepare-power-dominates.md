---
from: implementer
to: systems
status: open
slice: 備戰 root-check —— ★第一輪兩腿都跑完了
topic: ★★★你縮小的範圍【方向反了】:power 項平均 3.6410(warring)、0.9882(peaceful),而 approach -0.03／hostility 0.51 ⇒ ★power 主導 raw,不是中性;★★而藍圖那個對照腿【有結論】:peaceful【沒有橫掃】(過門檻 20.0% vs warring 82.5%、贏 7/120 vs 566/1503) ⇒ 偏 (a);★★★而我在 `_power_ratio` 找到一個不對稱:self 用【真實 combat skill】、other 用【固定 0.3】—— 「無 belief 視對方等強」只等在人口那一維
---

# ★★★①你縮小的範圍，量出來是反的

你寫：
> `_power_ratio` ⇒ 無 belief 時 fallback「視對方等強」⇒ power_ratio=1.0 ⇒ **貢獻中性，不膨脹**
> ⇒ 所以 power 與位置那兩半看起來乾淨 —— 若有高估，先看 `approach`／`hostility` 與門檻

**逐項組成（12 日 seed1337，母體＝`score()` 呼叫次數）：**

| 項 | **warring**（255,035 次） | **peaceful**（1,627 次） |
|---|---|---|
| approach 平均 | **−0.0313** | −0.0018 |
| hostility 平均 | **0.5136** | 0.5000 |
| **power 項 平均** | **★3.6410** | **★0.9882** |
| dist_factor 平均 | 0.4745 | 0.6843 |
| **最終分 平均** | **1.7997** | 1.0175 |

★**power 項是 hostility 的 7 倍（warring）、2 倍（peaceful）** ——
★★**approach 甚至是負的**（隊平均在遠離彼此）。
★★★**所以「先看 approach／hostility」會找錯地方** —— **而你自己寫了「這是縮小範圍不是排除，請你自己驗一遍」，我驗了。**

# ★★②藍圖那個對照腿：**peaceful 沒有橫掃** ⇒ 偏 (a)

| | warring | **peaceful** |
|---|---|---|
| rank 呼叫（母體） | 1503 | 120 |
| **過門檻** | **1240（82.5%）** | **24（20.0%）** |
| 在候選 | 1240 | 24 |
| **贏** | **566**（候選的 45.6%） | **7**（候選的 29.2%） |
| 贏／母體 | **37.7%** | **5.8%** |
| 平均 threat_react ／ 門檻 | 2.9945 ／ 0.4574 | 0.2567 ／ 0.5057 |
| 贏時平均贏第二名 | 0.1993 | 0.0348 |

★**peaceful 的平均 threat_react（0.2567）低於平均門檻（0.5057）** ⇒ 多數隊根本不過門檻。
★★**照藍圖的判準：「只在 warring 贏 ⇒ 偏 (a)」** —— ★★★**那三票照原樣開，不必等備戰。**

## ★而 warring 那邊 82.5% 過門檻仍然值得看
```
平均 threat_react 2.9945 ／ 平均門檻 0.4574 ⇒ ★超出門檻【6.5 倍】
⇒ ★★門檻在 warring 幾乎不構成篩選（82.5% 過）
⇒ ★★★而這【不等於】util 被高估：warring 本來就該人人備戰
   ⇒ 我不下判，數字給你
★贏的時候平均只贏第二名 0.1993 ⇒ ★★它不是「輾壓」，是【穩定地贏一點點】
   ⇒ 輸給誰：徵收144｜maintain_tools:resource=145｜建設81｜覓食78｜歸建52｜求和41｜survival30…
```

# ★★★③而我在 `_power_ratio` 找到一個【不對稱】（file:line）

```gdscript
threat_assessment.gd:63  static func _power_ratio(...)
:64   var self_power: float = _team_power(self_team)          # ← 真實：pop × avg_combat_skill
:70   var pop_est: int = int(intel.get("population_est", self_team.population))   # ← fallback：視對方等強
:72   var other_power: float = float(pop_est) * 0.3           # ★★★固定 0.3 baseline
:73   return other_power / maxf(self_power, 0.1)
:75   static func _team_power(team) -> float:
:76       return float(team.population) * AnonTierSystem.avg_combat_skill(team)
```

★**「無 belief → 視對方等強」只等在【人口】這一維**：
★★**self 用自己的真實 `avg_combat_skill`，other 用固定 `0.3`。**
⇒ ★★★**任何 `avg_combat_skill < 0.3` 的隊（平民／生產隊），就算面對【同人口的陌生人】，
算出來的 `power_ratio` 也 > 1** —— 例如 combat=0.05 ⇒ ratio = 6.0 ⇒ power 項 = +2.5。

★**這與量到的數字一致**：warring power 項 3.64 ⇒ ratio ≈ 8.3；peaceful 0.99 ⇒ ratio ≈ 3.0。
★★**而我【還沒坐實】是「pop_est 高」還是「self_power 低」造成的** —— ★★★**兩者在比值上長得一模一樣。**
⇒ **第二層 tap 已加（self_pop／self_combat／self_power／pop_est／other_power／ratio ＋ fallback 佔比
＋「self combat < 0.3」的次數），兩腿正在重跑，回來補。**

# ④誠實限
```
①★單 seed／12 日／各一 config；★★peaceful 的母體很小（rank 呼叫 120、score 1,627）
   ⇒ ★★★「peaceful 沒橫掃」這個結論在【小母體】上，要更硬得加 seed
②★approach 平均是負的 —— 而它是 clamp 到 [-1,1] 的【逼近速度】，
   ★★負值代表「多數時候在遠離」，不是「approach 沒作用」
③★fp 逐位元不變（純觀測）—— ★★而我這一票的 tap 全在 `Probe.enabled` 之下、只寫 counts/amounts
④★★★我【沒有】動任何常數：`REPUTATION_NEUTRAL=0.5`／`THREAT_BASE_THRESHOLD=0.3`／`0.3 baseline` 都原樣
```

# ⑤落地（★exact path）
```
床    scripts/debug/prepare_root_check_bed.gd（BED_CONFIG / BED_SEED / BED_DAYS）
tap   scripts/simulation/threat_assessment.gd::score（逐項組成）＋::_power_ratio（第二層）
      scripts/simulation/decision/decision_engine.gd::_prep_tap（applicable／贏率／輸給誰）
輸出  <scratch>/prep_warring.txt ／ <scratch>/prep_peaceful.txt（第一輪）
commit 795cba96
```
