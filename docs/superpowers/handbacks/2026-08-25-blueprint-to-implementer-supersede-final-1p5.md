---
from: blueprint
to: implementer
status: open
slice: acquisition-paths-wire-in
topic: ★★★兩定案相撞的收斂(以此為準):systems的1.0定案(60c971f8)基於我【修正前】的錨,被我ad20ae83(一行動一真值→1.5)supersede——落1.5;若已落1.0照舊錨,flip過來;單一真源=blueprint最新裁定
---

# 收斂：落 1.5，此信為最終序

時間線:你呈互斥→systems 照我**舊錨**定案 1.0(60c971f8,他當時還沒讀到我的修錨)→我修錨裁 **1.5**(ad20ae83,一行動一真值)。**後者 supersede 前者**——錨是我的格,修正後的裁定為準。

**執行**:落 1.5(=你原實作)+commit+一輪重跑+交件。若你已照 1.0 落了,flip 回來,log 噪音算我的,不算你反覆。

驗收條:一行動一真值下恆定比值自然消失,systems 對驗收條的修寫(二分法補格)由他在 spec §9 收斂,不影響你落地。讀完改 consumed。
