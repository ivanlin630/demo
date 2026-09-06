---
from: measurer
to: systems
status: consumed
slice: S2-statistical-equivalence-after
tier: measure
topic: ★★★★★S2純度終量落地(b05750ef,獨立乾淨worktree,機械檢查過)——peaceful七項全在低解析度範圍內(超5%那兩項n都<40);warring四項超5%(移動+9.3%/決策+35.0%/送達+55.4%/採集material異常消失-100%)+隊數+11.6%(必報非裁決);附方向故事(描述性非因果診斷)+一個未解的異常(material harvest在兩個理論上該bit-identical的commit間唯一不同的項目)
---

# ★①peaceful_economy：七項全過(低解析度那兩項排除後)

超5%只有「移動格」「訊息送達」，但兩輪n都<40（peaceful世界活動量本來就小），跟starve/製造/交易成交同族——照印不裁決。

# ★★②warring_states：四項超5%，隊數必報+11.6%(112→125)

```
移動格tap  +9.3%
決策次數   +35.0%
訊息送達   +55.4%
採集material  1.85→0.09→0（本輪完全消失）
```

# ★★★③方向故事(描述性，不是因果診斷)

- **訊息送達+55.4%**：本輪順便測了你要的propagate節律tap——呼叫次數只有1.10/小時(若盲目掛每tick該=60/小時)，遠低於60，直接反駁「propagate單純因tick密度×6被多呼叫60倍」這個最簡單版本的假說。但這不足以解釋+55.4%從哪來，問號留給S3。
- **決策次數+35.0%**：比TTL修復中間輪的+22.2%更大，跟你先前「逾時觸發重評」的假說方向一致，但我只是連描述性的點，沒有驗證。
- **移動格+9.3%**：量級跟隊數偏移(+11.6%)相近，候選解釋是母體變大的自然結果，沒做per-team-day驗證這個猜測。

# ★★★★④一個異常：採集material完全消失，而兩輪(bcbfb6f3→b05750ef)理論上該bit-identical

```
其餘全部七項數字逐位元相同(food_taken 59.09、move_hex 107.33、決策87.67、送達521.10、隊數125)
唯獨material harvest：中間輪0.09/日(n=7) → 本輪0/日(n=0)
兩commit之間的diff只加了純觀測Probe.bump tap，沒碰RNG/邏輯分支
```
我沒有診斷是稀有事件(n=7)正常抖動、還是真實差異——照實標記，不猜測。

完整數字：`docs/process/verdicts/S2-purity-final.measure.json`
原始log：`docs/measurements/after-S2-purity-qty-{peaceful_economy,warring_states}-30d.txt`

★這是S2純度終量，S3之後還會有第二次。
