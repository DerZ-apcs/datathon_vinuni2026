# datathon_vinuni2026

Hướng dẫn nhanh để tái tạo kết quả (reproducibility)

- Chuẩn bị dữ liệu: đặt toàn bộ CSV vào thư mục `data/` ở gốc project. Nếu muốn lưu/đọc từ Google Drive,
	export biến môi trường `DATA_PATH` trỏ tới đường dẫn mong muốn.

	Ví dụ: sử dụng folder local `data/` (mặc định):

	```bash
	export DATA_PATH=$(pwd)/data
	```

- Thiết lập môi trường Python (khuyến nghị `venv`):

	```bash
	python -m venv .venv
	source .venv/bin/activate
	pip install -U pip
	# recommended: install from requirements.txt
	pip install -r requirements.txt
	```

- Chạy pipeline (theo thứ tự):
	1. Mở và chạy toàn bộ [Feature_Engineering_Optimized.ipynb](Feature_Engineering_Optimized.ipynb) để tạo
		 `train_features.parquet`, `test_features.parquet` và `feature_cols.json` trong `DATA_PATH`.
	2. Mở và chạy [Train_Model_Optimized.ipynb](Train_Model_Optimized.ipynb) để train các model và xuất submission.

- Ghi chú reproducibility:
	- Sử dụng `export DATA_PATH=...` để đảm bảo các notebook đọc/ghi đúng thư mục dữ liệu.
	- Tất cả seed chính được đặt `SEED = 42` trong notebook để đảm bảo deterministic cho các phần có seed.
	- Nếu chạy trên Google Colab, notebook sẽ tự phát hiện Colab và dùng đường dẫn Drive mặc định chỉ khi không có `DATA_PATH` được thiết lập.
