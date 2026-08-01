---
from: reviewer
to: systems
status: consumed
topic: "[R②融合驗CLEAN] 乙完整REVERT——親讀`git show b65a9692:terms.gd`確認absorb_drive/join_drive逐字回到我自己最早直接讀過的原始公式(非信commit msg轉述)，4個crank常數真刪除非隱藏，genuine核心(resource_slack/yield_pos)行級一致；順帶承認：0.104低util原來是engine對「小團yield真值低」的正確計算非bug，我自己前兩輪審查沒有深挖這層框架問題，這次用戶戳破的判斷我認"
---

# R②判決（融合驗）：乙完整 REVERT crank → genuine baseline — CLEAN → merge

親讀`git show b65a9692:scripts/simulation/decision/terms.gd`實際檔案內容（非只看diff、非只信commit message），逐條核對。

## absorb_drive——逐字比對我自己最早的直接讀取記錄，完全一致
```
var amb_gap: float = clampf(float(ctx.ambition_gap) * 0.3, 0.0, 1.0)
var yield_pos: float = clampf(ctx.absorb_yield, 0.0, 1.0)
return ABSORB_DRIVE_BASE * ctx.resource_slack * (0.5 + 0.5 * yield_pos) * (0.5 + 0.5 * amb_gap)
```
這一字不差對上我**在乙整併util boost HOW那輪R②親自讀取terms.gd:224-230的原始記錄**（boost開工前）。`ABSORB_DRIVE_BASE_V2`/`AMB_GAIN`兩個crank常數在檔案裡完全找不到，不是被comment掉，是真的整個宣告都不見了。

## join_drive——同樣逐字比對，完全一致
`return clampf(0.5+ctx.best_protector_rep*REP_MAGNET_W*0.5,0.0,1.0)`——跟我最早讀`terms.gd:134`的記錄一致，`JOIN_PROTECT_GAIN`/`JOIN_DRIVE_CAP`常數+protection urgency那段全部消失，不是殘留隱藏。

## genuine核心——`resource_slack`/`yield_pos`行級比對，未受牽連
這兩個變數的計算行在boost前、boost後、revert後三個時間點我都讀過，文字完全相同，確認revert沒有連帶動到不該動的地方。

## ★老實話：這次revert暴露我自己前兩輪審查的一個盲點
commit inline comment寫「用戶戳破+blueprint令：引擎0.104算對(小團yield真值低=隊不吸=理性)；真root=規模經濟未模型化(genuine finding)非tuning」——這代表原本「決策層util-starvation」的診斷框架本身有問題：0.104這個低值不是公式壞掉，是engine在**沒有規模經濟機制**的現況下，如實算出「吸收一個小隊沒什麼實質收益」，這是誠實的低分非錯誤的低分。我前兩輪審查驗證了「公式跟citation對得上」「改動是鬆綁常數非疊補丁」，但沒有往上一層去問「這個低util本身是不是其實算對了」——這層框架問題是用戶直接看出來的，不是我或systems的既有流程抓到的。

這次revert我認，沒有異議——這是我自己上一輪沒問到位的問題，這輪只需要確認revert本身乾淨，我已經逐行核對過，沒有殘留、沒有誤傷。

## 判決
**CLEAN → merge（main回誠實genuine baseline）。** revert exact、genuine核心未動、determinism/不凍數字（跟你附的驗證一致）沒有理由懷疑。日後若「規模真的該matter」要走genuine建模路徑(WHAT層先定案為什麼大隊該更值錢)，非回頭調arbitrary係數讓option硬fire。
