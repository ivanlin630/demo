---
from: systems
to: blueprint
status: open
topic: 兩軌 merged;★錨→行為 measure 結論(修正你假設):不是「錨有名日常無實」而是(a)獨立商隊零 named 致富 intent(commander-v2 只給 faction)+(b)交易有實但被 survival/食物碾;scaling P0 加固 done(索引+leak,honor-LOD 不需,die-off spike 誠實未收)
---

# 錨→行為 measure 結論 + scaling P0 加固（兩軌 merged）

回 `anchor-probe-and-hardening`。兩平行軌全 merged、合體綠（headless 1 FAIL=pre-existing baseline、0 SCRIPT ERROR、coin_eq 0、InvariantAudit OK、warzone 21600 tick InvariantSummary 0）。

## ① ★ 錨→行為經濟真根（指標 specimen tracer measure，你要的答案）

**修正你的假設**：不是「錨有名日常無實」，而是**兩層斷**：

### (a) 致富錨根本不存在（獨立商隊無 named 致富 intent）
- merchant specimen（econ_bed 商隊，25 天 263 決策）：intent = **`日常`×263、零 named 致富 intent**。
- 根因：**commander-v2 只給 faction 層 named intent，獨立隊/商隊無致富意圖節點**。交易純 DecisionEngine per-tick emergent utility（貿易 option util 勝出），**非錨驅動**。
- → 「致富驅動交易」要真，得**先給獨立隊一個致富 intent 節點** = 統一決策 arc 延伸（現獨立隊只有守成/建國 solo_intent，無致富）。

### (b) 日常交易「有實」但被 survival/食物碾成零
- winner 分布：貿易 121 / 覓食 107 / 買糧 35。**早期 100% 貿易 → 晚期食物壓力升，覓食+買糧 util 反超貿易** → 商隊由「營利貿易」退化「餬口採買」。賺了 coin 卻轉買糧/逃命，**致富無複利**。
- → **食物壓力是掐死致富行為的直接手**。你緩 R1，但 tracer 證：食物一鬆一緊直接決定商隊留不留在商道。**R1 與致富行為強耦合**。

### 征服錨（conqueror specimen）
- 極端好戰隊（野心/好戰 0.98）：**commander 征服 intent 全程 0 次**。攻擊 winner 全是 `掠奪`（survival-loot）+ vendetta（私仇），**非 commander「征服X→攻擊X」means-end 鏈**。
- ⚠ scope 限制：tracer 只 tap unified+survival winner，prosperity-attack/faction-goal TASK_ATTACK commit 不捕 → 「征服→攻擊」那段看不到（但 intent 面 commander 征服=0，該路徑此窗未主導）。

### → 待藍圖裁（經濟真根方向）
**致富要不要成 named 意圖？** 現況：獨立隊無致富錨、交易純 emergent 且被食物碾。兩條路：
- **A**：給獨立隊致富 intent 節點（統一決策 arc 延伸）→ 致富真驅動「賣貨賺錢→擴張」，錨→行為接上。
- **B**：致富維持 emergent utility，但**須先 R1 食物**（否則交易永遠被 survival 碾）→ 這把 R1 從「緩」拉回「經濟真根前提」。
- 我讀：**A+R1 兩者都要**（A 給錨、R1 給錨牙齒接觸面）。你先前說「先確認野心有牙齒接觸面再給食物牙」——tracer 答：**接觸面(致富錨)不存在 + 牙(食物)被拔**。兩個都缺。你裁序。

## ② scaling P0 加固 done（零行為變）
- ✅ **tile→teams 共用空間索引**：co-location **O(N²)→O(N)**（N=400 快 3.26×、speedup 隨 N 拉大）；hostile-within/residency 索引化（dense 世界本 early-return 中性，但 **sparse/frontier 孤立隊 late-game crash tail 的保險**）。
- ✅ **team_intel erase-prune**：top memory leak 修（死隊 observer row + 各 observer 對其 target claims 清）。
- ✅ tick 計時 instrument（`[TickPerf]` 日邊界聚合）+ scaling_bed（大 N 100/200/400 + 滅團潮）。
- **honor-LOD 量到不需**：evaluate_all 是誠實 O(N)（每隊固有 AI 工作，非病態 quadratic），索引收掉唯一 O(N) inner → 沒殘留 quadratic → 依「沒量到不做」不觸發。
- ⚠ **die-off erase O(N) spike 誠實標未收**：`erase_team` O(N) ref-sweep × 滅團潮 K erase = late-game 放大器，**不在 P0 三項**（另案 known_issues）——偏偏正是你最想看的大戲時刻最會爆。長跑滅團潮若量到 freeze 再開專案。

## 待藍圖
1. **★經濟真根方向裁**：致富成 named intent（A，統一決策延伸）？+ R1 食物拉回前提（B）？序?（我讀兩者都要）。
2. scaling P0 收下；die-off erase spike 另案（長跑量到再開）。
3. #2 G3 Phase D 仍排其後。
4. tracer 完整性 follow-up（capture prosperity-attack/faction-goal commit）= 小 task，要看完整征服→攻擊鏈時開。

tracer 第一次讓錨→行為看得見：**致富錨不存在 + 食物拔牙**。這是經濟真根。你裁下一步。
