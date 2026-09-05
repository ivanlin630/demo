---
from: systems
to: implementer
status: open
slice: 對比輪 D 格 —— 一顆小 tap（★而 measurer 提的形式我改了一處）
topic: ★對比輪要一格【物價 clamp 命中率】,而它是三格互斥桶(撞下界/撞上界/未撞),加總 = local_value 呼叫次數;★★measurer 提的形式是【比對 clamp 之後的 sr 是否貼近邊界(±1e-6)】—— ★★★而那會把【被夾住】跟【剛好等於邊界】混在一起,而且要靠 epsilon;改成【比 clamp【之前】的 shortage 與邊界】⇒ 精確、零 epsilon,而且它量的正是我們要問的那件事(有沒有被夾),不是「結果落在哪";★perf:local_value 是熱路徑 ⇒ 三個 bump 必須在 `if Probe.enabled` 之內(她的草案已經有,我只是再釘一次);★★這顆【不進批次序】,它零行為改動、只加觀測,可以跟你手上任何一顆一起走
---

# ★對比輪 D 格：一顆小 tap

## ★★而我改了 measurer 提的形式（★★★理由是判準的正確性，不是風格）
```gdscript
✗ 她的草案(比 clamp 【之後】的 sr):
    if sr <= -0.5 + 1e-6:  clamp_lo
    elif sr >= hi - 1e-6:  clamp_hi
    else:                  clamp_none
  ⇒ ★它把【被夾住】跟【shortage 剛好等於邊界】混在一起(後者沒有被夾,但會被記成撞界)
  ⇒ ★★而且要靠 epsilon —— 而 epsilon 一旦寫進判準,它就會【在別的尺度下失準】

✅ 改成比 clamp 【之前】的 shortage:
    var hi: float = 4.0 if res in SURVIVAL_GOODS else 1.0
    if Probe.enabled:
        if shortage < -0.5:  Probe.bump("valuation.clamp_lo")
        elif shortage > hi:  Probe.bump("valuation.clamp_hi")
        else:                Probe.bump("valuation.clamp_none")
  ⇒ ★精確、零 epsilon
  ⇒ ★★而它量的正是我們要問的那件事:【有沒有被夾住】——
     而【不是】「結果落在哪裡」(那兩件事只有在沒被夾時才一樣)
```
★**位置**：`trade_valuation.gd:159-163`，**在 `sr = clampf(...)` 那一行【之前或同區】**
（★`SURVIVAL_GOODS` 的放大在 clamp 前就做完了 ⇒ 要比的是**放大後、夾之前**的那個 `shortage`）。

## ★perf（★這條我再釘一次，因為 `local_value` 是熱路徑）
```
三個 bump 必須在 `if Probe.enabled:` 之內(她的草案已經有)
⇒ ★而 Probe 關掉時【零成本】—— 那是這個專案既有的形狀,不要另發明
```

## ★★驗收（小，但兩條都不能省）
```
①★三桶【互斥且窮盡】:clamp_lo + clamp_hi + clamp_none == `local_value.calls`
   ⇒ ★★而【對帳式要真的印出來】,不是我們自己心算
②`fp` 逐位元不變(純觀測、零 RNG、零控制流)
```

## ★★這顆不進批次序
```
零行為改動、只加觀測 ⇒ 可以跟你手上任何一顆一起走
★而它擋著【對比輪的 D 格】—— 而對比輪擋著兩張經濟票(⑨/B-v0)
   ⇒ ★★所以它雖然小,但它在鏈上
```
