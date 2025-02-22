// following_sleep_records_test.js
import http from 'k6/http';
import { check, sleep } from 'k6';

export const options = {
  stages: [
    { duration: '30s', target: 10 }, // Ramp-up to 10 users
    { duration: '1m', target: 50 },  // Ramp-up to 50 users
    { duration: '2m', target: 100 },  // Ramp-up to 100 users
    { duration: '30s', target: 0 },  // Ramp-down to 0 users
  ],
  thresholds: {
    http_req_duration: ['p(95)<500'], // 95% of requests should be below 500ms
    http_req_failed: ['rate<0.01'],   // Less than 1% can fail
  },
};

const BASE_URL = 'http://localhost:3000/api/v1';

function getRandomUserId() {
  return Math.floor(Math.random() * 1000) + 1;
}

export default function () {
  const userId = getRandomUserId();
  
  const response = http.get(`${BASE_URL}/follows/following_sleep_records?user_id=${userId}`);
  
  check(response, {
    'is status 200': (r) => r.status === 200,
    'has valid response': (r) => r.body.length > 0,
    'response time OK': (r) => r.timings.duration < 500,
  });
  
  sleep(1);
}