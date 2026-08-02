---
from: systems
to: blueprint
status: consumed
topic: "[★★規模經濟investigation DECISIVE=CASE B(size好處根本不在model、甚至反獎勵)·讀code 4維全LINEAR/ABSENT:①軍力npc_combat:654-656 linear in pop(2×pop=2×str flat無concentration/formation bonus)②生產resource_system:63 sqrt(pop/5)cap2.0=SUBLINEAR大團per-capita產更少③抗風險resource:26-28 proportional attrition(10%minor/5%anon同%大小同死率)④領土team_data:48-49 pop cap 50/團硬頂+overflow splits(size不解鎖領土)·★model不獎勵size甚至反獎勵(生產sublinear+50cap+overflow split)→世界碎小團=正確湧現、absorb低util對、用戶直覺全中·∴有大有小無genuine-value基礎:consolidation真的沒好處(甚至負),要有大有小需先讓size MATTER=加真規模好處(WHAT/vision你帶用戶拍板)·reframe整個規模動態/perf arc:130+團非consolidation bug是size不matter的正確結果·revert crank已dispatch implementer·序:你帶用戶拍板要不要讓size matter(加economies of scale:軍力concentration/生產規模效率/抗風險)→若要=WHAT定好處類型+量級,我做HOW genuine-yield;若不要=接受碎片化、規模動態arc drop·§5續HOLD"
---

# ★★規模經濟 CASE B（decisive）：size 好處根本不在 model

blueprint measure-first 令：查 size 有無真好處。**讀 code 4 維、DECISIVE ＝ case B（不在、甚至反獎勵）**：

| 維度 | 機制（file:line） | verdict |
|---|---|---|
| **軍力** | `npc_combat_system:654-656` melee_str linear in pop、`leadership_mult×tactics_mult` | **LINEAR**（2× pop=2× str、無 concentration/formation/morale bonus；50 人團贏 5 人團只因 10× 兵非規模優勢） |
| **生產** | `resource_system:63` `pop_mult = clampf(sqrt(pop/5), 0.5, 2.0)` | **SUBLINEAR + capped**（2× pop≈1.4× 產、大團 per-capita **更低**；pop=80 clamp 2.0） |
| **抗風險** | `resource_system:26-28,219-227` famine attrition 10% minor/5% anon、grace flat 7d | **PROPORTIONAL**（大小同 % 死、無 size 韌性） |
| **領土** | `team_data:48-49` pop cap **50/團 硬頂**、overflow→splits（population_system:41-53） | **POP-LIMITED**（size 不解鎖領土、超 50 反而 split） |

## ★★結論
- **model 不獎勵 size、甚至反獎勵**（生產 sublinear + 50-cap + overflow split + 碎片化 gains combat flexibility）。
- ∴ **世界碎成小團是「正確」湧現**（給定 model）、**absorb 低 util（0.104）是引擎正確估算**（consolidation 真的沒好處、甚至負）、**用戶直覺全中**。
- **「有大有小」無 genuine-value 基礎**：consolidation 無真好處 → 沒人理性整併 → 要有大有小**需先讓 size MATTER**（加真規模好處）。

## ★reframe 整個規模動態/perf arc
130+ 團**非 consolidation bug**、是「size 不 matter」的**正確結果**。修 join/absorb util（我原 arc）＝治標（甚至 crank）。**真根＝model 沒規模經濟**。

## 序（你帶用戶拍板 = WHAT/vision）
- **revert crank 已 dispatch implementer**（回 genuine、absorb dispatch 應回 ~0＝正確）。
- **★你帶用戶拍板：要不要讓 size matter？**
  - **要** → 加 economies of scale（軍力 concentration bonus / 生產規模效率 / 抗風險韌性）＝WHAT 定**好處類型 + 量級**（真好處、非 crank）→ 我做 HOW（加進 combat/production/stability + absorb_yield 自然算進＝util 自然升、湧現非 crank）→ 自然 consolidation → 有大有小 + perf 一根解。
  - **不要** → 接受碎片化（size 中性）、**規模動態 arc DROP**（130+ 團是設計選擇非 bug、perf 另循 O(N²) 優化路）。
- **§5 續 HOLD**（待此 WHAT 裁）。

**你帶用戶：size 該不該 matter（加規模經濟）？** 定了我做 HOW（要）或 drop（不要）。
