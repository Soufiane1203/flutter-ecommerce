/**
 * Script de test pour vérifier l'authentification
 */

const http = require('http');

function testLogin(email, password, name) {
  return new Promise((resolve, reject) => {
    const data = JSON.stringify({ email, password });
    
    const options = {
      hostname: 'localhost',
      port: 3000,
      path: '/api/auth/login',
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'Content-Length': data.length
      }
    };
    
    const req = http.request(options, (res) => {
      let responseData = '';
      
      res.on('data', (chunk) => {
        responseData += chunk;
      });
      
      res.on('end', () => {
        try {
          const parsed = JSON.parse(responseData);
          resolve({ name, status: res.statusCode, data: parsed });
        } catch (error) {
          reject({ name, error: 'Invalid JSON response' });
        }
      });
    });
    
    req.on('error', (error) => {
      reject({ name, error: error.message });
    });
    
    req.write(data);
    req.end();
  });
}

async function runTests() {
  console.log('=== TEST AUTHENTIFICATION ===\n');
  
  // Test admin
  console.log('[1/2] Test login ADMIN (admin@ecommerce.com / admin123)...');
  try {
    const adminResult = await testLogin('admin@ecommerce.com', 'admin123', 'ADMIN');
    if (adminResult.status === 200) {
      console.log('✅ ADMIN LOGIN SUCCESS');
      console.log('   Email:', adminResult.data.data.user.email);
      console.log('   Nom:', adminResult.data.data.user.full_name);
      console.log('   Role:', adminResult.data.data.user.role);
      console.log('   Token:', adminResult.data.data.token.substring(0, 50) + '...\n');
    } else {
      console.log('❌ ADMIN LOGIN FAILED - Status:', adminResult.status);
      console.log('   Message:', adminResult.data.message);
    }
  } catch (error) {
    console.log('❌ ADMIN LOGIN FAILED');
    console.log('   Error:', error.error);
  }
  
  // Test user
  console.log('[2/2] Test login USER (user@test.com / user123)...');
  try {
    const userResult = await testLogin('user@test.com', 'user123', 'USER');
    if (userResult.status === 200) {
      console.log('✅ USER LOGIN SUCCESS');
      console.log('   Email:', userResult.data.data.user.email);
      console.log('   Nom:', userResult.data.data.user.full_name);
      console.log('   Role:', userResult.data.data.user.role);
      console.log('   Token:', userResult.data.data.token.substring(0, 50) + '...\n');
    } else {
      console.log('❌ USER LOGIN FAILED - Status:', userResult.status);
      console.log('   Message:', userResult.data.message);
    }
  } catch (error) {
    console.log('❌ USER LOGIN FAILED');
    console.log('   Error:', error.error);
  }
  
  console.log('=== TEST TERMINE ===');
}

runTests();
