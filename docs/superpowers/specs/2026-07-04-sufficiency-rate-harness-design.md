# 全系統充足性率表 harness — Design（機器層；判決歸 QA）

> 藍圖 `2026-07-04-sufficiency-audit`：貿易能以「非零」混過舊 bar → 舊 bar 過關的所有環同等可疑，一次掃完。
> **驗 fire 率非重建**：不動機制內部/守恆/已帶分母驗過者（同化率/狼弧/捕俘漏斗——收編其輸出格式即可）。
> 分工（qa-role-revival）：**本軌=系統備機器**（counters+率表 bed+dump）；**跑+判=QA 驗收官**。
> **★判準（audit-explainability-bar，用戶 WHAT）**：**可解釋性非量級**——判決三類=可解釋（含合理的 0，附解釋句）/矛盾（想要+可行+沒發生=斷鏈）/未知（觀測缺→補探針）。**廢量級配額**。故率表每列除了率，**必附矛盾判定素材：想要量/可行量/發生量 三元組**（QA 才判得出「合理 0 vs 斷鏈 0」）。
> 序=最高優先，與貿易漏斗軌併行（貿易鏈那列=貿易軌產出，本軌不重做）。

## 產出物

1. **`scripts/debug/sufficiency_bed.gd`**：default 自然世界（seed 1337+2674，各 6 月）自跑，輸出**全系統率表**。
2. **輸出格式強制（R3+矛盾三元組）**：每列 `分子/分母=率`＋月切面＋**想要/可行/發生 三元組**（可行=條件滿足計數：有供給/有路/有對象，各鏈自定義並在輸出註明定義）；裸計數=違規。表尾 machine-readable 區塊（JSON 一行/列），供之後固化常駐回歸（縮減版每 merge 跑）。
3. **事件流 dump**：跑完把 `global_messages`+`observer_messages` 全量落檔（headless 直讀 state，不依賴 observer GUI dump——與貿易軌 `--obs-ticker-dump` 互補不撞檔）。

## 率表列（至少，藍圖清單照收）

| 鏈 | 率 |
|---|---|
| 貿易 | **併入貿易軌六站漏斗**（本軌只留佔位列引其輸出） |
| 消息傳播 | 送達/發出、被消費/送達、失真/傳播 |
| belief | 決策讀到實質 belief 次數/決策評估次數（vs 無估 fallback 路徑）、claim 新鮮度分佈 |
| G3 識破 | 識破/謊言 claim、scout 派出/gate-fail、口碑 update fire/比對機會 |
| 外交 | envoy delivered/dispatched（已知 0=首列病單）、提案 accept/提案發出 |
| RelationGraph | feud/gratitude 邊改變 tribute_accept 結果次數/含邊評估次數（剛接線，驗真的在咬） |
| 意圖→行為 | 各 intent「想=做」轉化率（specimen 擴多樣本：per-intent winner-option 一致率） |
| 捕俘/同化/佔村/立國 | 既有漏斗補分母格式（俘/戰、同化/俘、佔/capture、立國/夠格隊） |
| 事件系統 | 各 event 型 fire/eligible 檢查次數 |

## 硬約束

- **counters 零行為變**：純計數/append，不動 RNG 流（濾鏈含 randf 勿重排——cadence 教訓）；驗證=seeded warring 逐點 diff=0。
- counter 放 chokepoint/單寫者入口優先（set_*/bank/emit 已收攏處掛鉤=站點少）。
- 不修任何被量出來的病（判決歸 QA、修序歸藍圖、修=後續軌）。**本軌=純機器**。

## 驗收

1. bed 跑兩 seed 出完整率表（全列有值、全帶分母、JSON 區塊 parse 得動）。
2. 事件流 dump 檔可讀（QA 世界句子審計素材）。
3. 回歸：headless+framework+coin_eq 綠 + seeded 逐點 diff=0（counters 零擾證明）。
4. handback 附率表原始輸出（**不附判決**——判決是 QA 的活）。

## 檔案 scope（平行紀律：與貿易軌撞檔規避）

新：`scripts/debug/sufficiency_bed.gd`。
改（僅 +counter/+dump）：`message_system.gd`、`belief_system.gd`、`diplomatic_ai_system.gd`、`npc_combat_system.gd`、`event 系統`、`faction_ai_system.gd`（intent counter）。
**勿碰**：`order_system.gd`、`interaction_system.gd` trade resolve 段、`decision/options.gd`、observer UI——**貿易軌領地**（貿易列=引用其漏斗，不自建）。`faction_ai_system.gd` 兩軌都碰：本軌只掛 intent counter（讀側），勿動商隊 option/dispatch 區。
