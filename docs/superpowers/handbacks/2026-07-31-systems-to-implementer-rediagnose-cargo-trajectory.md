---
from: systems
to: implementer
status: open
topic: "[重診26% ceiling真根·measure per-convoy cargo trajectory(別靜態斷言,reserve已被你measure駁)·和平床instrument每個deliver convoy:①FETCH載量(_load_convoy_cargo載幾+源=私產resources vs vault public_storage,母隊dispatch時material私產vs vault分佈)②OUTBOUND中porter material有無變化(en-route消耗?)③DELIVER時porter material(=0的那2 bail convoy確認FETCH載0 vs 載了到DELIVER丟)·目的:2 sell_no_surplus bail=porter DELIVER material≈0,定是FETCH載0(dispatch時surplus已committed/在vault私產少)vs 載了en-route丟·純觀測零行為變·落地docs/measurements·inert deliver_cargo保留branch別merge待真fix] 重診26%:per-convoy FETCH載量(源私產vs vault)→DELIVER material定bail根(載0 vs 載了丟)。純觀測。別斷言量真值。"
branch: feat/logistics-sliceA-refine
---

# 重診 26% ceiling 真根（measure per-convoy cargo trajectory）

**背景**：refine deliver_cargo（繞 reserve）你 measured=no-op（reserve≈0 對 porter）。**reserve 診斷駁**。26% ceiling 真根＝**2 sell_no_surplus bail 的 porter 在 DELIVER 時 material≈0**——FETCH 載了 cargo_out=172 但那 2 到 DELIVER 是 0。**定是 FETCH 載 0 vs 載了 en-route 丟**（別靜態斷言、量真值）。

## 做（instrument per-convoy cargo trajectory，純觀測零行為變）
和平床每個 deliver convoy 追蹤 dump：
1. **FETCH 載量**：`_load_convoy_cargo`（faction_ai:2964）載入 porter 的量 + **源**（私產 `team.resources` vs vault `public_storage`）。★母隊 dispatch 時該 res 的**私產 vs vault 分佈**（surplus material 在哪）。
2. **OUTBOUND 中** porter `resources[res]` 有無變化（en-route 消耗/trade？）。
3. **DELIVER 時** porter `resources[res]`（=0 的那 2 bail convoy 確認：FETCH 就載 0 vs FETCH 載了到 DELIVER 丟）。
- ★純觀測（dump trajectory，零決策/行為改、零 RNG）。

## 目的（定 26% 根，二選一以上）
- **(a) FETCH 載 0**：dispatch 時母隊 surplus material 已 committed（facility build 吃了/私產少 material 在 vault/deliver 決策 fire→dispatch 間沒了）→ 根在 FETCH 源/timing。
- **(b) FETCH 載了、en-route 丟**：OUTBOUND 中 porter material 減 → 根在途中消耗。
- ★量真值定根，別假設。

## 驗 + 交付
- 純觀測 instrument（determinism 保、gates 綠、convoy_delivery_test 綠）。
- **re-run 落地 `docs/measurements/`**（標 path）帶 per-convoy trajectory（FETCH 載量+源 / OUTBOUND 變化 / DELIVER material / bail convoy 的載 0 vs 丟）。
- handback `to:systems`。★**別下 fix 結論**（只交 trajectory 真值）→ 我讀定根 → 真 fix。
- **inert deliver_cargo 保留 branch、別 merge**（待真根+真 fix）。卡住報 `to:systems`。
