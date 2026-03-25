/**
 * Script pour créer ou mettre à jour les comptes de test
 */

const bcrypt = require('bcrypt');
const { Pool } = require('pg');

const pool = new Pool({
  host: 'localhost',
  port: 5432,
  user: 'postgres',
  password: '123',
  database: 'ecommerce_db'
});

async function createTestAccounts() {
  console.log('=== CREATION COMPTES DE TEST ===\n');
  
  try {
    // Hash des mots de passe
    const adminHash = await bcrypt.hash('admin123', 10);
    const userHash = await bcrypt.hash('user123', 10);
    
    // Supprimer les anciens comptes s'ils existent
    await pool.query(`DELETE FROM users WHERE email IN ($1, $2)`, [
      'admin@ecommerce.com',
      'user@test.com'
    ]);
    
    console.log('✅ Anciens comptes supprimés\n');
    
    // Créer le compte admin
    const adminResult = await pool.query(
      `INSERT INTO users (email, password_hash, full_name, phone, role) 
       VALUES ($1, $2, $3, $4, $5) 
       RETURNING id, email, full_name, role`,
      ['admin@ecommerce.com', adminHash, 'Admin Principal', '0612345678', 'admin']
    );
    
    console.log('✅ Compte ADMIN créé:');
    console.log('   ID:', adminResult.rows[0].id);
    console.log('   Email:', adminResult.rows[0].email);
    console.log('   Nom:', adminResult.rows[0].full_name);
    console.log('   Role:', adminResult.rows[0].role);
    console.log('   Password: admin123\n');
    
    // Créer le compte user
    const userResult = await pool.query(
      `INSERT INTO users (email, password_hash, full_name, phone, role) 
       VALUES ($1, $2, $3, $4, $5) 
       RETURNING id, email, full_name, role`,
      ['user@test.com', userHash, 'John Doe', '0698765432', 'user']
    );
    
    console.log('✅ Compte USER créé:');
    console.log('   ID:', userResult.rows[0].id);
    console.log('   Email:', userResult.rows[0].email);
    console.log('   Nom:', userResult.rows[0].full_name);
    console.log('   Role:', userResult.rows[0].role);
    console.log('   Password: user123\n');
    
    console.log('=== COMPTES CREES AVEC SUCCES ===');
    
  } catch (error) {
    console.error('❌ Erreur:', error.message);
  } finally {
    await pool.end();
  }
}

createTestAccounts();
