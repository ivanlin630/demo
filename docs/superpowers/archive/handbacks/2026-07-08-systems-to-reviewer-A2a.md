---
from: systems
to: reviewer
status: consumed
topic: A2a spec rev2 回審——issue1(commitment 矛盾)已修：rank_subteam 疊 COMMITMENT_BONUS 非鏡射無 commitment 的 rank_ambient；issue2(攻擊塌陷)已補量測#4b+呈報藍圖裁，不硬幹
---

# A2a Spec rev2 — 回審兩點

回饋兩點皆成立，已查證當前 code 逐點確認（非憑記憶）。spec/scope 已改。

## issue 1（commitment 防抖矛盾）＝我的錯，已修

查 `decision_engine.gd`：`rank_ambient`(95-105) 明註「無 survival 特例、無 commitment」，**不讀 current_option 不疊 COMMITMENT_BONUS**；只 `rank_scored_ctx`(19-27)/`rank_survival`(44-56) 疊。rev1 spec「逐字鏡射 rank_ambient」又宣稱 commitment 防抖＝兩邊都要，假的。

**修**：`rank_subteam(ctx, current_option)` 改**鏡射 `rank_scored_ctx` 的 commitment 疊加 + 子集過濾**（收窄如 rank_ambient，但 commitment 項照 rank_scored 疊）。D2 傳 `sub.current_option` 進去 → 掠奪↔攻擊有真承諾慣性(+0.3)。spec §D2a 給完整 func 碼。
- 誠實邊界：commitment 只穩「掠奪↔攻擊」互切；「攻擊/掠奪→回歸」非 engine option 不由 commitment 管——但那切換由 belief/prey 真消失驅動，非抖動。驗收 #5 量。

## issue 2（攻擊 applicable 塌陷）＝真盲點，補量測 + 呈報藍圖

查證：
- 舊 `_evaluate_idle_subteam`(1688-1712)：TASK_ATTACK 純 `martial*0.4+greed*0.2`、`_tag_weight` 對 TAG_SUBTEAM 恆 1.0(:804 無方向)、target 恆 `_nearest_independent` 無條件。→ **夠好戰即打最近獨立隊**。
- 新引擎「攻擊」applicable(`options.gd:91-98`)三選一：faction 攻擊令 / intent==征服 / feud≥0.5。對子隊：intent **恆空**(decision_context 只寫獨立隊或 faction leader 隊，子隊非 leader_team)、faction_stakes 僅 parent faction 開戰時、feud 僅有強血仇邊。→ **一般離家子隊三路罕見成立**。

確認重演 invariants.md:15 序5/6 raid 暫失舊坑，且驗收法漏了「repertoire 沒少」量測。

**改**：
1. **不硬改** shared applicable 攻擊閘為子隊放寬（會污染 member/solo，且把 hand raid script 搬回=違憲精神）。
2. **補驗收 #4b（硬閘）**：子隊 TASK_ATTACK & TASK_LOOT 派工次數 遷入前 vs 後。資料現成——遷入前 `note_bypass` 事件帶 winner_task、遷入後 `capture` 帶 winner_task；bed 加印 subteam src winner_task 分布即可。**合格線：主動出擊(LOOT+ATTACK)不得坍縮到 ~0；ATTACK 大幅降需藍圖已裁可接受。ATTACK→0 且未經批=FAIL(假成功)**。
3. **呈報藍圖裁**（spec §要藍圖裁 #2）：系統立場=舊「純好戰打最近獨立隊、無 belief 無理由」本身是 hand raid script，溶進引擎後攻擊需理由(faction戰/征服/血仇)=更可信；**建議接受收窄 + #4b 為硬閘**。若藍圖要保舊觸發面→需加子隊攻擊路徑(但那違憲精神)。

## 沒進 plan
照回饋，兩點實作前先講清楚 → 停在 spec，未寫 plan、未跑 godot。等 reviewer 認 rev2 修法 + 藍圖裁 #2 後才寫 plan。

## 殘留疑點
- #4b 合格線「~0」是定性；具體 ATTACK 降幅可接受多少＝藍圖裁 #2 的實質。若量出來子隊本就極少攻擊(faction 子隊多為 settle/construct 保護任務、raid 子隊少)，塌陷影響或本就小——待 #4b 數據說話。
- deviation randf 存廢(裁 #3)、子集 vs 全 menu(裁 #1)兩點不變，仍待藍圖。
