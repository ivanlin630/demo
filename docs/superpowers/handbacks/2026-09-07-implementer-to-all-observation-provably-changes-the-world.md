---
from: implementer
to: all
status: open
topic: ★★★**機械證據：呼叫 `gather` 去觀測，會改變世界** —— 同種子 A/B 的 `fp` **不同**｜★★而誠實限跟結論一起走：這證明**機制存在且有 fp 級後果**，**不等於**量出了 `a4_rout_witness_bed` 實際的擾動大小
---

# 一、★結果
```
warring_states 20 日、seed 1337、a4 的觀測動作鏡射（每天對隊呼 gather 讀 threat_react）
   A（不觀測）        fp = 7f83b4875ef1248874f1d5bfd555cf3b
   B（每天 gather 全隊）fp = a652923e4b414b78609cf6a37d632910
⇒ ★★★不同。而 fp 是【機械的】——我沒有挑欄位（挑就會挑到我猜的那些）。
產物：docs/measurements/2026-09-07-gather-purity-fp.txt
床　：scripts/debug/gather_observation_purity_bed.gd（★未註冊，要不要常設 systems 判）
```

# 二、★★而讀法我在**跑之前**就寫死了，★兩個方向都寫
```
fp 相同 ⇒ 只說【那些寫入沒有在 fp 上顯現】，★不等於 gather 是純讀
         （七處裡三個是 cadence 欄位，而 fingerprint 未必涵蓋它們）
fp 不同 ⇒ 機械證據
★★沒有先寫死的話，「相同」很容易被讀成「所以沒事」——
  ★★★而今天一整天的病就是【沒有訊號被讀成沒有事情發生】。
```

# 三、★★★誠實限（★寫進床的檔頭，跟結論一起走）
```
★我的 B 輪對【全部】隊呼 gather；`a4_rout_witness_bed` 只對【半徑內】的隊呼
⇒ ★★本床證明【機制存在、且有 fp 級後果】
⇒ ★★★它【沒有】量出那支床實際的擾動大小 —— 兩件事不要混
⇒ 所以我【仍然沒有】判 T-A4 那份數字作廢：那需要量
  【延後評估對 `threat_react` 有沒有影響】，而那是另一個對照。
```

# 四、★我沒有做的事（★邊界）
```
★沒有改 `gather` —— 決策層所有權在 systems，而快取存廢是【設計選擇】
★★沒有動 measurer 的床 —— 我自己造了一支等價的
★★★沒有把那支床註冊成常設閘 —— 擴大 merge-gate 集合是排程決定
```
