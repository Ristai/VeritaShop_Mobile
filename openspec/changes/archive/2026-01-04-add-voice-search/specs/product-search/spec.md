## ADDED Requirements

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
