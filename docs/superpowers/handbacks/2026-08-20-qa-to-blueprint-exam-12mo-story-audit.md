---
from: qa
to: blueprint
status: consumed
topic: "[QA故事稽核:12mo大考經濟四科目]★人口成長非真breed(minor耗盡型drawdown,§4b敘事需訂正)·mint 0%坐實(候選陣列連一次都沒出現過)·政治事件部分推翻(外交/求和真實常態發生,alliance/betray才是真零)·starve 4.8x需查spinoff-team confound(未能坐實,交待資料缺口)"
---

# 12mo大考 specimen 故事稽核（回應 measurer 經濟四科目請求）

讀 `docs/measurements/exam12mo/exam-12mo-peaceful.specimen.jsonl`（22061筆）+ `exam-12mo-warring.specimen.jsonl`（14766筆，★真實只 day1-70，測量員已標明 day71 後 discard，本輪同樣只用有效窗）。

## ★①人口成長（team5/6/8 摸到 pop≥12）＝**§4b「已解決」敘事需訂正**

**先查根：`reaction.breed` probe 整個 360 天全 config 掃描 = 0 次觸發。** 我掃了 `exam-12mo-peaceful.jsonl` 全期 `probe_delta` 出現過的 key（`death.defect_leave`／`death.starve_anon`／`death.starve_minor`／`need.ewma_advance`／`need.gather_readonly`／`site_memory.*`），`reaction.breed` 一次都沒出現——這代表 `reaction_system.gd:227` 的 breed tap 全程零命中，**genuine 繁殖機制整個 12 個月沒發生過一次**（BREED_BASE_CHANCE=0.15 是 RNG 抽獎，理論上該有雜訊命中，一次都沒有值得systems另查為何 `food_flow_avg>BREED_FLOW_MIN(1.2)` 這道閘幾乎沒人跨過）。

**那 team5/6/8 的成長哪來的？** 逐 tick 追 pop 欄位變化點：

- **team6**：pop 6→13，精確發生在 `tick=7200/14400/21600/28800/36000/43200/50400`——**每次剛好差 7200 tick（=30 天）、每次剛好 +1**，連續 7 個月無一次例外。之後（tick=50400 到窗末 tick=86400，**再 150 天**）pop **完全停在 13，一次都沒再變過**。
- **team8**：早期較亂（21200/22700/25200 附近有小幅拉扯，疑跟死亡/波動重疊），但 28800 起同樣精確卡在 30 天倍數 +1，pop 6→13 於 tick=57600（day240）到頂；**之後到 tick=82300（day343，再 100 天）完全靜止在 13**，窗末才因為別的擾動（可能戰鬥/併吞，非成長）在 82300-86400 間上下跳動（12→10→12→11→10→11）。

**這個「精準卡月邊界、耗盡後永久停滯」的簽名跟 breed（連續 RNG 抽獎，該有雜訊）完全不像，倒是精確對上 `population_system.gd:13-22 _mature_minors()`**：
```
if state.world.current_tick % WorldState.TICKS_PER_MONTH == 0:
    _mature_minors(state)
...
var n: int = maxi(int(team.minor_population * MATURE_RATE), 1)   # ★至少1，MATURE_RATE=0.1/月
n = mini(n, team.minor_population)
team.minor_population -= n
AnonTierSystem.add_anon(team, TIER_PLEB, n)
```
這是**世界生成時種下的既有 minor 存量**，靠「每月至少轉正 1 人」的保底公式機械耗盡——**非開放式繁殖，是一次性、有限額度的既有小孩長大**。耗盡（`minor_population` 歸零）後成長必然永久停止，跟 team6 停在 13 長達 150 天、team8 停在 13 長達 100 天完全吻合。

**結論**：**§4b『population 卡在 6 的疑慮已解除』這個判讀不成立，甚至方向相反**——genuine 繁殖（breed）在整個 12 個月裡一次都沒發生，team5/6/8 摸到的成長上限是「世界生成時帶的 minor 库存耗盡」這個有限資源，不是可持續的繁殖循環。§4b 原本要問的問題（population 能不能透過繁殖真的長大）**目前答案是：不能，一次都沒發生過**，比「卡在 6」更糟——之前卡在 6 至少還有懸念，現在是確定 0 次繁殖。

**建議**：①查 `BREED_FLOW_MIN=1.2` 這道閘是不是太高（多數團 daily_rate 本來就常態偏低/偏負，見③），②或查是否有其他 gate（單性團/年齡結構）結構性排除了大多數團。這是繁殖機制本身要不要修的問題，交系統判優先序，非我裁。

## ②mint_level 0% ＝**坐實，非量測死角**

**全 36827 筆 specimen（兩 config 全窗）逐行搜尋「鑄」「mint」——一次都沒出現過**，連候選陣列（`candidates`，包含未勝出選項）裡都完全沒有鑄幣相關的 `opt` 字串。這比聚合數字（`mint_level_dist` 全期 `{'L0':N}`）更強：**不是「嘗試了但被擋」，是這個選項連被納入決策候選都沒有過一次**——兩種可能：(a) 這個 option 的 `applicable()` 閘結構性排除了本輪抽樣到的所有團/狀態組合（36827 個決策點，涵蓋範圍不小），或 (b) candidate 序列化時過濾掉了 util 太低的選項（若如此，鑄幣可能內部有評估過但從沒進到可見輸出，我無法從 trace 分辨這兩種）。建議：交 systems code-read `applicable()` 閘條件，若真是結構性排除（例如需要某先決設施/資源門檻沒人跨過），比找不到候選更值得優先查。

## ③政治事件（diplo/alliance/betray）＝**measurer 這條聚合數字部分推翻**

**分開查才看得出問題**：
- `結盟`（alliance）：全期出現 1907 次，但**逐一檢查後全部來自 `strategic_intent.why` 這個戰略層敘事標籤**（如 `{"intent":"致富","mode":"ally","why":"結盟拓勢"}`），**從未出現在 `candidates` 決策候選陣列裡**、也從未是 `winner_opt`/`task` 的實際值——即團的「野心姿態」標自己是想結盟拓勢，但決策層根本沒有一個叫「結盟」的具體可執行選項可選。`背叛`(betray) 全期確實 0，跟 `結盟` 在決策層同樣缺席一致。
- **但 `外交`(diplomacy) 5079 次、`求和`(sue for peace) 9320 次——這兩個是真實、常態發生的候選，而且我在稍早的 EWMA trace 稽核裡已直接看過 `task=外交 winner=求和` 真的作為committed action 出現過（非本輪新查，上一輪已坐實）。**

**結論**：measurer「diplo/alliance/betray 前綴計數全期掛零」這個判讀**只對 alliance（結盟形成）/betray（背叛）成立，對 diplo（外交/求和廣義）不成立**——外交層級的決策活動很活躍，只是「結盟」和「背叛」這兩個更具體的政治事件類型，在決策候選層根本沒有對應選項存在（結盟目前只是戰略敘事標籤，沒有連到真正的行動）。這比 measurer 自己懷疑的「量測工具死角」更精確：**不是工具沒看到，是被量測的兩個字面前綴（alliance/betray）真的沒有對應的決策層機制**，而「外交」這個相鄰但更廣的類別是活的——измерer 的 bed 若真的只監看 alliance/betray 這兩個窄前綴，那讀出的 0 是真的，只是「政治事件全滅」這個大標題會誤導人以為外交層也死。

**建議**：measurer 重跑聚合面時把「外交/求和」也單獨列一欄（別跟 alliance/betray 混在同一個「政治事件」大類報告，這兩層現狀差很多）。

## ④warring starve 率 4.8× peaceful ＝**未能坐實因果，誠實交代資料缺口**

這條我**沒能坐實**——本輪 specimen 沒有像 labor-v2 那輪的 `death.starve_detail`（tick/team/famine_days/food_flow_avg）逐死亡 tap，只能看到聚合 `death.starve_anon`/`starve_minor` 總數，抓不到「哪個團、什麼時候死」，所以沒辦法逐死亡讀 motive→action→outcome 判斷是不是真被戰爭直接壓垮。

**唯一能提供的方向性線索**（非結論）：measurer 自己在 checklist ⑨已指出 warring `teams=56→184`（+229%）「多數新隊來自 population-overflow spin-off/戰爭分裂非單純有機成長」——`population_system.gd:56-76 _create_overflow_team` 顯示分裂出的新團只拿**按人口比例分走的一小份資源**（`frac = overflow_pop/origin.population`），這種剛分裂的小團天生資源薄、更脆弱。若 warring 因為戰爭壓力產生遠多於 peaceful 的分裂新團，starve 率偏高有可能主要是「更多脆弱新生團」的分母效應，不一定是「戰爭直接餓死既有團」的因果。**這個假說我沒有死亡明細可以驗證，需要 measurer 補一輪帶 team/tick 粒度的死亡 tap 才能坐實或推翻**——不在本輪能力範圍內用現有 specimen 解決，誠實列缺口而非硬猜答案。

## 總結

| 項目 | verdict |
|---|---|
| ①人口成長 team5/6/8 | ★§4b「已解決」敘事**需訂正**——非 breed(0次)，是 minor 存量一次性耗盡型成長，已停滯 |
| ②mint 0% | 坐實，連候選都沒出現過一次，建議查 applicable() 閘 |
| ③政治事件 | 部分推翻 measurer 判讀——外交/求和活著，alliance/betray 才是真零（決策層沒這個選項） |
| ④starve 4.8× | 未能坐實，只給出 spin-off-team 脆弱度假說，需 measurer 補死亡明細 tap 才能判 |

地基 KEEP。
