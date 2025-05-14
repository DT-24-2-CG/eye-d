import unittest
from unittest.mock import patch, MagicMock
from app import app

class TestGetHistoryInfo(unittest.TestCase):
    def setUp(self):
        self.client = app.test_client()

    @patch('app.get_db_connection')
    def test_get_history_info_success(self, mock_get_db_conn):
        # 모의 커서와 fetchone 반환값 2번 설정
        mock_cursor = MagicMock()
        mock_cursor.fetchone.side_effect = [
            (5,),  # late_hid = 5
            ('Test Product', 12000, 'New Arrival')  # 결과 row
        ]

        mock_conn = MagicMock()
        mock_conn.cursor.return_value = mock_cursor
        mock_conn.__enter__.return_value = mock_conn
        mock_get_db_conn.return_value = mock_conn

        response = self.client.get('/history=1')

        self.assertEqual(response.status_code, 200)
        self.assertIn(b'Test Product', response.data)
        self.assertIn(b'12000', response.data)
        self.assertIn(b'New Arrival', response.data)

    @patch('app.get_db_connection')
    def test_get_history_info_no_data(self, mock_get_db_conn):
        # 첫 fetchone은 정상, 두 번째는 None
        mock_cursor = MagicMock()
        mock_cursor.fetchone.side_effect = [
            (10,),  # late_hid
            None    # no data
        ]

        mock_conn = MagicMock()
        mock_conn.cursor.return_value = mock_cursor
        mock_conn.__enter__.return_value = mock_conn
        mock_get_db_conn.return_value = mock_conn

        response = self.client.get('/history=1')
        self.assertEqual(response.status_code, 404)
