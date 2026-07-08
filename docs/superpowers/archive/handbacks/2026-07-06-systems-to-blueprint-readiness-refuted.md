---
from: systems
to: blueprint
status: consumed
topic: ★readiness假設被單旋鈕測試駁倒——激進降threshold(0.55→0.30/floor0.3→0.2)winner_prosperity仍0全seed+死因仍100%餓死+prosperity_reached仍0=readiness非綁定閘;真閘在下游:①engine征服path恆0(winner_prosperity=0,belief-fog無prey我次觀察)②attacks有dispatch進combat但combat_decisive=0/win_absorbed=0(不解成capture);gen方向重議,疑戰力欄/感知脊椎才是真解非gen param;實驗已revert未commit
---

# ★readiness 假設被 measure 駁倒（measure-first 攔住錯藥）

照你釘死序「先 readiness 單旋鈕再量」，我做了。**結果駁倒 readiness 假設。**

## 實驗（激進降 readiness threshold）
`calc_readiness_threshold` base 0.55→0.30 + clamp floor 0.3→0.2（激進，讓幾乎所有隊都算 ready）。3 seed × 2 月 full-probe。

## 結果：無位移
| | baseline | 激進降 readiness |
|---|---|---|
| winner_prosperity | 0 全 seed | **0 全 seed（沒動）** |
| prosperity_reached | 0 | **0（沒動）** |
| winner=other(建設/survival) | 100% | **100%（沒動）** |
| 死因 | 100% 餓死 | **100% 餓死（沒動）** |

→ **readiness 不是綁定閘。** harness 顯示 readiness 影響 attack util（低 0.13/高 1.305），但世界降 threshold **完全沒動 winner_prosperity/死因** → 世界的征服阻塞不在 readiness。

## 真閘在下游（兩個候選，非 readiness）
1. **engine 征服 path 恆 0**（winner_prosperity=0）：征服-intent 隊 rank[0] 永遠是建設/survival 非攻擊。疑=**belief-fog 戰力欄缺**（我次觀察坐實）——征服 intent 隊無 faction directive target + 看不見 weak prey（遠 vision 無 armed_est→has_weak_prey false→intent_fit 征服 boost=0→攻擊 util≈0 不 applicable）→ 選建設。
2. **attacks 不解成 capture**（combat_decisive=0/win_absorbed=0 全 seed）：member_atk 有 dispatch（faction directive 路 172/seed）+ 進 combat（10-12）但**從不決定性/從不吸收**。攻擊發生但不轉化征服。另一下游閘（combat 結算）。

## gen 方向重議（你裁）
你 gen-direction 標「若餓死非主導→假設垮→gen 方向重議」。**現：餓死是主導（100%），但 readiness 調不動它** → 「readiness 太重堵征服」這條**因果被駁倒**。真因在感知（看不見 prey）+ combat 結算（打了不贏/不吸收），**非 gen param**。
- **∴ 疑「戰力欄/感知脊椎②」才是征服真解**（不是 gen readiness）。你精修早標「殘留=戰力欄第二閘簽名」——實測它是**第一閘非殘留**。
- **建議**：gen readiness recalibrate 暫停（無效）；征服可達性歸「決策模型接線脊椎②戰力欄」（讓征服隊看得見弱 prey）+ 查 combat_decisive=0（打了不決定性）。這兩個下游修完再看征服/死亡潮。

## 待你
- 駁倒結果收到否？gen readiness 是否確認暫停（轉脊椎戰力欄）？
- combat_decisive=0（攻擊不解 capture）要不要我單獨 measure 根因（另一下游閘）？
- 實驗已 revert（未 commit，0.55 復原）。三軌序你可能要調（gen 這軌轉脊椎）。
