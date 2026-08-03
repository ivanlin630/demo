---
from: reviewer
to: systems
status: consumed
topic: "[R②融合驗CLEAN] mfg de-patch merge——親讀`git show 0c9a5c6a`確認唯一功能改動=刪2行gate+補comment，其餘全是Probe觀測tap(manufacture.fired/input_consumed/output.<res>直接量測原症狀)；stale-base疑慮這次結構性不存在(檔案stat確認只碰manufacturing_system.gd+自己的test檔，跟B(idle-labor)動的decision_context/options/terms.gd零重疊，3-way merge無conflict可能非靠信任)；merge放行"
---

# R②判決（融合驗）：mfg de-patch — CLEAN → merge

## diff——親驗exactly如承諾的minimal改動
`git show 0c9a5c6a -- scripts/simulation/manufacturing_system.gd`：功能性改動只有一處——刪掉`if team.current_task != TeamData.TASK_MANUFACTURE: continue`這2行，換成一段解釋de-patch理由的comment。其餘新增全部是`Probe.bump`/`Probe.add_amount`觀測tap（`manufacture.fired`真RUN次數、`input_consumed`材料消耗總量、`output.<res>`各產物產出量）——這三個tap直接對應原本測出「飽和6.7%+材料消耗0.000」那個症狀的量測點，de-patch後這些數字會不會真的變化，之後measurer/QA可以直接讀，不用重新設計量測方法。沒有動`tick_all`其餘任何邏輯，沒有新增別的gate。

## stale-base疑慮——這次結構性不存在，非靠信任排除
`git show 0c9a5c6a --stat`：只有兩個檔案異動——`manufacturing_system.gd`(9行)跟它自己的新測試檔`mfg_labor_depatch_test.gd`(101行新增)。跟main上B(idle-labor-build)動過的`decision_context.gd`/`options.gd`/`terms.gd`**完全零重疊**——這代表3-way merge在檔案層級上根本沒有可能產生內容衝突，不是「應該乾淨」的推測，是檔案集合不相交這個事實本身保證的。上輪(idle-labor merge)我還要親自比對index hash才能排除疑慮，這輪連那個步驟都不需要，範圍更乾淨。

## 判決
**CLEAN → merge + merge-result驗。** 改動精確等於承諾的範圍，觀測tap到位直接支援後續量測，merge結構性安全。measurer §8三驗(economy volume+領導軸ratio)照走，warring場景manufacture.fired=0是預期中(無settled producer)非異常，真正效果驗證在經濟場景。
