---
from: measurer
to: systems
status: consumed
topic: "T3死歸因verdict:★★不是masked gap,是第三機制——event_faction_defect(T3義氣0.3<DEFECT_HONOR_THRESHOLD 0.35,unrest_turns≥20觸發)day0(tick~60)T3就自行脫離faction1,member剩1(僅T2)→連鎖disband_faction→T2/T3 faction_id雙雙變-1,此後60天全程=-1。①T1仍救活confirm(alive_at_end=true,food_delivered 58→72,dispatch14,faction fix不退)。②T3死歸因:(a)T3 herald mini-util數學閉式證明恆負(-0.427,severity=1封頂仍負,pmult=0.155因野心0.9義氣0.3)——但這是formula事實非實際路徑,實際code在mini-util算之前就先被_resolve_help_target的faction_id==-1擋掉(target_unresolved)(b)T2 scout同理恆≤-0.05,且_try_scout_side本身faction null-check直接擋,scout_target_id全程=-1(c)discriminator決定性:手動注入T3distress進T2.team_known後仍0 dispatch,直呼info_side_dispatch_all([2])繞過cadence也0,直接call _distribute_candidates回傳[],追蹤到根因=t2.faction_id當下=-1(f_null=true)——非util計算失敗,是faction根本不存在,_distribute_candidates第一道gate直接return。★誠實結論:T3死非broadcast人格masked bug,是faction defect機制(同樣T3自己低義氣觸發)提前把整條relief鏈的structural prerequisite(faction membership)自己拆了,連T2都被拖累(disband波及leader)。人格層(a)(b)本身也是genuine(數學閉式證負)但在此案例中屬moot(被更上游的defect搶先擋)。純觀測+定位介入(c)已如實聲明非純觀測。別下accept，genuine vs masked判準本身不完全適用,交systems判是否为defect門檻本身需review"
---

# T3 死歸因：★不是 masked gap，是第三機制（event_faction_defect 自我脫離）

## ①T1 仍救活 confirm

`config/infonet_whole.json` + `infonet_whole_diag_bed.gd`（persist bed，未改一字）against `20a7d8ef`：
- `alive_at_end=true`（保持，faction fix 不退）。
- `food_delivered` 58.0→**72.0**、`distribute.dispatch=14`（比 RE7 更多，因 home 現在正確指向 T0（14,14），非誤指 T2）。
- 落地 `docs/measurements/2026-08-05-infonet-t1confirm-20a7d8ef.txt`。

## ②★★T3 死歸因：真根因＝faction defect（第三機制，非 broadcast 人格、非 masked bug）

**faction 結構確認**（如工單要求）：`T0=fac0 T1=fac0 T2=fac1 T3=fac1`（config 意圖已生效）。

但往下追發現：**faction1 在模擬第一天（tick~60）就已經解散**，往後 60 天全程 `T2.faction_id=T3.faction_id=-1`：

```
[Faction] 立國：勢力1（leader=Team2，2 teams）
...(tick~60,無任何死亡/戰鬥事件介於中間)...
[Faction] 勢力1 解散
[Faction] Team3 脫離勢力1
```

**code 追根**（`scripts/simulation/events/event_faction_defect.gd`）：
```gdscript
const DEFECT_UNREST_THRESHOLD: int = 20
const DEFECT_HONOR_THRESHOLD: float = 0.35
func check(...): return team.unrest_turns>=20 and (honor<0.35 or trust<0.35)
func execute(...):
    state.clear_team_faction(team)   # 脫離
    if f.member_team_ids.size() <= 1: state.disband_faction(fid)   # 只剩領主一人=連鎖解散
```
T3 的 config 人格 `義氣=0.3`——**低於 `DEFECT_HONOR_THRESHOLD=0.35`**。一旦 T3 的 `unrest_turns` 達到 20（模擬顯示這在第一天內就達標），**T3 自己觸發「脫離勢力」事件**（跟 distribute/herald/scout 機制完全無關的獨立事件）。T3 脫離後，faction1 只剩 T2 一人（size≤1）→ **連鎖觸發 `disband_faction`**，把 T2（領主本人）的 `faction_id` 也一併打成 `-1`。此後全程，T2/T3 都不再是任何 faction 的成員。

### (a) T3 herald mini-util——公式閉式證明恆負，但★這是 moot（實際路徑更早被擋）

用 T3 真人格值（求生欲0.2/野心0.9/義氣0.3）+ code 原公式手算並跑時逐日驗證：`help_pmult=0.155`，`mini_util = severity * 0.155 * 2.4 - 0.8`。**即使 `severity` 封頂 =1.0（最餓），`mini_util = -0.427`，恆負**——T3 的人格（義氣低+野心高）結構上永遠不會讓 herald 划算，這是**真人格 genuine gate**（不是被擋，是算出來就負）。

但★這個計算在實際 code 路徑裡**根本沒機會執行**：`_try_herald_side` 先呼叫 `_resolve_help_target`，而該函式第一行就是 `if team.faction_id == -1: return {id:-1}`——T3 從第一天起 `faction_id=-1`，所以每次都在 `target_unresolved` 就返回，mini-util 從未真正被算過。**(a) 的「genuine 人格」結論在數學上成立，但在實際模擬裡是被 faction defect 提前架空的假設情境。**

### (b) T2 scout mini-util——同款恆負 + 同款被 faction 擋在更前面

`smult=0.312`（野心0.8疏忽×0.5抑制），`mini_util` 理論上限（staleness=1.0）＝`-0.0512`，**也恆負**（比 T3 更接近 0，但仍過不了）。實際路徑：`_try_scout_side` 第二行 `f = state.factions.get(team.faction_id); if f==null: return`——T2 同樣 `faction_id=-1`，每次直接被擋，scout_target 全程 `id=-1 staleness=0`。

### (c) ★discriminator：手動注入 T3 distress 進 T2.team_known → 決定性 0

- day20 手動把 T3 的 order_buy 訊息塞進 `state.team_known[2]`（繞過 broadcast 完全模擬「T2 已聽到」）。
- 之後 40 天：**0 筆 convoy 指向 T3**。
- 追加探針直呼 `_distribute_candidates(state, T2, ctx, lv)` **直接回傳 `[]`**；印出 `t2.faction_id=-1 f_null=true`——**答案在此**：`_distribute_candidates` 第一道 gate `team.faction_id == -1: return out` 直接擋下，跟我塞進 team_known 的訊息內容完全無關（訊息確實有進去，但函式第一步就已經 exit，根本沒掃到）。
- 再繞過 cadence 直呼 `fai.info_side_dispatch_all(state, [2])`：`distribute.dispatch` 前後不變（5→5），**確認不是排程沒輪到，是 candidates 本身在 gate 拒絕**。

## ★誠實結論

**不是「genuine 人格 vs masked gap」二選一——是第三個更上游的機制**：`event_faction_defect`（T3 自己的低義氣觸發的自我脫離事件）在模擬第一天就把 T2/T3 的 faction 關係整條拆掉，連 T2（領主本人）都被連坐波及。這發生在 herald/scout/distribute 三個 side-dispatch 機制的 broadcast/util 計算之前，**使 (a)(b) 的人格閉式證明（雖然數學上真實）在實際模擬裡從未有機會操作**，(c) 的 0 結果也不是「distribute settle 有 bug」，而是**這條 faction 關係從一開始就不存在**。

若把 T3 的人格視為「唯一」死因敘事——它確實低義氣，但驅動死亡的具體機制是**它自己觸發的 faction 脫離事件**，不是「太驕傲不求援」的敘事本身（那個敘事在數學上為真但被搶先架空）。這是 genuine 人格驅動的結果（低義氣→defect→孤立→死），只是驅動的**通道**跟工單假設的（herald/scout broadcast 未 fire）不同。

## 落地檔案（已 ls/wc 驗證存在）

- `docs/measurements/2026-08-05-infonet-t1confirm-20a7d8ef.txt`（1895行）
- `docs/measurements/2026-08-05-infonet-t3-attribution-run1.txt`（1851行,含(a)(b)(c)完整trace）
- `docs/measurements/2026-08-05-infonet-t3-attribution-run2-samples.txt`（1857行,含diag.dist_heard/dist_pick production tap樣本+outpost確認）
- `docs/measurements/2026-08-05-infonet-t3-masked-probe.txt`（972行,決定性(c)追根：faction_id=-1直接證據+bypass-cadence測試）
- `docs/measurements/2026-08-05-infonet-t3-attribution-diagnostic.json`（959行,結構化dump）

## 清理狀態

- temp `infonet_t3_attribution_bed.gd`/`infonet_t3_masked_probe.gd`（僅 worktree,main 未複製）已刪除確認乾淨。
- ★(c) 是唯一非純觀測的環節：手動寫入 `state.team_known`（模擬「訊息已送達」的世界分支），未改任何 production code/函式邏輯,如實聲明。
- 跑本工單期間發現 worktree 有另一 session 正在動 `docs/measurements/2026-08-05-t3-crossfaction-targeting-diagnostic.json`（implementer 自己的診斷檔，非我所有），未觸碰。

★別下 accept。genuine-vs-masked 判準本身在此案例不完全適用（是第三機制），是否要動 `DEFECT_UNREST_THRESHOLD`/`DEFECT_HONOR_THRESHOLD` 或這條 defect 事件跟 distribute 的交互設計，交你們/blueprint 判。
