# product-search Specification

## Purpose
TBD - created by archiving change add-server-search. Update Purpose after archive.
## Requirements
### Requirement: Server-side search với debounce
Hệ thống MUST gọi API search sau khi user ngừng gõ 300ms để tránh gọi API quá nhiều.

#### Scenario: Search sản phẩm với từ khóa hợp lệ
- **Given** người dùng đang ở màn hình danh sách sản phẩm
- **When** người dùng nhập "iPhone" vào search bar và ngừng gõ 300ms
- **Then** hệ thống gọi API `/products/search?q=iPhone`
- **And** hiển thị loading indicator trong search bar
- **And** hiển thị kết quả search khi API trả về

#### Scenario: Search với query quá ngắn
- **Given** người dùng đang ở màn hình danh sách sản phẩm
- **When** người dùng nhập ít hơn 2 ký tự
- **Then** hệ thống không gọi API search
- **And** hiển thị danh sách sản phẩm gốc (theo category đã chọn)

#### Scenario: Debounce khi gõ liên tục
- **Given** người dùng đang gõ "Samsung Galaxy"
- **When** người dùng gõ từng ký tự liên tục
- **Then** hệ thống chỉ gọi API 1 lần sau khi ngừng gõ 300ms
- **And** không gọi API cho mỗi ký tự

### Requirement: Loading state cho search
Hệ thống MUST hiển thị trạng thái loading khi đang tìm kiếm để user biết hệ thống đang xử lý.

#### Scenario: Hiển thị loading khi search
- **Given** người dùng vừa submit search query
- **When** API đang được gọi
- **Then** hiển thị loading indicator trong search bar
- **And** giữ nguyên kết quả cũ cho đến khi có kết quả mới

### Requirement: Xử lý lỗi search
Hệ thống MUST xử lý gracefully khi search thất bại và cung cấp fallback.

#### Scenario: Network error khi search
- **Given** người dùng search khi không có kết nối mạng
- **When** API call thất bại
- **Then** hiển thị thông báo lỗi "Không thể tìm kiếm. Vui lòng kiểm tra kết nối mạng."
- **And** fallback về local filter với dữ liệu đã có

#### Scenario: Empty search results
- **Given** người dùng search với từ khóa không có kết quả
- **When** API trả về danh sách rỗng
- **Then** hiển thị "Không tìm thấy sản phẩm cho 'từ khóa'"
- **And** hiển thị gợi ý "Thử tìm với từ khóa khác"

### Requirement: Voice Search với Speech-to-Text
Hệ thống MUST hỗ trợ tìm kiếm sản phẩm bằng giọng nói thông qua tích hợp với API transcribe.

#### Scenario: Voice search thành công
- **Given** người dùng đang ở màn hình danh sách sản phẩm
- **And** microphone permission đã được cấp
- **When** người dùng nhấn giữ nút microphone và nói "iPhone 15 Pro Max"
- **And** người dùng thả nút microphone
- **Then** hệ thống gửi audio lên API transcribe
- **And** hiển thị loading indicator trong khi chờ kết quả
- **And** hiển thị text "iPhone 15 Pro Max" trong search bar
- **And** tự động trigger search với text đó

#### Scenario: Permission chưa được cấp
- **Given** người dùng đang ở màn hình danh sách sản phẩm
- **And** microphone permission chưa được cấp
- **When** người dùng nhấn nút microphone
- **Then** hệ thống hiển thị dialog giải thích lý do cần permission
- **And** request microphone permission từ hệ thống
- **When** người dùng cấp permission
- **Then** hệ thống bắt đầu recording

#### Scenario: Permission bị từ chối vĩnh viễn
- **Given** người dùng đã từ chối microphone permission và chọn "Don't ask again"
- **When** người dùng nhấn nút microphone
- **Then** hệ thống hiển thị thông báo "Vui lòng cấp quyền microphone trong Cài đặt để sử dụng tìm kiếm bằng giọng nói"
- **And** cung cấp button để mở App Settings

#### Scenario: Network error khi transcribe
- **Given** người dùng đã hoàn thành recording
- **When** API transcribe thất bại do network error
- **Then** hệ thống hiển thị thông báo "Không thể nhận dạng giọng nói. Vui lòng kiểm tra kết nối mạng và thử lại."
- **And** xóa file audio tạm

#### Scenario: Transcribe trả về kết quả rỗng
- **Given** người dùng đã hoàn thành recording
- **When** API transcribe thành công nhưng không nhận dạng được text
- **Then** hệ thống hiển thị thông báo "Không nhận dạng được giọng nói. Vui lòng nói rõ hơn và thử lại."

#### Scenario: Recording duration giới hạn
- **Given** người dùng đang recording voice search
- **When** thời gian recording đạt 30 giây
- **Then** hệ thống tự động dừng recording
- **And** tiến hành transcribe như bình thường

### Requirement: Voice Search UI Feedback
Hệ thống MUST hiển thị trạng thái recording rõ ràng để user biết hệ thống đang lắng nghe.

#### Scenario: Hiển thị trạng thái recording
- **Given** người dùng bắt đầu voice search
- **When** hệ thống đang recording
- **Then** nút microphone hiển thị animation pulse màu đỏ
- **And** hiển thị thời gian recording (VD: "0:05")
- **And** search bar có visual indicator cho biết đang recording

#### Scenario: Hiển thị trạng thái processing
- **Given** người dùng đã hoàn thành recording
- **When** hệ thống đang gửi audio lên API và chờ kết quả
- **Then** nút microphone hiển thị loading spinner
- **And** nút microphone bị disabled
- **And** không cho phép nhập text trong search bar

#### Scenario: Hủy recording
- **Given** người dùng đang recording voice search
- **When** người dùng vuốt ra khỏi nút microphone (cancel gesture)
- **Then** hệ thống hủy recording
- **And** xóa file audio tạm
- **And** không gọi API transcribe
- **And** trở về trạng thái idle

