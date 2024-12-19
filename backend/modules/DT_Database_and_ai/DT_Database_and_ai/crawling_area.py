from bs4 import BeautifulSoup
import os
import csv

# HTML 파일 목록 설정
html_files = ["drink.html", "food.html", "ice_cream.html", "quick_meal.html", "snack.html"]  # 크롤링할 HTML 파일들

# CSV 파일 저장 경로
output_csv = 'detailed_results.csv'  # CSV 파일 이름

# CSV 파일 열기 (쓰기 모드)
with open(output_csv, 'w', newline='', encoding='cp949') as csvfile:
    writer = csv.writer(csvfile)

    # CSV 파일에 헤더 작성
    writer.writerow(['File Name', 'Alt Text', 'Name', 'Price', 'Badge'])

    # 각 HTML 파일 처리
    for file_name in html_files:
        file_path = os.path.join(os.getcwd(), file_name)  # 각 파일 경로 생성

        print(f"Processing file: {file_name}")

        # HTML 파일 읽기
        try:
            with open(file_path, 'r', encoding='utf-8') as file:
                html_content = file.read()
        except FileNotFoundError:
            print(f"파일 '{file_name}'을(를) 찾을 수 없습니다.")
            continue

        # BeautifulSoup으로 HTML 파싱
        soup = BeautifulSoup(html_content, 'html.parser')

        # prod_item 단위로 데이터 추출
        prod_items = soup.find_all('div', class_='prod_item')
        print(f"Found {len(prod_items)} items in {file_name}")

        for i, item in enumerate(prod_items, 1):
            # 1. alt 텍스트 추출
            img_tag = item.find('img')
            alt_text = img_tag['alt'] if img_tag and 'alt' in img_tag.attrs else 'N/A'

            # 2. name 정보 추출
            name_tag = item.find('div', class_='name')
            name_text = name_tag.text.strip() if name_tag and name_tag.text else 'N/A'

            # 3. price 정보 추출
            price_tag = item.find('div', class_='price')
            price_text = price_tag.text.strip() if price_tag and price_tag.text else 'N/A'

            # 4. badge 정보 추출
            badge_tag = item.find('div', class_='badge')
            badge_text = badge_tag.text.strip() if badge_tag and badge_tag.text else 'N/A'

            # CSV에 데이터 작성
            writer.writerow([file_name, alt_text, name_text, price_text, badge_text])

            # 디버그 출력
            print(f"Alt: {alt_text}, Name: {name_text}, Price: {price_text}, Badge: {badge_text}")

print(f"Results saved to {output_csv}")