---
from: implementer
to: reviewer
status: consumed
slice: 未加種子的閘床
topic: ★R² 請審 `feat/unseeded-beds` ＝ `739d4ffbe`｜★★★**而最值得打的是我的【比對母體】**：第一輪我把三張床全判成「加了 seed 還是不穩」，而真相是我沒扣掉時間數字 —— 請確認我現在扣的那組【不多不少】｜★反向驗有一支回答「種子對它沒作用」，我沒有把它當成綠
---

# ★一、做了什麼

```
三張床（agent_verbs_c1_bed／merchant_turnover_test／phase_root_conservation_bed）
加 `seed(BED_SEED, 預設 1337)`，★env 名【三張統一】—— 不是每床一個名
```

# ★★★二、請優先打這三處

```
①【比對母體】：我扣掉 [TickPerf]／[PhaseSpike]／[FaiPhase]／wrapper 噪音／一次性 --import 輸出
   ★問：有沒有【不該扣的】被我扣掉了？★★扣太多 ⇒ 這個 5 跑比對會變成恆綠
   —— 而它是本票唯一的兜底，扣過頭等於本票沒有守衛
②【agent_verbs 的反向驗】：1337 與 9999 的輸出【完全相同】
   ⇒ ★我寫成「種子對它沒作用、今天保護它的是它自己不隨機」而不是「穩定 ⇒ 過」
   ★★問：這個判讀對嗎？還是它其實有一條路徑吃 RNG 而我的母體剛好看不到？
③【zhagen_controlled_bed 我沒動它】：5 跑逐位元相同 ⇒ 經驗層判 STABLE
   ★★★問：spec 說它歸經驗層【不預先判它零風險】—— 我只跑了 5 次就收手，夠嗎？
```

# ★★三、實測數字（★四張床都貼，含我沒動的那張）

```
床                              1337 五跑     9999      判讀
agent_verbs_c1_bed              1 個指紋      ★相同     穩定但【種子無作用】
merchant_turnover_test          1 個指紋      不同      ✔種子有效
phase_root_conservation_bed     1 個指紋      不同      ✔種子有效
zhagen_controlled_bed           1 個指紋      －        穩定（未做反向，未動）
```

# 四、誠實限

```
★全電池【沒跑】—— 這張票只動三支 debug 床、未動 production，而我想先聽你對①的判斷
  （★★若母體扣錯，跑電池也證明不了這張票）
★★★而我第一輪的錯【留在 commit 訊息與 code 註解裡】，沒有清掉 —— 下一個人會犯同樣的
```
