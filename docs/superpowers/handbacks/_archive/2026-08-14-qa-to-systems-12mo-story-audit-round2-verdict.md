---
from: qa
to: systems
status: consumed
topic: "[12mo期末考QA verdict]故事講得通(有硬機制解釋非隨機崩壞)但仍嚴重不健康。4WHY:①resident飢餓非全體均一是雙峰分佈——T12(faction3領主)day34就崩到pop1後325天永困0-2天糧量卡『覓食/return_home』無限循環vs T42同為resident卻pop8-12+食物500-700天撐~350天,差異=T12早期被碎裂拖到勞力池只剩1人夠不上farming產出門檻落入永久貧窮陷阱,T42躲過早期碎裂就真的繁榮,daily_curve resident_food_days_avg(2.5-5.7天)低是被大量T12型隊拖累的平均非全員如此②day301本身無異狀(pool_curve/daily_curve在301前後平滑),真正斷崖在day306-307(teams61→55)加速到312(→35),且resident_n同步崩(47→19)nonresident_n全程死板16不動——這是漫長knife-edge(resident平均只2-3天糧量撐了幾十天)終於多隊同時觸底非單一觸發事件③CONFIRM founding主導:worldgen.build_outpost全年272次(月1-3集中,月5後=0)vs convert_via_settle全年僅2次,~136:1,直接讀aggregate硬數字④factions8→2讀cohesion.defect_fire月1-4=5/65/11/3(共84次,跟月1-4完全同期)+combat死全年=0=沒有戰爭吞併的痕跡,判斷是defect驅動的解體(各自獨立化)非征服合併,無直接merge事件證據反證。六symptom對照:famine持續且量化更細(雙峰非均質)、no-founding(established全年0)持續、碎裂本回合看到完整弧非只上升段(月2峰170→月12剩28,真相是先炸後陣亡非單純爆炸)、零戰死持續、no-merge本回合未直接覆核(defect≠昨天查的dispatch未歸隊,是不同機制,建議下輪分開查)、no-recovery更確立(invest.dispatched全年12個月連續=0,一次都沒有,比第一輪更嚴重)。總評:世界故事講得通但故事本身講的是『多數團活不下去』,核心真根=labor-pool-based生產模型撞上大規模碎裂(defect)產生大量小到無法自足的殘存團,這條因果鏈今天首次完整串起來,建議下一步查defect_fire觸發條件是否過鬆(unrest閾值/distress公式)。"
---

# ★QA story-audit 二輪（12mo 期末考）verdict

讀完 12mo specimen（8隊全程）+ aggregate（`daily_curve`/`pool_curve`/`curve` 逐月 delta），這輪比第一輪多了完整的月度/日度聚合資料，能把因果鏈串得更完整。**結論先講：世界的故事講得通——不是隨機亂跳的崩壞，背後有一條可以追出來的機制鏈——但這條故事線本身講的是「大多數團活不下去」，世界整體是不健康的。**

## 12個月完整故事線

**月1-2（炸裂期）**：世界從 49隊/pop444 暴增到 170隊（月2峰值）、pop 崩到278。這段是雙重動力疊加：`worldgen.build_outpost`（真的在蓋新據點，月1=12次、月2=175次，佔全年 272 次裡的大多數）+ `cohesion.defect_fire`（脫離勢力，月1=5、**月2=65**）同時發生——世界在「拓殖」跟「解體」兩頭同時燒。

**月3-4（勢力塌陷期）**：factions 8→4→2，`cohesion.defect_fire` 仍有 11+3 次，`occupy.applicable`（可佔據目標）歸零——地圖上已經沒有新地方可佔了。

**月5-9（死寂高原）**：teams/pop 幾乎完全不動（68→68→68→64），`new_delta` 裡幾乎所有 Probe 都是 0，唯一每月穩定跳動的是 `relocate.ordered`（穩定 24/24/24/24），像是背景固定速率的東西在跑、沒有其他世界活動——這是**守成心態**最赤裸的體現：什麼都不做，也沒什麼可以做。

**月10-12（二次崩潰）**：teams 62→27→28、pop 111→70→65，餓死數在月10 突然回升到 16（月5-9 全部是 0）。逐日拆解發現這不是單一觸發事件，是**漫長 knife-edge 終於同時觸底**（見 WHY②）。

## ★4 大 WHY

### ①residents 為何最餓 / wanderers 為何 500+ 天肥 — 雙峰分佈，非全體均一

抽樣裡 T12（faction3 領主、確認為 resident）跟 T42（同樣是 resident）給出兩個天差地遠的命運：

- **T12**：day0-33 從 pop8 崩到 pop1（碎裂+餓死+訓練/掠奪多重消耗），**day34.7 起卡在 pop=1，往後 325 天（到遊戲結束）food 在 0-2 之間反覆，`task` 永遠在「覓食/遷移找糧」↔「return_home」兩個狀態間循環，從沒真正恢復過**——一個人撐不起一支「有據點」的隊伍，food 收支長期是負的，永久卡在赤貧線。
- **T42**：同樣 resident，pop 大部分時間維持 8-12，food 一度飆到 500-700（遠超維生所需），一路撐到 **day352** 才突然崩到 pop5——**這是一個真的繁榮到接近終局才出事的 resident**。

兩者的分岔點看起來是「有沒有在早期被碎裂/減員拖到勞力池撐不起自產」——T12 早早被打到 pop1，落入一個人種不出東西的死循環；T42 躲過早期消耗，靠正常人口規模的產出撐了將近一整年。`daily_curve.resident_food_days_avg`（月10附近只有 2.5-5.7 天）這個低平均值，**是被大量 T12 型「有據點但只剩 1-2 人」的殘存團拖下去的，不是所有 resident 都這麼慘**——這題答案是「resident 群體內部貧富分化極端」，不是「resident 這個身分本身有詛咒」。

### ②day301 崩潰觸發 — day301 本身無異狀，真正斷崖在 day306-307，且只打 resident

逐日核對 `pool_curve`/`daily_curve`：day290-305 之間世界食物總量、team 數、pop 都是平滑漸降，**day301 這一天本身沒有任何離散事件**。真正的斷崖出現在 **day306→307**（teams 61→55，-6）並加速到 day312（→35），到 day307 附近，`resident_n` 從 47（day295）→19（day312）幾乎腰斬再腰斬——**但 `nonresident_n` 全程死死釘在 16，一個都沒少**。

這代表「day301 崩潰」比較精確的講法是：**resident 群體已經在 2.5-3 天食物緩衝這個懸崖邊上活了至少幾十天（day290 就已經是 2.88 天），不是某天忽然發生什麼事，是這個長期懸崖式生存狀態終於在 day306 前後讓夠多隊伍同時觸底**——是一場慢動作的雪崩，不是單一觸發器。

### ③founding 主導的世界故事線 — CONFIRM

硬數字：`worldgen.build_outpost`（真的蓋新據點）全年 **272 次**（12+175+64+20+1，集中在月1-3，月5 後歸零）；`convert_via_settle`（移入既有空據點）全年僅 **2 次**。**~136:1**，founding 完全主導佔據率上升，`convert_via_settle` 幾乎不存在——跟 ticket 已知一致，這輪用逐月 delta 硬數字覆核過。

### ④factions 8→2 — 判斷傾向解體（defect 驅動），非征服兼併

`cohesion.defect_fire`：月1-4 = 5/65/11/3（共 84 次），**時間點跟 factions 從 8 掉到 2（月1-4）完全同期重疊**。同時 `death.combat_pop` 全年 12 個月合計 = 0——**沒有任何戰鬥死亡痕跡**，代表這不是「A 勢力打贏 B 勢力吸收其地盤」這種征服式兼併故事。比較合理的讀法是：**6 個勢力各自因為底下隊伍大量 defect 脫離而萎縮/解體**（可能是領主隊自己也 defect 或死亡，導致勢力群龍無首消滅），不是被誰吞併。我手上沒有直接的「A 勢力接管 B 勢力領土/隊伍」證據，這題傾向解體說，但不是 100% 排除某種未留痕的隱性合併——如果要 100% 坐實，需要一個「faction 消滅」事件的 tap（目前沒有，跟昨天抓到的 `cohesion.defect_fire` tap-gap是類似的觀測缺口，這次是缺一個 faction-level 而非 team-level 的 tap）。

## ★六 symptom 對照（第一輪 → 這輪）

| symptom | 第一輪 | 這輪（12mo） |
|---|---|---|
| famine | 確認，-32.6%/2mo | **持續且更細**：不是均質饑荒，是 resident 群體內部雙峰分化（少數繁榮多數赤貧），85.4%/12mo |
| no-founding（established=0） | 確認 | **持續**，12 個月全程=0 |
| 碎裂（團數暴增） | 只看到上升段（49→130） | **這輪看到完整弧**：170（月2峰）→28（月12），先炸裂後陣亡，不是單純無限增殖 |
| 零戰死 | 確認 | **持續**，12 個月合計=0，包含 warring states 場景設定下 |
| no-merge | 未在本輪直接覆核 | ★這輪找到的碎裂主因是 `cohesion.defect_fire`（政治脫離），**不是**昨天查的「dispatch 子隊沒歸隊」——兩個不同機制，建議下一輪分開查 no-merge 到底還在不在 |
| no-recovery（migrant/invest 死寂） | 確認，月2幾乎靜默 | **更確立**：`invest.dispatched` **12 個月連續全部=0，一次都沒有**；`migrant` 僅月1發生1次，之後 11 個月=0 |

## 總評

世界故事講得通——每個宏觀數字背後都能追到具體、可驗證的機制（founding 驅動佔據、defect 驅動勢力解體、labor-pool 規模不足驅動 resident 貧困陷阱）——但這條故事線描述的是一個**結構性地讓大多數團活不下去**的世界：真根落在「碎裂機制（defect）跟生產機制（labor-pool 規模門檻）互撞」——一旦隊伍被打散到臨界規模以下，就落入永久貧窮陷阱（T12 型），而躲過這個臨界點的少數隊伍能一路繁榮（T42 型）。建議下一步優先查 `cohesion.defect_fire` 的觸發條件（unrest 閾值/distress 公式）是不是校準得太鬆，這是這條崩潰鏈最上游的閥門。

---
*QA 驗收官 · 2026-08-14*
