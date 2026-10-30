// Ambil URL dari environment variable Vercel, atau fallback ke localhost untuk development
const API_URL = import.meta.env.VITE_API_URL || 'http://localhost:8091'

export async function submitInquiry(data) {
  try {
    // Panggil API langsung ke URL Railway
    const res = await fetch(`${API_URL}/api/inquiries`, {
      method: 'POST', 
      headers: { 'Content-Type': 'application/json' }, 
      body: JSON.stringify(data),
    })
    
    if (!res.ok) {
      throw new Error(`Server responded with ${res.status}`)
    }
    
    return await res.json()
  } catch (err) {
    console.error('[Serenity] Gagal mengirim inquiry:', err.message)
    return { 
      status: 'error', 
      message: 'Gagal terhubung ke server. Pastikan backend berjalan.' 
    }
  }
}