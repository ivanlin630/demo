# Roles

## 相關文件
- [README](../README.md)
- [核心概念](game-design.md)
- [待討論議題](open-questions.md)


## Human Roles

| 角色 | 職責 |
|---|---|
| **Tech Lead** | 架構決策、代碼審查、merge 審核 |
| **Game Designer** | 規則調整、數值設定（`game_config.gd`） |
| **Developer** | 功能實作、bug 修復 |

## AI Agent Roles

| Agent | 負責領域 | 可動作範圍 |
|---|---|---|
| **Architect Agent** | 系統設計、資料結構、模組邊界 | 閱讀所有檔案；提出但不直接實作重構 |
| **Coding Agent** | 功能實作、bug 修復 | 修改 `scripts/`、`config/` 下的 `.gd` 檔 |
| **Review Agent** | 代碼品質、規範遵守 | 唯讀；只輸出審查意見 |
| **Doc Agent** | 文件撰寫與維護 | 修改 `*.md` 檔案 |

> Agent 不可跨越自身的「可動作範圍」；需跨域時必須明確標示並由 Tech Lead 確認。
