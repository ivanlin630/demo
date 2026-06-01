**主 session職責**：

brainstorm → spec → plan 設計，不實作。

主 session 職責：
- 設計 Spec
- 審核 Plan
- 確保跨系統一致性
- Merge 管理

禁止：

- 直接修改程式碼
- 為了實作方便未經同意改 Spec

**Plan 完成後，主 session 自動輸出精簡子 session 指令：**
```
在 A:\GDS\demo 的 feat/<feature> worktree 實作 docs/superpowers/plans/<plan-file>.md 的全部 Task，完成後回報結果。
```
不加額外注意事項（注意事項寫在 plan 內）。