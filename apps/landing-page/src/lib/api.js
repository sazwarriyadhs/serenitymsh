const API_URL = '/api' // Vite proxy akan meneruskan ini ke http://https://serenitymsh-production.up.railway.app

export async function submitInquiry(data) {
  try {
    const res = await fetch(`${API_URL}/inquiries`, {
      method: 'POST', 
      headers: { 'Content-Type': 'application/json' }, 
      body: JSON.stringify(data),
    })
    
    if (!res.ok) {
      // Jika backend mengembalikan error (misal 500 atau 404)
      throw new Error(`Server responded with ${res.status}`)
    }
    
    return await res.json()
  } catch (err) {
    console.error('[Serenity] Gagal mengirim inquiry:', err.message)
    
    // Jika backend belum siap (misal: error koneksi/404), kita biarkan form
    // memberi tahu user bahwa pesan tidak terkirim secara permanen.
    // JANGAN memberikan status "mock_success" palsu.
    return { 
      status: 'error', 
      message: 'Gagal terhubung ke server. Pastikan backend berjalan.' 
    }
  }
}