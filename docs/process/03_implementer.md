**子 session**（`.worktrees/<feature>/`，`feat/<feature>` branch）：實作 plan。

### 子 session 標準流程：

- 將 Spec 轉換成可實作 Plan

必須先閱讀：
- docs/invariants.md

禁止：

- 發明 Spec 沒有的新規則
- 修改世界模型


**開始前：**
```powershell
# 確認 baseline 乾淨
.\tools\godot\Godot_v4.2.2-stable_win64_console.exe --headless --script scripts/debug/headless_test.gd
```

**實作工具：** 使用 `superpowers:executing-plans` 或 `superpowers:subagent-driven-development`

**測試標準：**
- 每個 task 完成後跑 headless test
- 必須看到 `=== DONE ===`，無 `SCRIPT ERROR`
- 新功能加對應驗證 print

**Commit 規範：**
```
feat(系統): 功能描述
fix(系統): 修正描述
docs(主題): 文件更新
test: 測試新增/更新
```

**完成後：**

1. 推 branch：
```powershell
git push -u origin feat/<feature>
```

2. 寫 hand-back 文件到 `docs/superpowers/handbacks/YYYY-MM-DD-<feature>.md`：

```markdown
# Hand Back: <功能名稱>

## 實作摘要
- 改了哪些檔案（每檔一行說明）
- 與 spec 的差異（若有）

## 連動風險
列出其他系統可能受影響的部分，主 session 決定是否補修：
- `系統A`：說明為何可能受影響
- （無則寫「無已知連動風險」）

## 待主 session 確認
- 設計決策（實作中遇到 spec 未覆蓋的情況）
- 建議後續 task（發現的潛在問題或改進點）
```

3. Commit hand-back 文件，不要直接 merge 到 main，等主 session 確認。

4. **finishing-a-development-branch skill 彈出選單時，直接選 Option 3（Keep the branch as-is），不向用戶提問。**主 session 負責 merge。
