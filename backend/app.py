from flask import Flask, render_template, jsonify, request, send_file
import pymysql
import json
from functools import wraps
from flask import Response
import multiprocessing
import os
from modules.DT_Database_and_ai.DT_Database_and_ai import find_img

def run_server():
    try:
        app.run('0.0.0.0',port=5000)
        #debug=True
    except:
        print("SystemExit 발생, 서버를 종료하지 않고 계속 실행합니다.")

def as_json(f):
    @wraps(f)
    def decorated_function(*args, **kwargs):
        res = f(*args, **kwargs)
        res = json.dumps(res, ensure_ascii=False).encode('utf8')
        return Response(res, content_type='application/json; charset=utf-8')
    return decorated_function


def send_image(file_path):
    #파일 확장자 소문자로 내놔
    _, ext = os.path.splitext(file_path)
    ext = ext.lower()

    #jpg나 jpeg임?
    if ext == '.jpg' or ext == '.jpeg':
        mime_type = 'image/jpeg'
    #png임?
    elif ext == '.png':
        mime_type = 'image/png'
    #둘다 아니면 jpeg로 리턴할래. 어짜피 jpg,png 둘 밖에 없어서...
    else:
        mime_type = 'image/jpeg'

    return send_file(file_path, mimetype=mime_type)
#try except 활용할것

#include text info
def get_db_connection():
    product_info_db = pymysql.connect(host = '127.0.0.1',user='root',password='Detective@spes31',database='flask_test',charset='utf8')
    return product_info_db

    #cursor.execution() : parameter로 받은 sql쿼리를 실행함.

#cursor.execute('SELECT COUNT(*) AS row_count FROM history;')
#his_row_max = cursor.fetchone()[0]


#fetchall is data in product_info table. return tuple type.
#fetchall : all data in table
#fetchone : only one row data in table
#fetchmany : only n row data in table (n is assigned by user)

app = Flask(__name__)

@app.route('/')
def hello_world():
    return render_template('index.html')

#get all images
'''@app.route('/images', methods=['GET'])
def get_image_pahts():
    with get_db_connection() as db:
        cursor = db.cursor()
        #Get ID, Path from images table.
        cursor.execute("SELECT ID, Path FROM images")
        #but if too many elems are in images table,
        #load time problem!!

        results = cursor.fetchall()
        #if you altered some data, db.commit() is required.
        images = [{"ID": row[0], "Path": row[1]} for row in results]
        cursor.close()
    return jsonify(images)'''


#get product info by ID that users want
@app.route('/ID=<int:id>', methods=['GET'])
@as_json
def get_product_info(id):
    try:
        with get_db_connection() as db:
            cursor = db.cursor()
            cursor.execute(f"SELECT Name, Price, Promotion FROM product_info2 WHERE ID={id};")
            results = cursor.fetchone()
            product_info = {"Name": results[0], "Price": results[1], "Promotion": results[2]}
            cursor.close()
        return product_info
    except Exception as e:
        print(f"ID Error : {e}")
        cursor.close()
        db.close()
        return None


#앱에서 이미지 파일 전송받기
@app.route('/upload', methods=['POST'])
def upload_file():
    if 'file' not in request.files:
        return {"message": "No file part"}, 400
    file = request.files['file']
    if file.filename == '':
        return {"message": "No  selected file"}, 400
    file.save(f"C:/Users/nadda/Desktop/sw/github/Kim-Sumin-711.github.io/Flask/Flask_Test_for_24-2H_DT/static/uploads/{file.filename}")
    file_name  = file.filename
    #module here

    #모듈에서 사진을 전송받음. 서버 컴퓨터 로컬 폴더에 저장한 후, 이미지 경로를 파라미터로 보냄.
    #서버 노트북에서 모듈을 import혹은 py파일을 실행시켜서 결과값을 얻어옴.
    #가능하면 ID정보를 얻어옴.
    #얻어온 ID정보를 클라이언트에게 보냄.
    #클라이언트에서 /ID=n 을 이용해서 상품정보 요청.
    #만일 인식 실패의 경우. ID를 -1로 가져옴. -1이면 인식실패가 뜨도록 클라이언트에서 작업.

    #만일 인식에 성공해서 ID를 보내야한다면 이 정보를 History ID에 맞춰서 정리하자.
    #History에는 ID와 이어진 제품 정보 (이름, 가격, 행사정보) 가 저장된다.
    #History ID는 primary key로 중복 불가임. 

    


    with get_db_connection() as db:
        cursor = db.cursor()

        target_image_path = f"{"static/uploads/"+file_name}" # 기준 이미지 경로
        image_folder = "modules/DT_Database_and_ai/DT_Database_and_ai/good_files"  # 비교할 이미지들이 있는 폴더 경로
        csv_file_path = "modules/DT_Database_and_ai/DT_Database_and_ai/detailed_results.csv"
        # 비교 실행
        try:
            best_image, max_matches = find_img.compare_images_sift_multiprocessing(target_image_path, image_folder)
            if max_matches<=50:
                print(0)
                product_id = '0'
            else:
                print(f"\nMost similar image: {best_image} with {max_matches} good matches")
                # 2. CSV에서 매칭 행 검색
                matched_row_num = find_img.find_matching_row_from_csv(csv_file_path, best_image)
                product_id = f"{matched_row_num}"
                cursor.execute(f"SELECT Name, Price, Promotion FROM product_info2 WHERE ID={product_id};")
                history_data = cursor.fetchone()
                cursor.execute("INSERT INTO history (name, price, promotion,Img_name) VALUES (%s, %s, %s,%s)", (history_data[0], history_data[1], history_data[2],file_name))
                db.commit()
                # 3. 결과 출력
                if matched_row_num:
                    print("\nMatched row found:", matched_row_num)
                else:
                    print("\nNo matching row found in the CSV.")

        except Exception as e:
            print(f"An error occurred: {e}")
        #auto Increment로 ID를 작성할 것인데, 만약 upload를 비우고 increment를 초기화하고 싶으면 사용.
        #cursor.execute("ALTER TABLE history AUTO_INCREMENT = 1;")
        
        #his_row_max+=1
        #0 문자열로 반환하면 인식실패.
        response = {"data" : {"id" : product_id}}
        cursor.close()
    return jsonify(response), 200


@app.route('/history=<int:hid>', methods=['GET']) 
@as_json
def get_history_info(hid):
    try:
        with get_db_connection() as db:
            cursor = db.cursor()
            cursor.execute("SELECT History_Id FROM history ORDER BY History_Id DESC LIMIT 1 OFFSET %s;",(hid-1,))
            late_hid = cursor.fetchone()
            cursor.execute("SELECT Name, Price, Promotion FROM history WHERE History_Id=%s;",(late_hid,))
            results = cursor.fetchone()
            if(results == None):
                print("history ERROR : Data is null!\n")
                return None,404
            product_info = {"Name": results[0], "Price": results[1], "Promotion": results[2]}
            cursor.close()
        return product_info
    except Exception as e:
        print(f"history ERROR : {e}")
        cursor.close()
        return None,404

@app.route('/history_image=<int:hid>', methods=['GET']) 
def get_img_file(hid):
    try:
        with get_db_connection() as db:
            cursor = db.cursor()
            cursor.execute("SELECT History_Id FROM history ORDER BY History_Id DESC LIMIT 1 OFFSET %s;",(hid-1,))
            late_hid = cursor.fetchone()
            cursor.execute("SELECT Img_name FROM history WHERE History_Id = %s ORDER BY History_Id DESC LIMIT 1;",(late_hid,))
            path = cursor.fetchone()
            print(path)
            if(path == None):
                print("Path is null!\n")
                return None,404
            if(path[0] == "Unknown"):
                cursor.close()
                print("Error : Image not exist\n")
                return jsonify({"Error" : "Image not exist"}),404
        
            file_path = "C:/Users/nadda/Desktop/sw/github/Kim-Sumin-711.github.io/Flask/Flask_Test_for_24-2H_DT/static/uploads/"+str(path[0])
            if not os.path.exists(file_path):
                cursor.close()
                print("Error : File not found")
                return jsonify({"Error" : "File not found"}),404 
            cursor.close()
        return send_image(file_path)
        #return send_file(file_path, mimetype='image/jpeg')
    except Exception as e:
        print(f"his_img Error : {e}")
        cursor.close()
        return jsonify({"error": "Something is wrong"}), 404


if __name__ == '__main__':
    #app.run('0.0.0.0',port=5000,debug=True)
        p = multiprocessing.Process(target=run_server)
        p.start()
        p.join()
        print("서버 프로세스가 종료.")