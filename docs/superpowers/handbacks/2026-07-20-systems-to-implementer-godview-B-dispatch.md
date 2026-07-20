---
from: systems
to: implementer
status: open
topic: "[dispatch·god-view Slice B 創世②+③+relay-discovery·R² v2 CLEAN·★off LOCAL main b6a2d234·measure 敏感 8 config] spec=2026-07-20-godview-slice-B-creation-knowledge.md。兩部:①創世知識(game_setup:575-578 all-pairs→②派系(同 faction 互 discovered)+③本地鄰居(proximity≤CREATION_KNOW_RADIUS TEST VALUE,起 VISION_RADIUS=3 measure tune)+③淵源(config parent 若有))+omniscient_discovery config flag(default false,純機制 test set true 保 all-pairs)②★relay-discovery(message_system:239 record_claim 前:receiver 未 discovered tgt→set team_discovered[receiver].append(tgt);含 distorted;record_claim 已建 belief entry;唯一 relay choke reviewer 坐實)。★8 config(demo/econ_bed/game_sim_test/merchant/survival_start/tyrant/warzone/world_sim)fixture 依賴開局全知的→改 omniscient_discovery:true(測 fixture 該顯式全知)vs 補 belief(測真實情境)逐個判(slice2 fixture 教訓,別盲設全知掩蓋真 gap)。★跨-faction 預盟被 relay-discovery 軟化,per-config 查即可。★★off LOCAL main b6a2d234 禁 origin,pre-push hook 已裝。TDD 6型(②faction/③本地/omniscient flag/default 非全知/relay-discovery/distorted discover)。gate/headless 0new(8 config fixture 處理)/determinism/★measure=emergence 對照(discovery 兩-channel 曲線 vision+relay)+doom-delta seed1337/42/4201+8 config sanity。task=systems+reviewer。"
---

# dispatch：god-view Slice B（創世②+③ + relay-discovery，R² v2 CLEAN）

spec：`docs/superpowers/specs/2026-07-20-godview-slice-B-creation-knowledge.md`。blueprint WHAT 裁 (b)（創世全知=bug + relay-discovery 兌現 2026-07-18 前置承諾）。

## ★★ branch base
- **off LOCAL main `b6a2d234`**（禁 origin 落後）。pre-push hook 已裝。

## 兩部
### ① 創世知識（`game_setup:575-578` all-pairs → ②+③）
替 all-pairs loop：
- **② 派系**：同 faction 互相 discovered。
- **③ 本地鄰居**：`_hex_dist(ta_pos, tb_pos) <= CREATION_KNOW_RADIUS`（TEST VALUE，起 `VISION_RADIUS=3` measurer tune；創世認識可稍廣）。
- **③ 淵源**：config 若有 `parent_team_id`/founding 關係則納。
- **`omniscient_discovery` config flag**（default false）→ true 保 all-pairs（純機制 unit test 用，顯式標非預設）。

### ② ★relay-discovery（`message_system:239` record_claim 前）
```gdscript
if not state.team_discovered.get(receiver_id, []).has(tgt_id):
    if not state.team_discovered.has(receiver_id): state.team_discovered[receiver_id] = []
    state.team_discovered[receiver_id].append(tgt_id)
BeliefSystem.record_claim(...)   # 已建 belief entry
```
- 含 distorted（真隊假 details）。**不建率/延遲/失真完整模型=defer**。reviewer 坐實 message:239 是唯一 relay choke（覆蓋全 relay）。

## ★8 config fixture 處理（slice2 教訓）
8 explicit config 測可能靠開局全知——依賴的改 `omniscient_discovery:true`（測 fixture 該顯式全知）vs 補 belief setup（測真實情境）**逐個判**（別盲設全知掩蓋真 gap）。跨-faction 預盟被 relay-discovery 軟化，per-config 查。

## 驗收
- **TDD 6型**（②faction/③本地/omniscient flag/default 非全知/relay-discovery/distorted discover）。
- **gate** PASS / **headless** 0 new（8 config fixture 處理後）/ **determinism** 2 跑 byte-identical。
- **★measure（→measurer）**：emergence 對照（**discovery 兩-channel 曲線**：vision+relay 漸識，非開局全知也非卡死）+ doom-delta（seed1337/42/4201）+ **8 config sanity**（explicit config headless 不崩）。

## 完成判定 = systems + reviewer/QA。做完 → to:measurer。
