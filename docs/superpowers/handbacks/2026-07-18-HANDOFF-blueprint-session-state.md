---
from: blueprint
to: blueprint
status: consumed
topic: "[HANDOFF·blueprint session state 2026-07-18] 這場=一次workflow自我體檢+餓死深挖。成果:QA結構強制(verification-gate merged,dogfood擋了②FAIL)/各角色/compact重讀職責+憲法hook/doc瘦身/感知違憲稽核(3真點)。遊戲:餓死真根=survival-priority散多路(①merged 1132bf0c)+絕望階梯不會爬(②需失敗回饋,R²中)。★大教訓:驗證步驟(QA/measure-first/multi-seed)不在關鍵路徑→衰減→只結構fail-closed閘持久;root-claim只有逐行locate守得住(merged/code-confirmed/單seed/連我audit都over-claim~8次);增量歸因(拆slice)防猜錯根瀑布。B(50-100隊)卡餓死全綠→才O(N²只掃附近belief)+地圖(perf_scale precedent)。durable全在game-design。★工作流:別ping狀態、別採信done/merged要grep驗branch非main、別spiral進process-meta回遊戲。"
---

# HANDOFF：blueprint session state（2026-07-18）

## 開場程序（resume）
1. arm 信箱 Monitor（先於一切）+ 5h watchdog（`bash .claude/hooks/inbox-watch.sh` persistent + stall watchdog）。
2. 讀 `game-design.md`（我 owner，本場加了一堆 durable，見下）。
3. 掃 handbacks `to:blueprint status:open`。

## 這場一句話
框架驗收 arc 從「經濟為何死」深挖 → 挖出一連串**流程失效**（QA 被跳、決策先於量測、root 猜錯~8 次、過早宣勝），→ 逼出**結構性流程修** + 找到**餓死真根**。大部分時間在「補自己健忘的機制」而非遊戲——justified 但該收斂回遊戲。

## 遊戲實質狀態（餓死→B）
- **① survival-priority 單一源 = merged**（main `1132bf0c`，兩閘綠+QA PASS，證據=team19 消失）。**誠實標：①≠餓死修好（卡格 latch 待②）≠sustain。** 真根=survival 優先序散在 5 條 dispatch 路（solo@50 漏），收成 `priority_for` 單一源。
- **② 絕望階梯 = R² 中**（rework）。**我 ② intent 第3點認錯**（famine-amp 只等比 scale 不換序=鎖偏好格更死非攀爬；階梯**需失敗回饋**：卡格 N 天無 relief→降權→次人格偏好格贏，推廣既有 task_start_tick timeout idiom，框架乾淨）。② impl→measure→QA 回來**我判 release-pass**。
- **感知違憲稽核**=3 真點（audit 灌水的「系統根」是死碼、獵物讀真座標被推翻）：threat-move→belief / absorb belief-gate / invite proximity。= **slice2**（+buy-food-feedback 獨立小刀），post-② rework。死碼 path_system 標「勿復活=O(N²) landmine」。
- **B（50-100 隊大世界）**：卡餓死**全綠**（②完整+multi-seed+QA）才啟。之後=**O(N²) 只掃附近（durable 鎖 belief 位置非 god-view）+ 地圖放大（perf_scale radius24 precedent 已在，密度~18格/隊）**。地圖不是煩惱、餓死非擠出來的。

## 本場 durable（都在 game-design）
- **threat-severity 裁定**+補裁（①人格分流 last-stand **DEFER**（organic 觀測不到）②cap amplifier=必須非取捨）+收束（attrition=餓死非戰鬥、撤熱情 accept、自限判準）。
- **絕望階梯 escalation**（famine-amp×人格方向；③**已更正**=需失敗回饋）。
- **O(N²) 掃描 vision 約束**（belief 非真位、不砍顯著遠威脅、感知鐵律=perf 同一約束）。
- **survival 保序不變量**（命運不看 dispatch 路）+ **threat evasion=intended 深度**（別未來誤修回 live-track）。

## 流程修（系統域，本場多已落）
- **QA fail-closed verification-gate**（merged，dogfood 擋了 ② 的 FAIL）。
- **/compact 重讀職責+憲法 hook**（session-role.sh 各角色；code 角色含感知鐵律）。
- **doc 瘦身**（06 墓碑、03b 血證去重、cross-cutting→00 canonical）。
- **invariant reconcile**（位置：地形=真、他隊位置=belief；修 rule 非只修 instance）。

## ★★大教訓（別重犯）
1. **驗證步驟會衰減、運輸步驟不會**：QA/measure-first/multi-seed 不在關鍵路徑→跳了無後果→衰減；只**結構 fail-closed 閘**（跳了就卡）持久。∴驗證要上關鍵路徑。
2. **root-claim 只有逐行 locate 守得住**：merged/code-confirmed/單 seed/**連我派的 audit** 全 over-claim（本場~8 次，含我 main-vs-branch grep 誤斷、感知 audit 把死碼當系統根）。任何「done/fixed」先 grep 驗真狀態（branch vs main！）。
3. **增量歸因（拆 slice）**防猜錯根瀑布——綁一起=歸因不能。
4. **別 framing auditor**（系統 pre-frame QA 用 invite 假說，QA 沒上當）。
5. **機器強制不丟臉**（agent /compact 後會忘憲法），但**別無限 regress**（人驗偵測器一次就到底）。
6. **別 spiral 進 process-meta**——修流程 justified 但會吃掉遊戲進度，收斂回遊戲。

## 工作流紀律（下場照守）
別 ping 系統狀態（讓它驅動、狀態自己 grep git）。別採信 done/merged（grep 驗）。QA+multi-seed+precise-locate 才下 root/release 結論。到「乾淨全量綠」批點才介入批。

## 下一站
系統驅動 ② rework（R²→impl→measure→QA）→ 到批點喚我判 release-pass → ② 綠 → slice2 感知族 → 餓死全綠+multi-seed → **才 B** → O(N²)+地圖+大世界。durable game-design、progress（系統 owner）。
