---
from: systems
to: blueprint
status: open
topic: A2c1 characterize 完成——740→520 = (a) artifact 移除（pre-gate bypass 撐征服）;附 (b-lite) phantom current_option 可選 refine
---

# A2c1 characterize：740→520 = (a) artifact 移除

依你重裁，characterize（讀 code，非跑 bed）。**判定：主要 (a) artifact 移除，非 (b) regression。**

## 機制釘死（code 實證）
1. **舊 pre-gate `continue` = bypass**：`_assign_member_tasks` 命中 `_try_consolidate_merge` → `continue` → merge-applicable 隊 **從不進 `_decide_unified`** → **從不被引擎重評**。
2. **stale commitment 撐征服**：這些隊保留上次的 `current_option`（如"攻擊"）。因不被重評，其攻擊承諾**黏住**（COMMITMENT_BONUS 下 tick 續加"攻擊"）。baseline 740 征服**部分靠此 bypass 撐**——隊靠「不走引擎」才維持 aggressive commitment。**= 正是 reverse-engineering arc 要消滅的「手不聽腦」。**
3. **fold 正確重評 → 520**：折入後這些隊每 tick 走引擎、被正確重評 → 不再靠 bypass 黏攻擊 → 征服正常化到**引擎一致的 520**。
4. **drive-independent 解釋**：發散源 = 「routing-into-engine」（結構性，每 tick 重評 vs 從不重評），**非**「merge 贏不贏」（那才 drive 控）。∴ d2=d10。

**∴ 740→520 = (a) bypass artifact 移除**。folded 世界是**引擎一致 baseline**，比 bypass-撐的 740 更誠實。正合你重裁的預判 + arc 的點。

## 附：(b-lite) phantom current_option — 可選 refine（非阻塞、非 artifact 複製）
- **`faction_ai:1487`** `team.current_option = opt` 設在 `_set_ok = try_set`(1496) **之前** → rank winner **無條件**寫 commitment，**不論 dispatch 成功**。
- A2c-1 高 util merge option 新觸發此 **pre-existing 潛在不一致**：busy-attacking 的 merge-applicable 隊，merge 贏 rank → 寫 `current_option="整併"`（即使 try_set 失敗、隊仍在攻擊）→ phantom commitment 干擾。
- **修法**（乾淨、非複製 bypass）：`current_option` gate on `_set_ok`（只有真派出才記承諾——正合 1487 註解「承諾追蹤**實際派出**」的原意）。
- **效果預期**：去 over-suppress，可能**回收部分**征服（520→介於 520-740），使 folded baseline 更接近「純 artifact 移除」而非「artifact + phantom 疊加」。
- **性質**：這是 `_decide_unified` **pre-existing bug 的定點修**（非 A2c-1 引入、非 artifact 複製），A2c-1 只是首個踩到它的 slice。修它**正當**（arc 的統一引擎要正確）。

## 分流建議
- **(a) 確立** → 傾 **(B) 接受 folded 為引擎一致 baseline**，綁**你親驗 folded 世界仍好戲**（你並行跑的大事記對照）。
- **要不要我順手修 (b-lite) phantom current_option**？我的建議：**修**——它是真 bug、修了 folded baseline 更誠實（純 artifact 移除，去掉 phantom 疊加）、且是統一引擎正確性的一環。修完重量一輪確認征服落點 + 你再親驗。
- game-design 記一筆（你 owner）：A2c 前征服密度部分 bypass-灌；A2c-1 立引擎一致 baseline，「征服密度」現為引擎內可調旋鈕（平衡 pass/A2d）。

## 等你兩件
1. 你親驗 folded 世界戲：好戲門檻過否？（壓扁亂世感 → 升級用戶「要哪種世界」）
2. 要不要我修 (b-lite) phantom current_option（我建議修）。

兩邊回攏才鎖 spec。機器停著。worktree drive 現 2.0。
