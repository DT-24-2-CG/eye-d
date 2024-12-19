import cv2
import os
import csv
from multiprocessing import Pool

def process_image(args):
    target_descriptors, img_path = args
    sift = cv2.SIFT_create()
    bf = cv2.BFMatcher(cv2.NORM_L2, crossCheck=True)

    # 이미지 읽기
    img = cv2.imread(img_path, cv2.IMREAD_GRAYSCALE)
    if img is None:
        return img_path, 0  # 이미지 로드 실패 시 0 매칭 반환

    # 특징점 추출
    _, descriptors = sift.detectAndCompute(img, None)
    if descriptors is None:
        return img_path, 0  # 특징점이 없으면 매칭 점수 0 반환

    # 특징점 매칭
    matches = bf.match(target_descriptors, descriptors)
    good_matches = [m for m in matches if m.distance < 0.7 * matches[-1].distance]
    return img_path, len(good_matches)

def compare_images_sift_multiprocessing(target_image_path, image_folder):
    # 기준 이미지 읽기
    target_img = cv2.imread(target_image_path, cv2.IMREAD_GRAYSCALE)
    if target_img is None:
        raise FileNotFoundError(f"Target image not found: {target_image_path}")

    sift = cv2.SIFT_create()
    _, target_descriptors = sift.detectAndCompute(target_img, None)
    if target_descriptors is None:
        raise ValueError("No features found in the target image.")

    # 이미지 폴더 내 파일 리스트 가져오기
    image_files = [os.path.join(image_folder, f) for f in os.listdir(image_folder) if f.lower().endswith(('.png', '.jpg', '.jpeg'))]

    # 멀티프로세싱으로 처리
    with Pool() as pool:
        results = pool.map(process_image, [(target_descriptors, img_path) for img_path in image_files])

    # 가장 많은 매칭을 가진 이미지 찾기
    best_match = max(results, key=lambda x: x[1])
    return os.path.basename(best_match[0]), best_match[1]

def find_matching_row_from_csv(csv_file, target_filename, alt_column_name='Alt Text'):
    with open(csv_file, 'r', encoding='cp949') as file:
        reader = csv.DictReader(file)
        for row_number, row in enumerate(reader, start=1):
            if row[alt_column_name] == target_filename:
                return row_number
    return None

if __name__ == "__main__":
    target_image_path = "choco.jpg"  # 기준 이미지 경로
    image_folder = "good_files"  # 비교할 이미지들이 있는 폴더 경로
    csv_file_path = "detailed_results.csv"
    # 비교 실행
    try:
        best_image, max_matches = compare_images_sift_multiprocessing(target_image_path, image_folder)
        if max_matches <=50:
            print(0)
        else :
            print(f"\nMost similar image: {best_image} with {max_matches} good matches")
            # 2. CSV에서 매칭 행 검색
            matched_row = find_matching_row_from_csv(csv_file_path, best_image)

            # 3. 결과 출력
            if matched_row:
                print("\nMatched row found:", matched_row)
            else:
                print("\nNo matching row found in the CSV.")

    except Exception as e:
        print(f"An error occurred: {e}")

