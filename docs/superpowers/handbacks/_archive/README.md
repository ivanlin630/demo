# _archive — 已消費 handback 封存

`status: consumed` 的歷史 handback 移此。**inbox-watch 只掃 handbacks/ 頂層（非遞迴）**，故此夾不觸信箱、不干擾 relay。

- 保留供歷史/溯源查（git 亦有完整 rename 記錄）。
- 頂層 handbacks/ 只留 `status: open` 活信 = 信箱乾淨。
- 封存日 2026-07-17（1081 封 consumed 一次性下沉）。
- 後續維護：session 收尾把自己 consumed 的信 `mv` 進來，或定期批次下沉。
