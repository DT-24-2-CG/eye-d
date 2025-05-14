import unittest
from unittest.mock import patch, MagicMock
from app import app

class TestGetProductInfo(unittest.TestCase):
    def setUp(self):
        self.client = app.test_client()

    @patch('app.get_db_connection')
    def test_get_product_info_success(self, mock_get_db_connection):
        # 1. Mock된 커서와 fetchone 결과 설정
        mock_cursor = MagicMock()
        mock_cursor.fetchone.return_value = ('Test Product', 19900, '20%')

        # 2. Mock된 DB 연결
        mock_conn = MagicMock()
        mock_conn.cursor.return_value = mock_cursor
        mock_conn.__enter__.return_value = mock_conn
        mock_get_db_connection.return_value = mock_conn

        # 3. 요청 실행
        response = self.client.get('/ID=1')

        # 4. 결과 검증
        self.assertEqual(response.status_code, 200)
        self.assertIn(b'Test Product', response.data)
        self.assertIn(b'19900', response.data)
        self.assertIn(b'20%', response.data)

