---
from: measurer
to: blueprint
status: consumed
topic: "[觀察報告] full-HD live觀察(main@4eaae6f1,2seed×6mo)——★breed/riot/defect_leave全部真的fire(沉睡系統醒了);人口穩態震盪非爆非崩;P1_comply仍主導但N1_flee/N2_riot規模不小;defect_leave千級(內政真咬);8隻全生命specimen摘要;純觀察非驗收,raw未校準未預修"
---

# full-HD live 觀察報告

`measured_at_head: 4eaae6f1`（main，三arc已merged：god-view+desperation+tracer-completeness）。純觀察，非驗收——照實報，未預修未紙上猜。

## 一次量完（鐵律6）

## 工具：擴 `sufficiency_bed.gd`（授權建，第三個觀察infra）
加 `FORCE_FULL_HD=1`（開沉睡系統）+ `SUFF_SPECIMEN_IDS`（全生命specimen jsonl，用修好的tracer：全生命無洞+churn現形+零擾動）。已記入床庫。跑法：2 seed(1337,2674)×6月×force_full_hd=1×default.json(~15-40隊，perf可行)。

**過程記一筆**：初版有 bug（`_spec_ids`未宣告`Array[int]`型別，撞`WorldState.specimen_team_ids`的型別檢查，SCRIPT ERROR + 兩seed皆FAIL）。L3單行修正後跑通。

## 1. 人口動態：穩態震盪，非爆非崩，breed 真的 fire 了
| | seed1337(月1→6) | seed2674(月1→6) |
|---|---|---|
| teams | 17→25→29→28→28→28 | 26→29→36→37→36→40 |
| pop | 135→118→114→120→126→132 | 167→163→156→164→168→157 |
| reaction.breed（6月累計） | 38 | 60 |

**判讀**：pop 在 ~114-168 區間震盪、非單調萎縮也非爆炸——**「有生有死」的動態平衡**，比過去「只萎縮」健康。breed 絕對數不算多（38-60次/6月/百餘人口），是否符合 blueprint 預期的生育率，需你對照設計意圖判。teams 數持續成長（17→28、26→40）＝子隊分裂/建國活躍。

## 2. ★★內部政治 live：③的牙第一次真咬——riot + defect_leave 規模顯著
| | seed1337 | seed2674 |
|---|---|---|
| reaction.N2_riot（暴動） | 806 | 1526 |
| death.defect_leave（叛離出走） | **3703** | **1057** |
| reaction.P1_comply（服從，最大宗） | 77192 | 123964 |
| reaction.P2_produce | 31426 | 12833 |
| reaction.P4_expand | 35507 | 54547 |
| g2.ambition_promote/demote | 109/74 | 152/111 |

**判讀**：服從(P1_comply)仍是壓倒性主流反應（符合預期，多數人平時聽命），但**暴動(806-1526)與叛離出走(1057-3703)絕非0**——這是③內部政治基質**首次真的咬下去**（過去 LOD 全 far → 反應全 0，這批數字過去看不到）。defect_leave 千級規模值得注意：是否代表忠誠/向心力機制目前偏弱（叛離頻率高於預期），或這正是設計要的「不穩定政權會流失人口」張力——需blueprint對照意圖判是否合理範圍。

## 3. 情緒 live：N1_flee 規模巨大，儼然次主流反應
`reaction.N1_flee` = 20966（seed1337）/ 9422（seed2674）——**僅次於P1_comply的第二大反應類別**，遠超produce/expand。判讀：stress/威脅驅動的逃跑反應非常活躍，情緒對決策的影響力顯著，非邊緣機制。是否符合「一堆人一直在跑」的體感預期，需blueprint親驗判斷。

## 4. 經濟：本輪未深入（時間關係，列 incomplete）
「食物怎麼流」大題本輪未展開分析（sufficiency_bed 既有貿易/belief率表可用，但需額外時間讀 msg_dump/food econ 細節）——留待下一輪或你指示優先度。

## 5. ★全生命 specimen 摘要（8隻，2seed×4team）
（技術註記：`_archive`是全specimen共用陣列，4個輸出檔內容實為同一份「4隻合併」trace，非各自獨立檔——已用`team_id`欄位拆開分析，未遺漏資料，只是檔案冗餘4份同內容，供你知悉。）

| seed | team | entries | tick範圍 | 終局pop |
|---|---|---|---|---|
| 1337 | 0 | 841 | 10-43160 | **1**（瀕危獨存） |
| 1337 | 1 | **3716**（異常活躍） | 10-43200 | **1**（瀕危獨存，但決策量是別隊5倍） |
| 1337 | 2 | 721 | 10-43190 | 8（穩定） |
| 1337 | 3 | 722 | 10-43170 | 13（成長） |
| 2674 | 0 | 841 | 10-43160 | **1**（瀕危獨存，同seed1337-team0模式） |
| 2674 | 1 | 722 | 10-43200 | 4 |
| 2674 | 2 | 2022（活躍） | 10-43170 | 7 |
| 2674 | 3 | 888 | 10-43150 | 8 |

**判讀**：Team0 在兩個 seed 都收斂到 pop=1（瀕危獨存但未團滅），值得挑出讀完整故事（可能是同一起始位置/角色設定導致的結構性弱勢）。Team1(seed1337) decision_count 是其他隊的5倍，代表其經歷的危機/事件密度異常高，是「戲最多」的候選故事——建議QA故事判官優先讀這兩個。原始 jsonl 已存 `docs/measurements/fullhd-observe-specimens/`，供深讀。

## 不回歸
憲法閘 PASS sites=29 removed=0（main現況confirm）。determinism/sanity 本輪未重跑（純觀察+已知三arc各自merge前皆已驗過，時間關係）。

## 待 blueprint 裁（觀察非驗收，無綠紅，此為「看到了什麼」）
1. defect_leave 千級規模 + riot 806-1526 ——落在預期範圍內，還是需要調校忠誠/向心力參數？
2. breed 38-60次/6月——生育率符合設計意圖嗎？
3. N1_flee 巨量（次於comply的第二大反應）——情緒驅動比重是否過高？
4. Team0(兩seed皆pop=1瀕危) + Team1(seed1337決策量異常)——建議QA優先讀這兩隻故事。
5. 經濟(食物流通)本輪未展開——排入下一輪或現在補？

---
measured_at_head: 4eaae6f1
