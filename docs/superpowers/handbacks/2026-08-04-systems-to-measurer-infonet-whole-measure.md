---
from: systems
to: measurer
status: consumed
topic: "[資訊網whole獨立驗收量(implementer build完4 slice整合gate綠,交你獨立whole一次量餵blueprint JUDGE)·branch feat/info-network-whole,worktree已在.worktrees/info-network-whole(★godot --path對branch code跑,禁原地checkout)·spec=2026-08-04-information-network-whole-HOW.md·量=whole一次(禁分片量),taps就位(board.relay_*/help.*/scout.*/trade.peer_deal/food_seek_target/distribute.dispatch)·驗:①§5商業unstall(trade.deal·convoy.dispatch·order_fulfilled真>0,多床非單床premature)②饑荒解(distribute.dispatch·food_delivered真>0領主經傳到belief賑濟非直掃+relocate找糧活food_seek_target獲值)③人格分化(per-option util dump傲少求務實早求·統領多查野心疏忽,非齊一常數,implementer報help務0.640>傲0.102/scout統0.800>野0.160你獨立確認)④fog保住(遠/敵belief stale·無god-view)+★hub效應(R²追蹤①:熱門市集高頻造訪+隊belief freshness分佈→功能會否逼近near-global-awareness即使結構不違憲,非只看detector)⑤economy不爆(keep-line不空掏)⑥determinism byte-identical不凍雙seed·★★最重⚠flag(implementer報):1mo warring attrition 0.68%→teams 84→86=可能emergent合作vs戰鬥抑制regression,跨seed/月斷(info-network該解餓/通商非壓戰鬥,若戰鬥被抑制=regression需flag)·perf-watch _market_peer_trade O(teams)/市集到訪·誠實measured數字回systems,別下accept結論(blueprint JUDGE)·escaped_defects記"
---

# 資訊網 whole — 獨立驗收量（whole 一次、餵 blueprint JUDGE）

implementer build 完（4 slice 整合 gate 綠自報）。**交你獨立 whole 一次量**（implementer 自測 ≠ 驗收；[[feedback_verify_execution_end]] 驗執行端真效果）。

**branch**：`feat/info-network-whole`。**worktree 已在** `.worktrees/info-network-whole`（★`godot --path .worktrees/info-network-whole` 對 branch code 跑、**禁原地 checkout**、[[reference_hob_perf_protocol]]）。
**spec**：`docs/superpowers/specs/2026-08-04-information-network-whole-HOW.md`。taps 就位（`board.relay_*/help.*/scout.*/trade.peer_deal/food_seek_target/distribute.dispatch`）。

## 量 = whole 一次（★禁分片量、多床）
1. **§5 商業 unstall**：`trade.deal / convoy.dispatch / order_fulfilled` 真 >0（**多床、非單床 premature**——前科：SLICE A 窄場景 0→6 冒充 general）。
2. **饑荒解**：`distribute.dispatch / food_delivered` 真 >0（領主經**傳到的 belief** 賑濟、非直掃）+ **relocate 找糧活**（`food_seek_target` 真獲值→遷移找糧 fire）。
3. **人格分化**：per-option util dump——傲少求/務實早求、統領多查/野心疏忽（**非齊一常數**）。implementer 報 help 務0.640>傲0.102、scout 統0.800>野0.160，**你獨立確認**（genuine 非 crank）。
4. **fog 保住**：遠/敵 belief stale、無 god-view。+ **★hub 效應（R² 追蹤①）**：tap 熱門市集造訪頻率 + 隊 belief freshness 分佈 → **功能上會否逼近 near-global-awareness**（少數熱門市集高頻造訪→多數隊 belief 幾乎全知、fog 名存實亡）——**非只看 constitution_gate detector 有沒跳**。
5. **economy 不爆**：keep-line 不空掏（戰略/survival 品沒被賣光）。
6. **determinism byte-identical + 不凍雙 seed**。

## ★★最重 watch（⚠implementer flag）
- **1mo warring attrition 0.68% → teams 84→86** = 可能 **emergent 合作**（資訊通→求援/賑濟→隊活下來、good）**vs 戰鬥抑制 regression**（info-network 不該壓戰鬥）。**跨 seed / 跨月斷**：資訊網該解餓/通商、**非壓戰鬥**；若戰鬥被抑制（conquest/attrition 異常降）= **regression、必 flag**。這是 accept-vs-regression 的關鍵判別。

## perf
- **perf-watch**：`_market_peer_trade` O(teams)/市集到訪——量 per-tick median 有無 spike（[[reference_hob_perf_protocol]] 雙 checkout 比）。

## 交付（★QA 硬閘回歸 2026-08-04：大 arc 量完→QA 故事稽核→blueprint→用戶）
- **★必配 specimen trace dump**（`SpecimenDumpHelper`、[[feedback_qa_inversion]]「光 aggregate QA 履不了職」）——whole 量順手掛逐 specimen trace（求援/賑濟/relocate/peer-trade 的 motive→action→outcome 鏈），**餵 QA 故事稽核**（QA 讀真實事件故事、非只 aggregate JSON）。尤 ⚠warring-attrition flag 需 specimen 死因 trace（餓死 vs 戰死 vs 合作存活）。
- **誠實 measured 數字回 `to:systems`**（別下 accept 結論）。escaped_defects 記。
- 綠 → 我路 **QA 故事稽核（非直 blueprint）→ 綠 → blueprint → Telegram 用戶驗收**。灰/regression → 報 `to:systems` 定 fix。
