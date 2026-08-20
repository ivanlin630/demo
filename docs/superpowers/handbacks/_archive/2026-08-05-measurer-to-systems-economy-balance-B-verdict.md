---
from: measurer
to: systems
status: consumed
topic: "補完批(B)economy-balance verdict:★★population觸底不回升=mechanism gap非tuning(blueprint疑對)——2個獨立fixture交叉驗證:rep床T5食物day14-33連續20天穩定正值(12-25區間)pop仍鎖死=2從未回升;T1-confirm(20a7d8ef)床T1食物day44-49連續6天穩定6-7.3 pop同樣鎖死=2從未回升——兩個不同config/不同resident/不同時間窗,同款『食物穩定充足≥6-20天,population仍0恢復』,讀作真無population-recovery通路非relief量級/timing問題(若只是tuning,充足期夠長該有訊號,兩案例都沒有)。①relief量級/頻率(rep床45天窗):distribute.dispatch=3次(~每15天1次)/food_delivered=64.0(45天均攤約1.4/天,對pop2resident剛好在1.6/天基本消耗線附近,量級屬邊緣夠用非寬裕)②timing:首2次注入約day5+day14落地,day12 pop已先觸底(注入來得及穩住食物但來不及在觸底前介入,relief在population已跌到底之後才追上food)③餓死底線confirm:pop2是這整條arc(含T1/T3/T5三隻獨立resident,三個不同config)全數收斂的統一下限,無例外。★method聲明:本輪嘗試逐tick cargo-delta抓取『真deposit時刻』方法不準(混進porter在途小額cargo耗損雜訊,13筆多為OUTBOUND階段0.3-0.7小額非真settle),已誠實標註取而代之改用日food曲線大跳點+aggregate Probe數對照,不精確到秒但方向可信。純觀測未新建bed-tuning-for-narrative(用既有rep床原生45天窗,未壓起義取更長)。別下accept，population-recovery mechanism gap是否列入known issue/是否需要新機制(如breed/immigrate)交systems/blueprint判"
---

# 補完批 (B) economy-balance：population 觸底不回升 = ★mechanism gap（非 tuning）

## 窗

用既有 rep 床 `config/infonet_faction_rich_rep.json`（未壓 uprising、未 bed-tuning-for-narrative），跑 45 天（T5 day42 起義離場前）。純觀測，temp 探針（`infonet_econ_balance_probe.gd`）已刪除（本輪未要求 persist）。

## ★★核心發現：population 觸底不回升，兩個獨立 fixture 交叉印證

**blueprint 疑「pop 觸底不回升可能不只 tuning、population 恢復機制」——本輪證據支持這個懷疑，讀作 mechanism gap。**

**rep 床 T5**：day14 起食物穩定回正（day14-33 連續 **20 天** 維持 12-25 區間的健康水位），population 全程鎖死在 **2**，**一次都沒回升**。

**交叉驗證（既有 T1-confirm 床 `20a7d8ef`，另一獨立 config/另一 resident）**：day44-49 連續 6 天食物穩定 6-7.3，population 同樣鎖死在 **2**，也**一次都沒回升**。

**兩個完全不同的 config、不同的 resident、不同的時間窗，同款「食物穩定充足達 6-20 天、population 仍零恢復」**——若只是「relief 量級不夠/timing 太晚」的 tuning 問題，充足期拉這麼長本該看到至少一次回升訊號，兩案例都沒有。**讀作真的沒有 population-recovery 通路，不是 relief 沒調好**。（純觀察現象比對，未讀 population-growth/breed 相關 code 確認根因，交你們判斷是否要查 breed/immigrate 機制存在與否。）

## ①relief 量級（rep 床 45 天窗）

```
distribute.dispatch=3 distribute.deliver(settle)=6 food_delivered=64.0
```
- 45 天內僅 **3 次** dispatch（約每 15 天 1 次），總送達 64.0，均攤約 **1.4/天**。
- T5 pop=2 時基本消耗約 `2 × FOOD_PER_PERSON_PER_DAY(0.8) = 1.6/天`——均攤 relief 量**剛好落在基本消耗線邊緣**（1.4<1.6），量級屬「勉強夠用、非寬裕」，這也符合前幾輪看到的「間歇撐命非穩定復甦」整體印象。

## ②relief timing

- T5 pop 在 **day12** 就已觸底到 2（首次觸底 tick=3100）。
- 前兩次可辨識的大幅食物回升點約在 **day5**（0→22.7）與 **day14**（0→18）——**day14 那次落地時，population 已經觸底 2 天了**——relief 趕得及穩住食物（之後 20 天食物健康），但**趕不及在population 觸底前介入**。

## ③餓死底線 confirm

- pop=2 是整個 arc（含 T1/T3/T5 三隻獨立 resident、三個完全不同的 config：`infonet_whole.json` 兩隻 + `infonet_faction_rich_rep.json` 一隻）**全數收斂的統一下限，無一例外**——讀作系統性底線非個案巧合。

## ★method 誠實聲明

本輪原打算逐 tick 追蹤 convoy cargo 精確掉量時刻（定位「真 deposit」發生的準確 tick），但偵測邏輯不夠精確——13 筆記錄多半是 `OUTBOUND` 階段的小額（0.3-0.7）耗損雜訊，非真正的 settle 事件（真 settle 應是單次大幅掉量，本輪方法未能可靠抓到）。**改用「日 food 曲線大跳點」+ 既有 aggregate Probe 數（dispatch/settle/food_delivered）對照**——精確到「哪一天」而非「哪一 tick」，方向可信但不到秒級精度，如實聲明方法侷限。

## 落地檔案（已 ls/wc 驗證存在）

- `docs/measurements/2026-08-05-infonet-econ-balance-probe.txt`（1564行，含 T5 逐日曲線+cargo-delta嘗試記錄+population恢復檢查）
- `docs/measurements/2026-08-05-infonet-econ-balance-diagnostic.json`（420行，結構化dump）
- 交叉引用（既有已landed）：`docs/measurements/2026-08-05-infonet-t1confirm-20a7d8ef.txt`

## 清理狀態

- temp `infonet_econ_balance_probe.gd` 已刪除（未要求persist，跟phase(A)的rep床本身不同）。
- rep 床本身（`config/infonet_faction_rich_rep.json`+`infonet_faction_rich_rep_bed.gd`）維持上輪persist狀態不動。

## ★誠實淨判

- **relief 量級**：邊緣夠用（均攤略低於基本消耗線），非寬裕。
- **timing**：能穩住食物但趕不及在 population 觸底前介入。
- **population 恢復**：★★兩獨立 fixture 交叉證實「食物穩定充足很久仍零恢復」——讀作 **mechanism gap**（無 population-recovery 通路），非單純 relief tuning 問題。

別下 accept。population-recovery mechanism gap 是否正式列 known issue、是否需要新機制（breed/immigrate/其他）填補，交你們/blueprint 判。
