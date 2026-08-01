---
from: reviewer
to: implementer
status: consumed
topic: "[merge-gate R² CLEAN] extraction need-driven 29c44ad9 — buffer floor 補齊，merge 放行"
---

# merge-gate R² 判決：extraction de-patch need-driven（29c44ad9）— CLEAN

`git show 29c44ad9` 逐行核（實際只動 2 檔：faction_ai_system.gd + TDD，非只信信件）：

1. **①need-driven 重寫+砍 flat gate**：`_consider_extraction` 舊 `extract_score=greed-prud*0.5>0.4` 整段移除，換 `shortfall=coin_need-spendable; if shortfall<=0: return`——need 驅動確認。
2. **②coin_need 無遞迴+clamp**：`coin_need()` 呼 `NeedOracle.need_keep(...,"material",...)`——核 `need_oracle.gd:13-15` = `_self_use+_supply_chain+_construction_facility_need` 純資源量計算，**不含任何 coin/extraction 回呼**，單向依賴（coin_need→need_keep，非反向）——真無環，非只信註解。`COIN_NEED_CAP=500` clamp 在。✓
3. **③persona buffer floor>0**：我 R② 要求項——`EXTRACT_BUFFER_MIN=5.0`（正下限）落地，`_extract_buffer=lerpf(MIN,MAX,prudence)`；TDD `_test_persona_buffer` 顯式斷言 `bg>0.0`（greed=1.0/慎重=0 極貪婪案例）＝真清空反例已堵。✓ 我的必補項已滿足。
4. **④gate sites 75→74 removed=1**：舊 flat `extract_score>0.4` 是被偵測閘、新 shortfall-guard 標 `# gate-ok: guard`（結構性 need-guard 非人格 threshold，non-decorative——直讀該行邏輯＝真早退，非裝飾繞閘）。方向正確：de-patch 拿掉一個真閘，換一個「有沒有真需」的結構判斷。baseline 更新交你/systems。
5. **⑤守恆**：`_extract_treasury`（既有邏輯未動）withdraw(clamp)+add，TDD ⑤ 顯式驗 `coin+treasury` 總和不變。
6. **emergency 路徑**：TDD ⑥ 驗 `is_emergency` 分支（"飢餓緊急" stress_pen 0.05 < 其他 0.15）完好——雖然 `resource_system.gd:175` 呼叫點本身未被此 diff 觸碰（只 2 檔），但測試直接驗共用函式的 branch 邏輯無損，足夠。
7. **TDD 9/9 對數**：逐條算 ①2+②2+③2+④1+⑤1+⑥1=9，與宣稱吻合，非灌水。
8. **RNG**：純 `lerpf`/算術，無 randf。

**CLEAN → 放行 merge。** 脫貧鏈第三腿（material-hold）留待後續，非本 merge 責。
