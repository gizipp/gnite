import http from 'k6/http';
import { check, sleep } from 'k6';
import { Rate } from 'k6/metrics';

const errorRate = new Rate('errors');

export const options = {
  scenarios: {
    // Normal load
    normal_load: {
      executor: 'ramping-vus',
      startVUs: 1,
      stages: [
        { duration: '1m', target: 20 },  // Normal load
        { duration: '3m', target: 20 },  // Stay at normal load
        { duration: '1m', target: 0 },   // Scale down
      ],
    },
    // Stress test (spike)
    stress_test: {
      executor: 'ramping-vus',
      startTime: '5m',
      startVUs: 1,
      stages: [
        { duration: '30s', target: 50 }, // Quick ramp-up
        { duration: '1m', target: 50 },  // Stay at peak
        { duration: '30s', target: 0 },  // Scale down
      ],
    },
  },

  // Success criteria
  thresholds: {
    http_req_duration: [
      'p(95)<300',  // 95% requests must be done within 300ms
      'p(99)<500',  // 99% requests must be done within 500ms
      'avg<200',    // Average response time < 200ms
    ],
    http_req_failed: ['rate<0.01'], // Error rate < 1%
    errors: ['rate<0.01'],          // Custom error rate < 1%
    http_reqs: ['rate>50'],         // Minimal 50 RPS
  },
};

export default function () {
  const BASE_URL = 'http://localhost:3000/api/v1';
  
  // Random user ID dari seed data
  const userId = Math.floor(Math.random() * 1000) + 1;
  
  // Request dengan timeout
  const response = http.get(
    `${BASE_URL}/follows/following_sleep_records?user_id=${userId}`,
    {
      timeout: '3s', // Request timeout
      tags: { name: 'following_records' }
    }
  );

  // Checks
  const success = check(response, {
    'is status 200': (r) => r.status === 200,
    'response time OK': (r) => r.timings.duration < 300,
    'has valid data': (r) => {
      try {
        const body = JSON.parse(r.body);
        return Array.isArray(body);
      } catch (e) {
        return false;
      }
    },
  });

  // Track errors
  errorRate.add(!success);

  // Cooldown
  sleep(1);
}