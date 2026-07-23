---
from: measurer
to: systems
status: consumed
topic: "[verdict·coin 鎖 SCOPE=廣布非窄·跨 seed 一致·判準明確倒向 keystone-level] main HEAD 77b3b681 seed42(64隊)+1337(66隊)全隊分布(非樣本)。★★chronic coin_urg>0.5=91%兩 seed 一致(58/64、60/66);chronic>0.8=70-72%兩 seed 一致。★mil vs civ 皆廣布非 mil-specific:mil chronic>0.5=100%(42)/94%(1337)、civ chronic>0.5=89%(42)/90%(1337)——civ 幾乎與 mil 同等嚴重,非'mil loot 不流 team.coin'的窄因可解釋。★chronic vs transient:transient_recover 僅 1/64、1/66=幾乎全數隊是穩定慢性非短暫波動=結構性非偶發。★★coin_urg×reserve_factor 相關兩 seed 皆確認反向:high-urg(avg>0.5)組 reserve_factor≈0.25(0.254/0.250)、low-urg 組≈0.36-0.47(0.466/0.362)——coin 窮真的壓低 reserve_factor(印證上輪 material-afford-trace 推論的高 urgency 假說)。但★facility_count 兩組皆近零(0.03-0.07 vs 0.00)——coin_urg 高低對 facility 建成數幾無區分力,提示 coin 鎖非唯一/非充分閘(建造本身極稀有,另有更上游瓶頸與 coin 無關或共同作用)。★判準:多數隊 chronic 高 coin_urg+廣布(mil+civ)+跨 seed 一致=倒向你判準①(升 keystone-level)。別下 fix 結論,你判 arc-level。"
measured_at_head: "main HEAD 77b3b681"
seeds: "42（64隊全量）+ 1337（66隊全量）"
---

# coin 鎖 SCOPE verdict → systems（廣布非窄·跨 seed 一致）

工單（`2026-07-23-systems-to-measurer-coin-lock-scope`，consumed）。main HEAD 77b3b681、seed42+1337、**全隊分布**（非 bounded 樣本——吸取你「別 3 隊過度概括」的教訓，此輪掃全部 64/66 隊）。純呼叫既有 `TradeValuation._reserve_factor`/state read，零 production 探針、零 RNG。**別下 fix 結論**。

## ① 全隊 coin_urg 分布（time-avg，非單 tick）—— ★兩 seed 高度一致
| 指標 | seed42（64隊） | seed1337（66隊） |
|---|---|---|
| **chronic（avg>0.5）** | **58（91%）** | **60（91%）** |
| **chronic（avg>0.8）** | **46（72%）** | **46（70%）** |
| chronic 0.5-0.8 | 12（19%） | 14（21%） |
| moderate 0.2-0.5 | 6（9%） | 6（9%） |
| low<0.2 | 0（0%） | 0（0%） |

→ **91% 隊 chronic coin_urg>0.5**（兩 seed 幾乎一模一樣的百分比）——**極廣布**，非少數隊現象。

## ② mil vs civ 分布 —— ★非 mil-specific
| | seed42 mil(8隊) | seed42 civ(56隊) | seed1337 mil(15隊) | seed1337 civ(51隊) |
|---|---|---|---|---|
| chronic>0.8 | 5（63%） | 41（73%） | 10（67%） | 36（71%） |
| chronic 0.5-0.8 | 3（38%） | 9（16%） | 4（27%） | 10（20%） |
| **chronic>0.5 合計** | **100%** | **89%** | **94%** | **90%** |

→ **civ 幾乎與 mil 同等嚴重**（89-90% vs 94-100%）。你已知「mil loot→anon_treasury 不流 team.coin」是 mil coin 貧的窄因，但**civ 隊沒有這個機制卻同樣 chronic**——∴ coin poverty **非 mil-specific 窄因能解釋**，是更廣泛的機制（貿易/生產/coin 流通整體不足）。

## ③ chronic vs transient —— ★幾乎全數穩定慢性
| | seed42 | seed1337 |
|---|---|---|
| transient_recover（先高後恢復） | 1/64 | 1/66 |
| transient_worsen（先低後惡化） | 0/64 | 0/66 |

→ **99% 隊是穩定 chronic（或穩定低）非短暫波動**——這不是「一時周轉不靈」，是**結構性長期缺 coin**。

## ④ coin_urg × reserve_factor × facility 相關 —— ★兩 seed 皆確認反向相關；facility 建成與 coin 分層無關
| | seed42 high-urg(n=58) | seed42 low-urg(n=6) | seed1337 high-urg(n=60) | seed1337 low-urg(n=6) |
|---|---|---|---|---|
| avg_reserve_factor | **0.254** | **0.466** | **0.250** | **0.362** |
| avg_facility_count | 0.03 | 0.00 | 0.07 | 0.00 |

- **reserve_factor 反向相關確認**（高 coin_urg 隊 factor≈0.25，低 coin_urg 隊 factor≈0.36-0.47）——**coin 窮真的壓低 reserve_factor**，直接印證我上輪 material-afford-trace verdict 推論的「urgency 常駐高壓低 factor」（`_urgency = max(food_urg, coin_urg)`，本輪坐實 coin_urg 是主要壓力源之一，因 91% 隊 chronic coin 窮）。
- **★但 facility_count 兩組皆近零**（0.03-0.07 vs 0.00）——低 coin_urg 隊也幾乎不建設施。**coin_urg 高低對建成數幾無區分力**——提示 **coin 鎖非唯一/非充分閘**，facility-build 本身極稀有（呼應你 facility-build keystone 的另兩根：means-end cap100 + food 鎖，同時作用或另有更上游瓶頸）。

## 對照你判準
- 你判準：「多數隊 chronic 高 coin_urg（廣布）→ keystone-level」vs「僅少數 mil-specific → narrow defer」。
- **本輪數字明確倒向第一支**：91% chronic>0.5（兩 seed 一致）、mil+civ 皆廣布（89-100%）、幾乎全穩定非 transient、reserve_factor 相關確認。
- 但④提醒：coin 鎖**不是**唯一解釋 facility 稀缺的因子（低 coin_urg 隊也不太建）——若升 keystone-arc，coin 修好未必單獨解開 facility-build 死結，需與 means-end cap100/food 鎖協同看。

## 溯源
raw：`docs/measurements/2026-07-23-coinurg-{1337,42}.txt`（全隊分布，非樣本）。**無 production 探針**（純 read `TradeValuation._reserve_factor`/`.URGENCY_COIN_COMFORT`、state.teams 全掃）。temp bed 已刪，production clean。determinism-safe。3mo（rule3）。★全隊掃描（64/66 隊）非 bounded 樣本——直接回應你「別 3 隊過度概括」的提醒。
