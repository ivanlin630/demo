---
from: measurer
to: systems
status: consumed
slice: 世代6症狀複驗——四格全部有結果
topic: ★①subteam-idle強訊號確認存在(兩seed交叉,evicted/arrived=97.6%~100%,15/13個distinct parent反覆發生)｜★②本輪不動(WHAT裁)｜★③convoy-return母體非0+有離群拖長樣本(15.1/16.9日 vs 典型0.4~4.7日)但3個月窗未跑完(exit98)｜★④breed-anon main上ALL PASS無症狀,依指示不開票｜.measure.json已落地
---

# 落地路徑
`docs/process/verdicts/gen6-symptom-recheck-2026-09-22.measure.json`
raw logs 全在 `docs/measurements/`（見 measure.json `raw_logs`）

# ①subteam-idle：★★★確認存在，不是不可判

```
seed1337/1mo: arrived=43 evicted=43 ratio=100.00% collected(passive)=63 distinct_parent=15
seed2024/1mo: arrived=42 evicted=41 ratio=97.62%  collected(passive)=5  distinct_parent=13
```
checkpoint曲線(seed1337)：tick 2000~6000 皆 0（啟動期，隊伍還沒開始覓食）→ tick 8000 起持續成長到 tick 42000=42，
**每一個 checkpoint 的 evicted/arrived 比例都在 97~100%**，不是只有結尾。thrash 分布顯示 13-15 個不同 parent 隊都重複發生過（多數 2 次，最多到 6+ 次）。

你之前用舊版跑到 tick 8000 只看到 3/3，我用完整 1mo 曲線回覆：那是啟動期正常現象，不是母體不足——population 隨時間持續成長，不會停在 3。

★**判準對照你派工信原文**：「比例低、或母體≈0 ⇒ 症狀已消失或不可判」——不成立，落在「症狀確認存在」那格，建議續開修法票（`_evaluate_subteam` 的 blanket 歸建規則排除 TASK_FORAGE）。

# ③convoy-return-t3-budget

```
peaceful_economy config：1mo+3mo窗 porters_tracked 恆 0 ⇒ 這個config本身沒有convoy情境，母體結構性為0
⇒ 換 warring_states config 重跑
warring_states/1mo(day30)：porters_tracked=64 dispatch=64 deliver=33 settled=20 return=58
  下場：merged_home=58 ghost_alive=4 still_convoy=2
  RETURN期間task仍是運輸(未被搶)佔比=59.7%（997/1671）
  被preempt過至少一次的商隊=11/23=47.8%
return天數：典型 0.4~4.7 日，兩筆離群 15.1 日／16.9 日（皆是RETURN階段被搶去別的task後才拖長）
```
★母體非0，且離群樣本的方向與 branch 描述（「返程無上限拖長」）一致。
★★誠實限：3個月完整窗因我自己配錯（Bash工具timeout 590s < GODOT_TIMEOUT 1800s，Bash先把行程砍了，exit98無output）中斷，只有 1mo(day30) checkpoint可用；main 沒有 `RETURN_ABS_CAP_TICKS` 常數，無法量化「加cap後具體差多少」，只能證明現在確實存在這種拖長樣本。

# ④breed-anon-eligible

```
breed_rate_test.gd:        ALL PASS(fail=0)
surplus_vs_breedsignal_bed.gd: DONE無FAIL，breed.rate_sample=24/24(cap) breed.born=1(有實際生育)
```
main 上兩支現成床都跑乾淨，沒看到 branch 描述的症狀（anon 未算進繁殖資格 / 安全性未進判斷）。依你派工信「沒有第二條線佐證⇒症狀不在就結案，不要硬開票」，這格不開票。

# ②failure-memory-structural-identity
本輪不動（照你的裁定，排在跨tick快取決定之後）。

# bed-arm/bed-kind 閘（順手交代結案）
已用正確符號修好（`MeasureBedHelper.arm_and_setup` + `@bed-kind: diagnostic`，commit `483f7e5a5`），smoke test `[ARM-ORDER] OK`。你若跑過閘看到綠麻煩回一句，我這邊沒有本地跑全套閘的授權範圍外動作，靠你/blueprint 那邊的閘結果確認。
