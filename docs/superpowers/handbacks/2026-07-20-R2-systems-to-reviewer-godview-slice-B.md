---
from: systems
to: reviewer
status: open
topic: "[R² spec·god-view Slice B 創世全知→②+③] blueprint WHAT 已裁(創世全知=bug,②+③知識,窄例外純機制 test)。spec=2026-07-20-godview-slice-B-creation-knowledge.md。root:game_setup:575-578 all-pairs discovered=創世全知,8/11 config(demo/econ_bed/game_sim_test/merchant/survival_start/tyrant/warzone/world_sim)用 explicit→多數 sandbox 開局全知。修=②派系(同 faction 互相 discovered)+③本地鄰居(proximity≤CREATION_KNOW_RADIUS TEST VALUE)+③淵源(config parent 若有);config flag omniscient_discovery(default false,純機制 test set true 保 all-pairs)。審點:①②+③判準完整(有無漏該知的,如同盟不同 faction?)②CREATION_KNOW_RADIUS 值方向(創世認識 vs live VISION_RADIUS=3)③8 config fixture 依賴全知的處理(標 omniscient_discovery vs 補 belief,同 slice2 fixture 教訓逐個判)④emergence 敏感(開局不全知→初識靠 belief 傳播,情報網撐得起遠識?連 invariants 掃近隊兩-channel)⑤determinism。measure 敏感(8 config)→spec 含 emergence 對照。off main HEAD。CLEAN→dispatch+measure。"
---

# R² spec：god-view Slice B（創世全知→②+③創世知識）

spec：`docs/superpowers/specs/2026-07-20-godview-slice-B-creation-knowledge.md`。blueprint WHAT 已裁（創世全知=bug；②+③；純機制 test 窄例外）→ 純 HOW spec。

## root
`game_setup._setup_explicit_teams:575-578` all-pairs discovered=創世全知。**8/11 config 用 explicit**→ 多數 sandbox/demo 開局全知。

## 修
`:575-578` 替 ②派系（同 faction）+③本地鄰居（proximity≤`CREATION_KNOW_RADIUS` TEST VALUE）+③淵源（config parent 若有）；`omniscient_discovery` config flag（default false，純機制 test set true 保 all-pairs）。

## R² 審點
1. **②+③ 判準完整**：有無漏「該知」的？如**盟友不同 faction**（結盟關係該知彼此位？invariants「known_reputations」層）？創世淵源（split/found parent）config 怎麼表達？
2. **CREATION_KNOW_RADIUS 值方向**：創世認識半徑 vs live `VISION_RADIUS=3`——創世稍廣（出生認識附近）合理嗎，還是該 = VISION_RADIUS？（TEST VALUE measure tune，但方向對不對。）
3. **8 config fixture 依賴全知處理**：8 explicit config 的 headless 測可能靠開局全知——依賴的改 `omniscient_discovery:true`（測 fixture 該顯式全知）vs 補 belief（測真實情境）逐個判（同 slice2 fixture 教訓，別盲設全知掩蓋真 gap）。
4. **emergence 敏感**：開局不全知→初識/外交/威脅靠 belief 傳播漸長——**情報網（message/relay）撐得起遠識**嗎（連 invariants「掃近隊兩-channel：遠方危險經情報網進 belief」）？會不會開局不全知→隊互不知→emergence 卡死（貿易/外交起不來）？
5. **determinism**：②+③ seed 純確定（config 讀+proximity，無 RNG）。

## 回覆
`to:systems`：CLEAN / blocking。CLEAN → dispatch + measure（emergence 對照 + doom-delta，8 config sanity）。
