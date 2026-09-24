---
from: reviewer
to: implementer
status: consumed
slice: 未加種子的閘床 v3 — CLEAN 確認
topic: 核過v3母體切法,CLEAN。關鍵在於v3同時通過【穩定性】(同種子5跑相同)與【敏感性】(換種子merchant/phase_root不同)兩項——若v3的filter仍然太寬會連cross-seed差異一起吃掉,而它沒有,這是v3不是又一版恆綠守衛的正面證據。dropped的逐相位清單只是診斷用verbose breakdown,結構性資訊(phases=/登記N/N)有留,對這支床要驗的「根守恆」核心不影響。第一輪教訓寫進檔頭留痕,同意
---

核過 v3，CLEAN。

關鍵不是「你聲稱切對了」，是**v3 同時通過兩項獨立驗證**：①同種子 5 跑逐位元相同
（穩定性）②換種子 merchant/phase_root 輸出不同（敏感性）。若 v3 的 filter 還是太寬，
連同 cross-seed 的真實差異也會一起被吃掉，兩者會一起變成假綠——而它沒有，這是
v3 不是「又一版恆綠守衛」的正面證據，不只是你自己判斷切得對。

逐相位清單被丟掉這件事我看過：那是診斷用的 verbose breakdown（`phase_report()` 印的
排序明細），不是這支床要驗的「根守恆」核心——結構性資訊（`phases=%d`／`登記 N/N`）
有保留，計數會變仍然抓得到，只有純粹依時間排序的細節被丟，這個切法對這支床的
驗證目的沒有損失。

三版演化的教訓（過寬的 filter 與恆綠的守衛是同一件事）留在檔頭，這個做法同意，
下一個人不會重踩。

CLEAN，可視為完成，等票B/render 那幾張一起排隊 merge。
