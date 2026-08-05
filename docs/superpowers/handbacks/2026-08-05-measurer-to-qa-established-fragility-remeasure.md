---
from: measurer
to: qa
status: open
topic: "established-fragility①②③ re-measure specimen→QA故事稽核(2964 entries):床=config-assigned established factions(好領主relief史 vs 壞領主暴君,各1 lord+1 fed member+1 distress member),seed6066 30天,g3 extension(03f03ce4)+uprising faction_id gate(00a40775)已landed。②genuine-exit-preserved確認(distress member真退出)③下游不秒崩確認(established全程=2,lord+fed留到day30)。①分化INCONCLUSIVE(好/壞兩側distress member同day0退出,defect_fire兩faction對稱6:5,無顯著存活差)。g3.betrayal=0本輪未fire,(a)bond-counter驗測不到。誠實標g3=通用修非rep床藥。請讀specimen trace判①INCONCLUSIVE的故事是否符合(是否真是relief來不及建立,還是別的)。verdict ref供systems鎖spec用。"
---

# established-fragility①②③ re-measure — specimen → QA 故事稽核

## 床規格

- config `.worktrees/faction-cohesion/config/infonet_established_fragility.json`（已 persist commit `f0a78d51`）
- bed `scripts/debug/infonet_established_fragility_bed.gd`（同 commit）
- seed=6066，30 天，`.worktrees/faction-cohesion` HEAD=`00a40775`（含 g3 extension `03f03ce4` + uprising faction_id gate `00a40775` 已 landed；ledger subteam 記帳缺口另案 `known_issues` 追蹤，與此床出口動態機制無關非 blocker）
- 2 faction pair：T0(GoodLord,relief 人格)+T1(GoodMember_Fed)+T2(GoodMember_Distress,food=15 mountain) / T3(BadLord,暴君人格)+T4(BadMember_Fed)+T5(BadMember_Distress,同 distress 設定)
- `is_established=true` 由 bed script setup 後直接標記兩 faction（config 無此欄位，founding pipeline P3 已知斷根，模擬「世界開局就有勢力」正當初始條件，非繞過機制——defect/uprising/g3.betrayal/defection-eval 全部原樣 live、非 force-stable）

## 原始輸出（已 ls/wc 驗證落地）

- `docs/measurements/2026-08-05-established-fragility-remeasure-30d.txt`（14961 行，完整跑 log）
- `docs/measurements/2026-08-05-infonet-established-fragility-remeasure.json`（1620 行，聚合 dump）
- **`docs/measurements/2026-08-05-infonet-established-fragility-remeasure.specimen.jsonl`（2964 行，SpecimenDumpHelper 全量 trace，T0-T5 六隊逐事件，含死隊/退出隊）**

## 聚合數字

```
final: teams=21 factions=2 established=2
T0(GoodLord):            exit_day=-1 alive_at_end=true day30: faction=0(remapped) unrest=0 pop=7  food=6805.3
T1(GoodMember_Fed):      exit_day=-1 alive_at_end=true day30: faction=0            unrest=0 pop=10 food=3360.9
T2(GoodMember_Distress): exit_day=0  alive_at_end=true day30: faction=-1(已退)     unrest=792 pop=2 food=0
T3(BadLord):              exit_day=-1 alive_at_end=true day30: faction=1(remapped) unrest=0 pop=8  food=6772
T4(BadMember_Fed):        exit_day=-1 alive_at_end=true day30: faction=1           unrest=0 pop=10 food=3606.7
T5(BadMember_Distress):   exit_day=0  alive_at_end=true day30: faction=-1(已退)     unrest=792 pop=2 food=0

★出口機制：g3.betrayal=0  cohesion.defect_fire=11  cohesion.uprising_stay_faction=0
```

（★config 的 `faction_id:1`(好)/`faction_id:2`(壞) 被 GameSetup 重映射成 0-indexed：好→`0`、壞→`1`，per-team `last_daily.faction` 欄位是重映射後的值，非 config 原值——已用重映射值核對，非 bug 只是 print 標籤易混淆，供你讀 specimen 時對照。）

`docs/measurements/...remeasure-30d.txt:50-51`（初始 T2/T5 day0 退出）+ 全 11 次退出事件（`grep 脫離勢力`）：`Team2/Team5(day0)`、`Team16(好側,day~13)`、`Team6/Team7/Team22(day~23)`、`Team24(壞側,day~24)`、`Team18(好側,day~29)`、`Team19(好側)`、`Team13(壞側)`、`Team11(好側)`——好側 6 次 vs 壞側 5 次，數量對稱無明顯差。

## 誠實淨判（未經你故事稽核前，僅供參考不鎖）

- **②genuine-exit-preserved：初步確認**——T2/T5 distress member 皆真退出（defect 驅動，非卡死不退）。
- **③下游解鎖：初步確認**——established 全程=2 未崩，T0/T1/T3/T4（lord+fed member）全存活到 day30，faction member 數甚至因新生團加入而成長（3→6）,非秒崩。
- **①差異化：INCONCLUSIVE**——好/壞兩側 distress member 同 day0 退出（幾乎同步，relief 尚未有時間累積 stay_benefit 就已觸發 defect），11 次退出事件在好/壞兩側數量對稱(6:5)，聚合數字看不出好領主勢力比暴君持久。**可能原因（未坐實，請故事稽核判斷）**：(a) 我這輪 distress fixture（food=15 山地）太極端，餓死螺旋比任何社交機制反應更快——這可能是**真實模型行為**（餓到那程度社交羈絆來不及救）非 bug；(b) 需要更長窗或較不極端的 distress 起始值，才給好領主 relief 機制累積 stay_benefit 的視窗。**別讓我這句猜測定調——請讀 specimen trace 判斷 T2/T5 退出當下的 motive→action→outcome 到底是哪種故事。**
- **(a)g3 bond counter 驗：測不到**——本輪 g3.betrayal=0 未 fire，忠的/被救的 vs 無情+利大+無恩義的行為差異這輪看不出。若要驗，需另建 betrayal-fires 專床（P4 fixture 那種矛盾利益結構）或延長窗口等 diplomatic_ai 評估累積到門檻。

## 下游

- **QA**：讀 specimen trace 判①INCONCLUSIVE 的故事是否符合我的猜測、或有別的解讀，出 verdict ref。
- 同時回 `to:systems`（另封）：報同組數字 + 明確標「①差異化因果結論待你 QA verdict ref 後才可鎖 spec」（`QA:<ref>` 通行證，`01_architect §spec 鎖在長跑因果`）。

## 清理

- fixture 已 persist commit `f0a78d51`（`.worktrees/faction-cohesion`），非 temp、留供未來 re-measure 複用。
- bed script 本身無 production code 改動（`SpecimenDumpHelper` hook 2 行 = 既有工具既有慣例接法，非新機制）。
