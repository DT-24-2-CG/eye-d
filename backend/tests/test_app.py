import unittest
from unittest.mock import patch, MagicMock
from your_module import app   # 실제 Flask app import

class ProductInfoTestCase(unittest.TestCase):
    def setUp(self):
        self.app = app.test_client()

    @patch('your_module.get_db_connection')
    def test_get_product_info_success(self, mock_db_conn):
        # 커서와 DB 모킹
        mock_cursor = MagicMock()
        mock_cursor.fetchone.return_value = ('테스트제품', 10000, '10% 할인')
        
        mock_db = MagicMock()
        mock_db.cursor.return_value = mock_cursor
        mock_db.__enter__.return_value = mock_db
        mock_db_conn.return_value = mock_db

        response = self.app.get('/ID=1')
        self.assertEqual(response.status_code, 200)
        self.assertIn(b'"Name": "\xec\xa0\x9c\xed\x92\x88', response.data)
