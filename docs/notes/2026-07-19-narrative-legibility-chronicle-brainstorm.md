# 敘事可見性 / 史書（觀者真史 A）— 未來 arc 停車筆記

> 藍圖×用戶 brainstorm 2026-07-19（無信箱藍圖 session，純未來願景）。**非現在派工**。存 `notes/`。observe-gated。**盲點掃描 #1**（藍圖主動挖出）——今天 1-7 全在「生故事」，此為「讓故事被看見」，缺它則沙盒 bar 後半（看得下去）fail、其他戲全白生。

## 定位：敘事可見性 ≠ 新模擬，是 tap 之上的敘述/閱讀層
- 接地：observer infra 已有（`observer_ticker/inspect/event_text/query_api` + `specimen_tracer`）但**除錯/QA 級非敘事級**（「Team14 移到(3,4)」不是故事）。
- **全量暫態可觀測性＝憲法級不變量** → 每 decision/motive/outcome 已 tap，**原料全在**。缺的是**敘述**（把 tap 串成人能追的故事）。
- **接 QA 故事判官**：QA 讀 specimen trace 判 motive→action→outcome；敘事層用**同一因果原料**呈現。一個判、一個呈現。

## 裁定＝A（觀者真史，essential 先做）；B（世界內偏史）標遠
- **A 觀者真史**：surface 真因果故事讓看沙盒的人追得下去。沙盒 bar「看得下去」硬需求，且驗證其他一切、餵 QA。**先做。**
- **B 世界內史書**（deeper，deferred）：史 belief-mediated、有偏（勝者寫史、史含宣傳連①造謠、口述失真 hop-decay），史成世界內資訊物件（騎 belief-store）＝連歷史都不透明。接資訊不透明命題，很美但 optional/後續。

## A 的兩個硬核心（其餘是呈現形式）
**1. 顯著性（salience）——選什麼**：每 tick 千百事件 narrate 不完 → 選戲丟噪音。高顯著＝改變世界多/戲劇性高：死亡（尤 named/頭人）、背叛、立國、覆滅、政變、大戰、聯姻、天命轉移、弧的轉折點。

**2. 因果串（causal threading）——「為什麼」**：tap provenance 已記因果（action←motive←trigger）→ 跟 provenance 鏈呈現「X 因 Y 發生」。例：「Team7 頭人死」是事件；串是「饑荒(天災)→Team14 絕境→劫 Team7→殺頭人→其子(羈絆)→復仇弧起」。**這步把事件清單變故事。**

## 脊椎＝人物中心
故事關於人 → 繞 named 人物組織：弧(成長弧)+羈絆+事蹟。人物誌＝該角色為核心的顯著事件串，染其弧（「這時他變殘暴」）+羈絆（「為友復仇」）。世界 legible as 人物＝人讀故事的方式（M&B/CK/DF 全人物中心）。

## 三種呈現形式
- **即時敘述流**：顯著事件連因果即時 narrate（「饑荒漸深，Team14 終於對鄰下手…」）＝watch the story。
- **人物誌**：點角色→生平 saga。
- **世界編年**：宏觀時間軸（王朝立亡/大戰/大人物/紀元）。

## ★壓軸：讓今天 1-7 全部可見/有價值
mandate 爭奪、人物弧、羈絆、天災、造謠——史書 narrate 它們。**無 A，那 7 條戲全白生。** 且餵 QA 故事判官、騎全量暫態可觀測性 tap stream。

## 紀律
- **忠實 tap（禁 confabulation）**：敘 tap 到的因果，非虛構戲；模板化 NL from tap 資料 OK，非自由小說。
- salience-thresholded（surface 戲非噪）。
- 人物中心（named；anon=統計背景）。
- **read-only（純觀測不影響 sim）** → 憲法不直接約束（非行為驅動），但品質要求＝忠實不捏造。

## 一句
A＝**salience（選戲）× 因果串（連為什麼）× 人物中心（繞人組織）的忠實敘述層**，騎已有 tap stream；即時流/人物誌/世界編年三形式；壓軸——讓今天所有戲被看見、服務沙盒 bar、餵 QA。

## 溯源
本 session brainstorm（盲點掃描 #1 → 敘述層非新模擬 → salience+因果串兩核心 → 人物中心脊椎 → A真史/B偏史二分）；`observer_*.gd`/`specimen_tracer.gd`（除錯級 observer）；全量暫態可觀測性不變量（[[feedback_full_transient_observability]]）；QA 故事判官（04_qa 第五職）；接今天諸筆記（1-7 是被 narrate 的內容）；沙盒 bar「看得下去」（game-design line 100-109）。
