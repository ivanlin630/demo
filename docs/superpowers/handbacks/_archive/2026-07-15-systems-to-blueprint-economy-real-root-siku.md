---
from: systems
to: blueprint
status: consumed
topic: "[★★經濟真根定音·私囊鎖非accessor] measure破accessor:no_coin 91%主根=私囊鎖(salary team→person單向,person→team僅死亡,living成員囤coin→team.resources.coin單調枯竭→買不了);accessor<3%/threat 5起全非binding;measure-first第4次救大重構;真修=coin循環非accessor"
---

# ★★經濟真根定音：私囊鎖（no_coin 91%），非 accessor 結構

measurer 兩死法量化 + local_value 抽驗 + systems patch-gate-first coin 流查——**經濟 binding 真根＝私囊鎖 coin 循環斷，非 accessor 結構、非 threat**。誠實：**accessor 結構主刀 measure 證 <3% 效果，會是第 4 個非-binding 大重構**。measure-first 又救一次。

## 死法二真根（no_coin 91%，碾壓性）＝私囊鎖（code-verified）
measurer：27020 co-loc bail 中 **no_coin=91%(24600)**（買方 team.resources.coin 空）。systems 查 coin 流坐實根：
- **salary（`salary_system:65-66`）**：`team.resources.coin → person.coin`（named 成員，每 cycle **單向抽**）+ anon→treasury。
- **person.coin 唯一 outflow＝死亡**（`npc_combat:745 death_coin_return`）；inflow＝salary/promote/extort。**living named 成員永不花 person.coin 回流團池。**
- **anon_treasury 有 extraction 回收**（`_consider_extraction:2235`）；**named person.coin 沒有任何回收/花用路徑。**
- ∴ **team.resources.coin 單調枯竭**（salary 每 cycle 抽走、只死才回）→ 買方到 market 口袋空 → no_coin → 市場死。**這就是你早先 coin census 抓的私囊鎖，現在精準 root：named 成員 coin 黑洞（入到死）。**

## accessor / threat / churn 全 measure 證非 binding（第 4 次救）
| 假設 | measure 結果 | 判 |
|---|---|---|
| supply seam（可見性）| kill_nostock 月1-3 降但 deals~0 | 非 binding（已證）|
| merchant-target churn | target 穩定 28000tick 僅切6次 | trace 推翻 |
| threat-preempt（死法一）| 真 preempt ~6 起，80.6% normal rotation、FLEE 是缺糧非 threat | 推翻（threat 非主因）|
| **accessor 結構（local_value）**| absorb 修 material +114% **但仍 <3%**，ask>=bid 樣本只差 2.5% | **部分真但非 binding** |
| **★no_coin 私囊鎖** | **91%** | **★真 binding** |

**seam→churn→threat→accessor 四層假設全被 measure/trace 推翻，真根第 5 層＝私囊鎖。** 你 flag 的「先量再 spec」擋下第 4 個非-binding 大重構（accessor 統一若當主刀 spec，<3% 效果＝白做）。

## 真修向（待你願景，coin 循環非 accessor）
- **主根＝coin 循環**：named 成員 person.coin 該**花回經濟**（個人消費買糧/貨→coin 流回賣方團池）or **團週期回收**（稅/上繳）or **salary 別單向枯竭團池**。這是 WHAT——**成員該怎麼花錢**（有錢的成員在死世界裡當守財奴＝私囊鎖病）。
- **accessor 統一降級**：從「經濟主刀」→ **小 follow-up**（line 252/86/138/absorb 仍真債，local_value 材料類 +114% 是真小改善，但非 binding，別當主刀大重構做）。併框架債 backlog or coin 修後順手。
- **Team6 execlock thrash**（死法一 24 筆）＝churn 家族（survival↔trade 同 cadence 反覆，同你 backlog#5 + 早先求生執行鎖 bug family）→ 併 churn-latch 結構 backlog。
- **threat 韌性（B）**：真 preempt 僅 ~6 起＝**非急**（世界不是靠 threat 殺貿易，是沒錢買）→ B threat 韌性降優先。

## 下一站
**你出 coin 循環願景**（成員消費/回收機制怎麼設）→ systems patch-gate-first + spec coin 循環修 → R² → impl → measurer（team.resources.coin 不枯竭 + no_coin 降 + deals 真發生）→ 你批。**經濟真 binding＝錢不流通，先通錢再談 accessor/threat。** measure-first 第 4 次證值。
