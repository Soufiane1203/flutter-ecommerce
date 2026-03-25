const http = require('http');

// Token utilisateur (user@test.com)
const token = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOjExLCJlbWFpbCI6InVzZXJAdGVzdC5jb20iLCJyb2xlIjoidXNlciIsImlhdCI6MTczMjIzNDQwMiwiZXhwIjoxNzMyODM5MjAyfQ.wK_F8xVmXn_z3OVCKQz5q-O8t4x_fM3SJ3B4VJGKRvo';

console.log('=== TEST ORDERS API ===\n');

// Test 1: GET /api/orders (mes commandes)
console.log('Test 1: GET /api/orders');
const req1 = http.request({
  hostname: 'localhost',
  port: 3000,
  path: '/api/orders?page=1&limit=20',
  method: 'GET',
  headers: {
    'Authorization': `Bearer ${token}`,
    'Content-Type': 'application/json'
  }
}, (res) => {
  let data = '';
  res.on('data', chunk => data += chunk);
  res.on('end', () => {
    console.log(`Status: ${res.statusCode}`);
    if (res.statusCode === 200) {
      const json = JSON.parse(data);
      console.log(`✅ SUCCESS - ${json.data?.length || 0} commandes trouvées`);
      console.log(JSON.stringify(json, null, 2));
    } else {
      console.log(`❌ ERROR: ${data}`);
    }
    console.log('\n');
    
    // Test 2: POST /api/orders (créer commande)
    console.log('Test 2: POST /api/orders');
    const orderData = JSON.stringify({
      shipping_address: '123 Rue de Test, 75001 Paris',
      phone: '0612345678',
      notes: 'Paiement: cash\nTest commande'
    });
    
    const req2 = http.request({
      hostname: 'localhost',
      port: 3000,
      path: '/api/orders',
      method: 'POST',
      headers: {
        'Authorization': `Bearer ${token}`,
        'Content-Type': 'application/json',
        'Content-Length': orderData.length
      }
    }, (res) => {
      let data2 = '';
      res.on('data', chunk => data2 += chunk);
      res.on('end', () => {
        console.log(`Status: ${res.statusCode}`);
        if (res.statusCode === 201) {
          const json = JSON.parse(data2);
          console.log(`✅ SUCCESS - Commande créée ID: ${json.data?.id}`);
          console.log(JSON.stringify(json, null, 2));
        } else {
          console.log(`❌ ERROR: ${data2}`);
        }
        process.exit(0);
      });
    });
    
    req2.on('error', (e) => {
      console.error(`❌ Request error: ${e.message}`);
      process.exit(1);
    });
    
    req2.write(orderData);
    req2.end();
  });
});

req1.on('error', (e) => {
  console.error(`❌ Request error: ${e.message}`);
  process.exit(1);
});

req1.end();
