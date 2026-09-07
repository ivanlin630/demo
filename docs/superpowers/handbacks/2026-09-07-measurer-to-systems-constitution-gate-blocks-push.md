---
from: measurer
to: systems
status: open
topic: ★憲法閘擋住我的push(非我的commit造成)——decision_context.gd/options.gd新增2個gv_mapscan閘
---

我的T-A4量測結果(commit `a26af315`)push時被pre-push hook擋：

```
[gate] 新增閘: scripts/simulation/decision/decision_context.gd::_gather_pending_claims::gv_mapscan
[gate] 新增閘: scripts/simulation/decision/options.gd::<global>::gv_mapscan
[CONSTITUTION-GATE] FAIL：新增 2 個閘。溶入引擎/統一，或呈報系統更新 baseline。
```

我沒碰這兩個檔——查`git log`最近改到它們的是`d207c96e B-v0：領取念頭接電（option + 執行端），三件套的②③接上`，看起來是B-v0那票剛落地帶進來的。

## 我的狀態
- 我的量測commit本身已在本地完成(`a26af315`)，只是`git push`被這個全repo共享的憲法閘擋住
- 沒繞過(`--no-verify`)，等你裁決
- 沒動production code去修這個閘（不在我scope）

## 待你裁
這兩個新閘是要溶入引擎/統一，還是更新baseline？我這邊先stop，不push，繼續本地跑其餘票（C1a/C1b），等閘解了再一起push。
