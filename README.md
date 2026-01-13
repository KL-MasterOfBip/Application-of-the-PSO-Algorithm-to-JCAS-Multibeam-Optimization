# PSO-based Beamforming Optimization for Integrated Sensing and Communication (ISAC)

## Giới thiệu
Dự án này nghiên cứu **ứng dụng thuật toán Particle Swarm Optimization (PSO)** và các biến thể của nó để **tối ưu hóa vector beamforming** trong hệ thống **Integrated Sensing and Communication (ISAC)**, trong đó:

- **Truyền thông và cảm nhận môi trường** sử dụng:
  - Cùng phần cứng anten
  - Cùng băng tần
  - Cùng tín hiệu phát

Mục tiêu là thiết kế beamforming thỏa hiệp giữa:
- **Hiệu năng truyền thông** (búp chính, độ lợi, beamwidth)
- **Hiệu năng cảm nhận** (hạ sidelobe, kiểm soát búp phụ)

Bài toán được xét chủ yếu trong trường hợp **tối ưu pha (phase-only beamforming)**, là một bài toán **phi tuyến, không lồi**, khó giải bằng các phương pháp gradient truyền thống.

---

## Cấu trúc dự án

### 1. `main.m`
File chạy chính của chương trình.

Chức năng:
- Khởi tạo tham số hệ thống (số phần tử anten, miền góc, steering vector, mẫu búp mong muốn)
- Sinh mẫu búp tham chiếu cho ISAC
- Gọi các thuật toán tối ưu beamforming dựa trên PSO

Trong file này, nhóm đã **chỉnh sửa và mở rộng phần tối ưu pha** để thử nghiệm:
- PSO gốc
- Các biến thể PSO
- So sánh hiệu năng beamforming thông qua đồ thị búp sóng

---

### 2. `pso_beamforming_*.m`
Tập hợp các file cài đặt **thuật toán PSO và các biến thể**, bao gồm:

- PSO gốc (Original PSO)
- LDIW-PSO (Linearly Decreasing Inertia Weight PSO)
- APSO (Adaptive PSO)
- CF-PSO (Constriction Factor PSO)

Các file này chịu trách nhiệm:
- Khởi tạo swarm
- Cập nhật vận tốc và vị trí các hạt
- Tối ưu pha của vector beamforming dựa trên hàm mục tiêu định nghĩa trước

---

### 3. `MultiSwarm_PSO.m`
Cài đặt **biến thể Multi-Swarm PSO**, trong đó:
- Toàn bộ swarm được chia thành **nhiều bầy con (sub-swarms)**
- Các bầy con tìm kiếm song song trong không gian nghiệm
- Định kỳ trao đổi nghiệm tốt nhất để tránh hội tụ sớm vào cực trị địa phương

Phù hợp cho các bài toán:
- Không gian nghiệm lớn
- Nhiều cực trị địa phương
- Yêu cầu khả năng tìm kiếm toàn cục mạnh

---

### 4. `APSO_swarm_core.m`
File lõi điều khiển hoạt động của **mỗi bầy con trong Multi-Swarm PSO**.

Chức năng:
- Cập nhật tham số thích nghi (inertia weight, acceleration coefficients)
- Thực hiện APSO ở mức swarm con
- Trả về nghiệm tốt nhất cục bộ cho quá trình trao đổi giữa các bầy

---

## Đặc điểm nổi bật của phương pháp

- Áp dụng PSO cho bài toán **beamforming pha-only** trong ISAC
- So sánh nhiều biến thể PSO trên cùng mô hình hệ thống
- Phân tích đánh đổi giữa:
  - Hạ sidelobe
  - Độ sắc của búp chính
- Phù hợp cho nghiên cứu và mở rộng sang:
  - Hybrid PSO–ILS
  - Multi-objective optimization
  - ISAC đa mục tiêu

---

## Ghi chú
- Mã nguồn được xây dựng phục vụ mục đích **nghiên cứu và học thuật**
- Có thể mở rộng cho các kịch bản ISAC khác như:
  - Nhiều hướng truyền thông
  - Nhiều mục tiêu cảm nhận
  - Ràng buộc biên độ–pha kết hợp

---

## Từ khóa
`ISAC`, `Beamforming`, `Particle Swarm Optimization`, `APSO`, `Multi-Swarm PSO`, `Phase-only Optimization`
