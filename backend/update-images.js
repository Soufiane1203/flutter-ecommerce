/**
 * Script pour mettre à jour toutes les images produits avec des URLs Unsplash valides
 */

const { Pool } = require('pg');

const pool = new Pool({
  host: 'localhost',
  port: 5432,
  user: 'postgres',
  password: '123',
  database: 'ecommerce_db'
});

const imageUrls = [
  'https://images.unsplash.com/photo-1510557880182-3d4d3cba35a5?w=400&q=80', // iPhone
  'https://images.unsplash.com/photo-1610945415295-d9bbf067e59c?w=400&q=80', // Samsung
  'https://images.unsplash.com/photo-1598327105666-5b89351aff97?w=400&q=80', // Pixel
  'https://images.unsplash.com/photo-1546868871-7041f2a55e12?w=400&q=80', // OnePlus
  'https://images.unsplash.com/photo-1511707171634-5f897ff02aa9?w=400&q=80', // Xiaomi
  'https://images.unsplash.com/photo-1517336714731-489689fd1ca8?w=400&q=80', // MacBook
  'https://images.unsplash.com/photo-1496181133206-80ce9b88a853?w=400&q=80', // Dell
  'https://images.unsplash.com/photo-1593642632823-8f785ba67e45?w=400&q=80', // ASUS
  'https://images.unsplash.com/photo-1588872657578-7efd1f1555ed?w=400&q=80', // HP
  'https://images.unsplash.com/photo-1484788984921-03950022c9ef?w=400&q=80', // Lenovo
  'https://images.unsplash.com/photo-1544244015-0df4b3ffc6b0?w=400&q=80', // iPad
  'https://images.unsplash.com/photo-1561154464-82e9adf32764?w=400&q=80', // Galaxy Tab
  'https://images.unsplash.com/photo-1606220588913-b3aacb4d2f46?w=400&q=80', // AirPods
  'https://images.unsplash.com/photo-1545127398-14699f92334b?w=400&q=80', // Sony
  'https://images.unsplash.com/photo-1609091839311-d5365f9ff1c5?w=400&q=80', // Powerbank
  'https://images.unsplash.com/photo-1527814050087-3793815479db?w=400&q=80', // Mouse
  'https://images.unsplash.com/photo-1434493789847-2f02dc6ca35d?w=400&q=80', // Apple Watch
  'https://images.unsplash.com/photo-1579586337278-3befd40fd17a?w=400&q=80', // Galaxy Watch
  'https://images.unsplash.com/photo-1508685096489-7aacd43bd3b1?w=400&q=80'  // Garmin
];

async function updateAllImages() {
  console.log('=== MISE À JOUR DES IMAGES PRODUITS ===\n');
  
  try {
    for (let i = 0; i < imageUrls.length; i++) {
      const productId = i + 1;
      const imageUrl = imageUrls[i];
      
      await pool.query(
        'UPDATE products SET image_url = $1 WHERE id = $2',
        [imageUrl, productId]
      );
      
      console.log(`✅ Produit ${productId}: ${imageUrl.substring(0, 60)}...`);
    }
    
    console.log(`\n✅ ${imageUrls.length} images mises à jour avec succès!`);
    
    // Vérification
    const result = await pool.query(
      'SELECT COUNT(*) as count FROM products WHERE image_url LIKE $1',
      ['%unsplash%']
    );
    
    console.log(`\n📊 Vérification: ${result.rows[0].count} produits avec images Unsplash`);
    
  } catch (error) {
    console.error('❌ Erreur:', error.message);
  } finally {
    await pool.end();
  }
}

updateAllImages();
