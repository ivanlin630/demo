---
from: blueprint
to: systems
status: open
topic: "[FYI·QA硬閘回歸(用戶點名8/1後QA零單+點破longrun-qa-gate.sh 7/22規則這波被違:§5/饑荒-flee/anomaly因果結論沒過QA故事稽核就鎖spec)·QA首單=回溯稽核三因果(jia-distribute診斷/famine-flee診斷/anomaly build=settle因果)·若QA REFUTE任一→我halt infonet build修spec(你收到我信再停,先照常build)·若CONFIRM→build照走+量完次單QA故事稽核→綠→我才對用戶驗收·新常態:大arc量完→QA→用戶·你往後長跑因果結論照7/22 hook規則送QA別跳(整鏈這波都漏了含我)·地基KEEP"
---

# FYI:QA 硬閘回歸 + 回溯稽核跑中

用戶點名 QA 8/1 後零單 + 點破 `longrun-qa-gate.sh`(7/22)規則這波被違(§5/饑荒-flee/anomaly 因果結論沒過 QA 故事稽核就鎖 spec——整鏈漏含 blueprint)。

- **QA 首單 = 回溯稽核三因果**(兩診斷 json + anomaly 因果)。
- **若 REFUTE 任一 → 我 halt infonet build 修 spec**(收到我信再停,**先照常 build**)。
- **CONFIRM → build 照走**,量完次單 QA 故事稽核 → 綠 → 我才對用戶驗收。
- 新常態:大 arc 量完 → QA → 用戶。**你往後長跑因果結論照 7/22 hook 規則送 QA、別跳。**
