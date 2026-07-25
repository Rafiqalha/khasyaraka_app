import ws from 'k6/ws';
import http from 'k6/http';
import { hmac } from 'k6/crypto';
import { check, sleep } from 'k6';
import { randomIntBetween } from 'https://jslib.k6.io/k6-utils/1.2.0/index.js';

const API_HOST = __ENV.API_HOST || 'localhost:8081';
const JWT_SECRET = __ENV.JWT_SECRET || 'dev-secret-key-change-in-production';
const GLOBAL_ROOM_ID = __ENV.GLOBAL_ROOM_ID || '1';
const TEST_DURATION = __ENV.TEST_DURATION || '60s';

export const options = {
  stages: [
    { duration: '10s', target: 50  },
    { duration: '20s', target: 200 },
    { duration: '30s', target: 300 },
    { duration: TEST_DURATION, target: 300 },
    { duration: '10s', target: 0   },
  ],
  thresholds: {
    'ws_connecting':          ['p(95)<3000'],
    'http_req_duration':      ['p(95)<5000'],
    'http_req_failed':        ['rate<0.01'],
  },
};

function base64urlEncode(str) {
  return str.replace(/\+/g, '-').replace(/\//g, '_').replace(/=+$/, '');
}

function generateJWT(userID) {
  const header = base64urlEncode(JSON.stringify({ alg: 'HS256', typ: 'JWT' }));
  const now = Math.floor(Date.now() / 1000);
  const payload = base64urlEncode(JSON.stringify({
    sub: String(userID),
    is_superuser: false,
    exp: now + 3600,
    iat: now,
  }));

  const signature = hmac('sha256', JWT_SECRET, `${header}.${payload}`, 'base64');

  return `${header}.${payload}.${signature}`;
}

export default function () {
  const userID = randomIntBetween(1, 1000);
  const token = generateJWT(userID);
  const wsUrl = `ws://${API_HOST}/api/v1/chat/ws?token=${token}`;
  const chatUrl = `http://${API_HOST}/api/v1/chat/rooms/${GLOBAL_ROOM_ID}/messages`;

  let wsConnected = false;
  let messageCount = 0;
  const startTime = Date.now();

  // ========== 1. OPEN WEBSOCKET CONNECTION ==========
  const res = ws.connect(wsUrl, null, function (socket) {

    socket.on('open', function () {
      wsConnected = true;
      socket.setTimeout(10000 + randomIntBetween(1000, 5000));
    });

    socket.on('message', function (data) {
      messageCount++;
    });

    socket.on('close', function () {
      wsConnected = false;
    });

    socket.on('error', function (e) {
      console.error(`WS ERROR [user=${userID}]: ${e.error()}`);
    });

  });

  check(res, {
    'WebSocket handshake OK': (r) => r && r.status === 101,
  });

  // ========== 2. MESSAGE BOMBING LOOP ==========
  const durationMs = parseInt(TEST_DURATION) * 1000;
  const messageBodies = [
    'Halo dari pengujian beban!',
    'Server Go + Redis kita kuat banget.',
    'Testing chat global room.',
    'Pesan stres test ke-%d.',
    'K6 rocks untuk WebSocket load testing.',
    'Pradigi international chat active!',
    'Stress test message from VU.',
    'Load balancer test payload.',
    'WebSocket stress benchmark running.',
    'Pesan ke chat global dari simulasi 300 pengguna.',
  ];

  const sendInterval = randomIntBetween(1000, 2000);
  socketLoop:

  while (Date.now() - startTime < durationMs) {
    if (!wsConnected) break socketLoop;

    const msg = messageBodies[messageCount % messageBodies.length] + ` [VU${__VU}]`;

    const httpRes = http.post(chatUrl,
      JSON.stringify({ content: msg }),
      {
        headers: {
          'Content-Type': 'application/json',
          'Authorization': `Bearer ${token}`,
        },
        timeout: '5s',
      }
    );

    check(httpRes, {
      'chat message sent': (r) => r.status === 200,
    });

    sleep(sendInterval / 1000.0);
  }
}

export function handleSummary(data) {
  const wsConnectingP95 = data.metrics['ws_connecting']?.values?.['p(95)'] || 0;
  const httpFailRate = data.metrics['http_req_failed']?.values?.rate || 0;
  const httpReqP95 = data.metrics['http_req_duration']?.values?.['p(95)'] || 0;
  const httpReqs = data.metrics['http_reqs']?.values?.count || 0;

  return {
    'stdout': `
===========================================================================
  PRADIGI STRESS TEST — WebSocket + Chat Report
===========================================================================
  Total VUs:           ${data.metrics['vus_max']?.values?.max || 'N/A'}
  WSS Connections:     ${data.metrics['ws_sessions']?.values?.count || 'N/A'}
  WS Connect P95:      ${wsConnectingP95.toFixed(1)}ms
  HTTP Requests:       ${httpReqs}
  HTTP Fail Rate:      ${(httpFailRate * 100).toFixed(2)}%
  HTTP Req P95:        ${httpReqP95.toFixed(1)}ms
  Test Duration:       ${(data.state.testRunDurationMs / 1000).toFixed(1)}s

  Thresholds:
    WS Connect P95 < 3s: ${wsConnectingP95 < 3000 ? '✅ PASS' : '❌ FAIL'}
    HTTP Fail < 1%:      ${httpFailRate < 0.01 ? '✅ PASS' : '❌ FAIL'}
    HTTP Req P95 < 5s:   ${httpReqP95 < 5000 ? '✅ PASS' : '❌ FAIL'}
===========================================================================
`,
  };
}
