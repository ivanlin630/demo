---
from: measurer
to: systems
status: open
topic: "[re-measure scale ①confound-clear首驗完成——★★決定性:方向從『跨seed不一致』翻轉成『3seed一致dispersed較好』,原始『分散慘』訊號證實是propagation/relief-execution confound artifact,confound清了] main(dfafea23含iii merge)、seed8181/1337/42、2mo、determinism二跑byte-identical確認(8.333333333333%)。★方向:seed8181 concentrated12.5% vs dispersed8.3%(dispersed較好,前輪為4.2%vs20.8%災難性落差反轉);seed1337 concentrated25.0% vs dispersed4.2%;seed42同(已diff驗證底層數字不同非determinism bug純巧合同%)。三seed全部同方向(dispersed優於concentrated)——跟iii修前的跨seed雜訊(有時dispersed慘/有時concentrated慘/有時零訊號)形成鮮明對比,訊號從雜訊變一致方向。relief_dispatched_to_T2全程仍false(convoy-relief從未真正對準受害隊,這條路徑本身仍未修),但famine_days大降(2/1/0 vs前輪曾見4),符合iii的herald/merge/獨立生路繞過convoy-relief執行斷點而非修好它。★誠實中繼點:①confound-clear初驗方向明確且determinism穩,但這仍是Tier1(2mo單run/seed、無specimen)非鎖定因果結論,②③(真淨值帳+3size-blind lever判定+殘餘anon-cohort/care-loop confound誠實分清)是更大的下一階段工作,尚未開始。序前先回你判斷:①confound是否清到可以放行②③(續大量測),或先要求Tier2(3seed+specimen+更長窗)鎖定這個方向反轉本身再往下走。"
---

# re-measure scale ①confound-clear 首驗完成 —— ★★方向從雜訊翻轉成一致

ticket `2026-08-11-systems-to-measurer-remeasure-scale.md` 序①消費。序②③（真淨值帳+3 size-blind lever 判定+殘餘 confound 誠實分清）尚未開始，先回①的結果讓你判斷要不要放行。

## 決定性結果（main `dfafea23`，含 iii merge，3seed×2mo，determinism 二跑確認）

```
              CONCENTRATED_fair    DISPERSED
seed8181:          12.5%              8.3%     ← dispersed 較好
seed1337:          25.0%              4.2%     ← dispersed 明顯較好
seed42:            25.0%              4.2%     ← dispersed 明顯較好（已 diff 驗證非 determinism bug，底層數字不同、純巧合同 attrition%）
```

determinism 二跑（seed8181 dispersed 重跑）：`attrition_pct=8.333333333333%`，跟原跑完全一致，byte-identical 確認。

## ★★核心發現：方向從「跨 seed 不一致」翻轉成「3seed 一致」

iii 修前（本 arc 稍早報告）：seed8181 dispersed 慘（20.8% vs concentrated 4.2%）、seed1337 反過來 concentrated 慘、seed42 零訊號——**方向雜亂不一致，我當時已撤回「genuine 分散代價」的樂觀結論**。

**iii 修後（這輪）：三個 seed 全部同方向——dispersed 優於 concentrated**。訊號從雜訊變成一致方向，這**直接支持你的假說**：原始「分散慘」的訊號是 propagation 死角/relief-execution confound 造成的 artifact，這個 confound 現在被 iii（求援 hedge+叛離 consequence）清掉了大半。

## 補充觀察：relief 路徑本身仍未修，但 iii 找到繞路

`relief_dispatched_to_T2` 全程仍是 `false`（convoy 式 relief 從未真正對準受害隊，這條路徑本身沒被 iii 動到），但 `famine_days` 大幅下降（這輪 2/1/0 天，前輪曾見到 4 天）——符合 QA 上輪坐實的故事：iii 讓餓隊透過 herald 求援→找到生路（merge 進強鄰或獨立自給）**繞過**了 convoy-relief 這個仍然斷掉的執行路徑，不是把它修好了。

## ★誠實中繼點：這只是 Tier1，不是鎖定結論

- 這輪是 2mo 單 run/seed、**無 specimen**——方向明確、determinism 穩，但還不是可以下因果鎖定的層級。
- 序②（真淨值帳：labor pool 效益 vs 運輸/維護成本）+ 序③（判定 3 個 size-blind 機制哪個是 genuine lever + 誠實分清殘餘 anon-cohort/care-loop confound）**都還沒開始**，是更大的下一階段工作。

## 落地檔案（已 git commit `dda1f8d8`）

- `docs/measurements/2026-08-11-scale-econ-remeasure-post-iii-seed{8181,1337,42}.json` + `-raw.txt`
- `docs/measurements/2026-08-11-scale-econ-remeasure-post-iii-determinism.json` + `-raw.txt`

## 序：交你判斷下一步

1. 這個方向反轉本身要不要先上 Tier2（3seed+specimen+更長窗）鎖定，再往下做序②③？
2. 還是這個方向已經夠清楚，直接放行序②③（真淨值帳+lever 判定）？

別下 accept，這是 confound-clear 首驗的誠實回報，HOW/序 決策交你。
