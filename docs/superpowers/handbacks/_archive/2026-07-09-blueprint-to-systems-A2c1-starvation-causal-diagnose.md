---
from: blueprint
to: systems
status: consumed
topic: A2c1 重框——用戶點破:轉靜=餓死下游非征服旋鈕;疑 merge=小隊生存手段被 fold 弱化;要診斷因果鏈別瞎調
---

# A2c-1 重框：轉靜是餓死下游，非征服旋鈕（用戶點破）

我先前「520 偏靜 = 征服密度旋鈕調低、tune 回來即可」的框架**錯**。用戶點破更 coherent 的因果，我收回。

## 用戶假設（可測，別在腦內定）
**衝突降是餓死的下游症狀，不是可調侵略度**：
1. fold → 該 merge 的隊引擎沒選 merge → 維持小隊。
2. **merge 疑是小隊的生存手段**——小隊靠合併成大隊才養得起/守得住。舊強制 merge 順便把弱隊 merge 成能活的大隊。
3. 小隊不 merge → 食物經濟撐不住 → **餓滅隊 +19% / 餓死 +9%**。
4. 餓死/垂死的隊**打不動仗** → 征服 −30%/掠奪 −69%/血仇 −67% 全是**下游**。
5. ∴ **調 consolidate_drive 或征服 target 沒用**：死隊不征服，且不治「為何不 merge 求生」。

## 要你診斷（measure，非臆測——用戶+我都戳過別理論化）
驗證上鏈，關鍵可測問：
- **A. 因果方向**：衝突降發生在「垂死/小隊」還是「健康存活隊也打更少」？若健康隊照打、只是死隊變多拉低總量 → 支持用戶假設(下游)。若健康隊也轉靜 → 另有因。
- **B. merge=生存手段？**：舊 forced-merge 是否把弱/小隊 consolidate 成存活大隊？fold 後那些「該 merge 卻沒 merge」的隊，是不是正是餓滅的那批？（追 merge-applicable 但 fold 選了別的 option 的隊 → 其後續存活率）。
- **C. 食物經濟**：520 世界餓滅的隊，pop/food_flow 對比 740 同 seed 存活的隊——小隊食物赤字是否因未 consolidate？

## 願景重框（診斷後可能改 A2c-1 定性）
若用戶假設坐實：
- A2c-1 的 fold **弱化了 merge-as-survival**（強制 merge 本是生存 lifeline，非只 conquest artifact）。
- 則「治轉靜」不是 tune conquest，是**引擎要正確 value「求生整併」**——弱/餓隊該 merge 時引擎得選 merge。
- **這可能不是可延 A2d 的深化，是 A2c-1 shipping 的世界健康前提**：fold 若讓世界系統性多餓死，是 shipping regression，非中性 artifact 移除。

## 對我先前裁定的修正
- 我先前把「威脅/duress 下該不該整併」劃給 A2d。用戶揭露其**求生版本**（餓/弱隊求生整併）可能是**load-bearing、不可延**。若診斷坐實，A2c-1 需先解 merge-for-survival 的引擎估值，而非 merge-as-is。
- **暫緩 A2c-1 收尾 spec / merge**，等診斷。別在錯因上鎖。

## 分工
- 你/measurer：跑 A/B/C 診斷（seed 1337 手上 JSON 可能已夠答 A/C；B 需追 option 選擇+後續存活）。回信箱。
- 我：等診斷 → 重判 A2c-1 定性 + 願景方向。
- 用戶已在線深度參與，重大轉折我會同步他。

別瞎調 drive。先釘因果。
