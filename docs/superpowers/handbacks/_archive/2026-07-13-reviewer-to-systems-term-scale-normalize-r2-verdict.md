---
from: reviewer
to: systems
status: consumed
topic: [R②verdict·S2.7] term-scale normalize = CLEAN，附worked-example數值訂正
---

# R② 審判 verdict — term-scale normalize（S2.7）

## verdict: CLEAN

```json
{ "verdict": "clean",
  "premise_contradiction": false,
  "issues": [],
  "note": "代入真實terms.gd公式重算優先序保全（非信spec worked example的illustrative數字）：極餓隊覓食vs訓練實際比值≈6.65×非宣稱的20×，worked example數字不精確但質性結論(survival仍支配)成立。邊界case(半餓隊)代入驗算確認margin平滑遞減非斷崖反轉，無regression。faction_duty exempt疑慮經架構分析自動解答(coeff per-option非per-term，架構上無法選擇性exempt)。" }
```

## 逐項驗證（含自行代入真實公式重算）

1. **★優先序保全（最高風險項，代入真實公式重算）**：spec worked example用illustrative數字（weight 0.5/eval 0.5/coeff 0.2）聲稱20×，但代入真實`terms.gd`公式（`survival_pressure weight=1.0`確認`:217`，`train weight=0.3+好戰×0.4+野心×0.2`確認`:249`，coeff公式neutral人格steepness=0.525）重算：
   - **極餓隊**（survival urgency=1，其餘0）：覓食util=1.0×1.0×coeff(alignment=0.9×1=0.9→coeff≈0.9475)≈**0.95**；訓練util=0.6×0.5(ambient_train_drive TEST VALUE)×coeff(alignment=0，因訓練affinity在L_SURVIVAL權重=0→coeff≈0.475)≈**0.14**。實際比值**≈6.65×**，非spec宣稱的20×——worked example數字不精確（illustrative代入非真公式），但**質性結論（survival仍支配）成立**，非fatal，建議spec更新worked example為真實代入值。
   - **邊界case（半餓隊，你特別要求查）**：food_days=3（中度，raw urgency=0.4）代入：覓食util≈0.664 vs 貿易util(merchant最佳情況，eval=1.0，weight=0.8)≈0.414，覓食仍贏≈1.6×。food_days=4（接近飽，urgency=0.2）：覓食≈0.57 vs 貿易≈0.40，仍贏≈1.4×，margin隨food改善**平滑遞減**非斷崖式反轉——**確認無「半餓隊突然跑去貿易」的regression**，是graduated priority正確運作（spec本意），非bug。

2. **回歸面拆分**：T1→organic→T2→…逐bucket驗證的拆分序合理，跟本session已驗證多次的漸進式slice pattern一致（S1/S2/worldgen等皆同款），適合~13term這種高風險規模。

3. **faction_duty outlier——你的疑慮架構上自動解答**：`coeff`是**per-option**乘一次（`rank_scored_ctx`裡`u*=coeff`在所有term加總**之後**），非per-term——架構上根本沒有per-term exempt coeff的機制，faction_duty(1.5)不管正規化與否，整個option的u最終都會被同一個coeff調變。真正作用只是「duty內部量級（1.5）相對同option其他term（如attack_drive base 0.3）是否夠大以確保服從壓過個人偏好」——這是既有設計意圖（服從>個人偏好），1.5不正規化只是維持這個內部相對優勢，不影響需求優先序的coeff機制本身。你的問題#3已被架構自動解答，非需要額外裁決。

4. **urgency剝淨抽查**：`join_drive`新eval`clampf(0.5+protector_rep×REP_MAGNET_W×0.5,0,1)`，舊`hunger`/`threat`確認移除，只留品質因子（名聲）；`absorb_drive`同式僅base 1.2→1.0，保留resource_slack/yield/gap（機會品質非urgency）。抽查通過，無殘留優先序乘子。

5. **駐守affinity**：`[0.3,0.1,0.1,0.4,0.1]`加總=1.0確認，esteem(0.4)主導，語意「知足經營」合理。

## 建議（非阻擋）
spec §優先序保全 worked example 建議改用上述真實代入數值（6.65×而非20×），避免未來查證時數字對不上實際公式造成誤解。

CLEAN，逐sub-task dispatch implementer（T1→organic→T2→…）。
