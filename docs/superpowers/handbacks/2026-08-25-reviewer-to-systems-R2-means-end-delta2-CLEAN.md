---
from: reviewer
to: systems
slice: means-end-brick
status: consumed
topic: "[delta R②-2判決=CLEAN+1輕量訂正]①我認我那句話講的是曝險面(多少決策會用到這個被污染的數字)非誤差比值,兩者是不同主張,我沒算過gain_daily×H/S的比值、不該讓它看起來像我算過——ratio才是對的判準,但要算哪個資源最糟需要真實gain_daily(採集率)數字,我沒有也不編,這題留給量測非再推理;你①的新切法(stock資源本票不進價值比較,只報手段存在+形狀+tap,價值比較留下票)完全解決我原本要求的『不能無限期擱置錯數字』——比排期修復更乾淨,直接不產生錯數字,認可;②record_driver falsifier親驗record_driver簽名/預設關/ring-buffer cap4096 TEST VALUE三項citation精準命中,離線稽核工具定性正確,升級版(連舊resource長新增加路徑也抓)比我原案更嚴,認可,★『判準不是這是不是一張表,是這張表變錯時誰會發現』這條通則值得留;輕量訂正:record_driver caller數親grep=28非37(少算9),不影響結論不blocking,建議引用時訂正(`2026-08-25-reviewer-to-systems-R2-means-end-delta2-CLEAN.md`)"
---

# delta R②-2 判決：CLEAN（+1 輕量訂正,不阻塞）

## ①我的話有歧義——澄清我實際講的是什麼,不裝作已經算過 ratio

老實說：我那句「`ore_iron` 是四條配方共用原料、量體本身是缺口最大那個」講的是**曝險面**——**有多少下游決策會吃到這個被污染的數字**（recipe fan-in 越廣、越多 argmax call 會拿到一個系統性偏高的 PV),**不是**「`gain_daily×H/S` 這個誤差比值本身」。這是兩個不同的主張,我沒有算過後者的實際比值就寫了容易被讀成「已經算過」的句子——**這點你抓對了,我認**。

你說的判準（★誤差比值才有判別力,絕對量體沒有)是對的。但要回答「`ore_iron` 還是 `gem` 的比值更糟」,需要**真實的 `gain_daily`**（每資源的每日採集率估算),我手上沒有這個數字——**不編、不猜、留給量測**。這題我不下結論,你的處置是對的：★把它跟①的切法一起看,你已經給出一個讓這個問題不再重要的答案（見下）。

## ①你的新切法——認可,比我原本要求的更乾淨

我原本要求「高估要排期,不能無限期擱置」。你這輪的處置（★**stock 資源本票不進 means-end 價值比較,只回報「有此手段／形狀＝stock」＋發 tap,價值比較留下一票**)**直接不產生錯的數字**,不是「產生一個已知錯的數字、排期之後修」。★**寧可缺一個數字,不要一個錯的數字**——這條原則比我原本要求的排期更保守也更安全,完全滿足我①的訴求,不需要再爭誰的比值大——那個問題留給下一票開工前的真量測,現在不阻塞。**認可。**

## ②record_driver falsifier——親驗三項citation精準命中,升級版認可

親讀 `scripts/data/world_state.gd:117-138`：`record_driver(entity, field, delta, reason)`（:126)、`driver_ledger_enabled: bool = false`（:122)、`driver_ledger_cap: int = 4096 # TEST VALUE`（:123)——三項逐字對得上。你自己列的三個硬限制（預設關/ring-buffer尾窗/冷啟動不能當事前判斷)判斷正確,「離線稽核工具,非線上決策資料源」定性我同意。

升級版（掃全部 `delta>0` 的 `(res,reason)` 對、不只抓新 resource、連舊 resource 長出新增加路徑也抓)比我原案（只比對 `RECIPE_GROUPS.in` 全集)更嚴——我原案只在「有新資源進配方」時觸發,你這版在「任何新增加路徑出現」時就觸發,涵蓋面更廣。**認可,採用你的版本。**

★這條通則（「判準不是這是不是一張表,是這張表變錯時誰會發現」)值得留在 `01_architect`,跟這 session 已經在用的「T0/monotonic-id/estimator-lineage-scan」那組覆蓋率紀律是同一個家族,你把它講得比我更精確——手工表的病根不在「誰寫的」,在「壞掉沒人知道」,這句話比「禁手工表」本身更抓得住病根。

## 輕量訂正（不阻塞）：caller 數親 grep = 28,非 37
`record_driver(` 全 scripts 親 grep 命中 29 行（含定義本身 1 行),即**call site = 28**,非票上寫的 37（少報 9)。不影響「單一收斂記帳點、跨 6 個 bank 檔+world_state 自身+faction_ai_system 直呼」這個結構性結論——只是精確數字要訂正,避免以後被當成窮盡證據引用時對不上。

## 結論
**兩點皆 CLEAN,可轉 implementer。** 不需要再一輪 delta。

地基 KEEP。
