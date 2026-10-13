# 大地圖整張看得到（合成畫面不切右半）——HOW

狀態：**依藍圖裁定 43817c7d1 簡化**（用戶：「幾列無所謂，終端 UI 只是暫時」）⇒ 固定一種版面、不做自適應與視窗退路；R² 兩輪中仍適用的部分保留
來源：藍圖 2026-10-13-blueprint-to-systems-TICKET-map-pane-clips-right-half-full-map-never-fits（第五輪用戶回饋 #3）
順位：Q 鍵、子隊輸入之後；附身隊三件之前。

## 事實（藍圖已坐實，main cc2db2d25）
- `text_map_renderer.gd:112-135`：整張地圖每列＝縮排 `"  "×(dr+R)` ＋ 每格 4 字元 ×(2R+1)；R＝8 ⇒ 68～100 欄。
- `text_ui_view.gd:118-122 box_widths()`：地圖欄＝(COLS−3)/2＝58（COLS＝120，`text_ui_layout.gd:24`）。
- `map_pages_box` 逐列 `clip_to` ⇒ 每列右側被靜默切掉。F10 的床只驗 renderer 輸出。

## 決定（HOW，systems）
### 固定版面：地圖整寬、分頁在下
- 地圖框寬＝`COLS`；分頁框寬＝`COLS`，接在地圖框下面。地圖列**不再經 `clip_to`**。
- 不做 `:size` 協定、不做並排＋視窗、不做死區（藍圖裁）。play.py 協定不動 ⇒ R² v2 ① 的鎖步風險不存在。
- 超寬（renderer 最寬列 > COLS−2，即 R ≥ 10）⇒ push_error **且**地圖框標題印「（版面異常）」（不靜默截）；不做退路。renderer 回 `{text, max_width}`，單次 render。

### 視窗不夠高／不夠寬的提示
- **由 play.py 自己判**（它讀得到 `shutil.get_terminal_size()`，server 讀不到）：每收到一屏，數 frame 行數 N 與最寬列，跟視窗列數 M、欄數比。
- 不夠 ⇒ 印「畫面需 N 列、現 M 列，請拉高視窗」（欄不足同型「需 120 欄」）。讀不到視窗大小 ⇒ 不印。
- 位置：藍圖寫「頂列」；**我改放畫面最後一列之後**——R² v2 ③：屏高不夠時終端最先捲掉的是最上面，提示放頂列會是第一個看不見的東西。已通知藍圖。

### 錨與既有床（R² §3，仍適用）
- 上下排後 `A_PAGES` 獨佔一行、`┬` 不成立 ⇒ `REGION_ANCHORS` 改新字面（只有一種版面，單一常數即可）；讀它的床同步：`terminal_selfcheck_bed:230,344`、`text_ui_layout_bed:224-232`、`ui_flow_test:3223`；「六個錨各剛好一次」跟新字面。
- 其他 `clip_to` 靜默截清單（交件信列、我判）：分頁列、`panel_block` 每列（`clip_to(COLS)`）、頂列以外各處。

## 驗收（合成後的最終畫面）
- M1（修前紅）：預設世界，地圖每列格數齊（R 從 world 讀）。
- M2（修前紅）：`@` 與游標在畫面內；游標移到最右下角也在。
- M3：分頁區——改前輸出是改後輸出的**逐列前綴**。
- M5：無任何地圖列被靜默截。
- M7：R＝10 世界 ⇒ 標題含「（版面異常）」、有 push_error。
- M8：play.py `--selfcheck` 加一格：給定 frame 行數 50、視窗 30 列 ⇒ 印提示；讀不到視窗 ⇒ 不印。
- 負對照：`box_widths` 改回左右各半 ⇒ M1 紅。
- terminal E2E、ui-flow、text_ui_layout 床照綠（錨字面同步後）。world-fp 不變。交件信寫出實量總列數。

## 範圍外
- 自適應版面、游標中心視窗（藍圖裁不做）。
- 走路逐格刷畫面（圖形介面階段）。
