---
from: systems
to: measurer
status: open
topic: "[量測·乞食強制樣本] 逼乞食情境驗完成(mercy floor轉糧?)+診斷為何從不被選;code初判=非幻覺(有mercy完成路)"
---

# 量測：乞食強制樣本（用戶提，驗是否同款幻覺）

乞食 desperation 複判 0 樣本（從沒被選）→ 用戶要驗它是否**同款幻覺**（餓世界無施捨者→乞食恆不成）。

## ★systems code 初判（先給你參照，非結論）
讀 `_resolve_aid_request:968`：**有 mercy floor**——`if give<=0 and beggar_starving and honor>0.1 and annoyance<0.4: give=mercy_amount(1天份)` → 真轉糧（`:1030-1031 set_amt/add food`）。∴ 餓世界施捨者無 surplus 但**非禽獸施主仍給 1 天糧**＝**有完成路徑**（異於併入硬 feed_ok 恆拒無 mercy）。**初判乞食非同款幻覺**，「從不被選」疑 util/applicability 死 rung。**但要你強制樣本 behavioral 確認 + 診斷 util。**

## 要跑（強制乞食情境）
1. **逼乞食樣本**：`survival_start.json`（tick0 零資源逼絕境）或手構——**乞食偏好 leader（高義氣/低貪婪，belief 傾乞食）+ 附近有非禽獸施主（honor>0.1）**。目標=逼出乞食真被選 + resolve。
2. **驗完成（世界效果）**：乞食 winner 選中後 → `[aid_given]` print / beggar food 真升（mercy 或 surplus 轉糧）? vs `[aid_refused]`（無餘糧/吝嗇拒）率。
3. **★診斷為何從不被選（死 rung 根）**：乞食 candidate 出現過嗎（`has_aid_target` finder 有無給 target）? util 多少 vs 買糧/覓食/掠奪（`beg_drive` 太低被壓? applicability `has_aid_target` 太嚴 finder 撲空?）。

## 判定
- **乞食真能完成（mercy/surplus 轉糧成功率 >0）** → 確認非幻覺 → **不需 Fix A look-before-leap**；死 rung=util 問題（backlog，非 merge blocker）。
- **乞食選中恆不完成（連 mercy 都不轉）** → 深層 bug，回報，systems 查。

## 下游
handback `to:blueprint`（乞食是否幻覺定音 + 死 rung util 診斷）。不擋 Fix A-2 併入（那條已 R²/impl 進行）。全量一封信。

## 溯源
raw + measured_at_head（branch feat/desperation-food-seeking 最新，或 main + 手構床，你定）。
