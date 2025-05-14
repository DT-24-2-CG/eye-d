# tests/test_app.py
import unittest
from unittest.mock import patch, MagicMock
from app import app


class TestProductInfoAPI(unittest.TestCase):
    def setUp(self):
        self.client = app.test_client()

    @patch('app.get_db_connection')
    def test_get_product_info_success(self, mock_get_db_connection):
        # DB 커서 mocking
        mock_cursor = MagicMock()
        mock_cursor.fetchone.return_value = ('Test Product', 10000, '10% 할인')

        # DB 연결 mocking
        mock_conn = MagicMock()
        mock_conn.cursor.return_value = mock_cursor
        mock_conn.__enter__.return_value = mock_conn
        mock_get_db_connection.return_value = mock_conn

        response = self.client.get('/ID=1')
        self.assertEqual(response.status_code, 200)
        self.assertIn(b'Test Product', response.data)
