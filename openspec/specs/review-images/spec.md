# review-images Specification

## Purpose
TBD - created by archiving change add-review-image-upload. Update Purpose after archive.
## Requirements
### Requirement: REVIEW-IMG-001 - Image Selection in Review Form
The system SHALL allow users to select images from their device when writing a product review.

#### Scenario: User adds images to review
- **WHEN** user is on the write review screen and taps "Thêm ảnh" button
- **THEN** system displays a bottom sheet with 2 options: "Chọn từ thư viện" and "Chụp ảnh"
- **AND** after selecting image, it appears in a grid preview with a delete button

#### Scenario: User reaches image limit
- **WHEN** user has selected 5 images (maximum limit)
- **THEN** "Thêm ảnh" button is disabled
- **AND** text "Đã đạt giới hạn 5 ảnh" is displayed

#### Scenario: User removes selected image
- **WHEN** user taps the delete button on a selected image
- **THEN** that image is removed from the preview list
- **AND** "Thêm ảnh" button is re-enabled if it was previously disabled due to limit

### Requirement: REVIEW-IMG-002 - Image Upload to Cloudinary
The system SHALL upload images to Cloudinary before creating the review.

#### Scenario: Successful image upload
- **WHEN** user taps "Gửi đánh giá" with selected images
- **THEN** system displays loading indicator with text "Đang tải ảnh lên..."
- **AND** images are uploaded to Cloudinary via endpoint `/api/upload/images`
- **AND** after successful upload, URLs are sent with review data

#### Scenario: Image upload fails
- **WHEN** image upload fails due to network or server error
- **THEN** system displays SnackBar with error message
- **AND** user can retry submitting the review

#### Scenario: Submit review without images
- **WHEN** user submits review without selecting any images
- **THEN** review is created normally with `images: []`

### Requirement: REVIEW-IMG-003 - Display Review Images
The system SHALL display review images in the review list on product detail screen.

#### Scenario: Review has images
- **WHEN** a review with images is displayed
- **THEN** images are shown below review content as a horizontal scrollable list
- **AND** each thumbnail has 80x80 pixels size with 8px border radius

#### Scenario: User taps on review image
- **WHEN** user taps on an image in the review
- **THEN** system displays full screen image viewer with zoom and swipe capabilities

#### Scenario: Review has no images
- **WHEN** a review has no images
- **THEN** image section is not displayed (no empty space)

