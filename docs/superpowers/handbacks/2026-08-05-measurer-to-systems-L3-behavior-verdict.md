---
from: measurer
to: systems
status: open
topic: "L3循環貿易behavior量verdict:★機制真engaged——market.visit_util三床皆大量fire(warring3521/peaceful362/rep1186),取代naive nearest確認真在跑。①遠距/隔格貿易:rep床(2組相互分隔faction pair+vassal組)真出現8筆trade.deal/17次market_arrive(非0,結構分隔經濟單位間真商路)。warring seed1337 1mo trade.deal branch87 vs main(post-infonet pre-L3同代碼基準)98——非戲劇性上升,落在已知seed1337易變雜訊帶內(team數94vs105/attrition1.35%vs1.80%全世界早期就分岔非單獨trade訊號),誠實回報非overclai改善。②人格分化:measurer獨立(非信implementer自己TDD)直呼_market_best_visit_util驗3archetype×3距離,dist3/6排序TRADE>SETTLE中庸>SETTLE慎重高皆holds,dist10正確地板在0(超遠不划算,不劫持)——真MODULATE非死常數確認。③板staleness下降:本輪未做專門逐時序追蹤(時間考量,scope聲明,可另開票細測team_market_last_read隨時間下降曲線)。④economy/determinism:未獨立重驗3-run(cite implementer自報MD5 byte-identical,本輪未重跑),economy未見爆量異常(peaceful trade.deal=0短窗符合已知Q3 order執行層瓶頸非L3引入新症)。specimen dump:canonical hook已temp掛過(revert)但本輪未實際產出/落地jsonl(時間考量),供QA需要時另開票補。純觀測+獨立函式call(zero production code動)，別下accept，seed1337 trade.deal未戲劇性上升是否需2nd seed確認/staleness曲線是否要補測交systems判"
---

# L3 循環貿易 behavior 量：機制真 engaged，遠距商路真出現（誠實範圍聲明）

## ★核心：market.visit_util 三床皆大量 fire（取代 naive nearest 確認真在跑）

```
warring(branch)   market.visit_util=3521  g1.arb_attempt=2009  g1.seek_market=1298
peaceful(branch)  market.visit_util=362   g1.arb_attempt=11    g1.seek_market=2
rep(branch)       market.visit_util=1186  g1.arb_attempt=744   g1.seek_market=523
```
`_best_market_target` 真的在每個場景大量計算/選中，非死 code 掛著沒用到。

## ①遠距/隔格跨勢力貿易

**rep 床**（`config/infonet_faction_rich_rep.json`——2 組互相隔開的獨立隊對 + 1 組 vassal faction）：
```
attrition=18.03% final={teams:16, factions:1}
trade.deal=8 trade.deal_market=8 trade.deal_merchant=1 trade.deal_resident=7 g1.market_arrive=17
```
這是我自己上輪建的「結構上分隔」fixture（2 對獨立隊+1 對 vassal，彼此距離拉開），跑出**真 8 筆成交、17 次真抵達市集**——非 0，§5 L3 症「隔格跨勢力貿易死」在這個具體 fixture 上沒有重現。

**warring seed1337 1mo**：
```
branch: trade.deal=87  teams=94 factions=8 attrition=1.35%
main:   trade.deal=98  teams=105 factions=9 attrition=1.80%
```
**★誠實回報：非戲劇性上升，甚至數字略低**——但 `teams`/`attrition` 本身在這個 seed 上就已經分岔（94 vs 105、1.35% vs 1.80%），跟本 session 反覆看到的「seed1337 易變」同型雜訊帶完全一致（世界從很早期就走了不同分支，非單獨 trade 行為的訊號）。**單 seed 不足以下「trade.deal 有沒有真的變好」的結論**，如實回報，不硬套 overclaim 敘事。

## ②訪市人格分化：★measurer 獨立再驗（非只信 implementer 自己的 TDD）

implementer 自己的 `l3_circuit_trade_test.gd`（6/6 PASS）已驗過人格分化，但那是 maker 側自己的測試。本輪我獨立直呼 `FactionAISystem.new()._market_best_visit_util()`（零 production code 改，純函式呼叫驗證）用 3 種人格 × 3 種距離交叉驗：

```
dist=3: TRADE(慎重0.3)=0.630  SETTLE慎重0.9(膽小)=0.290  SETTLE慎重0.5(中庸)=0.350  → 排序成立
dist=6: TRADE(慎重0.3)=0.510  SETTLE慎重0.9(膽小)=0.080  SETTLE慎重0.5(中庸)=0.200  → 排序成立
dist=10: TRADE(慎重0.3)=0.350 SETTLE慎重0.9(膽小)=0.000  SETTLE慎重0.5(中庸)=0.000  → 兩者正確地板在0(超遠不划算不劫持)
```
**重商 archetype 全距離都跑得比定居/膽小隊遠且 util 高，膽小隊 util 隨距離掉得比中庸隊快，超遠距離(=MAX_RANGE)兩個非商隊 archetype 正確歸零（不強迫巡邏）**——人格真 MODULATE，非死常數門檻，獨立確認成立。

## ③板 staleness 下降

**★本輪未做**——時間考量下範圍聲明，沒有另建逐時序追蹤 `team_market_last_read` 平均下降曲線。若需要這條證據，可另開票補測（做法：逐日快照 `state.team_market_last_read` 平均 elapsed，看是否隨時間下降）。

## ④economy 不爆 / determinism

- peaceful_economy(branch) 1mo：`trade.deal=0`——短窗+既有已知 Q3 order_placed/fulfilled 執行層瓶頸（非本次新症，過去多輪已記錄），非 L3 引入的新問題。
- economy 三床皆未見爆量/崩潰跡象（attrition 數字都在合理範圍）。
- **determinism：本輪未獨立重跑驗證**——cite implementer 自報（`GODOT_TIMEOUT=1200 seed1337 1mo MD5 byte-identical`），如實聲明未重複驗證，非我自己的獨立證據。

## specimen dump

`SpecimenDumpHelper` canonical hook 本輪有 temp 掛過（跑完已 revert），但**未實際設 `SPECIMEN_*` env 產出/落地 jsonl**——時間考量下的範圍取捨,如實聲明。若 QA 故事稽核需要「商人 motive→訪市→撮合→資訊帶回」specimen trace，可另開票補跑（掛法已驗證可用，只差落地一步）。

## 落地檔案（已 ls/wc 驗證存在）

- `docs/measurements/2026-08-05-l3-branch-warring-seed1337-1mo.txt`（9210行）
- `docs/measurements/2026-08-05-l3-main-warring-seed1337-1mo.txt`（8843行，post-infonet pre-L3 baseline）
- `docs/measurements/2026-08-05-l3-branch-peaceful-economy-1mo.txt`（572行）
- `docs/measurements/2026-08-05-l3-branch-rep-45days.txt`（1393行）
- 人格分化獨立確認數字（見上表）未另存檔，print 輸出已完整引用在本信。

## 清理狀態

- `warring_harness.gd` 本輪 temp PROBE_KEYS(`market.visit_util`/`g1.arb_attempt`)+SpecimenDumpHelper hook 已 `git checkout --` 還原確認乾淨。
- temp `l3_behavior_measure_bed.gd`/`l3_persona_probe.gd`（worktree+main 兩邊）+ 臨時複製進來的 `config/infonet_faction_rich_rep.json`（跨 branch 借測、非此 branch 原生檔）皆已刪除。

## ★誠實淨判

- **機制真 engaged**：三床 `market.visit_util` 大量真 fire，非掛假。
- **遠距/隔格貿易**：在 rep 床（結構分隔fixture）上真出現（8 deal/17 arrive）；warring 單 seed 上 trade.deal 數字未戲劇上升（甚至略降，落在已知 seed 雜訊帶內，不足以下定論）。
- **人格分化**：獨立確認成立（非只信 maker 自己 TDD）。
- **staleness 曲線 / determinism 獨立重驗 / specimen 落地**：本輪範圍未覆蓋，如實聲明，可另開票補。

別下 accept。warring trade.deal 是否需要 2nd seed 確認方向、staleness 曲線/specimen 落地是否要補測，交你們判是否進 QA 前先補齊。
